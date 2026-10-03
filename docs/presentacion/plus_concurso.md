# Plus para ganar el concurso — BancoCloud

> Análisis de qué subirle al proyecto, priorizado por **impacto en el jurado / horas de trabajo**.
> Basado en el estado real del repo hoy: data generada y validada, 7 pruebas escritas,
> app funcionando en **modo mock**, endpoint de AWS **pendiente**, carpeta
> `pruebas/evidencia/` **vacía** (las capturas de los tests son entregable de la guía).

---

## Tier A — Gratis, hoy, cierran entregables que faltan (1–2 h entre todos)

| # | Plus | Por qué gana | Cuánto |
|---|---|---|---|
| A1 | **Capturar evidencia**: correr los 7 `.sql` + `validar_demo.py` + `gen_mock_lista.py` y guardar salidas/capturas en `pruebas/evidencia/` | La guía los lista como entregable y hoy la carpeta está vacía. Un jurado de banco pedirá «enséñenme que pasó» | 40 min |
| A2 | **Número honesto de cuarentena en todo el deck**: 80 créditos (no 412) | Coherencia total app ↔ PowerPoint ↔ discurso. Si chocan los números, se cae la confianza en todos los demás | 10 min |
| A3 | **README del repo** con: qué hay en cada carpeta, la batería de comandos y *qué imprime* cada test (`TEST 05 PASSED: D=C=128747294.14…`) | El jurado abre el repo: un README que responde las 3 primeras preguntas = criterio profesional | 1 h |
| A4 | **Revisar que el repo esté privado** (o al menos: sin claves reales, `.env` vacío, secreto de demo renombrado y comentado) | La guía lo pide expresamente; son 10 segundos antes de que alguien lo note mal | 5 min |
| A5 | **Un GIF animado** en el README de: lista → detalle → registrar gestión → pestaña cuarentena | Primera impresión cuando el revisor abre el link | 15 min |

---

## Tier B — Pocas horas, efecto «en vivo» enorme (2–5 h c/u)

| # | Plus | Por qué gana | Cuánto |
|---|---|---|---|
| B1 | **Sacar la app del mock**: `VITE_API_URL` → endpoint de Victor, probar GET lista + POST gestión de punta a punta | Es *la* dependencia dura de la guía: «sin esa URL, la app sigue siendo una maqueta». Demostrado en vivo = otra categoría | 1,5 h (con Victor) |
| B2 | **Video de respaldo 60–90 s** (app completa + `TEST 05 PASSED` + lote RAW deteniéndose) | Plan B obligatorio por wifi; además se puede ver en la lámina de cierre en loop | 1 h |
| B3 | **Prueba de carga con el lote de 1 M** (el script ya existió: `generar_1m_bancocloud`): una corrida con cronómetro y captura del tiempo | «Aguanta volumen» es una respuesta de infra que el jurado valora; la guía ya lo reservó para el martes | 1–2 h |
| B4 | **GitHub Action** que al hacer push: regenera con semilla → `validar_demo.py` → badge verde en el README | «Data verificada en cada commit» — suena a equipo que ya trabaja así en producción | 1,5 h |
| B5 | **Docker Compose** (Postgres + COPY de `entrega/*.sql` + app): `docker compose up` y la demo corre en cualquier máquina en 2 min | Elimina el riesgo «en mi máquina sí funciona» y el setup en vivo | 2 h |

---

## Tier C — Alto impacto, ya tienen la base hecha (medio día c/u)

| # | Plus | Por qué gana | Cuánto |
|---|---|---|---|
| C1 | **Diccionario de datos automático** (tabla, columna, tipo, nulidad, comentario) generando desde `information_schema` → `docs/diccionario.md` | Entregable pedido en la guía; mitiga la pregunta «¿qué significa esta columna?» sin improvisar | 1,5 h |
| C2 | **OpenAPI del contrato API** (el contrato ya está congelado en `src/api.js`) | Muestra que el front y el backend conversan por un acuerdo versionado, no por costumbre | 1 h |
| C3 | **Health check al arranque de la demo**: `CALL core.sp_database_health_check();` en pantalla (0 huérfanos, 0 sobregiros) antes de la primera transferencia | Prende la demo con un control, no con fe. Máximo «criterio de operación» en 30 segundos | 30 min |
| C4 | **Benchmark COPY vs INSERT** (la guía ya lo menciona): misma tabla, dos tiempos, una lámina | Elegir COPY no es un detalle: es la diferencia entre 40 min y 4 h de carga | 1 h |
| C5 | **Diseño de la prueba A/B en una lámina** (cómo se partiría la lista, qué se mide a 30 días: roll-rate) | Responde la pregunta más difícil («¿cómo saben que funciona?») con honestidad + método | 45 min |
| C6 | **Flujo completo cerrado**: app → POST → JSON en Bronze → clasificación → lista del día siguiente, con una sola captura de la cadena | «El ciclo se cierra» es la imagen que el jurado se lleva a casa | 3–4 h |

---

## Tier D — No hacer (scope creep)

- Reescribir la app en TypeScript o migrarla a Next.js.
- Un segundo chatbot/IA «para mostrar más IA» (la guía ya advirtió que sería el error opuesto).
- Más tablas, más migraciones, más volumen «por si acaso».
- Rediseñar el dashboard o el pipeline de otro frente (no es tu casa y el tiempo no da).

---

## Los plus gratuitos: vender mejor lo que ya existe

A veces el plus no es código, es **contarlo**:

1. **Abrir con el número exacto**: «hoy, 217 casos para llamar, 80 que no podemos tocar» — con la app al lado.
2. **Mostrar el ledger cuadrado en vivo** (`test_05`) en vez de decir «cuadra»: S/ 128,747,294.14 = S/ 128,747,294.14 en pantalla.
3. **La demo del replay idempotente en 10 segundos**: misma clave dos veces → misma transacción, dinero intacto.
4. **El catálogo RAW como transparencia**: «sembramos 2 % de errores y aquí está exactamente cuáles, fila por fila» — nadie en el jurado esperaba que lo dijeran.
5. **Las 2 notas adversariales del prompt**: «intentaron engañar al modelo desde el texto y está evaluado contra eso» — ciberseguridad ama este detalle.
6. **El manifiesto con semilla**: «misma semilla, mismos bytes; tres personas trabajaron sobre la misma data sin una sola discusión de número».
7. **La honestidad como estrategia**: data simulada, A/B propuesto, «en el banco iría Aurora». Decirlo antes de que lo pregunten convierte una debilidad en criterio.

---

## Resumen: si solo hay tiempo para 5 cosas

1. **A1** capturas de las 7 pruebas (entregable vacío).
2. **B1** app fuera del mock (la pieza que más dramatismo aporta).
3. **A3** README que responda todo.
4. **B2** video de respaldo de 90 s.
5. **C3** health check arrancando la demo.

Con esas cinco, el proyecto pasa de «bien armado» a «se ve que esto ya funciona».
