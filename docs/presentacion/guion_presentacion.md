# Guion de exposición — Iván (script, base de datos y front)

## Lámina 1 — Apertura (0:00–0:30)
---

## Lámina 2 — El script generador (0:30–2:30)

**Dices:**
> «El generador es un script de Python de 1230 líneas. Se corre con una semilla fija, así que cada vez que lo corres sale exactamente la misma data.»

**Cómo funciona, en 5 pasos:**
1. Crea la cartera: 8000 clientes, 12000 cuentas, 8000 tarjetas, 3000 solicitudes, 2000 créditos, 41424 cuotas y 20190 pagos.
2. Simula 12 meses de movimiento (octubre 2025 a septiembre 2026): 200000 transacciones y 5000 notas de gestión en texto libre.
3. Aplica 10 reglas para que la data sea creíble: nadie sin cuenta, moneda de la cuenta origen, geografía real, saldo calculado desde el ledger, mora del 10 %.
4. Escribe dos salidas una data limpia y otra sucia con 2 % de errores a propósito.

**Volúmenes reales del manifiesto, semilla 20260926**

| Tabla | Filas | Para qué |
|---|---|---|
| clientes / cuentas / tarjetas | 8 000 / 12 000 / 8 000 | Gráficas y segmentos con forma real |
| solicitudes / créditos | 3 000 / 2 000 | Incluye rechazadas → tasa de aprobación |
| cuotas / pagos | 41 424 / 20 190 | Cronograma 12–36 cuotas, historia mes a mes |
| transacciones (198 247 OK / 1 753 rechazadas) | 200 000 | 12 meses de movimiento |
| movimientos ledger (2 por tx) | 396 494 | Cuadratura débitos = créditos |
| gestiones_cobranza | 5 000 | Notas en texto libre para la IA |

**Data sucia, con el catálogo**

| Error sembrado en RAW | Filas | Regla que lo atrapa |
|---|---|---|
| fecha_futura | 1 043 | fecha ≤ hoy |
| duplicadas (misma idempotency_key) | 696 | unicidad de la clave |
| origen_inexistente | 626 | integridad referencial ← **dispara el corte** |
| monto_no_positivo | 522 | rango de monto |
| moneda_invalida (EUR) | 417 | catálogo de monedas |
| nulos (monto/cuenta/fecha) | 232 × 3 | nulos no permitidos |
| dni_duplicado / saldo>aprobado / ledger descuadrado | 60 / 80 / 40 | reglas cruzadas |

`catalogo_errores.csv` (así se ve, fila por fila):

---

## Lámina 3 — La base de datos (2:30–6:00)

**Dices:**
> «La base es PostgreSQL, con el script maestro más 5 migraciones con su reversa»

**Tecnologías usadas:**
> «PostgreSQL como motor, con tres extensiones: `uuid-ossp` para los IDs, `pgcrypto` para cifrar los DNI, y `vector` (pgvector) para los embeddings de las quejas que usa la IA. Las transacciones van particionadas por mes: 12 particiones, una por cada mes de la ventana.»

**Los temas (el 360):**
> «La base cubre el círculo completo del banco en 6 esquemas: `core` con todo lo operativo (clientes, cuentas, tarjetas, créditos, cuotas, pagos, transacciones y el ledger), `reference` con los catálogos, `security` con la auditoría, `dq` con la calidad, `ai` con lo de inteligencia artificial, y `analytics` con las vistas para el dashboard. O sea: del cliente que abre su cuenta, al movimiento, al control de calidad, a la mora y al reporte. Todo conectado.»

| Esquema | Qué guarda | Tablas clave |
|---|---|---|
| `core` | Todo lo operativo | clientes, cuentas, tarjetas, créditos, cuotas, pagos, transacciones, movimientos, idempotencia, gestiones |
| `reference` | Catálogos fijos | monedas (2), sucursales (10), canales (7), productos (11), tipos_transaccion |
| `security` | Auditoría inmutable | audit_logs (sin UPDATE/DELETE ni como admin) |
| `dq` | Calidad y corte | rules, results, pipeline_runs, cuarentena (umbral 0,01 %) |
| `ai` | IA | quejas con `vector(1536)`, clasificaciones, auditoría humana |
| `analytics` | Reportes | `dim_*`, `fact_*`, vistas y materializada por sucursal y día |

**Lo que la hace fuerte:**
> «Uno, ledger de doble partida: cada movimiento escribe un DÉBITO y un CRÉDITO. Resultado real: 128 747 294.14 en cada lado, al centavo.»
> «Dos, idempotencia: la tabla `core.idempotencia` con clave por canal. Si la misma operación llega dos veces, devuelve la original sin duplicar. Se demuestra en diez segundos.»
> «Tres, concurrencia: bloqueo ordenado por ID. Cien sesiones contra la misma cuenta y el ledger no se descuadra.»

**La seguridad que se usó:**
> «Tres capas. Primera, RLS: cada cliente solo ve sus filas, en lectura, inserción y modificación, y la prueba 07 lo comprueba. Segunda, datos personales: el DNI nunca está en claro, se busca por hash y se recupera solo con la clave, como pide la Ley 29733. Tercera, auditoría: cada cambio en transacciones queda fotografiado en JSONB y la tabla de auditoría no se puede editar ni borrar, ni como administrador.»

**Muestra (las 7 pruebas, con lo que imprime cada una):**

| # | Prueba | Sale en pantalla |
|---|---|---|
| 01 | Transferencia OK | `TEST 01 PASSED: transferencia, saldos 9900/10100, ledger 1D+1C` |
| 02 | Sin saldo | `TEST 02 PASSED: SALDO_INSUFICIENTE y cero filas a medias` |
| 03 | Replay idempotente | `TEST 03 PASSED: replay devuelve la original sin duplicar` |
| 04 | 100 concurrentes | `TEST 04 PASSED: 100/100 concurrentes, destino en 1000.00 exactos` |
| 05 | Cuadratura global | `TEST 05 PASSED: D=C=128747294.14 y 0 cuentas fuera del ledger` |
| 06 | Reversión | `TEST 06 PASSED: original intacta + compensatoria (neto 0)` |
| 07 | RLS | `TEST 07 PASSED: A ve solo lo suyo e INSERT ajeno bloqueado` |

---

## Lámina 4 — El front (6:00–7:30)

**Dices:**
> «La app es `gestor-web/`: React con Vite y Tailwind, servida con Express. Hace una sola cosa, pero bien: le muestra al gestor a quién llamar hoy y le deja registrar qué pasó.»

La demo muestra el flujo diario del gestor en la app: abres Por contactar y ves los 217 casos ya ordenados por prioridad (lo más riesgoso primero), buscas un nombre y abres su tarjeta para leer en voz alta saldo expuesto, días de mora y acción recomendada; luego cambias a No contactar para enseñar los 80 excluidos y explicar que no se les llama no porque estén al día sino porque su dato falló los controles; y cierras registrando un resultado real.