-- BANCOCLOUD DEMO: carga CLEAN via \copy (run_id 9616f743-040c-4515-8bdf-701612aa21ba)
-- psql -d bancocloud -f entrega/load_demo.sql   (master v13 aplicado)
\set ON_ERROR_STOP on
SET row_security = off;
ALTER TABLE core.transacciones DISABLE TRIGGER ALL;
ALTER TABLE core.movimientos_contables DISABLE TRIGGER ALL;
ALTER TABLE core.idempotencia DISABLE TRIGGER ALL;
ALTER TABLE core.pagos_credito DISABLE TRIGGER ALL;
ALTER TABLE core.cuotas DISABLE TRIGGER ALL;
ALTER TABLE core.creditos DISABLE TRIGGER ALL;
ALTER TABLE core.evaluaciones_credito DISABLE TRIGGER ALL;
ALTER TABLE core.solicitudes_credito DISABLE TRIGGER ALL;
ALTER TABLE core.tarjetas DISABLE TRIGGER ALL;
ALTER TABLE core.cuentas DISABLE TRIGGER ALL;
ALTER TABLE core.clientes DISABLE TRIGGER ALL;
CREATE TABLE IF NOT EXISTS core.transacciones_y2025m10 PARTITION OF core.transacciones FOR VALUES FROM ('2025-10-01 00:00:00+00') TO ('2025-11-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS core.transacciones_y2025m11 PARTITION OF core.transacciones FOR VALUES FROM ('2025-11-01 00:00:00+00') TO ('2025-12-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS core.transacciones_y2025m12 PARTITION OF core.transacciones FOR VALUES FROM ('2025-12-01 00:00:00+00') TO ('2026-01-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS core.transacciones_y2026m01 PARTITION OF core.transacciones FOR VALUES FROM ('2026-01-01 00:00:00+00') TO ('2026-02-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS core.transacciones_y2026m02 PARTITION OF core.transacciones FOR VALUES FROM ('2026-02-01 00:00:00+00') TO ('2026-03-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS core.transacciones_y2026m03 PARTITION OF core.transacciones FOR VALUES FROM ('2026-03-01 00:00:00+00') TO ('2026-04-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS core.transacciones_y2026m04 PARTITION OF core.transacciones FOR VALUES FROM ('2026-04-01 00:00:00+00') TO ('2026-05-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS core.transacciones_y2026m05 PARTITION OF core.transacciones FOR VALUES FROM ('2026-05-01 00:00:00+00') TO ('2026-06-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS core.transacciones_y2026m06 PARTITION OF core.transacciones FOR VALUES FROM ('2026-06-01 00:00:00+00') TO ('2026-07-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS core.transacciones_y2026m07 PARTITION OF core.transacciones FOR VALUES FROM ('2026-07-01 00:00:00+00') TO ('2026-08-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS core.transacciones_y2026m08 PARTITION OF core.transacciones FOR VALUES FROM ('2026-08-01 00:00:00+00') TO ('2026-09-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS core.transacciones_y2026m09 PARTITION OF core.transacciones FOR VALUES FROM ('2026-09-01 00:00:00+00') TO ('2026-10-01 00:00:00+00');
\copy reference.canales (canal_id, codigo_canal, nombre_canal, estado) FROM 'entrega/clean/canales.csv' WITH (FORMAT csv, HEADER true)
\copy reference.sucursales (sucursal_id, codigo_sucursal, nombre_sucursal, departamento, provincia, distrito, tipo_sucursal, estado) FROM 'entrega/clean/sucursales.csv' WITH (FORMAT csv, HEADER true)
\copy reference.productos (producto_id, codigo_producto, nombre_producto, familia_producto, moneda_id, tasa_interes_referencial) FROM 'entrega/clean/productos.csv' WITH (FORMAT csv, HEADER true)
\copy reference.tipos_transaccion (codigo, descripcion, requiere_destino) FROM 'entrega/clean/tipos_transaccion.csv' WITH (FORMAT csv, HEADER true)
\copy core.clientes (cliente_id, dni_hash, dni_cifrado, nombre, apellido, email_cifrado, telefono_cifrado, fecha_nacimiento, departamento, provincia, distrito, segmento_cliente, nivel_riesgo, score_riesgo, estado) FROM 'entrega/clean/clientes.csv' WITH (FORMAT csv, HEADER true)
\copy core.cuentas (cuenta_id, cliente_id, producto_id, numero_cuenta, moneda_id, saldo_actual, saldo_disponible, saldo_inicial, estado) FROM 'entrega/clean/cuentas.csv' WITH (FORMAT csv, HEADER true)
\copy core.tarjetas (tarjeta_id, cuenta_id, cliente_id, token_tarjeta_hash, mascara_pan, tipo_tarjeta, limite_credito, saldo_utilizado, saldo_disponible, fecha_corte, fecha_pago, estado) FROM 'entrega/clean/tarjetas.csv' WITH (FORMAT csv, HEADER true)
\copy core.solicitudes_credito (solicitud_id, cliente_id, producto_id, monto_solicitado, plazo_meses, fecha_solicitud, estado) FROM 'entrega/clean/solicitudes.csv' WITH (FORMAT csv, HEADER true)
\copy core.evaluaciones_credito (evaluacion_id, solicitud_id, score_calculado, capacidad_pago, decision, sustento, fecha_evaluacion) FROM 'entrega/clean/evaluaciones.csv' WITH (FORMAT csv, HEADER true)
\copy core.creditos (credito_id, solicitud_id, cliente_id, producto_id, monto_aprobado, saldo_capital_pendiente, tasa_tea, plazo_meses, dias_mora, bucket_riesgo, estado) FROM 'entrega/clean/creditos.csv' WITH (FORMAT csv, HEADER true)
\copy core.cuotas (cuota_id, credito_id, numero_cuota, monto_capital, monto_interes, seguro_desgravamen, monto_total_cuota, fecha_vencimiento, estado) FROM 'entrega/clean/cuotas.csv' WITH (FORMAT csv, HEADER true)
\copy core.pagos_credito (pago_id, cuota_id, monto_pagado, fecha_pago, canal_id) FROM 'entrega/clean/pagos.csv' WITH (FORMAT csv, HEADER true)
\copy core.transacciones (transaccion_id, cuenta_origen_id, cuenta_destino_id, canal_id, sucursal_id, tipo_transaccion, monto, comision, moneda_id, idempotency_key, run_id, fecha_transaccion, estado) FROM 'entrega/clean/transacciones.csv' WITH (FORMAT csv, HEADER true)
\copy core.movimientos_contables (movimiento_id, transaccion_id, cuenta_id, tipo_movimiento, monto, fecha_movimiento) FROM 'entrega/clean/movimientos.csv' WITH (FORMAT csv, HEADER true)
\copy core.idempotencia (canal_id, idempotency_key, transaccion_id, fecha_transaccion) FROM 'entrega/clean/idempotencia.csv' WITH (FORMAT csv, HEADER true)
SELECT setval(pg_get_serial_sequence('reference.canales','canal_id'), (SELECT max(canal_id) FROM reference.canales));
SELECT setval(pg_get_serial_sequence('reference.sucursales','sucursal_id'), (SELECT max(sucursal_id) FROM reference.sucursales));
SELECT setval(pg_get_serial_sequence('reference.productos','producto_id'), (SELECT max(producto_id) FROM reference.productos));
SELECT setval(pg_get_serial_sequence('core.cuentas','cuenta_id'), (SELECT max(cuenta_id) FROM core.cuentas));
SELECT setval(pg_get_serial_sequence('core.tarjetas','tarjeta_id'), (SELECT max(tarjeta_id) FROM core.tarjetas));
SELECT setval(pg_get_serial_sequence('core.solicitudes_credito','solicitud_id'), (SELECT max(solicitud_id) FROM core.solicitudes_credito));
SELECT setval(pg_get_serial_sequence('core.evaluaciones_credito','evaluacion_id'), (SELECT max(evaluacion_id) FROM core.evaluaciones_credito));
SELECT setval(pg_get_serial_sequence('core.creditos','credito_id'), (SELECT max(credito_id) FROM core.creditos));
SELECT setval(pg_get_serial_sequence('core.cuotas','cuota_id'), (SELECT max(cuota_id) FROM core.cuotas));
SELECT setval(pg_get_serial_sequence('core.pagos_credito','pago_id'), (SELECT max(pago_id) FROM core.pagos_credito));
SELECT setval(pg_get_serial_sequence('core.transacciones','transaccion_id'), (SELECT max(transaccion_id) FROM core.transacciones));
SELECT setval(pg_get_serial_sequence('core.movimientos_contables','movimiento_id'), (SELECT max(movimiento_id) FROM core.movimientos_contables));
ALTER TABLE core.clientes ENABLE TRIGGER ALL;
ALTER TABLE core.cuentas ENABLE TRIGGER ALL;
ALTER TABLE core.tarjetas ENABLE TRIGGER ALL;
ALTER TABLE core.solicitudes_credito ENABLE TRIGGER ALL;
ALTER TABLE core.evaluaciones_credito ENABLE TRIGGER ALL;
ALTER TABLE core.creditos ENABLE TRIGGER ALL;
ALTER TABLE core.cuotas ENABLE TRIGGER ALL;
ALTER TABLE core.pagos_credito ENABLE TRIGGER ALL;
ALTER TABLE core.transacciones ENABLE TRIGGER ALL;
ALTER TABLE core.movimientos_contables ENABLE TRIGGER ALL;
ALTER TABLE core.idempotencia ENABLE TRIGGER ALL;
ANALYZE core.clientes; ANALYZE core.cuentas; ANALYZE core.transacciones;
CALL dq.sp_test_post_carga_dw('9616f743-040c-4515-8bdf-701612aa21ba');
