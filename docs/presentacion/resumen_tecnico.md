# Cómo funciona el sistema (script, base de datos y front)

> Una sola página para exponer. Solo: generador, BD, transactions, functions y front.

## 0. Ficha rápida

| Dato | Valor |
|---|---|
| BD | PostgreSQL (`dataset_maldad/db/master/bancocloud_master_v13.sql`, 684 líneas + migraciones `V001-V005`) |
| Generador | `dataset_maldad/generar_demo_bancocloud.py` (1230 líneas, solo stdlib, semilla `20260926`) |
| Ventana demo | 2025-10-01 → 2026-09-30, sin fechas futuras |
| Front | `gestor-web/` (React 19 + Vite 8 + Tailwind 4, Express 5 para servir `dist/`) |

```powershell
python dataset_maldad\generar_demo_bancocloud.py --seed 20260926 --with-sql
python dataset_maldad\pruebas\validar_demo.py
cd gestor-web; npm run dev
```

## 1. Cómo funciona el script generador

1. Fija la semilla (`20260926`) para que cada corrida dé los mismos bytes.
2. Crea la cartera: 8000 clientes → 12000 cuentas (1-3 por cliente) → 8000 tarjetas → 3000 solicitudes (2000 aprobadas) → 2000 créditos solo consumo → 41424 cuotas → 20190 pagos.
3. Simula 12 meses de movimiento: 200000 transacciones + 396494 asientos de ledger (2 por tx) + 5000 notas de gestión en texto libre.
4. Aplica las 10 reglas de coherencia: moneda de la cuenta origen, geografía por tupla real, saldo calculado desde el ledger (`final = inicial + créditos − débitos`), canales digitales → sucursal DIGITAL, score ~N(650,80), mora 10 %, buckets SBS por `dias_mora` (≤8 AL_DIA, 9-30 CPP, 31-60 Deficiente, tope 60).
5. Escribe doble salida en `entrega/`: `clean/` (16 tablas en `.csv + .sql`, va a la BD) y `raw/` (misma data con 2 % de errores sembrados para frenar el pipeline en vivo), más `catalogo_errores.csv`, `metadata_manifest.json`, `load_demo.sql` y `ddl_gestiones.sql`.
6. Se valida con `pruebas/validar_demo.py` (conteos, geografía, ledger, catálogo → 0 desvíos).

## 2. Qué incluye la base de datos

PostgreSQL, 6 esquemas, ~40 tablas/vistas. Extensiones: `uuid-ossp`, `pgcrypto`, `vector` (pgvector).

| Esquema | Qué guarda |
|---|---|
| `core` | OLTP: clientes, cuentas, tarjetas, solicitudes, evaluaciones, créditos, cuotas, pagos, transacciones (particionada x12), movimientos (ledger), reversiones, idempotencia, gestiones_cobranza |
| `reference` | Catálogos: monedas, sucursales (10, una DIGITAL), canales (7), productos (11), tipos_transaccion |
| `security` | `audit_logs` inmutable (sin UPDATE/DELETE) + trigger forense |
| `dq` | Reglas, resultados, `pipeline_runs` y circuit breaker al 0,01 % |
| `ai` | Quejas con `vector(1536)`, clasificaciones y auditoría humana |
| `analytics` | Star schema (`dim_*`, `fact_*`), vistas `vw_kpi_diarios`, `vw_morosidad_region`, `vw_cartera_en_riesgo`, materializada `mv_agregados_diarios_sucursal` |

Verificado: débitos = créditos = S/ 128 747 294.14; 7 canales; 12 particiones oct-2025 → sep-2026.

## 3. Transactions (`core.transacciones`)

Tabla central del dinero, particionada por mes (`PARTITION BY RANGE (fecha_transaccion)`, PK compuesta `(transaccion_id, fecha_transaccion)`).

Campos clave: `cuenta_origen_id` (FK obligatoria), `cuenta_destino_id` (solo transferencias), `canal_id`, `sucursal_id`, `tipo_transaccion` (FK a catálogo), `monto > 0`, `moneda_id`, `idempotency_key`, `comision` (ingreso informativo), `estado` (COMPLETADA / RECHAZADA / REVERTIDA).

Toda tx monetaria escribe 2 filas en `core.movimientos_contables` (DEBITO al origen, CREDITO al destino) y actualiza ambos saldos en la misma transacción. Borrar no existe: se revierte con una compensatoria en `core.reversiones`.

## 4. Functions y procedures (qué hace cada uno)

| Nombre | Tipo | Qué hace |
|---|---|---|
| `core.sp_transferir_dinero(...)` | FUNCTION → `transaccion_id` | 1) Si la `(canal, idempotency_key)` ya existe, devuelve la tx original (replay sin efectos, antes de validar saldo). 2) Bloquea ambas cuentas en orden por ID (cero deadlocks). 3) Valida saldo. 4) Inserta tx + idempotencia (ante `unique_violation` borra la huérfana y devuelve la original). 5) Inserta DEBITO+CREDITO en el ledger. 6) Actualiza saldos. Es la demo de los 2 segundos. |
| `core.sp_database_health_check()` | PROCEDURE | Chequeo previo a la demo: cuenta cuentas, huérfanas, tx huérfanas y sobregiros; imprime `NOTICE` con el resultado. |
| `dq.sp_test_post_carga_dw(run_id)` | PROCEDURE | Cuenta tx sin cuenta válida; si la falla supera 0,01 % guarda `CRITICAL_HALT` y lanza `CIRCUIT BREAKER ACTIVADO`, si no guarda `PASSED`. La llama `load_demo.sql`. |
| `security.fn_audit_forense_jsonb()` + `trg_audit_transacciones_forense` | FUNCTION + TRIGGER | En cada INSERT/UPDATE/DELETE sobre `core.transacciones` fotografía `OLD/NEW` a JSONB en `security.audit_logs`. |
| `analytics.sp_refresh_materialized_views()` | PROCEDURE | Refresca `mv_agregados_diarios_sucursal` (totales por sucursal y día). La leen `vw_kpi_diarios` y `vw_morosidad_region` para el dashboard. |

Pruebas que los ejercitan: `test_01` (transferencia OK), `test_02` (sin saldo, atomicidad), `test_03` (replay idempotente), `test_04` (100 concurrentes), `test_05` (débitos = créditos), `test_06` (reversión), `test_07` (RLS).

## 5. El front (`gestor-web`), nada más

Lista de cobranza en 2 pestañas: **Por contactar** (217 casos ordenados por `prioridad = saldo × puntaje`, con búsqueda) y **No contactar · dato en revisión** (80 en cuarentena). Cada caso muestra saldo expuesto, días mora, cuotas impagas, acción y motivo IA; el gestor escribe su correo y registra `SE_COMPROMETE | NO_PUEDE_PAGAR | NO_CONTESTA | DERIVAR` (con fecha de compromiso obligatoria si se compromete).

Contrato congelado (`src/api.js`): `GET {BASE}/api/lista` y `POST {BASE}/api/gestiones` con `x-api-key`. Sin `VITE_API_URL` usa mocks locales (`src/mocks/lista.json`, `cuarentena.json` + `localStorage`); con URL habla con la Lambda real. Hoy está en mock (`.env.production` vacío).
