# AI Usage Documentation — Arrow Maze Frontend (Cliente)

> Obligatorio según el §7 del enunciado del proyecto.
> Este archivo registra cada uso significativo de IA durante el desarrollo del cliente móvil en Flutter.

---

## Herramientas utilizadas

| Herramienta | Modelo / Versión | Rol en el flujo de trabajo |
|---|---|---|
| **OpenCode** | [Ej. Llama 3 70B / Claude 3.5 Sonnet] | Diseño de arquitectura, planificación de BLoC, revisión de principios SOLID/GoF y definición de interfaces en la Capa de Dominio. |
| **OpenCode** | [Ej. GPT-4o / CodeLlama] | Implementación de widgets en Flutter, lógica del Grafo Dirigido en Dart puro, inyección de dependencias y pruebas de widgets/unitarias. |

---

## Registro de uso por tarea

### Entrada #01 — Configuración inicial de CI/CD (GitHub Actions) e Infraestructura

- **Fecha / autor:** 20-06-2026 / Alberto Monasterio
- **Herramienta:** Gemini (Modelo: Gemini 3.1 Pro)
- **Rol en el flujo:** Configuración de DevOps, pipeline de Integración Continua y versionado.
- **Tarea/problema:** Configurar un pipeline en GitHub Actions para compilar la app de Flutter, ejecutar el linter y las pruebas unitarias, y generar el APK. Además, inicializar el repositorio base protegiendo la rama principal.
- **Prompt (paráfrasis fiel):**
  > "Genera el archivo YAML de GitHub Actions para un proyecto nuevo en Flutter/Dart. El workflow debe activarse en push o pull request a main, instalar dependencias, pasar el linter, correr pruebas y generar un APK. También necesito añadir la opción de ejecutarlo manualmente (workflow_dispatch) y reducir la retención del APK a 3 días. ¿Cómo protejo la rama main?"
- **Resultado obtenido:** Archivo `.github/workflows/flutter-ci.yml` completamente funcional, instrucciones de protección de ramas en GitHub, y guía de inicialización con Conventional Commits.
- **Modificaciones del equipo:** - Se ajustó el comando de inicialización de Flutter añadiendo el flag `--project-name arrowconmango_front`, ya que la IA sugirió usar `flutter create .` directamente y el nombre de la carpeta local en Windows tenía mayúsculas, lo cual viola las estrictas reglas de `snake_case` del `pubspec.yaml` de Dart.
  - Se dividió la subida inicial en commits atómicos (separando la configuración de CI/CD del documento de requisitos) para cumplir rigurosamente con el estándar del proyecto.
- **Verificación:** Ejecución exitosa del pipeline en la pestaña Actions de GitHub, generando el artefacto `app-release.zip` con check verde.
- **Lecciones / limitaciones:** Configurar el CI en GitHub antes de subir el proyecto base de Flutter genera un fallo automático, ya que el workflow no encuentra el archivo `pubspec.yaml`. Es fundamental inicializar la estructura local primero.


### Entrada #02 — Análisis de Restricciones y Diseño del Grafo (Planificación)

- **Fecha / autor:** 21-06-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Asistente de planificación y diseño arquitectónico (Capa de Dominio).
- **Tarea/problema:** Analizar el documento `designFront.md` para establecer las reglas estrictas de la Capa de Dominio, diseñar el algoritmo iterativo de salida de las flechas (`isPathClear`), e identificar los casos borde antes de escribir el código de producción.
- **Prompt (paráfrasis fiel):**
  > "Actúa como un Arquitecto de Software Principal experto en Dart. Adjunto 'designFront.md'. Analiza las restricciones para mantener el dominio 100% aislado de Flutter, diseña el flujo iterativo del método `isPathClear(ArrowCell)` usando grafos, identifica 3 Edge Cases (bucles, choques) y define los contratos de las interfaces en Dart puro sin generar código ejecutable aún."
- **Resultado obtenido:** Un análisis exhaustivo que propuso: 
  1. Un enfoque iterativo usando un `Set<String>` de visitados para evitar bucles infinitos (Stack Overflow).
  2. El uso de un `typedef CellResolver` para evitar dependencias circulares directas entre las Celdas y el Tablero.
  3. La necesidad de que el tablero sea inmutable (`copyWithRotatedCell`) para que el BLoC funcione correctamente.
- **Modificaciones del equipo:** El modelo dejó 4 decisiones de diseño abiertas. El equipo evaluó y confirmó:
  1. Uso de `bool` simple para `isPathClear` en pro de la simplicidad.
  2. Aprobación del patrón `CellResolver`.
  3. Uso del paquete `equatable` para igualdades (previamente aprobado en el SRS).
  4. Implementación estricta de un Tablero Inmutable para facilitar el patrón Command y la reactividad del UI.
- **Verificación:** El diseño teórico resuelve correctamente los problemas de ciclos infinitos y choques contra paredes.
- **Lecciones / limitaciones:** Forzar a un modelo de alto razonamiento a generar primero un documento de diseño y preguntar antes de actuar, garantiza que las decisiones arquitectónicas clave permanezcan en manos del equipo y evita refactorizaciones masivas posteriores.

### Entrada #03 — Generación y Refactorización de Capa de Dominio (Entidades)

- **Fecha / autor:** 21-06-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: DeepSeek V4 Pro)
- **Rol en el flujo:** Generación de código base puro en Dart.
- **Tarea/problema:** Traducir los contratos de diseño del dominio (Capa 1) a código de producción (18 entidades), respetando la inmutabilidad y los principios de Clean Architecture.
- **Prompt (paráfrasis fiel):** > "Actúa como un Desarrollador Senior en Dart. Escribe el código de producción completo en Dart puro para la Capa de Dominio implementando los contratos y el algoritmo descritos. Respeta el CellResolver, equatable y la inmutabilidad. Cero imports de Flutter."
- **Resultado obtenido:** El modelo generó la estructura base de los 18 archivos (enums, value objects, entidades abstractas y concretas) compilando con cero advertencias y sin dependencias de Flutter.
- **Modificaciones del equipo:** Se detectaron fallos lógicos en el código generado por la IA y un fallo funcional respecto a la mecánica del juego. Se ejecutaron manualmente las siguientes refactorizaciones críticas:
  1. **Abstracción del trazo:** Creación del archivo `path_step.dart` para encapsular el resultado (`PathOutcome` y `Direction`) del comportamiento de una celda durante el trazado.
  2. **Aplicación OCP (Polimorfismo):** Eliminación de condicionales rígidos generados por la IA mediante la adición del método `PathStep evaluatePath(Direction incomingDirection)` en la base `Cell`. Implementación de la mecánica de "deslizamiento" en `EmptyCell` (`continuePath` manteniendo la dirección intacta) y comportamientos específicos en `ArrowCell`, `WallCell` y `ExitCell`.
  3. **Inversión de Dependencias (Patrón Composite):** Refactorización profunda de `board.dart`. Se migró la lista acoplada `List<Cell>` a una estructura abstracta polimorfa `List<CellComponent>`. Se ajustaron el constructor (`fromComponents`), la lógica recursiva segura (`isPathClear`) y los métodos de inmutabilidad (`clone`) para soportar tableros anidados sin romper la arquitectura limpia.
- **Verificación:** Código compilando a la perfección. La estructura ahora respeta estrictamente los principios SOLID (OCP y DIP) y modela fielmente las mecánicas del clon de Arrow Maze.

### Entrada #04 — Pruebas Unitarias y Validación AAA (Capa de Dominio)

- **Fecha / autor:** 21-06-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo de QA/Auditoría)
- **Rol en el flujo:** Asistente de QA Automation (Ingeniero de Pruebas).
- **Tarea/problema:** Validar la integridad de la refactorización del patrón Composite en la clase `Board` y la lógica de trazado de rutas (`PathStep`) mediante pruebas unitarias exhaustivas en Dart puro, cubriendo casos límite como ciclos infinitos y choques.
- **Prompt (paráfrasis fiel):** > "Actúa como un QA Senior. Escribe pruebas unitarias exhaustivas usando el patrón estricto AAA (Arrange, Act, Assert) para `Board` y `PathStep`. Implementa casos para: éxito al llegar a salida, bloqueos en paredes, detección de ciclos (bucles) y límites del tablero. Usa `package:test` puro sin librerías de mocking externas."
- **Resultado obtenido:** El modelo generó la suite de pruebas `board_test.dart` cubriendo exitosamente:
  1. Instanciación y comparaciones de igualdad del objeto `PathStep`.
  2. Pruebas lógicas del método `isPathClear` (caminos libres hacia `ExitCell`, bloqueos correctos ante `WallCell`, prevención de *stack overflow* ante ciclos infinitos, y validación de límites ).
  3. Pruebas de inyección y resolución correcta del `CellResolver`.
- **Modificaciones del equipo :** 1. Refactorización de la nomenclatura de los tests generados por la IA. Se renombraron las descripciones (ej. `should_return_true_when_arrow_reaches_exit_cell`) para alinearlas estrictamente con el estándar BDD/AAA exigido por la arquitectura del proyecto, mejorando la legibilidad de la consola durante la ejecución.
- **Verificación:** Ejecución exitosa de `dart test` cubriendo todos los casos destructivos y de éxito para la lógica base del juego, garantizando que el dominio es sólido antes de pasar a la capa de Casos de Uso.

### Entrada #05 — Rediseño Arquitectónico del Dominio (Topología N-Dimensional)

- **Fecha / autor:** 21-06-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Arquitecto de Software Principal.
- **Tarea/problema:** Corregir el modelado erróneo del juego (donde las flechas eran celdas 1x1 estáticas) para reflejar la mecánica real de objetos deslizantes multi-nodo. Además, cumplir con la exigencia académica de desacoplar la lógica del juego de una matriz 2D para soportar futuras topologías (3D, hexagonales) aplicando estrictamente el Principio de Inversión de Dependencias (DIP).
- **Prompt (paráfrasis fiel):** > "Actúa como Arquitecto de Software. Rediseña la Capa de Dominio de 'Arrowconmango'. Corrige el error: las flechas ocupan múltiples nodos y se deslizan hasta salir. Aplica estrictamente DIP y OCP: el diseño debe ser agnóstico a la dimensión espacial (no atado a 2D). Usa `NodeId` abstracto y una interfaz `Topology`. Genera el Documento de Diseño Arquitectónico detallando contratos, justificación SOLID y flujo lógico. No generes código de implementación aún."
- **Resultado obtenido:** El modelo generó un documento exhaustivo (`DOMAIN_REDESIGN_v2.md`) estableciendo:
  1. Abstracciones clave: `NodeId` opaco y `Topology` (dividida por ISP en `TrajectoryProvider`, etc.).
  2. Entidades precisas: `ArrowEntity` (multi-nodo, sin matemáticas espaciales) y `BoardState` (índice reverso de ocupación O(1)).
  3. Límite arquitectónico: La matemática de cuadrícula 2D se delegó completamente a la Capa 4 (Infraestructura) con `Grid2DTopology`.
- **Modificaciones del equipo :** Análisis y validación de la propuesta contra las mecánicas reales del clon de Arrow Maze y las métricas de evaluación de la asignatura. Se aprobó la depreciación total de la v1 del dominio para adoptar este diseño superior.
- **Verificación:** El diseño garantiza que la lógica del negocio (`CollisionValidator`) ignora la geometría del tablero, logrando un 100% de cumplimiento con los principios SOLID requeridos.


### Entrada #06 — Implementación de la Capa de Dominio v2 (Topología Abstracta)

- **Fecha / autor:** 21-06-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Desarrollador Senior en Dart (Generación de código de producción).
- **Tarea/problema:** Traducir el documento de diseño arquitectónico (`DOMAIN_REDESIGN_v2.md`) a código de producción en Dart puro. Reemplazar la antigua lógica de cuadrícula acoplada por una arquitectura agnóstica basada en Nodos e interfaces Topológicas, y actualizar las entidades de gestión de partida para depender del nuevo índice espacial `BoardState`.
- **Prompt (paráfrasis fiel):** > "Actúa como un Desarrollador Senior en Dart. Basado en el documento adjunto 'DOMAIN_REDESIGN_v2.md', escribe la implementación en Dart puro para la Fase 1 y Fase 2. Primero genera el núcleo espacial (`node_id`, `arrow_entity`, `board_state`, `topology`, `collision_validator`) y la infraestructura de cuadrícula 2D. En un segundo paso, actualiza las entidades sobrevivientes (`game_session`, `level`, `move_command`) para que consuman el nuevo `BoardState`. Cero dependencias de Flutter y estricta inmutabilidad."
- **Resultado obtenido:** Kimi procesó los contratos abstractos y generó con éxito el 100% del nuevo dominio en dos lotes de código continuo. Se implementó el índice reverso de ocupación O(1) en `BoardState`, el motor de colisiones agnóstico en `CollisionValidator`, y las reglas de partida actualizadas, respetando fielmente el patrón Clean Architecture.
- **Modificaciones del equipo (Realizadas manualmente por Alberto Monasterio):** 1. Depreciación y eliminación manual en el repositorio de toda la versión 1 del dominio (archivos y tests antiguos) mediante comandos de Git (`git rm`) para preparar un entorno limpio.
  2. Orquestación del contexto de la IA (Prompt Engineering): Se dividió deliberadamente la generación de código en dos fases (Núcleo Espacial y Reglas de Partida) para mantener el uso de la ventana de contexto (Context Window) por debajo del 32%, evitando la degradación y alucinaciones del modelo al generar múltiples archivos.
- **Verificación:** Los archivos generados se integraron en la estructura de carpetas `lib/features/game/domain/`. El código cumple estrictamente con el Principio de Inversión de Dependencias (DIP) y aisla las matemáticas del espacio (2D) en la Capa de Infraestructura.





### Entrada #07 — Implementación de Jerarquía de Errores de Dominio

- **Fecha / autor:** 21-06-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Desarrollador Senior en Dart (Generación de código de producción).
- **Tarea/problema:** Crear el "idioma" de fallos del dominio v2. El motor de colisiones y los futuros casos de uso necesitan fallar con gracia usando tipos específicos en lugar de excepciones genéricas como `ArgumentError`. Se requiere una clase base abstracta `Failure` con Equatable para que el BLoC pueda comparar errores por valor.
- **Prompt (paráfrasis fiel):** > "Implementa la jerarquía de errores de dominio: clase base abstracta `Failure` (Equatable + Exception) y tres errores específicos: `PathBlockedFailure` (con IDs de flecha moviéndose y bloqueadora), `ArrowNotFoundFailure` (con ID de flecha inexistente), y `TopologyOutOfBoundsFailure` (con coordenada inválida). Todo en Dart puro, sin Flutter."
- **Resultado obtenido:** 4 archivos en `lib/features/game/domain/errors/`:
  1. `failure.dart` — Clase base abstracta con `Equatable` e `Exception`.
  2. `path_blocked_failure.dart` — Lleva `movingArrowId` y `blockingArrowId`.
  3. `arrow_not_found_failure.dart` — Lleva `arrowId`.
  4. `topology_out_of_bounds_failure.dart` — Lleva `coordinate`.
- **Modificaciones del equipo:** Ninguna. El código generado cumplió con los requisitos SOLID (SRP: cada failure tiene una única razón de cambio; OCP: nuevos failures extienden la base sin modificar existentes).
- **Verificación:** Código compilando sin warnings. Listo para ser consumido por los casos de uso mediante el tipo `Result<T>`.

### Entrada #08 — Definición de Contratos de Repositorios (Puertos del Dominio)

- **Fecha / autor:** 21-06-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Arquitecto de Software (Definición de puertos DIP).
- **Tarea/problema:** Definir las interfaces abstractas de repositorio que la Capa 4 (Infraestructura) deberá implementar. Sin estos contratos, la capa de Casos de Uso estaba bloqueada porque no tenía abstracciones de las cuales depender (DIP). Además, el proyecto no tiene `dartz` ni `fpdart` como dependencias, por lo que `Either<Failure, T>` no estaba disponible.
- **Prompt (paráfrasis fiel):** > "Define los contratos de repositorio del dominio: `ILevelRepository` (cargar nivel, contar niveles, obtener definición) e `IProgressRepository` (leer/guardar progreso). Crea un `Result<T>` con sealed classes de Dart 3 en lugar de usar `Either` de fpdart, para mantener consistencia con el `MoveCommand` sealed que ya existe. Sin dependencias externas."
- **Resultado obtenido:** 3 archivos en `lib/features/game/domain/repositories/`:
  1. `result.dart` — Sealed class `Result<T>` con `Success<T>` y `Error<T>`. Reemplaza `Either` sin dependencias externas.
  2. `i_level_repository.dart` — Contrato con `loadLevel()`, `getLevelCount()`, `getLevelDefinition()`.
  3. `i_progress_repository.dart` — Contrato con `loadProgress()`, `saveProgress()`.
- **Modificaciones del equipo:** Decisión arquitectónica de usar sealed classes de Dart 3 en lugar de agregar `fpdart` como dependencia. Mantiene el dominio libre de dependencias FP externas y es consistente con el estilo del proyecto (`MoveCommand` ya usa sealed).
- **Verificación:** Los contratos están listos para que la Capa 4 los implemente. El `Result<T>` permite pattern matching exhaustivo con `switch` de Dart 3.

### Entrada #09 — Suite de Pruebas Unitarias v2 (Grid2DTopology, BoardState, CollisionValidator)

- **Fecha / autor:** 21-06-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max + sub-agent sdd-apply)
- **Rol en el flujo:** QA Automation (Ingeniero de Pruebas).
- **Tarea/problema:** Las pruebas de la v1 fueron eliminadas junto con el refactor a topología abstracta. El código actual del dominio v2 no tenía red de seguridad. Se necesitaban pruebas unitarias exhaustivas para las tres clases críticas: la matemática de la topología 2D, el índice reverso O(1) del tablero, y la lógica de colisiones.
- **Prompt (paráfrasis fiel):** > "Escribe 3 archivos de test usando `package:test` puro (NO flutter_test). Patrón AAA estricto con comentarios. Naming: `should_[expected]_when_[condition]`. Para Grid2DTopology: 12 tests cubriendo trayectorias, bordes, shifted nodes, neighbors, contains, exit boundary y tipo inválido. Para BoardState: 9 tests cubriendo lookups O(1), inmutabilidad al borrar/reemplazar, y reconstrucción del índice reverso. Para CollisionValidator: 6 tests cubriendo salida limpia, bloqueo frontal, bloqueo lateral, path parcial, slide libre y slide bloqueado. Usa Grid2DTopology real como dependencia del CollisionValidator."
- **Resultado obtenido:** 27 tests unitarios en 3 archivos (`test/domain/`):
  1. `grid_2d_topology_test.dart` — 12 tests (trayectorias en 4 direcciones, bordes, shift, neighbors, contains, exit boundary, tipo inválido).
  2. `board_state_test.dart` — 9 tests (lookups por nodo e ID, inmutabilidad, replace, empty, count, reconstrucción de índice).
  3. `collision_validator_test.dart` — 6 tests (exit limpio, bloqueo, boundary, path parcial, slide libre/bloqueado).
- **Modificaciones del equipo:** Revisión manual de cada test contra el código de producción para verificar que los asserts son correctos (especialmente la matemática de `getShiftedNodes` y la trayectoria parcial en `checkExit`). Se confirmó que todos los expected values coinciden con la lógica real.
- **Verificación:** Pendiente de ejecutar con `flutter test test/domain/` o `dart test test/domain/` en entorno con Flutter/Dart disponible. El código fue revisado manualmente y los valores esperados fueron verificados contra la implementación.
- **Lecciones / limitaciones:** No se pudo ejecutar `dart test` en el entorno de desarrollo (sin Flutter/Dart en PATH). La verificación se hizo por inspección manual del código. Se recomienda ejecutar la suite antes del próximo commit a main.

### Entrada #10 — Implementación de MoveBasedScoring (Strategy Concreto)

- **Fecha / autor:** 21-06-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Desarrollador Senior en Dart (Generación de código de producción).
- **Tarea/problema:** La interfaz `ScoringStrategy` existía pero no tenía implementación concreta. El futuro caso de uso `EvaluateGameStateUseCase` necesita un algoritmo inyectable para calcular puntos. Sin esto, la capa de aplicación no puede completar el flujo de puntuación.
- **Prompt (paráfrasis fiel):** > "Implementa una estrategia concreta de scoring llamada `MoveBasedScoring` que implemente `ScoringStrategy`. Fórmula: basePoints (1000) - (moves × movePenalty=50) - (seconds × timePenalty=10), con un mínimo garantizado de 100 puntos. Todos los parámetros deben ser configurables vía constructor. Dart puro, sin Flutter."
- **Resultado obtenido:** Archivo `lib/features/game/domain/services/move_based_scoring.dart` con la clase `MoveBasedScoring` que implementa `ScoringStrategy`. Constructor con 4 parámetros configurables (`basePoints`, `movePenalty`, `timePenalty`, `minPoints`) con valores por defecto razonables.
- **Modificaciones del equipo:** Ninguna. El código generado es limpio y cumple con OCP (abierto a extensión: se pueden crear nuevas estrategias sin modificar esta).
- **Verificación:** Código compilando sin warnings. Listo para ser inyectado en el caso de uso de evaluación de partida.

### Entrada #11 — Validación de Nodos Duplicados en BoardState

- **Fecha / autor:** 21-06-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Arquitecto de Software (Defensa de invariantes de dominio).
- **Tarea/problema:** `BoardState._buildNodeIndex` sobrescribía silenciosamente el índice cuando dos flechas ocupaban el mismo nodo. Esto permitía estados inválidos (flechas superpuestas) que indican un nivel mal definido. El dominio debe fallar rápido ante datos corruptos.
- **Prompt (paráfrasis fiel):** > "Crea un error de dominio `OverlappingArrowsFailure` con `nodeKey` y `arrowIds`. Modifica `BoardState._buildNodeIndex` para detectar cuando dos flechas ocupan el mismo nodo y lanzar este error. Agrega un test unitario que verifique que `BoardState` lanza `OverlappingArrowsFailure` al construirse con flechas superpuestas."
- **Resultado obtenido:** 
  1. `lib/features/game/domain/errors/overlapping_arrows_failure.dart` — Nuevo failure con `nodeKey` y lista de `arrowIds` involucradas.
  2. Modificación de `BoardState._buildNodeIndex` para detectar duplicados y lanzar el error.
  3. Test `should_throw_when_arrows_overlap_at_same_node` agregado a `board_state_test.dart`.
- **Modificaciones del equipo:** Se corrigió un error de compilación: el constructor de `OverlappingArrowsFailure` era `const` pero usaba `arrowIds.join(", ")` que no es una expresión constante. Se cambió a constructor no-const.
- **Verificación:** Suite completa de BoardState pasando (10/10 tests, incluyendo el nuevo de validación).

### Entrada #12 — LevelBuilder para Construcción de Niveles desde Definiciones

- **Fecha / autor:** 21-06-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Desarrollador Senior en Dart (Patrón Builder).
- **Tarea/problema:** El enunciado exige 15 niveles manuales con dificultad progresiva y distintas formas de tablero. No había forma de construir niveles desde configuración (JSON, YAML) sin acoplar la capa de datos al dominio. Se necesitaba un builder que traduzca definiciones estructuradas a `Level` + `BoardState` + `ArrowEntity`.
- **Prompt (paráfrasis fiel):** > "Crea un `LevelBuilder` en `domain/services/` con API fluida: `levelId` setter, `addArrow(id, nodes, direction)`, `build()` que devuelve `Level`, y `reset()` para reutilización. Debe validar que `levelId` esté seteado antes de `build()` (lanzar `StateError` si no). Debe propagar `OverlappingArrowsFailure` de `BoardState`. Incluye 6 tests: single arrow, multiple arrows, levelId no seteado, overlap, reset, y difficulty ranges."
- **Resultado obtenido:**
  1. `lib/features/game/domain/services/level_builder.dart` — Builder con API fluida, validación de `levelId`, propagación de errores de dominio, y método `reset()`.
  2. `test/domain/level_builder_test.dart` — 6 tests cubriendo todos los casos (construcción simple, múltiple, error de levelId, overlap, reset, y rangos de dificultad).
- **Modificaciones del equipo:** Ninguna. El código generado es limpio y sigue el patrón Builder canónico de Dart.
- **Verificación:** 6/6 tests pasando. El builder está listo para ser consumido por la capa de datos cuando implemente la deserialización de JSON.

### Entrada #13 — Validación de Flecha Existente en GameSession.afterArrowExit

- **Fecha / autor:** 21-06-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Arquitecto de Software (Defensa de invariantes de dominio).
- **Tarea/problema:** `GameSession.afterArrowExit` no validaba que la flecha existiera en el board antes de procesarla. Si se llamaba con una flecha inexistente, `boardState.withoutArrow` filtraba por ID, no la encontraba, y devolvía el mismo board sin error. Esto permitía bugs silenciosos donde el moveCount se incrementaba pero el board no cambiaba.
- **Prompt (paráfrasis fiel):** > "Modifica `GameSession.afterArrowExit` para validar que la flecha existe en el board antes de procesarla. Si no existe, lanza `ArrowNotFoundFailure`. Agrega 4 tests: exit válido, incremento de moveCount, error cuando la flecha no está en el board, y error cuando la flecha ya salió (doble exit)."
- **Resultado obtenido:**
  1. Modificación de `GameSession.afterArrowExit` para validar existencia con `boardState.getArrowById(arrow.id)`.
  2. Import de `ArrowNotFoundFailure` en `game_session.dart`.
  3. `test/domain/game_session_test.dart` — 7 tests cubriendo afterArrowExit (4) y undoLastMove (3).
- **Modificaciones del equipo:** Ninguna. La validación es directa y el test cubre el caso de doble exit (intentar sacar la misma flecha dos veces).
- **Verificación:** 7/7 tests pasando en game_session_test.dart.

### Entrada #14 — Método Level.startSession() para Crear GameSession

- **Fecha / autor:** 21-06-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Arquitecto de Software (Encapsulamiento de reglas de dominio).
- **Tarea/problema:** `Level` tenía `templateBoard` pero no había método para iniciar una `GameSession` desde él. El futuro `LoadLevelUseCase` necesitaría saber cómo generar un `sessionId`, setear `startedAtMs`, y clonar el board template. Ese conocimiento es de dominio y no debería vivir en el caso de uso (violación de SRP).
- **Prompt (paráfrasis fiel):** > "Agrega un método `startSession(sessionId, startedAtMs)` a `Level` que cree y devuelva un `GameSession` usando el `templateBoard`. Los parámetros `sessionId` y `startedAtMs` deben ser requeridos. Agrega un test que verifique la creación correcta de la sesión."
- **Resultado obtenido:**
  1. Método `Level.startSession({required String sessionId, required int startedAtMs})` que devuelve `GameSession`.
  2. Import de `game_session.dart` en `level.dart`.
  3. Test `should_create_GameSession_from_template_board` agregado a `level_builder_test.dart`.
- **Modificaciones del equipo:** Ninguna. El método es simple y delega la generación de UUID y timestamp al caso de uso (responsabilidad correcta).
- **Verificación:** 7/7 tests pasando en level_builder_test.dart.

### Entrada #15 — Getter isVictory en GameSession

- **Fecha / autor:** 21-06-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Arquitecto de Software (Encapsulamiento de reglas de negocio).
- **Tarea/problema:** La condición de victoria (`boardState.isEmpty` = todas las flechas salieron) no estaba expuesta en `GameSession`. El BLoC tendría que conocer esta regla de negocio directamente, lo que es una fuga de responsabilidad del dominio. Las reglas de negocio deben vivir en el dominio, no en la capa de presentación.
- **Prompt (paráfrasis fiel):** > "Agrega un getter `isVictory` a `GameSession` que devuelva `true` cuando `boardState.isEmpty` es `true`. Agrega 3 tests: retorna false cuando quedan flechas, retorna true cuando todas salieron, y retorna true para un board vacío desde el inicio."
- **Resultado obtenido:**
  1. Getter `bool get isVictory => boardState.isEmpty` en `GameSession`.
  2. 3 tests en `game_session_test.dart` cubriendo los casos: flechas restantes, todas salidas, y board vacío inicial.
- **Modificaciones del equipo:** Ninguna. El getter es directo y encapsula la regla de negocio correctamente.
- **Verificación:** 10/10 tests pasando en game_session_test.dart.

### Entrada #16 — Método elapsedSeconds() en GameSession

- **Fecha / autor:** 21-06-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Desarrollador Senior en Dart (Cálculo de métricas de dominio).
- **Tarea/problema:** `GameSession` tenía `startedAtMs` pero no había método para obtener el tiempo transcurrido. `Score` necesita `timeElapsed` para calcular puntos, pero no había forma limpia de obtenerlo desde la sesión sin que el caso de uso hiciera la matemática (violación de SRP).
- **Prompt (paráfrasis fiel):** > "Agrega un método `elapsedSeconds(int nowMs)` a `GameSession` que calcule los segundos transcurridos desde `startedAtMs`. Debe proteger contra clock skew (si `nowMs` es anterior a `startedAtMs`, retorna 0). Debe truncar milisegundos (división entera). Agrega 4 tests: tiempo correcto, cero cuando no pasó tiempo, cero en clock skew, y truncamiento de milisegundos."
- **Resultado obtenido:**
  1. Método `int elapsedSeconds(int nowMs)` en `GameSession` con protección contra clock skew y truncamiento.
  2. 4 tests en `game_session_test.dart` cubriendo todos los casos.
- **Modificaciones del equipo:** Ninguna. El método es robusto y maneja edge cases correctamente.
- **Verificación:** 14/14 tests pasando en game_session_test.dart.

### Entrada #16 — Plan de Implementación (Issue #7: Use Cases - Game Flow)

- **Fecha / autor:** 21-06-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Arquitecto de Software Principal (Planificador).
- **Tarea/problema:** Diseñar el plan de implementación detallado para el Issue #7 (Casos de Uso del flujo principal del juego), asegurando el estricto cumplimiento de Clean Architecture y preparando el terreno para el modelo "Coder".
- **Prompt (paráfrasis fiel):** > "Actúa como un Arquitecto de Software Principal. Basado en el código actual y vivo de la Capa de Dominio (BoardState, ArrowEntity, GameSession, CollisionValidator, etc.), genera un Plan de Implementación detallado para 5 Casos de Uso (LoadLevel, StartGameSession, TriggerArrowExit, UndoMove, EvaluateGameState). Para cada uno define: propósito, dependencias, inputs/outputs (usando `Result<T>`), flujo lógico y manejo de errores. Incluye además la estrategia de testing (patrón AAA). No generes el código de implementación aún."
- **Resultado obtenido:** El modelo generó un documento Markdown exhaustivo detallando las firmas de los métodos, inyección de dependencias (ej. `ILevelRepository`, `CollisionValidator`) y flujos lógicos para los 5 casos de uso. Adicionalmente, identificó la necesidad de crear un DTO (`GameEvaluation`) en la capa de aplicación y definió 22 escenarios de prueba unitaria usando *mocks* manuales.
- **Modificaciones del equipo: 1. Aplicación del Patrón Planner-Coder:** Se separó la fase de diseño de la fase de código para minimizar errores de contexto. 2. **Inyección de Contexto Dinámico:** En lugar de depender de documentación estática, se alimentó al modelo directamente con el código fuente actualizado de la rama `develop` para garantizar compatibilidad absoluta con los cambios recientes del equipo.
- **Verificación:** El diseño cumple con el Principio de Inversión de Dependencias (DIP), evita el uso de excepciones para el control de flujo (adoptando `Result<T>`) y mantiene la capa libre de dependencias de Flutter.
---------------------------------------------------------
### Entrada #17 — Implementación de Código (Issue #7: Use Cases - Game Flow)

- **Fecha / autor:** 21-06-2026 / Alberto Monasterio
- **Herramienta:** Opencode (Kimi K2.7 Code)
- **Rol en el flujo:** Senior Dart Developer (Ejecutor / Coder).
- **Tarea/problema:** Generar el código puro en Dart para la capa de aplicación (1 DTO y 5 Casos de Uso del Issue #7), basándose estrictamente en el plan arquitectónico de la Entrada #16 y manteniendo la pureza de Clean Architecture.
- **Prompt (paráfrasis fiel):** > "Actúa como un Senior Dart Developer. Estamos implementando el Issue #7 usando Clean Architecture pura. Tu tarea es generar el código Dart puro para los archivos [Nombres de los archivos] basándote exactamente en el plan del Arquitecto proporcionado a continuación. Reglas de código: Cero dependencias de Flutter, usa `Result<T>`, si la clase `Failure` es abstracta usa `GenericFailure(String message)`. Genera el código en un solo bloque estructurado."
- **Resultado obtenido:** El modelo generó la implementación exitosa y robusta de `GameEvaluation` (DTO), `LoadLevelUseCase`, `StartGameSessionUseCase`, `TriggerArrowExitUseCase`, `UndoMoveUseCase` y `EvaluateGameStateUseCase`. El código respetó las reglas funcionales (inmutabilidad, manejo seguro de errores con `try-catch`) y las inyecciones de dependencias indicadas.
- **Modificaciones del equipo:** 1. **Estrategia de Micro-Prompting:** En lugar de solicitar todo el código de una vez, se dividió la generación en 5 peticiones aisladas (una por caso de uso) en ventanas de contexto limpias para evitar alucinaciones. 2. **Ajuste de Tipado:** Se detectó que el modelo intentó instanciar directamente la clase base `Failure` (la cual es abstracta). Se intervino manualmente creando e implementando una clase concreta `GenericFailure` para envolver correctamente las excepciones no controladas. 3. **Resolución de Rutas:** Se corrigieron manualmente todas las rutas de los `import` relativos en los 6 archivos generados utilizando las herramientas de auto-importado del IDE.
- **Verificación:** Todos los archivos pasaron el análisis estático (`flutter analyze`) sin errores rojos, respetan las convenciones del equipo y se integraron en el historial de Git mediante una secuencia de 6 commits atómicos y semánticos (`feat(game-flow)`).


### Entrada #18 — Refactoring a Arquitectura Basada en Grafos (Graph<V>)

- **Fecha / autor:** 24-06-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Arquitecto de Software (Refactoring de infraestructura).
- **Tarea/problema:** `Grid2DTopology` contenía toda la lógica de adyacencia, trayectorias y navegación embebida en una sola clase monolítica. El profesor recomendó usar grafos explícitos para modelar el tablero y las flechas. Se necesitaba una abstracción `Graph<V>` en el dominio (DIP) y una implementación `GridGraph` en la capa de datos con listas de adyacencia precomputadas para lookups O(1).
- **Prompt (paráfrasis fiel):** > "Refactoriza `Grid2DTopology` para usar una arquitectura basada en grafos. Crea una abstracción `Graph<V>` en `domain/services/` con métodos `neighbors(node)`, `contains(node)`, `nodes`. Crea `GridGraph` en `data/topologies/` que precompute listas de adyacencia al construirse. `Grid2DTopology` debe delegar en `GridGraph` internamente. Mueve `CardinalDirection` de la capa de datos a `domain/entities/`. Actualiza todos los tests afectados."
- **Resultado obtenido:**
  1. `lib/features/game/domain/services/graph.dart` — Abstracción genérica `Graph<V>` con interfaz mínima.
  2. `lib/features/game/data/topologies/grid_graph.dart` — Implementación con adyacencia precomputada O(1).
  3. `lib/features/game/domain/entities/cardinal_direction.dart` — Movido de la capa de datos al dominio.
  4. Refactoring de `Grid2DTopology` para delegar en `GridGraph`.
  5. Actualización de 5 archivos de tests (imports y `const` → `late final`).
- **Modificaciones del equipo:** Se corrigieron imports en los tests (cambio de `const` a `late final` para instancias de `Grid2DTopology` ya que el constructor ahora construye un `GridGraph` internamente y no es una expresión constante).
- **Verificación:** Suite completa de tests del dominio pasando sin errores.
- **Lecciones / limitaciones:** Cuando un constructor deja de ser `const` (porque ahora hace trabajo computacional como precomputar adyacencia), todas las instancias en tests deben cambiar de `const` a `late final`.

### Entrada #19 — Implementación de Data Models & Mappers (Issue #1)

- **Fecha / autor:** 24-06-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Desarrollador Senior en Dart (Capa de Datos — Models & Mappers).
- **Tarea/problema:** La Capa de Datos necesitaba modelos serializables (JSON) y mappers bidireccionales para traducir entre los modelos de persistencia y las entidades puras del dominio. Sin esto, los repositorios no pueden implementar la deserialización requerida por `ILevelRepository` e `IProgressRepository`.
- **Prompt (paráfrasis fiel):** > "Implementa 5 data models (`NodeModel`, `ArrowModel`, `BoardStateModel`, `LevelModel`, `AppProgressModel`) con métodos `fromJson`/`toJson` en `lib/features/game/data/models/`. Crea 4 mappers bidireccionales (`ArrowMapper`, `BoardStateMapper`, `LevelMapper`, `AppProgressMapper`) en `data/models/mappers/` que traduzcan entre models y entidades de dominio. Incluye 18 tests unitarios con patrón AAA cubriendo round-trip serialization, edge cases y validaciones."
- **Resultado obtenido:**
  1. 5 archivos de modelos en `lib/features/game/data/models/` con serialización JSON completa.
  2. 4 archivos de mappers en `lib/features/game/data/models/mappers/` con conversión bidireccional.
  3. 5 archivos de tests en `test/data/models/` con 27 tests totales usando patrón AAA (19 tests de mappers + 8 tests de round-trip JSON).
- **Modificaciones del equipo:** Se corrigieron imports en los mappers (cambio de imports relativos a package imports para mayor robustez). Se agregaron imports faltantes (`ArrowModel`, `BoardStateModel`) en los archivos de tests. Se corrigió un cast inseguro en `ArrowMapper.toModel` agregando validación explícita con `ArgumentError`. Se documentó que `LevelMapper` es lossy y que `AppProgressMapper` usa `currentToken` como workaround temporal.
- **Verificación:** 27/27 tests pasando. Los mappers están listos para ser consumidos por los repositorios de la Capa de Datos.
- **Lecciones / limitaciones:** Los package imports (`package:arrowconmango_front/features/...`) son más robustos que los imports relativos en proyectos Flutter con estructuras de carpetas profundas.

### Entrada #20 — Implementación de Hive Repositories (Issue #2)

- **Fecha / autor:** 24-06-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: Qwen 3.7 Max + sub-agent sdd-apply)
- **Rol en el flujo:** Desarrollador Senior en Dart (Capa de Datos — Repositorios de Persistencia).
- **Tarea/problema:** Los contratos de repositorio del dominio (`ILevelRepository` e `IProgressRepository`) necesitaban implementación concreta usando Hive para persistencia local. Sin esto, los casos de uso no pueden cargar niveles ni guardar progreso del jugador.
- **Prompt (paráfrasis fiel):** > "Implementa `HiveLevelRepository` y `HiveProgressRepository` que implementen los contratos del dominio. Crea TypeAdapters manuales para los 5 modelos (NodeModel, ArrowModel, BoardStateModel, LevelModel, AppProgressModel) con typeIds 0-4. Agrega configuración de Hive en `lib/core/database/hive_config.dart`. Usa `Box<T>` inyectado por constructor para testabilidad. Incluye 8 tests unitarios con boxes mock."
- **Resultado obtenido:**
  1. `lib/core/database/hive_config.dart` — Inicialización de Hive, registro de adapters, apertura de boxes.
  2. 5 TypeAdapters manuales en `lib/features/game/data/models/adapters/` (typeIds 0-4).
  3. `HiveLevelRepository` implementando `ILevelRepository` con `Box<LevelModel>`.
  4. `HiveProgressRepository` implementando `IProgressRepository` con `Box<AppProgressModel>`.
  5. 8 tests unitarios en `test/data/repositories/` usando boxes fake.
- **Modificaciones del equipo:** Se agregó `dependency_overrides: analyzer: ^12.0.0` en `pubspec.yaml` para resolver conflicto entre `hive_generator` (requiere analyzer <7.0.0) y Flutter 3.44+ (requiere analyzer ^12.0.0). Los TypeAdapters se escribieron manualmente en lugar de usar `build_runner` por esta incompatibilidad. Posteriormente, se aplicaron 10 correcciones basadas en revisión de Copilot: (1) bug de compilación en test (`lengthOverride` → `_lengthOverride`), (2) guards con `isAdapterRegistered` para prevenir crashes en hot restart, (3-7) cambio de `on Exception catch (e)` a `catch (e)` para consistencia con use cases, (8) remoción de dependencias fantasma (`hive_generator`, `build_runner`, `dependency_overrides`), (9-10) alineación de nombres de tests con convención `should_[expected]_when_[condition]`.
- **Verificación:** 103/103 tests pasando (95 existentes + 8 nuevos). `flutter analyze` sin errores.
- **Lecciones / limitaciones:** `hive_generator` no es compatible con versiones recientes de `analyzer`. Los adapters manuales son una alternativa válida que además evita modificar los modelos de Issue #1. Cuando `hive_generator` actualice sus constraints, se puede migrar a adapters generados. Las revisiones automáticas de Copilot detectaron bugs de compilación y problemas de consistencia que mejoraron la calidad del código.

### Entrada #21 — Level Definitions v2: BoardSizeModel, TrajectorySegment length≥0, 15 niveles portados

- **Fecha / autor:** 08-07-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: big-pickle)
- **Rol en el flujo:** Desarrollador Senior en Dart (Capa de Datos — Modelos, Mappers y Definiciones de Niveles).
- **Tarea/problema:** Los 15 niveles existentes estaban en un formato antiguo (`nodes` + `direction`) que quedó obsoleto tras la introducción del modelo `ArrowTrajectory` con multi-segmento. Además, el `Level` entity no contenía información del tamaño del tablero, y `TrajectorySegment` rechazaba `length: 0` (imposibilitando flechas de un solo nodo). Se necesitaba portear todos los niveles al nuevo formato, agregar `BoardSizeModel` al modelo de datos, y relajar la validación de trayectorias.
- **Prompt (paráfrasis fiel):** > "Necesitamos portear los 15 niveles del branch `feat/level-definitions` al nuevo formato ArrowModel con ArrowTrajectory. Creá un helper compartido `arrowHelper(id, dir, cells)` que convierta `List<List<int>>` a `NodeModel` + `List<TrajectorySegment>`. Agregá `BoardSizeModel(rows, cols)` con adapter Hive (typeId 8). Modificá `TrajectorySegment` para que `length` pueda ser 0. Modificá `ArrowMapper.toModel` para soportar entidades con un solo nodo. Agregá `boardSize` a `LevelModel` y `rows`/`cols` a la entidad `Level`. Creá los archivos `easy_levels.dart`, `medium_levels.dart`, `hard_levels.dart` y `level_definitions.dart` con los 15 niveles. Actualizá todos los tests existentes. Creá `docs/level_design_rules.md` documentando las reglas estructurales."
- **Resultado obtenido:**
  1. `lib/features/game/data/models/board_size_model.dart` + `board_size_model_adapter.dart` — Nuevo modelo con Hive adapter (typeId 8).
  2. `TrajectorySegment` — Assert relajado de `>=1` a `>=0`; validación en `fromJson` usa `length < 0`.
  3. `ArrowMapper.toModel` — Soporte para entidades single-node (produce `TrajectorySegment` con `length: 0`).
  4. `LevelModel` — Nuevo campo `boardSize: BoardSizeModel` con serialización y adapter Hive.
  5. `Level` entity — Nuevos campos `rows: int` y `cols: int`.
  6. `LevelMapper` — Round-trip de `boardSize` ↔ `rows`/`cols`.
  7. `HiveConfig` — Registro de `BoardSizeModelAdapter`.
  8. `arrow_helper.dart` — Función `arrowHelper(id, direction, cells)` compartida.
  9. 15 niveles portados al nuevo formato en `easy_levels.dart` (5), `medium_levels.dart` (5), `hard_levels.dart` (5).
  10. `level_definitions.dart` — Aggregator con `allLevels`, `easyLevels`, `mediumLevels`, `hardLevels`, `getById()`.
  11. `test/data/level_definitions_test.dart` — 15 tests de validación estructural (counts, bounds, unicidad, JSON round-trip, domain mapping, budgets).
  12. `docs/level_design_rules.md` — Documentación completa de reglas de diseño de niveles.
  13. Corrección de 9 errores de compilación en archivos existentes que usaban `Level()` sin `rows`/`cols` y `GamePlaying()` sin `rows`/`cols`.
  14. Corrección de 2 tests en `arrow_mapper_test.dart` que esperaban errores para single-node arrows (ahora verifican el nuevo comportamiento).
- **Modificaciones del equipo:** Se agregaron defaults `rows: 8, cols: 8` a `GamePlaying` para minimizar el blast radius de los cambios en tests existentes. Se debuguearon y corrigieron test failures de `arrow_mapper_test.dart` que habían quedado del cambio de validación de single-node.
- **Verificación:** `flutter analyze` sin errores. `flutter test` da todos verdes (195+ tests pasando).
- **Lecciones / limitaciones:** Cambiar un modelo base como `Level` (agregar campos required) tiene efecto dominó en toda la base de código — 14 archivos modificados + tests. Usar defaults en estados de presentación (`GamePlaying.rows`/`cols`) reduce la cantidad de cambios necesarios en tests unitarios que no dependen del board size.

### Entrada #22 — Arquitectura de Leaderboard (Guest-First) y Actualización de ROADMAP

- **Fecha / autor:** 10-07-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: gemini-3.1-pro-preview)
- **Rol en el flujo:** Product Manager / Arquitecto de Software
- **Tarea/problema:** El equipo sugirió añadir un Leaderboard y Login para registrar puntuaciones. Había preocupación genuina sobre la fricción que genera un muro de login en un juego casual de puzzles. Además, se necesitaba reorganizar el `ROADMAP.md` para incorporar al usuario `@hetairoii` como responsable exclusivo de la capa de Presentación/UI.
- **Prompt (paráfrasis fiel):** > "Mis compañeros dicen que faltó incluir pantallas de leaderboard y login. El login no me convence para este tipo de juego, pero entiendo que es necesario para las puntuaciones. Analiza qué opinas. Luego, a mi equipo le gustó el enfoque, actualiza el ROADMAP.md para asignar los issues de UI (#4, #5, #12) y el nuevo del leaderboard al usuario hetairoii."
- **Resultado obtenido:** 
  1. Se diseñó y aprobó una arquitectura "Guest-First": juego inmediato con UUID anónimo desde el primer segundo y login social (Google/Apple) opcional y progresivo para vincular cuentas.
  2. Modificación del `ROADMAP.md` para crear la "Persona C" (`@hetairoii`), asignándole ~31 horas de trabajo en las ramas de UI (Menu, Game, Result, Leaderboard).
  3. Se formularon los comandos de la CLI de GitHub (`gh`) para crear el Issue #18 y reasignar los existentes sin fricciones.
- **Modificaciones del equipo:** Se ejecutaron manualmente los comandos de `gh` en Windows, ya que el entorno WSL de OpenCode carece de autenticación HTTP/SSH de GitHub para operar directamente sobre el repositorio remoto.
- **Verificación:** El documento `ROADMAP.md` refleja correctamente la división de tareas en 3 roles (Data, BLoC/UseCases, UI).
- **Lecciones / limitaciones:** Utilizar la IA como *sparring* para debatir UX (User Experience) previene errores graves de producto. Un login forzado aniquila la retención inicial; la solución Guest-First ofreció un compromiso perfecto entre buena retención y los requerimientos técnicos del backend.

### Entrada #23 — UI: Pantallas de Menú + Base de App + Identidad Invitado (Issue #4)

- **Fecha / autor:** 11-07-2026 / hetairoii
- **Herramienta:** Claude Code (Modelo: claude-opus-4-8)
- **Rol en el flujo:** Desarrollador Frontend (capa de Presentación) / Arquitecto de composición
- **Tarea/problema:** Implementar el Issue #4 (Splash, Menú Principal, Selección de Nivel, Ajustes) sobre la app, que aún era el contador demo de Flutter. Como #4 es el punto de entrada, incluye la **base compartida** (tema, routing, DI, arranque de Hive) y una **identidad de invitado** mínima (Guest-First) usada por Ajustes. Se omiten las pantallas de Login/Registro del mockup.
- **Prompt (paráfrasis fiel):** > "Trabajemos el frontend. Analiza los issues 4, 5 y 12 en el repo y la estructura, crea ramas por issue desde develop. El HTML adjunto es la UI deseada (omite el login). Usaremos usuarios Guest-First: UUID + nombre aleatorio, leaderboard opcional, cambio de nombre local. Planea paso a paso siguiendo la documentación del frontend."
- **Resultado obtenido:**
  1. Rama `4-menu-screens` desde `develop`.
  2. **Base:** `core/theme` (paleta y gradientes extraídos del mockup, tipografías Fredoka/Nunito vía `google_fonts`), `core/di/service_locator.dart` (get_it cableando repos → use cases → BLoCs), `core/router` (go_router), `main.dart`/`app.dart` reescritos (init de Hive, `MultiBlocProvider`, `MaterialApp.router`).
  3. **Identidad invitado:** `features/player/` con `GuestPlayer`, generador de UUID v4 + nombre aleatorio (`MangoLoco_99`), `PlayerLocalDataSource` (Hive) tras la interfaz `IPlayerRepository`, y `PlayerCubit` (editar nombre).
  4. **Pantallas #4:** Splash, MainMenu (Jugar/Ranking/Ajustes), LevelSelection (bind a `MenuBloc`), Settings (editar nombre) y un placeholder de Ranking.
  5. **Tests:** 10 pruebas nuevas (generador, persistencia/rename, y widget tests de las 3 pantallas). Suite completa: **217/217 en verde**, `flutter analyze` sin issues. Limpieza `pubspec` (eliminada la dependencia basura `lib`, corregido `description`).
- **Modificaciones del equipo:** (pendiente de revisión por PR). Correcciones aplicadas durante el desarrollo por el propio flujo: ver "Verificación".
- **Verificación:** `flutter analyze` (0 issues), `flutter test` (217/217). Arranque en `web-server`: la consola confirma `main()` ejecutado y Hive abriendo las cajas `levels`, `progress` y `player` sin errores. *Limitación:* el renderer CanvasKit de Flutter Web no permite capturas/lectura de accesibilidad desde el navegador headless, por lo que la verificación visual se apoya en los widget tests.
- **Lecciones / limitaciones:**
  1. **La caja Hive de niveles no se poblaba.** El `HiveLevelRepository` lee de una caja vacía; ningún componente la sembraba desde `LevelDefinitions`. Se añadió el *seeding* en el arranque (si no, el menú aparecería sin niveles). Hallazgo clave que la IA detectó al trazar la cadena DI.
  2. **`testWidgets` + Hive real se cuelga.** El I/O asíncrono de Hive dentro de `testWidgets` provoca timeout; se resolvió introduciendo `IPlayerRepository` + un fake en memoria para los widget tests (y mejor arquitectura de paso).
  3. **`pumpAndSettle` + spinner infinito.** El `CircularProgressIndicator` del estado de carga nunca "asienta"; se conduce el `MenuBloc` a `MenuLoaded` con `tester.runAsync` antes de construir la vista.
  4. **`GridView` es perezoso:** sólo construye las tarjetas visibles, así que las aserciones de conteo exacto (15/12) fallan; se verifican el subtítulo y el mapeo de bloqueo por tarjetas concretas.
  5. **Topología de colisión única para tableros de tamaño variable:** los niveles miden 6×7…12×12 pero el `GameBloc` usa un solo `CollisionValidator`; se dimensiona la topología al máximo (12) para que las trayectorias de salida resuelvan bien en todos.

### Entrada #24 — Rediseño fiel al mockup: Menú, Niveles, Ajustes, Splash (Issue #4)

- **Fecha / autor:** 11-07-2026 / hetairoii
- **Herramienta:** Claude Code (Modelo: claude-opus-4-8 / claude-sonnet-5)
- **Rol en el flujo:** Desarrollador Frontend (capa de Presentación)
- **Tarea/problema:** El primer pase de #4/#5/#12/#36 usaba la paleta y copys correctos pero un layout propio, no fiel al mockup de diseño. El usuario proporcionó el archivo fuente `Arrow con Mango.dc.html` (proyecto Claude Design) con el layout exacto, incluidas animaciones. Había que reconstruir cada pantalla para que fuera 100% fiel, rama por rama, con verificación intermedia antes de avanzar.
- **Prompt (paráfrasis fiel):** > "Tenemos que aplicar el cambio para que sea fiel al mockup en cada rama. Analiza el html y, para cada rama correspondiente, modifica el layout visual para que sea 100% fiel al layout del html, incluyendo las animaciones. Muéstrame una prueba rápida por rama y consúltame antes de proceder con la siguiente."
- **Resultado obtenido:**
  1. Se importó el archivo de diseño vía `DesignSync` (`get_file` sobre el proyecto `abf968f7-...`), extrayendo el HTML/CSS inline exacto de cada pantalla (`data-screen-label`) y las `@keyframes` (`floatMango`, `sparkle`, `confettiFall`, `slideUp`, `popBig`, `mangoPop`).
  2. Se agregó `flutter_svg` para reproducir los gráficos vectoriales del diseño tal cual (logo mango, hojas, íconos de botones).
  3. Nuevos widgets base reutilizables: `core/widgets/mango_logo.dart` (`MangoLogo` + `FloatingMango`, animación de flotación + destellos fieles a `floatMango`/`sparkle`) y `core/widgets/app_svgs.dart` (íconos SVG copiados del diseño: trofeo, ranking, ajustes, chevron, candado, mini-mango).
  4. **Menú principal:** header verde con borde curvo elíptico y hojas tenues, logo flotante, título de dos líneas (Fredoka 44/50), botón "¡ JUGAR !" con gradiente y sombra 3D, 3 botones de navegación con sus colores/sombras exactos del diseño, page-dots.
  5. **Selección de nivel:** header verde con "N de 15 disponibles", grid 3-col con los 3 estados exactos de tile (completado con gradiente mango-naranja + mini-mangos, desbloqueado con dificultad, bloqueado con candado y opacity 0.6), colores/sombras extraídos literalmente del script del diseño (`bg`/`shadow` ternarios).
  6. **Ajustes/Splash:** sin pantalla propia en el mockup; se mantuvieron consistentes con el sistema visual ya extraído (header verde, tarjetas, logo flotante).
  7. **Tests:** actualizados 2 (menú: nuevo copy de dos líneas y botones; niveles: candado con etiqueta "Nivel N" en vez de icono suelto). Suite completa: **217/217**, `analyze` limpio.
- **Modificaciones del equipo:** el usuario aprobó el rediseño de #4 tras revisarlo en vivo (build web servido localmente) antes de continuar con #5.
- **Verificación:** `flutter analyze` (0), `flutter test` (217/217 incluyendo los 2 actualizados). Build `--release` servido localmente; rutas `/menu`, `/levels`, `/settings` cargadas sin errores de consola.
- **Lecciones / limitaciones:**
  1. **El archivo `.dc.html` es la fuente de verdad real**, no el bundle React empaquetado: contiene el layout/CSS inline exacto y las animaciones declaradas, mientras que el bundle sólo se podía leer como texto (sin poder renderizarlo/compararlo visualmente desde el navegador headless disponible).
  2. **Extraer colores desde JS embebido requiere grep dirigido**: los ternarios `bg:`/`shadow:` de los tiles de nivel y filas del leaderboard sólo aparecen completos con suficiente contexto alrededor del match; hicieron falta varias pasadas de grep con ventanas de contexto crecientes para no perder literales partidos en el JSON del `.dc.html`.
  3. **Verificación de fidelidad visual sin capturas de pantalla:** ante la imposibilidad de comparar pixel a pixel, se usó una combinación de (a) build real corriendo en vivo para revisión humana, (b) consola sin errores por ruta, y (c) widget tests que verifican los textos/estructura exactos del nuevo layout.

### Entrada #25 — UI: Pantalla de Juego (tablero, flechas, controles, timer) (Issue #5)

- **Fecha / autor:** 11-07-2026 / hetairoii
- **Herramienta:** Claude Code (Modelo: claude-opus-4-8)
- **Rol en el flujo:** Desarrollador Frontend (capa de Presentación)
- **Tarea/problema:** Implementar el Issue #5 sobre la base de #4: renderizar el tablero desde `GamePlaying`, dibujar las flechas sobre sus celdas ocupadas, permitir sacarlas con un toque, controles (deshacer/reiniciar), HUD (nivel, flechas, toques, tiempo) y navegar a las pantallas de resultado en victoria/derrota.
- **Prompt (paráfrasis fiel):** > "Continuemos con el issue #5 (Game Screen) ya, ramificando desde la rama local de #4."
- **Resultado obtenido:**
  1. Rama `5-game-screen` desde `4-menu-screens`.
  2. Widgets: `board_grid_widget.dart` (grid `rows×cols`, posiciona cada flecha por su *bounding box* de nodos), `arrow_widget.dart` (cuerpo redondeado + chevron según dirección), `game_controls_widget.dart` (deshacer/reiniciar), y `animations/arrow_exit_animation.dart` (deslizamiento+desvanecido al salir).
  3. `game_screen.dart`: enlaza `GameBloc`, despacha `LoadLevel`, **bombea `Tick` cada segundo** (el BLoC no tiene reloj), HUD, y `BlocConsumer` que navega a `/victory` `/defeat` en `GameVictory`/`GameDefeat`. La animación de salida se dispara *diffando* el tablero previo vs actual.
  4. Se cableó la ruta `/game/:levelId` a la pantalla real (antes placeholder).
  5. **Tests:** 7 nuevos (board, controles, animación con avance de reloj, y game screen con `MockBloc`/`mocktail`). Suite: **224/224**, `analyze` limpio. Se agregó `mocktail` a dev_dependencies.
- **Modificaciones del equipo:** (pendiente de revisión por PR).
- **Verificación:** `flutter analyze` (0), `flutter test` (224/224). Smoke en `web-server` navegando a `/#/game/1`: consola sin errores; el `GameBloc` real cargó el nivel sembrado y renderizó `GamePlaying` (valida seeding + repos + topología + render end-to-end).
- **Lecciones / limitaciones:**
  1. **`MockBloc` (bloc_test/mocktail)** es la vía limpia para widget-testear una pantalla ligada a un BLoC sin construir todo el grafo de casos de uso.
  2. **Timers en `testWidgets`:** el `Timer.periodic` del `Tick` queda pendiente; se dispone la pantalla (`pumpWidget(SizedBox())`) al final del test para cancelarlo y evitar el fallo por "pending timer".
  3. **Golden tests omitidos a propósito:** generar baselines en Windows rompería el CI de Linux (render de fuentes distinto); se cubre el comportamiento con widget/animation tests y se deja el golden para generarse en el entorno de CI.
  4. **Último movimiento sin animación:** al sacar la última flecha el BLoC emite `GameVictory` directo (sin `GamePlaying` vacío), así que esa salida no se anima; la pantalla de victoria toma el relevo.

### Entrada #26 — Rediseño fiel al mockup: Pantalla de Juego (Issue #5)

- **Fecha / autor:** 11-07-2026 / hetairoii
- **Herramienta:** Claude Code (Modelo: claude-sonnet-5)
- **Rol en el flujo:** Desarrollador Frontend (capa de Presentación)
- **Tarea/problema:** Continuar el rediseño fiel al `.dc.html` (tras la aprobación de #4) sobre la pantalla de Juego: header, HUD, tablero y controles debían replicar el layout exacto del diseño, no la versión funcional-pero-genérica del primer pase.
- **Prompt (paráfrasis fiel):** > "Está bien esa extensión [del botón Deshacer]. Ahora continúa con lo demás." (confirmación tras revisar #4 y antes de esto: "aplica el rediseño fiel en cada rama, muéstrame prueba por rama, consúltame antes de seguir").
- **Resultado obtenido:**
  1. Rebase de `5-game-screen` sobre `4-menu-screens` actualizada (heredó el rediseño de #4); único conflicto en la numeración de `AI_USAGE.MD`, resuelto renumerando.
  2. `board_grid_widget.dart`: marco de madera oscura exacto (`#6D4C2A`, radio 22, padding 9, sombra `0 8px 28px rgba(109,76,42,.32)`), superficie con patrón de puntos vía `CustomPainter`, paleta de flechas en el orden exacto del diseño.
  3. `arrow_widget.dart`: sombra plana sin blur (`0 3px 0 rgba(0,0,0,.28)`) igual al diseño.
  4. Nuevos íconos SVG en `app_svgs.dart` (home, restart, flechas, toques, timer, undo) copiados del `.dc.html`.
  5. `game_screen.dart` reescrito: header con gradiente naranja exacto y botones home/reiniciar (el diseño no separa un control de "Reiniciar" del header), 3 chips de estadística translúcidos, texto de instrucción copiado literal.
  6. `game_controls_widget.dart` simplificado a solo "Deshacer" (Reiniciar quedó en el header, fiel al diseño). El mockup **no tiene botón de Deshacer**; se agregó como chip discreto y consistente, solo visible con movimientos deshacibles — extensión explícitamente consultada y aprobada por el usuario.
  7. **Bug real encontrado y corregido:** al anidar el header en una `Column`, el tablero perdió el `Expanded` que antes lo acotaba verticalmente; el `AspectRatio` intentaba crecer sin límite → `RenderFlex overflowed by 389 pixels`. Se corrigió envolviendo el tablero en `Expanded(child: Center(...))` dentro de la columna interna.
  8. **Tests:** actualizados 2 (`game_screen_test.dart` con los nuevos textos separados del HUD; `game_controls_widget_test.dart` sin el botón de reiniciar). Suite completa: **224/224**, `analyze` limpio.
- **Modificaciones del equipo:** el usuario aprobó explícitamente la extensión del botón Deshacer (ausente en el diseño original) tras revisarla en vivo.
- **Verificación:** `flutter analyze` (0), `flutter test` (224/224). Build `--release` servido localmente; `/game/1` y `/game/6` (tableros de distinto tamaño) cargados sin errores de consola.
- **Lecciones / limitaciones:**
  1. **Reestructurar un `Column` para insertar un header rompe silenciosamente las restricciones de tamaño heredadas** de widgets internos (`Expanded`, `AspectRatio`): hay que re-verificar explícitamente que cada elemento que dependía de una restricción de altura acotada la siga recibiendo tras anidar.
  2. **Clasificador de seguridad de comandos con caída temporal (~11 min) en esta sesión:** durante ese lapso se hizo únicamente revisión manual de código (imports, referencias a constantes existentes) sin poder compilar/testear; al recuperarse, esa revisión manual no detectó el bug de layout (solo visible en tiempo de ejecución), confirmando que la revisión estática no sustituye correr los tests.

### Entrada #27 — Flechas "serpiente" con CustomPainter + niveles resolubles por construcción (Issue #5)

- **Fecha / autor:** 11-07-2026 / hetairoii
- **Herramienta:** Claude Code (Modelo: claude-sonnet-5)
- **Rol en el flujo:** Desarrollador Frontend (capa de Presentación) / Autoría de contenido (niveles)
- **Tarea/problema:** Tras jugar en vivo, el usuario reportó 3 problemas: (1) las flechas se veían como píldoras/cilindros, no como flechas delgadas tipo "serpiente" del juego de referencia; (2) el juego se quedaba sin movimientos tras 1-2 toques; (3) el tablero pegado al header y demasiado grande en desktop. Se investigó primero con un agente Explore + un agente Plan antes de tocar código.
- **Prompt (paráfrasis fiel):** > "dejaron de tener forma de flecha (--->) y ahora tienen forma de cilindro... después de mover una flecha se me acaban los movimientos... el tablero está muy cerca del tope... quisiera que se viese... con flechas más delgadas y manteniendo esa animación de movimiento de serpiente cuando salen las flechas."
- **Diagnóstico (verificado a mano, no asumido):** el problema de "sin movimientos" **no era un bug del motor de colisión** — la topología compartida 12×12 (mayor que cualquier tablero real) solo agrega celdas fantasma vacías, nunca crea bloqueos falsos. La causa real: **el nivel 1 original era matemáticamente irresoluble** (10 de sus 12 flechas se bloqueaban mutuamente para siempre; solo 2 podían salir, y tras esas dos `_hasAvailableMoves` legítimamente devolvía `false`).
- **Resultado obtenido:**
  1. **Geometría pura** (`painting/arrow_geometry.dart`): polilínea por centros de celda (tail→head, soporta giros de 90°), cabeza en V, stub para flechas de 1 celda (evita `Path` degenerado que rompe `computeMetrics()`), cálculo de celdas de salida hasta pasar el borde.
  2. **Dos `CustomPainter`s**: `ArrowsLayerPainter` (todas las flechas vivas en una sola pasada, trazo delgado `stroke-width = cell·0.36` + sombra plana) y `ArrowExitPainter` (la "serpiente": ventana deslizante de longitud constante sobre `PathMetrics` del camino completo — cuerpo + extensión recta de salida — equivalente al `stroke-dashoffset` del diseño; sigue los giros de las flechas dobladas).
  3. **Hit-test exacto por celda** en `board_grid_widget.dart` (reemplaza el hit-test por bounding-box, que fallaba con flechas dobladas cuyo rectángulo tapa otras flechas): un solo `GestureDetector` en el tablero mapea el tap a `(row,col)` y busca qué flecha ocupa esa celda.
  4. **`ArrowColorAssigner`**: colores estables por id de flecha (primera vez vista = orden inicial del nivel), arregla un glitch preexistente donde los colores cambiaban al salir una flecha (antes se coloreaba por índice en la lista viva).
  5. **`LevelGenerator`** (`level_generator.dart`): generador determinista **provably-solvable por construcción** — cada flecha candidata solo se acepta si su cuerpo y su trayectoria de salida completa están libres en el momento de insertarla; por lo tanto deshacer las inserciones en orden inverso es siempre una solución válida (la regla de salida es monótona: quitar una flecha nunca bloquea a otra). Se regeneraron los **15 niveles** (9×12, flechas delgadas con giros en L), con los ids 1/6/11 llevando los nombres del diseño (Mango Verde/Pulpa Dulce/Piel Dorada).
  6. **Test de resolubilidad** (`test/data/level_solvability_test.dart`): drena cada uno de los 15 niveles con un algoritmo codicioso (sacar cualquier flecha con salida libre, repetir) y verifica que el tablero se vacía por completo — decide resolubilidad de forma exacta dado que la mecánica es monótona.
  7. **Nombre de nivel end-to-end**: `Level.name` (antes se perdía en el mapeo) → `GamePlaying.levelName` (parámetro opcional, no rompe tests de bloc existentes) → título del header. Dificultad traducida al español en el subtítulo.
  8. **Layout**: tablero acotado a `maxWidth: 400` y centrado, ya no pegado al header en pantallas grandes.
  9. Se eliminó `arrow_widget.dart` (píldora + chevron) y los 3 archivos de niveles hand-authored del equipo (`easy/medium/hard_levels.dart`), reemplazados por el generador.
  10. **Tests:** 4 archivos actualizados (board, screen, animación de salida) + 3 nuevos (geometría de flechas, color assigner, resolubilidad — 15 tests). Suite completa: **252/252**, `analyze` limpio.
- **Modificaciones del equipo:** el usuario aprobó el rediseño de flechas tras revisarlo en vivo; se le señaló explícitamente la desviación de "portar los 3 niveles del diseño" a "regenerar los 15 en el mismo estilo" (los puzzles exactos del `.dc.html` no estaban garantizados resolubles bajo nuestra regla de salida).
- **Verificación:** `flutter analyze` (0), `flutter test` (252/252, incluyendo 15/15 niveles resolubles por drenado codicioso). Build `--release` corrido en Chrome real para revisión del usuario.
- **Lecciones / limitaciones:**
  1. **No asumir que un reporte de "bug" es un bug de motor**: se verificó a mano contra `CollisionValidator`/`Grid2DTopology` antes de tocar código, y se confirmó que el problema era de *contenido* (datos de nivel), no de *lógica*. Cambiar la lógica hubiera sido el fix equivocado.
  2. **Generación de contenido "correcto por construcción" > prueba y error manual**: en vez de diseñar 15 tableros a mano y validarlos uno por uno, se diseñó una regla de inserción que garantiza resolubilidad matemáticamente, y un test que lo verifica automáticamente para cualquier futura regeneración.
  3. **`Path.computeMetrics()` en paths degenerados**: un `Path` con un solo `moveTo` (sin `lineTo`) produce métricas vacías y `.first` lanza `StateError`; las flechas de 1 celda necesitan un stub explícito de 2 puntos.
  4. **Hit-testing por bounding box es incorrecto para formas no rectangulares**: con flechas dobladas, la caja de una flecha en L puede cubrir celdas de otra flecha recta; el hit-test debe resolverse por ocupación de celda real, no por intersección de rectángulos.

### Entrada #28 — UI: Pantallas de Resultado (Victoria / Derrota) (Issue #12)

- **Fecha / autor:** 11-07-2026 / hetairoii
- **Herramienta:** Claude Code (Modelo: claude-opus-4-8)
- **Rol en el flujo:** Desarrollador Frontend (capa de Presentación)
- **Tarea/problema:** Implementar el Issue #12: pantallas de victoria (puntaje en "Mangos", toques, tiempo, siguiente nivel, celebración) y derrota (motivo, reintentar), leyendo el estado `GameVictory`/`GameDefeat` que la Game Screen pasa por navegación.
- **Prompt (paráfrasis fiel):** > (continuación de "procede con la implementación del plan"): completar las 3 pantallas de UI (#4, #5, #12) siguiendo el mockup y el enfoque Guest-First.
- **Resultado obtenido:**
  1. Rama `12-result-screens` desde `5-game-screen`.
  2. `victory_screen.dart`: lee `GameVictory` (por `GoRouterState.extra`), muestra Mangos/Toques/Tiempo, botón "Siguiente nivel" (oculto en el último nivel vía `AppInfo.totalLevels`) y "Menú", **persiste el desbloqueo** despachando `ProgressLevelCompleted` al `ProgressBloc` global en un post-frame; celebración con `confetti`.
  3. `defeat_screen.dart`: mensaje según `DefeatReason` (tiempo/sin movimientos), Toques/Tiempo, "Reintentar" y "Menú".
  4. Widgets compartidos `result_stat.dart` + `animations/victory_animation.dart`. Se cablearon las rutas `/victory` y `/defeat` a las pantallas reales (leyendo `extra`, con *fallback* si falta).
  5. **Tests:** 4 nuevos (victoria: puntaje + verify de `ProgressLevelCompleted` + ocultar "Siguiente" en el último nivel; derrota: ambos motivos). Suite: **228/228**, `analyze` limpio. Se agregó `confetti` a dependencias.
- **Modificaciones del equipo:** (pendiente de revisión por PR).
- **Verificación:** `flutter analyze` (0), `flutter test` (228/228).
- **Lecciones / limitaciones:**
  1. **Paso de datos entre pantallas con go_router:** el resultado se pasa por `extra` (objeto tipado `GameVictory`/`GameDefeat`); las rutas validan el tipo y muestran un *fallback* si se navega sin datos (p. ej. recarga directa).
  2. **`confetti` + tests:** la animación deja timers activos; se dispone la pantalla al final del test para evitar "pending timer", y se usa `pump()` acotado (no `pumpAndSettle`).
  3. **Persistencia del desbloqueo en `initState`:** se despacha `ProgressLevelCompleted` en un `addPostFrameCallback` para no leer el BLoC durante el build.

### Entrada #29 — Rediseño fiel al mockup: Diálogo de Victoria/Derrota + fix de nivel 1 bloqueado (Issue #12)

- **Fecha / autor:** 11-07-2026 / hetairoii
- **Herramienta:** Claude Code (Modelo: claude-sonnet-5)
- **Rol en el flujo:** Desarrollador Frontend (capa de Presentación)
- **Tarea/problema:** Continuar el rediseño fiel al `.dc.html` en la rama de Resultados: el diseño modela la victoria como un **bottom sheet** ("Dialogo Enhorabuena") sobre un fondo oscurecido, con confetti, rating de 1-3 mangos y animaciones (`slideUp`, `popBig`, `mangoPop`, `confettiFall`), no como una pantalla completa genérica. Además, al revisar en vivo, el usuario reportó que no había niveles disponibles para jugar.
- **Prompt (paráfrasis fiel):** > "Todo bien, aunque no veo los niveles disponibles para poder probar el juego. Recuerda que los niveles deben verse como la UI que pase por referencia, agrega los niveles." → luego, tras el fix: "Mejor, ahora pasa al issue 36."
- **Resultado obtenido (rediseño):**
  1. `result_sheet.dart` nuevo: chrome compartido (fondo oscuro + hoja deslizante `slideUp` + barra de arrastre) y `ConfettiRain` (reemplaza el paquete `confetti` por un `CustomPainter` propio, 46 partículas con las fórmulas exactas de posición/color/delay/duración del diseño). Se quitó la dependencia `confetti` y se borró `victory_animation.dart` (ya sin uso).
  2. `mango_rating.dart`: mapea `Score.totalPoints` a un rating de 1-3 mangos y su mensaje, replicando los umbrales/textos del diseño (adaptación: el diseño calcula el rating de datos internos que nuestro dominio no expone a la UI en el momento de victoria).
  3. `mango_slots.dart`: 3 íconos de mango (el del medio más grande), animación `popBig`/`mangoPop` escalonada, escala de grises para los no ganados.
  4. `result_stat.dart` reescrito: tarjeta de stats con divisores verticales entre celdas (sin íconos), fiel al diseño.
  5. `victory_screen.dart` y `defeat_screen.dart` reescritos sobre `ResultSheet`; botones con la sombra 3D plana exacta (`0 5px 0 #A83800`). El diseño **no tiene pantalla de derrota**; se reutilizó el mismo chrome visual con contenido propio (ícono, motivo, Reintentar) — deviación explícitamente señalada y aprobada.
  6. **Tests:** actualizados para el nuevo layout (mismos textos, se agregó disposición de la pantalla al final para cancelar los tickers de `ResultSheet`). Suite: **228/228** en este punto.
- **Resultado obtenido (bug fix):** al revisar en vivo, ningún nivel aparecía desbloqueado — `AppProgress()` por defecto trae `unlockedLevels: []`, y nada sembraba el nivel 1 como desbloqueado en el primer arranque, dejando al jugador sin forma de empezar.
  1. Nueva función pública y testeable `seedProgressIfEmpty()` en `lib/core/di/progress_seed.dart`: si la caja de progreso está vacía (primer arranque), guarda `AppProgressModel(currentLevel: 1, completedLevels: [1])`.
  2. Se expuso `HiveProgressRepository.progressKey` (antes privada) para reutilizar la clave sin duplicar el string mágico.
  3. Llamada desde `setupServiceLocator()`, junto al resto del *seeding* (niveles, identidad invitado).
  4. **Tests:** 2 nuevos (`progress_seed_test.dart`): siembra en caja vacía; no pisa el progreso real de un jugador que regresa. Suite final: **230/230**.
- **Modificaciones del equipo:** el usuario aprobó el rediseño y reportó el bug de niveles bloqueados al probarlo en vivo; tras el fix confirmó "mejor" y autorizó continuar con el issue #36.
- **Verificación:** `flutter analyze` (0), `flutter test` (230/230). Boot en Chrome real sin errores de consola; se intentó verificar el valor sembrado leyendo IndexedDB directamente vía `javascript_tool`, pero Hive codifica los registros en un formato binario propio no legible como JSON plano desde fuera del código Dart — la verificación final quedó en manos del usuario probando la app real.
- **Lecciones / limitaciones:**
  1. **Los datos por defecto de una entidad de dominio (`AppProgress()` vacío) pueden dejar el producto inutilizable en el primer arranque** si nadie los siembra explícitamente; los tests unitarios que fabrican estados `MenuLoaded`/`AppProgress` a mano no detectan esto porque nunca ejercitan el camino real "caja Hive vacía → `loadProgress()` → UI".
  2. **No toda verificación necesita reproducir la app**: extraer una función privada de *seeding* a un archivo público y testeable (`progress_seed.dart`) permitió cubrir el fix con tests unitarios rápidos en vez de depender solo de QA manual.
  3. **IndexedDB + Hive no es introspeccionable desde JS externo sin el codec de Hive**: para depurar estado persistido en Flutter Web hay que confiar en logs de la propia app o en tests, no en leer la base cruda del navegador.

### Entrada #30 — UI: Leaderboard Global (Guest-First) (Issue #36)

- **Fecha / autor:** 11-07-2026 / hetairoii
- **Herramienta:** Claude Code (Modelo: claude-opus-4-8)
- **Rol en el flujo:** Desarrollador Frontend (capa de Presentación)
- **Tarea/problema:** Implementar el Issue #36: pantalla de clasificación global "Guest-First" — ranking con el invitado anónimo resaltado y un botón opcional de vincular cuenta (Google/Apple). Datos mock por ahora (sin backend).
- **Prompt (paráfrasis fiel):** > "Existe ahora el issue #36 dedicado al leaderboard. Con base en la interfaz de leaderboard que ya definimos, resuélvelo en una rama nueva; y demuéstrame en vivo que la app funciona con la UI de cada issue."
- **Resultado obtenido:**
  1. Rama `36-leaderboard-guest-first` desde `12-result-screens`.
  2. Feature `leaderboard/`: `LeaderboardEntry` (dominio), `ILeaderboardRepository` + `MockLeaderboardRepository` (10 cosechadores fijos + el invitado fusionado y ordenado por mangos), `LeaderboardCubit` (+ estados) y `leaderboard_screen.dart` (lista con avatar/inicial, resaltado "(Tú)", botón "Vincular cuenta").
  3. DI: registrados `ILeaderboardRepository` (mock) y `LeaderboardCubit`. Ruta `/ranking` conectada a la pantalla real (se eliminó el placeholder del menú).
  4. El botón de login social es un **stub** (SnackBar "próximamente"): no se ejecuta OAuth real.
  5. **Tests:** 4 nuevos (repo mock: fusión/orden/rango/límite; pantalla: render + resaltado del invitado + snackbar). Suite: **232/232**, `analyze` limpio. Sin dependencias nuevas.
- **Modificaciones del equipo:** (pendiente de revisión por PR).
- **Verificación:** `flutter analyze` (0), `flutter test` (232/232); demo en vivo (build web release).
- **Lecciones / limitaciones:**
  1. **Carrera con `stream.firstWhere` en tests:** cuando el `load()` (mock rápido) completa antes de suscribirse al stream, `firstWhere` no ve el estado y el test cuelga hasta el timeout de 10 min. Solución: `MockCubit` (bloc_test/mocktail) con estado `LeaderboardLoaded` fijo — determinista, sin async.
  2. **`ListView` perezoso en tests:** para verificar una fila fuera de pantalla se usa un viewport alto (`tester.view.physicalSize`) en vez de `scrollUntilVisible` (que puede colgar).
  3. **SnackBar deja un timer pendiente:** se avanza el reloj (`pump(5s)`) para que se auto-cierre y no falle el test por "pending timer".
  4. **Guest-First real:** el leaderboard funciona desde el primer segundo con el UUID anónimo; el backend (`GET /leaderboard`) puede implementar la misma interfaz sin tocar la UI.

### Entrada #31 — Rediseño fiel al mockup: Leaderboard con podio (Issue #36)

- **Fecha / autor:** 11-07-2026 / hetairoii
- **Herramienta:** Claude Code (Modelo: claude-opus-4-8)
- **Rol en el flujo:** Desarrollador Frontend (capa de Presentación)
- **Tarea/problema:** Rediseñar la pantalla de Leaderboard fiel al `.dc.html`: el diseño la modela con un **header verde con podio de los top-3** (1° al centro, más grande y con aro dorado; 2° y 3° a los lados con barras más bajas) seguido de una lista de los ranks 4+; la primera versión era una lista plana genérica.
- **Prompt (paráfrasis fiel):** > (continuación del rediseño rama por rama) "aplica el rediseño fiel en cada rama… pasa al issue 36".
- **Resultado obtenido:**
  1. `leaderboard_screen.dart` reescrito: header verde (radio 30) con back, título "Clasificación", subtítulo, trofeo dorado; **podio** ordenado 2°-1°-3° con avatares/aros/barras de tamaños exactos del diseño; lista inferior de ranks 4+ con avatar de color, nombre + subtítulo ("N niveles"), chip de mangos, y la fila del invitado resaltada (borde/sombra naranja). El botón de vincular cuenta (que el diseño NO tiene en ninguna pantalla, pero el issue #36 pide) se degradó a un link de texto discreto.
  2. `mock_leaderboard_repository.dart`: los **8 jugadores exactos del diseño** (MangoMaster, Luisa_G, PulpaFan, Karo22, DulceVerde, ElHuertero, Flechita + el invitado) con sus colores.
  3. Nuevos SVG `trophyFilled` y `mangoDot` en `app_svgs.dart`.
  4. **Tests:** actualizados (podio + resaltado del invitado en la lista + snackbar). Suite: **234/234**, `analyze` limpio. Sin dependencias nuevas.
- **Modificaciones del equipo:** el usuario aprobó el rediseño en vivo.
- **Verificación:** `flutter analyze` (0), `flutter test` (234/234); `/ranking` en build release sin errores de consola.
- **Lecciones / limitaciones:**
  1. **Casi contamino el dominio (otra vez):** al mapear el color por jugador estuve a punto de meter `Color` de Flutter en la entidad `LeaderboardEntry` — exactamente la falla ya documentada en este archivo ("Contaminación del Dominio"). Se guardó como `int` (ARGB, `colorValue`) en el dominio y se convierte a `Color` solo en la capa de presentación.
  2. **El diseño no tiene login social en ninguna pantalla**; la funcionalidad requerida por el issue se añadió como extensión mínima y discreta, no como elemento protagónico.

### Entrada #30 — Planificación de Modo 3D, Dual Game Mode e Integración API

- **Fecha / autor:** 12-07-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: gemini-3.1-pro-preview)
- **Rol en el flujo:** Arquitecto de Software Principal / Product Manager
- **Tarea/problema:** El equipo propuso un plan avanzado para migrar el juego a 3D (grafos dirigidos por capas Z) y conectarlo con un backend NestJS (Guest-First). Simultáneamente, se descubrió que un agente previo había reemplazado los niveles artesanales densos (40-70 flechas con figuras) por un generador procedural infinito de baja densidad (7-18 flechas). Había que conciliar ambos enfoques y aprobar el plan 3D.
- **Prompt (paráfrasis fiel):** > "Revisa el siguiente plan que generó uno de mis compañeros: modo 3D (grafo dirigido) + integración Frontend-Backend. Además, me plantean usar nuestro diseño artesanal para los 15 niveles predeterminados y el generador en otro modo de juego. ¿Qué opinas? Agrega las nuevas issues a github y al roadmap distribuyéndolas en el equipo."
- **Resultado obtenido:** 
  1. Aprobación técnica del plan 3D destacando aciertos clave: uso de `BoardGeometry` (sealed classes) para no romper el 2D, versionado explícito de la caja de Hive (`levels_v2`) y patrón Decorator para fallback offline de red.
  2. Ajustes introducidos por la IA: (a) UX de Fantasmas: rendering semi-transparente de capas Z±1 para evitar confusión visual por bloqueos invisibles; (b) Limpieza explícita del disco en la migración de Hive.
  3. Formulación de la arquitectura "Dual Game Mode": Modo Campaña (15 niveles artesanales restaurados) vs Modo Arcade/Time-Attack (niveles procedurales infinitos).
  4. Redacción de 6 GitHub Issues atómicos (#19 a #24) distribuidos estratégicamente: Backend y Dominio 3D para `AlbertoMonasterio`, Migraciones y Red para `a-granadillo`, y todo el ruteo/UI/Animaciones de Capas para `hetairoii`.
- **Modificaciones del equipo:** Inserción manual de los issues generados vía la CLI de GitHub. 
- **Verificación:** `ROADMAP.md` y `AI_USAGE.MD` actualizados con las nuevas fases de desarrollo.
- **Lecciones / limitaciones:** Combinar generación procedural estricta (matemáticamente 100% resoluble hacia atrás) con tableros pequeños (9x12) genera cuellos de botella geométricos que impiden la alta densidad visual. La solución arquitectónica de "modos de juego duales" maximiza el valor sin desechar código: se preserva la artesanía visual para la campaña y la escalabilidad infinita matemática para un modo arcade.

### Entrada #31 — Implementación del Modo Supervivencia y Sistema de Vidas en Tiempo Real (Issue #24)

- **Fecha / autor:** 13-07-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: gemini-3.5-flash)
- **Rol en el flujo:** Desarrollador Frontend (BLoC, Casos de Uso y UI) / Diseñador de Niveles
- **Tarea/problema:** Traducir las especificaciones de diseño acordadas para el Modo Dual (Campaña artesanal estática vs. Supervivencia procedural infinita) a código de producción. Además, el sistema de vidas requerido ("perder una vida al chocar flechas en tiempo real") no existía: al chocar contra otra flecha se emitía un fallo silencioso sin penalización. Se requería implementar el sistema de vidas por colisión y el flujo de juego infinito con bonus de tiempo (+20s por nivel) y Game Over.
- **Prompt (paráfrasis fiel):** > "Implementa el modo de supervivencia completo: niveles infinitos procedurales, sistema de 3 vidas (al chocar una flecha con otra pierde una vida, si pierde las 3 pierde la partida), tiempo acumulado (+20s al pasar nivel), y que el sistema de vidas por colisión también funcione en el modo campaña."
- **Resultado obtenido:**
  1. **Datos:** Restauración de `easy/medium/hard_levels.dart` (15 figuras estáticas densas). Actualización de `LevelDefinitions` para separar el Modo Campaña (`campaignLevels`) de la generación de Supervivencia (`generateEndless`).
  2. **Generación procedural:** Se creó `LevelConfig` con 3 perfiles de dificultad (Easy 6x6, Medium 8x8, Hard 12x12) variando tamaño, densidad (hasta 60 flechas) y formas avanzadas (U-shape y Z-shape con giros). Se eliminaron las flechas de 1 celda (mínimo 2 celdas).
  3. **BLoC (Reglas de Vidas):** Modificado `GameBloc._onTriggerArrowExit` para que al capturar `PathBlockedFailure` (colisión de flechas), reste una vida local, actualice el estado `GamePlaying` y, si llega a 0, emita `GameDefeat` con el nuevo motivo `DefeatReason.outOfLives`.
  4. **UI por Modo:** `game_screen.dart` muestra `_LivesIndicator` (corazones ❤️/🖤) y alterna el timer según el modo (transcurrido en campaña, tiempo restante en supervivencia). `victory_screen.dart` y `defeat_screen.dart` actualizados con estadísticas específicas (niveles completados, vidas restantes, reintento sin romper el BLoC ni depender de un context fuera de scope).
- **Modificaciones del equipo:** Se detectaron y corrigieron errores de importación (mismatch entre `levels` y `all` en las clases de niveles) y firmas obsoletas en los tests de `LoadLevelUseCase` y `level_definitions_test.dart` debido al cambio de `allLevels` a `campaignLevels`.
- **Verificación:** `flutter analyze` (0 issues), `flutter test` en verde, y ejecución exitosa en Chrome verificando el descuento de corazones en tiempo real al chocar flechas en ambos modos de juego.
- **Lecciones / limitaciones:**
  1. **Lógica de navegación GoRouter:** Intentar invocar `context.read<GameBloc>().add()` en una pantalla de resultados que reemplazó a la de juego rompe porque el widget ya no tiene el `Provider` arriba en el árbol. La solución limpia fue usar navegación directa (`context.pushReplacement`) pasando el nuevo `levelId` negativo aleatorio y que el `LoadLevelUseCase` resuelva la generación del nivel.
  2. **El poder de la validación estricta de tests:** El test `level_solvability_test.dart` detectó inmediatamente que el Nivel 1 ("Heart") dibujado originalmente tenía un deadlock físico insalvable. Esto obligó a rediseñar las direcciones de las flechas apuntando "hacia afuera" (desarmando la figura desde el perímetro), lo que hizo que todos los tests volvieran a verde sin alterar la silueta del corazón.
### Entrada #32 — UI: Renderizado por Capas Z con Fantasmas para niveles 3D (Issue #44)

- **Fecha / autor:** 12-07-2026 / hetairoii
- **Herramienta:** Claude Code (Modelo: Claude Sonnet 5)
- **Rol en el flujo:** Implementación de UI + tests, en modo planificación con aprobación explícita antes de escribir código.
- **Tarea/problema:** Resolver el issue #44 ("implement Z-Layer rendering with ghosting for 3D levels"): `Board3DLayersWidget`, chips selectores de capa, flechas de Z±1 renderizadas como fantasmas al 30% de opacidad, y `ZAxisArrowPainter` con glifos ⊙/⊗. El dominio/datos del proyecto es 100% 2D (`Grid2DNodeId` es el único `NodeId`); la topología 3D real (issue #43) y la migración `BoardGeometry`/Hive (issue #42) —descritas en la Entrada #30— aún no existían en el código.
- **Prompt (paráfrasis fiel):** > "Analiza, indaga y propón un plan para el issue #44 asignado a mí, y al final dame una guía sencilla para probar que se resolvió." Tras explorar el código, la IA preguntó explícitamente por el alcance (kit de UI desacoplado vs. wiring de datos 3D reales vs. dominio 3D completo) y por cómo se debía poder probar la funcionalidad dentro de la app; el usuario eligió "kit de UI + tablero de muestra" y "pantalla demo desde Ajustes".
- **Resultado obtenido:**
  1. View-model de presentación (`Board3DModel`, `PlanarArrow3D`, `AxialArrow3D`) que desacopla el kit del dominio 2D; las flechas planares reutilizan `CardinalDirection` para no duplicar la geometría/pintor existentes.
  2. `ZAxisArrowPainter` + helpers puros `z_axis_geometry.dart` (glifos ⊙/⊗), y un parámetro `opacity` añadido a `ArrowsLayerPainter` (reutilizado para el ghosting en vez de duplicar el pintor).
  3. `Board3DLayersWidget` (chips de capa + stack de capas sólida/fantasma) y una pantalla demo (`Board3DDemoScreen`) accesible desde Ajustes, con datos de muestra — sin tocar el dominio ni el `GameBloc`.
  4. 15 tests nuevos (geometría del glifo, view-model, widget) más 267 preexistentes, todos en verde.
- **Modificaciones del equipo:** el usuario corrigió el alcance en la fase de planificación antes de escribir código (ver arriba); durante la implementación no hubo correcciones manuales adicionales.
- **Verificación:** `flutter analyze` (0 issues), `flutter test` (282/282). Verificación visual en navegador bloqueada por una limitación conocida del entorno (ver Lecciones); se compensó arrancando la app en un build de release real y confirmando el boot limpio de Hive sin excepciones en consola, tanto en `/` como en la ruta nueva `/board3d-demo`.
- **Lecciones / limitaciones:**
  1. **Números de issue del ROADMAP.md desactualizados:** los issues #19–#24 redactados en la Entrada #30 son placeholders que colisionan con PRs viejas ya mergeadas; los issues reales creados en GitHub quedaron en #42–#46 (#44 = este trabajo, bloqueado conceptualmente por #43 y #42, ninguno implementado aún).
  2. **CanvasKit headless:** el navegador headless de este entorno no puede tomar capturas ni leer el árbol semántico de una app Flutter Web con CanvasKit por defecto (confirmado también en modo release, no solo debug); forzar `flt-semantics-placeholder` vía JS quita el overlay pero no puebla el árbol de semántica. La verificación de UI en este proyecto depende de tests de widget + logs de consola, no de captura visual.
  3. **Overflow de layout en pruebas angostas:** un `Row` rígido para la leyenda ⊙/⊗ desbordaba en anchos de prueba de 320px; se cambió a `Wrap` para que se ajuste en pantallas angostas — un recordatorio de siempre probar el layout más nuevo en el ancho de prueba más angosto usado por el resto de la suite.

### Entrada #33 — Generador Basado en Grafos: Patrones, Chain Forcing y Drain de Resolubilidad

- **Fecha / autor:** 13-07-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: big-pickle)
- **Rol en el flujo:** Arquitecto de Software / Desarrollador Backend (Capa de Datos — Generación de Niveles).
- **Tarea/problema:** El generador procedural de niveles para el modo Supervivencia producía tableros irresolubles con frecuencia. Las flechas de patrón (ChainLink3, DoubleUInterlock, SpiralLock) interactuaban entre sí creando dependencias cíclicas que el grafo de bloqueos no detectaba. Además, el chequeo `_isSolvable` estaba dentro de un guard de profundidad (`graph.getMaxDepth() >= minGraphDepth`), por lo que boards con profundidad 0 nunca se verificaban — el generador devolvía tableros irresolubles silenciosamente.
- **Prompt (paráfrasis fiel):** > "Dos cosas: (1) por qué las flechas de patrón se quedan trabadas si la teoría dice que el generador es monótono, (2) después de 100 semillas fallidas, el generador devuelve el último tablero sin verificar si es resoluble."
- **Diagnóstico (verificado):**

  1. **SpiralLock**: La plantilla tenía una flecha D con dirección 'up' desde (1,0) cuya trayectoria de salida impactaba directamente en el cuerpo de A en (0,0). Esto creaba un ciclo A→D→C→B→A en el grafo de bloqueos, haciendo el tablero irresoluble aunque el generador lo aprobara.
  2. **`_isSolvable` mal scoped**: La llamada al drain estaba dentro del `if (graph.getMaxDepth() >= config.minGraphDepth)`, lo que significa que boards sin profundidad (ciclos) jamás ejecutaban el drain. El generador iteraba 100 veces buscando profundidad suficiente sin detectar que el board era irresoluble.
  3. **Cross-template cycles**: ChainLink3 (flecha C) y DoubleUInterlock (flechas en U) comparten regiones del tablero porque el generador siembra patrones en zona central y forcing en las orillas. La trayectoria de salida de una flecha de patrón intersecta celdas ocupadas por otra flecha de patrón o forcing, creando dependencias cíclicas sin que ninguna plantilla individual tenga un ciclo interno.
  4. **100 semillas insuficientes**: Para configuraciones complejas como Medium (ChainLink3 + DoubleUInterlock, 8×8), 100 semillas no son suficientes para encontrar una combinación sin cross-template cycle.

- **Resultado obtenido:**
  1. **SpiralLock corregido**: La flecha D se cambió de trayectoria `[(3,0),(2,0),(1,0)]` dirección 'up' (exit impactaba A en (0,0)) a `[(3,0),(4,0),(4,1)]` dirección 'right' (exit libre en (4,2)). Bounding box actualizado a 5×4.
  2. **`_isSolvable` movido fuera del guard**: Ahora se ejecuta en CADA board, no solo cuando la profundidad es suficiente. Se verificó que el drain codicioso funciona incluso para boards con depth=0 (ciclos, cross-template dependencies).
  3. **maxAttempts 100→1000**: 10× más iteraciones para encontrar una combinación viable de patrones + forcing.
  4. **Post-loop safety net**: Si después de 1000 intentos el board sigue siendo irresoluble, se regenera con una config simplificada (sin patrones, sin chain forcing, arrowCount reducido 40%, profundidad plana). Esta llamada recursiva siempre converge porque la generación simple sin patrones es monótona y produce boards resolubles garantizados.
  5. **Test de solvabilidad para survival**: 15 tests (Easy/Medium/Hard × 5 seeds cada uno) más un test de opening move, que verifican que todos los boards generados para survival son resolubles.

- **Modificaciones del equipo:** Se corrigió el scope de `_isSolvable`, se rediseñó manualmente la plantilla SpiralLock, y se añadió la red de seguridad post-loop. El equipo validó que la fallback nunca se active innecesariamente (1000 intentos son suficientes para la mayoría de configs).
- **Verificación:** `flutter test` — todos los tests de solvabilidad de survival en verde, incluyendo Medium seed 10001 que antes fallaba consistentemente.
- **Archivos afectados:**
  - `lib/features/game/data/level_definitions/level_generator.dart` — maxAttempts 100→1000, _isSolvable fuera del guard, post-loop fallback.
  - `lib/features/game/data/level_definitions/pattern_placer.dart` — SpiralLock template corregido.
  - `test/data/level_solvability_test.dart` — 15 nuevos tests de survival + opening move.
- **Lecciones / limitaciones:**
  1. **No asumir que el generador es "monótono" cuando hay patrones**: La monotonicidad (sacar cualquier flecha nunca bloquea a otra) se cumple para flechas individuales, pero los patrones se siembran TODOS JUNTOS y sus trayectorias de salida pueden cruzarse. El grafo de bloqueos detecta ciclos individuales pero no cross-template cycles que requieren 4+ flechas para cerrarse.
  2. **Un drain codicioso es la red de seguridad correcta**: En vez de intentar detectar todos los tipos posibles de ciclos (NP-hard), ejecutar un drain simple al final garantiza resolubilidad real en tiempo O(n²).
  3. **El fallback recursivo es seguro porque la base es monótona**: Generar sin patrones ni chain forcing siempre produce boards resolubles (se pueden desarmar en orden inverso de inserción). La recursión tiene un solo nivel porque la config simple siempre converge en ≤1000 intentos.

### Entrada #34 — Ajuste de Tiempos en Modo Supervivencia: 30s Iniciales, +10s por Nivel

- **Fecha / autor:** 13-07-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: big-pickle)
- **Rol en el flujo:** Desarrollador Frontend (BLoC — Ajuste de reglas de juego).
- **Tarea/problema:** El modo supervivencia iniciaba con 60 segundos y sumaba 20 segundos por nivel completado. El jugador solicitó que sea más rápido y ajustado: 30 segundos iniciales y solo +10 segundos de bonus al pasar nivel.
- **Prompt (paráfrasis fiel):** > "quiero cambiar los tiempos en el modo survival , quiero que te den 30 segundos y cuando pases de nivel solo se sumen 10 segundos a lo que quede de tiempo"
- **Resultado obtenido:**
  1. Tiempo inicial en `_onLoadLevel`: `_totalTimeRemaining = 60` → `_totalTimeRemaining = 30`.
  2. Reinicio tras game over en `_onRetryLevel`: `_totalTimeRemaining = 60` → `_totalTimeRemaining = 30`.
  3. Bonus por victoria en `_emitVictoryState`: `_totalTimeRemaining += 20` → `_totalTimeRemaining += 10`.
  4. Bonus por `NextEndlessLevel`: `_totalTimeRemaining += 20` → `_totalTimeRemaining += 10`.
  5. Default del campo: `int _totalTimeRemaining = 60` → `int _totalTimeRemaining = 30`.
- **Modificaciones del equipo:** Ninguna. Cambio directo de constantes.
- **Verificación:** `flutter analyze` sin errores. Requiere validación en vivo por el jugador.
- **Archivos afectados:**
  - `lib/features/game/presentation/bloc/game_bloc.dart` — 5 líneas modificadas.
- **Lecciones / limitaciones:** Ninguna. El cambio es puramente de constantes de juego.

### Entrada #35 — Deuda Técnica 2D y Migración de Datos (Sealed BoardGeometry y Hive levels_v2) (Issue #20)

- **Fecha / autor:** 14-07-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelos: gpt-5-mini para planificación, gemini-3.5-flash para ejecución)
- **Rol en el flujo:** Arquitecto de Software / Desarrollador Frontend (Refactorización de Dominio, Mapeadores y Persistencia).
- **Tarea/problema:** Preparar la base del frontend para soportar geometrías 3D en el futuro sin romper el comportamiento 2D actual, resolviendo la deuda técnica de representar dimensiones con enteros planos (`rows` y `cols`) en la entidad `Level`. Además, se necesitaba migrar el nombre de la caja Hive de niveles de `'levels'` a `'levels_v2'` para prevenir colisiones de esquemas/adaptadores de datos viejos con campos 3D futuros.
- **Prompt (paráfrasis fiel):** > "Procedamos con el issue #20 [Pagar deuda técnica 2D y migrar Hive]" (enfoque SDD interactivo en memoria Engram, budget 400 líneas).
- **Resultado obtenido:**
  1. **Clase Sellada `BoardGeometry`:** Creado `lib/features/game/domain/entities/board_geometry.dart` con la jerarquía sellada de Dart 3 `BoardGeometry`, `BoardGeometry2D` (con `rows` y `cols`) y `BoardGeometry3D` (con `rows`, `cols` y `depth`), validando con `assert` que todas las dimensiones sean estrictamente positivas (`> 0`).
  2. **Refactor de `Level` con Retrocompatibilidad:** Modificada la entidad `Level` para inyectar `BoardGeometry geometry` reemplazando los enteros de filas y columnas. Se expusieron getters delegados `int get rows` e `int get cols` que resuelven dinámicamente con un `switch` pattern matching sobre la geometría, aislando por completo el impacto en las vistas de juego preexistentes.
  3. **Mappers Robustos y Retrocompatibilidad:** Refactorizados `LevelMapper` y `LevelModel.fromJson`. `fromJson` ahora analiza el JSON recibido y, si no encuentra la estructura `boardSize` pero sí los campos planos heredados de Hitos anteriores (`rows` y `cols`), construye de forma transparente un objeto `BoardSizeModel` (el cual luego es mapeado a `BoardGeometry2D` en el `LevelMapper`) mitigando cualquier crash de datos antiguos. Asimismo, lanza una excepción robusta `FormatException` si faltan ambas estructuras en lugar de fallar silenciosamente.
  4. **Caja de Hive `'levels_v2'`:** Se actualizó la constante en `hive_config.dart` de `'levels'` a `'levels_v2'`.
  5. **Sembrado Idempotente:** En `service_locator.dart`, la carga del seed de campaña se condicionó con `if (levelsBox.isEmpty)` para garantizar que el sembrado sea puramente idempotente en arranques limpios y nunca sobreescriba datos.
  6. **Tests Automatizados:** Se creó `test/domain/board_geometry_test.dart` (validación de constructor, excepciones y Equatable) y se agregaron escenarios de deserialización legacy en `level_mapper_test.dart`.

- **Modificaciones del equipo:** Se detectó en el análisis estático un error de inicialización en `FakeLevel` (dentro de `start_game_session_use_case_test.dart`) que heredaba directamente de `Level` y usaba el constructor viejo. Se corrigió manualmente importando la geometría e instanciando `BoardGeometry2D`.
- **Verificación:** Ejecución de `flutter analyze` dando 0 issues y suite de pruebas `flutter test` en verde (100% de tests unitarios y de widgets pasando sin regresiones).
- **Archivos afectados:**
  - `lib/features/game/domain/entities/board_geometry.dart` (nuevo)
  - `test/domain/board_geometry_test.dart` (nuevo)
  - `lib/features/game/domain/entities/level.dart`
  - `lib/features/game/domain/services/level_builder.dart`
  - `lib/features/game/data/models/level_model.dart`
  - `lib/features/game/data/models/mappers/level_mapper.dart`
  - `lib/core/database/hive_config.dart`
  - `lib/core/di/service_locator.dart`
  - `test/data/models/mappers/level_mapper_test.dart`
  - `test/features/game/application/use_cases/start_game_session_use_case_test.dart`
- **Lecciones / limitaciones:**
  1. **Evitar el blast radius con abstracciones inteligentes:** Exponer propiedades delegadas (`get rows => ...`) usando switches de Dart 3 sobre clases selladas permite refactorizar la estructura de datos interna del dominio conservando la interfaz pública intacta. Esto ahorró tener que refactorizar decenas de archivos de UI.
  2. **Hot-reload de configuración en sub-agentes:** Al reescribir `opencode.json` de manera local para pisar modelos incorrectos de la configuración global, OpenCode lee e inyecta la nueva configuración del proyecto en los arranques subsiguientes de los sub-agentes sin requerir reinicio forzado del chat padre.
### Entrada #35 — feat(network): HTTP API integration with Hive offline fallback (Issue #45)

- **Fecha / autor:** 14-07-2026 / hetairoii
- **Herramienta:** Claude Code (Modelo: claude-opus-4-8)
- **Rol en el flujo:** Análisis cross-repo + implementación, en modo planificación con aprobación explícita antes de escribir código.
- **Tarea/problema:** Resolver el issue #45 ("implement HTTP API integration with Hive offline fallback"): sincronizar el progreso del jugador con el backend y hacer fallback a Hive cuando esté offline, sincronizando al reconectar. Al explorar el backend se encontró que ya implementaba `GET/PUT /api/v1/progress` (JWT, merge idempotente) y `POST /auth/guest`, salvo el campo `currentLevel` que el modelo local del frontend necesita; esa brecha se cerró primero en el backend (issue #12, PR #13, mergeado a `master`) antes de implementar este issue.
- **Prompt (paráfrasis fiel):** > "Analiza el issue #45 del frontend, analiza el backend para adaptarlo, crea el issue correspondiente en el backend en una rama desde master, y cuando esté mergeado implementa la funcionalidad en el frontend en una rama desde develop, dándome puntos de verificación manual en cada repositorio."
- **Resultado obtenido:**
  1. `dio` y `connectivity_plus` añadidos a `pubspec.yaml`.
  2. `ApiConfig` (`lib/core/config/api_config.dart`) — `baseUrl` configurable vía `--dart-define=API_BASE_URL`.
  3. `AuthTokenStore` (`lib/features/player/data/auth_token_store.dart`) — persiste el JWT en la caja Hive `'player'` existente.
  4. `AuthInterceptor` (`lib/core/network/auth_interceptor.dart`) — adjunta `Authorization: Bearer`, hace guest-login automático con el UUID del jugador si no hay token, reautentica una vez ante 401.
  5. `ApiClient` (`lib/core/network/api_client.dart`) — envuelve `Dio` con el interceptor.
  6. `RemoteProgressDataSource` (`lib/features/game/data/datasources/remote_progress_data_source.dart`) — mapea explícitamente entre las claves del modelo local (`completedLevels`/`scores`, IDs `int`) y las del backend (`completed`/`best`/`currentLevel`, IDs `String`).
  7. `SyncedProgressRepository` (`lib/features/game/data/repositories/synced_progress_repository.dart`) — decorador de `HiveProgressRepository` implementando `IProgressRepository`: guarda local primero (nunca se pierde progreso), intenta push remoto, marca un flag "pending" en la caja `'player'` si falla, y lo vacía automáticamente al recuperar conectividad (`connectivity_plus`) o al arrancar. `loadProgress` hace merge (unión de niveles + máximo nivel actual) entre lo local y lo remoto.
  8. Único cambio de wiring en `lib/core/di/service_locator.dart`: el binding de `IProgressRepository` ahora resuelve `SyncedProgressRepository` en vez de `HiveProgressRepository` directamente; nada aguas abajo (use cases, `ProgressBloc`) cambió.
  9. 7 tests nuevos (`test/features/game/data/repositories/synced_progress_repository_test.dart`) cubriendo online/offline/reconexión/merge/fallback, usando `mocktail`.
- **Modificaciones del equipo:** Se reordenó la sección "Player (Guest-First identity)" del `service_locator.dart` para que se registre antes que "Networking", ya que el `AuthInterceptor` necesita el UUID del jugador al construirse. Se corrigió una importación innecesaria (`test/fake.dart`) detectada por `flutter analyze`.
- **Verificación:** `flutter analyze` (0 issues) y `flutter test` (320/320, incluye los 7 tests nuevos).
- **Archivos afectados:**
  - Nuevos: `lib/core/config/api_config.dart`, `lib/core/network/api_client.dart`, `lib/core/network/auth_interceptor.dart`, `lib/features/player/data/auth_token_store.dart`, `lib/features/game/data/datasources/remote_progress_data_source.dart`, `lib/features/game/data/repositories/synced_progress_repository.dart`, `test/features/game/data/repositories/synced_progress_repository_test.dart`.
  - Modificados: `pubspec.yaml`, `lib/core/di/service_locator.dart`.
- **Lecciones / limitaciones:** Explorar el backend antes de asumir su alcance evitó reimplementar sincronización que ya existía; solo hizo falta un campo puntual. Falta persistir puntajes por nivel (`best`) desde el frontend — hoy se envía vacío porque `AppProgressMapper` aún los descarta (TODO documentado en ese archivo); quedará para un issue futuro.

### Entrada #37 — Optimización de Tiempos de Carga (Campaña), Sincronización No Bloqueante y Ajuste Matemático de Puntuación (3 Mangos)

- **Fecha / autor:** 14-07-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelos: gpt-5-mini para planificación y lógica, gemini-3.5-flash para ejecución)
- **Rol en el flujo:** Desarrollador Senior de Software / Game Designer (Optimización de Rendimiento y UX de Juego).
- **Tarea/problema:** Se detectaron tres bugs críticos de rendimiento y experiencia de usuario tras probar en vivo:
  1. **Lentitud de Campaña al arrancar/entrar:** La app se quedaba en blanco por varios segundos. Al haber migrado a `'levels_v2'`, la primera generación de los 15 niveles requería resolver en tiempo real profundidades de grafo altísimas (`minGraphDepth: 12` en difícil y `8` en medio). Eso bloqueaba el hilo principal.
  2. **Congelamiento de Interfaz por Red (Lag en Menús/Victoria):** En el modo campaña, el guardado y la carga de progreso (`SyncedProgressRepository`) esperaban de forma síncrona (`await`) la respuesta HTTP del servidor NestJS, provocando un congelamiento de 5 segundos si el servidor tardaba o si no había internet.
  3. **Puntuación de 3 Mangos Imposible:** Ningún jugador del grupo lograba superar los 1 o 2 mangos en la victoria debido a constantes de penalización desproporcionadas (`movePenalty: 50` y `timePenalty: 10`), las cuales consumían los 1000 puntos base de forma instantánea al requerir obligatoriamente como mínimo un movimiento por flecha para vaciar el tablero.
- **Prompt (paráfrasis fiel):** > "los fix que acabamos de hacer no los hemos representado en el AI_USAGE.MD , ademas aun no esta solucionado lo del modo campaña, a que se debe la diferencia de tiempos de carga entre 'campaña' y 'supervivencia'? ... que consideras para dar la puntuación en mangos? porque nunca a ninguno nos ha salido 3 mangos"
- **Resultado obtenido:**
  1. **Generación Instantánea de Campaña:** Se optimizaron las profundidades de grafo requeridas para el catálogo estático (Fácil: 5➔2, Medio: 8➔3, Difícil: 12➔4). El sembrado completo de los 15 niveles se redujo de 15 segundos a menos de **200ms**, logrando cargas instantáneas del menú.
  2. **Espera de Victoria Sutil (450ms):** Se redujo la espera asíncrona de victoria de 800ms a **450ms**, calzando con la duración exacta de la animación de deslizamiento de la última flecha para una respuesta reactiva.
  3. **Sincronización de Red en Background (Fire-and-Forget):** Se eliminaron los bloqueos en `SyncedProgressRepository` haciendo que las peticiones fetch/push de la API de red se ejecuten en segundo plano sin esperar a que resuelvan en el hilo principal. El juego prioriza mostrar la base de Hive y se sincroniza silenciosamente en background sin freezes.
  4. **Puntuación de 3 Mangos Equilibrada:** Se ajustaron las constantes de penalización en `MoveBasedScoring` a valores realistas (`movePenalty = 5` y `timePenalty = 1`), haciendo que una partida limpia y eficiente en cualquier dificultad premie correctamente con los 3 mangos (>= 700 puntos).
- **Modificaciones del equipo:** Ninguna. Se ajustaron los tests unitarios en `synced_progress_repository_test.dart` introduciendo esperas de microtarea `Future.delayed(Duration.zero)` para soportar las tareas en background del repositorio.
- **Verificación:** Ejecución de `flutter analyze` limpia y suite completa de `flutter test` en verde, verificando en vivo la carga instantánea del menú y la obtención de 3 mangos en partidas eficientes.
- **Archivos afectados:**
  - `lib/features/game/data/level_definitions/level_generator.dart` (profundidades optimizadas)
  - `lib/features/game/presentation/bloc/game_bloc.dart` (delay reducido a 450ms)
  - `lib/features/game/data/repositories/synced_progress_repository.dart` (async sync en background)
  - `lib/features/game/domain/services/move_based_scoring.dart` (penalizaciones justas)
  - `test/features/game/presentation/bloc/game_bloc_test.dart` (esperas en tests de BLoC)
  - `test/features/game/data/repositories/synced_progress_repository_test.dart` (tests adaptados a background futures)

### Entrada #38 — AOP Logging & Error Handling (Issue #14)

- **Fecha / autor:** 16-07-2026 / Abraham Granadillo
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Arquitecto de Software / Desarrollador Senior Dart (Capa Transversal).
- **Tarea/problema:** Implementar el Issue #14: añadir aspectos transversales de logging y manejo centralizado de errores sin contaminar la lógica de negocio de los repositorios ni los BLoCs. El reto era hacerlo 100% en Dart/Flutter sin reflection ni bytecode weaving, manteniendo las firmas públicas intactas y respetando el Service Locator existente.
- **Prompt (paráfrasis fiel):** > "Necesito empezar con el Issue de AOP, recuerda crear la rama correspondiente primero." Seguido de planificación SDD manual por fases y ejecución directa en la rama `feat/aop-logging-error-handling`.
- **Resultado obtenido:**
  1. Nuevo directorio transversal `lib/core/aop/`:
     - `aop_logger.dart` — logger interno que usa `dart:developer` y se silencia completamente en `kReleaseMode`.
     - `aop_invoker.dart` — helper central con dos caminos tipados:
       - `invokeResult<R>` para métodos que devuelven `Result<R>`: captura excepciones de infraestructura (`HiveError`, `DioException`, etc.) y las traduce en `Error<R>(GenericFailure(...))`.
       - `invoke<R>` / `invokeSync<T>` para métodos comunes: loguea y re-lanza para no ocultar errores de programación.
     - `app_bloc_observer.dart` — `BlocObserver` global que loguea create, close, event, transition y error usando solo tipos de runtime (sin volcar estados completos).
     - Decoradores concretos por interfaz: `AopProgressRepository`, `AopLevelRepository`, `AopPlayerRepository`, `AopLeaderboardRepository`.
  2. Registro del observador en `lib/main.dart` mediante `Bloc.observer = AppBlocObserver();`.
  3. Wireado en `lib/core/di/service_locator.dart` después de `sl.init()`, envolviendo `IProgressRepository`, `ILevelRepository`, `ILeaderboardRepository` y `IPlayerRepository`/`PlayerLocalDataSource` de forma transparente para casos de uso y BLoCs.
  4. Artefactos SDD en `openspec/changes/aop-logging-error-handling/` (proposal, specs, design, tasks) y `openspec/config.yaml`.
  5. 6 archivos de test en `test/core/aop/` cubriendo logging, mapeo de excepciones a `GenericFailure`, propagación de errores no-Result y observación de transiciones de BLoC.
- **Modificaciones del equipo:**
  - El wireado de `IPlayerRepository` requirió un caso especial porque el composition root registraba `PlayerLocalDataSource` (concreto) y `PlayerCubit` se armaba directamente con esa instancia. Se re-registraron tanto la abstracción como el cubit apuntando al repositorio decorado.
  - Se ajustó la firma del logger al ser una función de top-level (`void aopLog(...)`) para evitar mutable state en tests.
- **Verificación:** No se pudo ejecutar `flutter analyze` ni `flutter test` en la sesión de WSL porque Flutter CLI falló al intentar arrancar el SDK de Dart como root. Queda pendiente correr `flutter test` desde Windows.
- **Archivos afectados:**
  - Nuevos: `lib/core/aop/aop_logger.dart`, `lib/core/aop/aop_invoker.dart`, `lib/core/aop/app_bloc_observer.dart`, `lib/core/aop/aop_progress_repository.dart`, `lib/core/aop/aop_level_repository.dart`, `lib/core/aop/aop_player_repository.dart`, `lib/core/aop/aop_leaderboard_repository.dart`, y 6 archivos de test bajo `test/core/aop/`.
  - Modificados: `lib/main.dart`, `lib/core/di/service_locator.dart`, `AI_USAGE.MD`.
- **Lecciones / limitaciones:**
  1. **Dart no tiene proxies dinámicos multiplataforma**; el Decorator concreto por interfaz es la forma más limpia y type-safe de hacer AOP en Flutter.
  2. **Re-registrar servicios en get_it después de la generación de injectable** permite interceptar dependencias sin tocar los constructores de los consumidores, pero hay que tener cuidado con las dependencias que se resuelven temprano (como `PlayerCubit`).
  3. **El logger debe ser release-safe por diseño**, no por configuración: usar `kReleaseMode` como guard de primer nivel evita que logs sensibles o de debug se filtren en producción.

---
  ### Entrada #39 — Balanceo del Modo Campaña (Penalización por errores y Bugfix de Amnesia)                                            
                                                                                                                                      
    - **Fecha / autor:** 16-07-2026 / Alberto Monasterio                                                                                  
    - **Herramienta:** OpenCode (Modelo: Gemini 1.5 Pro - Antigravity)                                                                    
    - **Rol en el flujo:** Desarrollador Senior en Dart y Game Designer (Capas de Dominio, Aplicación y Presentación).                    
    - **Tarea/problema:** El modo campaña (2D) estaba calculando los puntos sin penalizar los toques en flechas bloqueadas (errores), lo  
  que permitía obtener la máxima puntuación (3 mangos) simplemente tocando al azar. Además, el BLoC sufría de un "bug de amnesia" donde el
  contador de errores se reiniciaba a 0 tras cada movimiento porque el estado `GamePlaying` no persistía esa propiedad.                   
    - **Prompt (paráfrasis fiel):**                                                                                                       
      > "Modifica el sistema de puntuación 2D para castigar las equivocaciones. Añade el registro de errores (`mistakes`) a `GameSession` 
  y pásalos a la estrategia de puntuación. Propón un balanceo matemático justo para que obtener los 3 mangos requiera un nivel perfecto.  
  Después, investiga y corrige por qué el juego sigue evaluando los errores como 0 al final de la partida."                               
    - **Resultado obtenido:**                                                                                                             
      1. Integración de `mistakes` en `GameSession` con el método inmutable `afterMistake()`.                                             
      2. Refactorización de la firma de `ScoringStrategy` y los casos de uso (`CalculateScore`, `EvaluateGameState`) para propagar los    
  errores.                                                                                                                                
      3. Rebalanceo de `MoveBasedScoring` (Base: 1000, Tiempo: -10/s, Error: -150, Movimiento: 0) para no castigar el tamaño del nivel,   
  sino la torpeza y lentitud.                                                                                                             
      4. Solución del bug de amnesia inyectando `mistakes` dentro del `GamePlaying` state y el `GameStateMapper`.                         
    - **Modificaciones del equipo:** Se decidió eliminar por completo el castigo por movimientos exitosos para nivelar la dificultad entre
  tableros pequeños y grandes. El equipo ajustó previamente el umbral visual de perfección a 900 puntos en `mango_rating.dart`.           
    - **Verificación:** Pruebas manuales exitosas. Realizar un nivel sin errores en menos de 10 segundos garantiza los 3 mangos. Cometer  
  un solo error (-150 puntos) inhabilita automáticamente el rango perfecto.                                                               
    - **Lecciones / limitaciones:** Las reconstrucciones de sesión a partir del estado de UI son propensas a pérdida de datos si el mapper
  de estado a dominio no incluye absolutamente todas las propiedades transitorias (como el contador de errores).                          
                                                                  ### Entrada #40 — Implementación de Pruebas Unitarias (Issue #7)

- **Fecha / autor:** 21-06-2026 / Alberto Monasterio
- **Herramienta:** Opencode(Kimi K2.7 Code)
- **Rol en el flujo:** Senior QA Engineer.
- **Tarea/problema:** Desarrollar las pruebas unitarias para los 5 casos de uso de la capa de aplicación, garantizando una alta cobertura de código y validando el manejo de errores.
- **Prompt (paráfrasis fiel):** > "Actúa como un Senior QA Engineer. Genera las pruebas unitarias en Dart puro para [Nombre del Caso de Uso]. Reglas: Usa `flutter_test`, crea Mocks manuales (no Mockito/Mocktail), sigue el patrón AAA estrictamente y nombra las pruebas usando el formato snake_case `should_[resultado]_when_[condicion]`." *(Nota: Este prompt se ejecutó 5 veces de forma independiente usando la técnica de Micro-Prompting).*
- **Resultado obtenido:** Se generaron exitosamente los 5 archivos de prueba cubriendo todos los flujos de éxito y fracaso (12 escenarios en total). La IA implementó Mocks manuales avanzados, inyectando estados controlados y excepciones para validar la lógica interna sin depender de la infraestructura real.
- **Modificaciones del equipo:** 1. **Aplicación estricta de convenciones:** Se detectó en la primera iteración que la IA utilizaba lenguaje natural para nombrar las pruebas. Se intervino deteniendo la generación y modificando el prompt maestro para forzar la convención  (`should_[resultado_esperado]_when_[condicion]`). 
  2. **Resolución de Imports:** Se corrigieron manualmente las importaciones sugeridas por la IA para apuntar a las rutas relativas correctas dentro de la arquitectura del proyecto.
  3. **Refactorización por Análisis Estático:** El código generado por la IA presentaba prácticas heredadas de versiones anteriores de Dart. Se refactorizaron manualmente las clases *Fake* para resolver las advertencias de `flutter analyze`, implementando *super parameters*, eliminando aserciones nulas redundantes (`!`), y utilizando *getters* en lugar de redefinir variables `final` para cumplir con las reglas `prefer_initializing_formals` y `overridden_fields`.
- **Verificación:** Todos los tests ejecutados vía `flutter test` pasaron exitosamente (100% de escenarios en verde). El código superó la revisión de `flutter analyze` con cero advertencias ("No issues found!").



### Entrada #[41] — Plan de Implementación (Issue #8: Use Cases - Progress & Scoring)

- **Fecha / autor:** 07-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Gwen)
- **Rol en el flujo:** Arquitecta de Software (Planificadora).
- **Tarea/problema:** Diseñar el plan de implementación detallado para el Issue #8 (Casos de uso de Progreso y Puntuación), estableciendo los contratos antes de generar cualquier línea de código.
- **Prompt (paráfrasis fiel):** > "Actúa como una Arquitecta de Software experta en Clean Architecture. Diseña un plan de implementación paso a paso para los casos de uso: `SaveLocalProgress`, `LoadProgress` y `CalculateScore`. Para cada uno define: la firma de la clase, el método `call` (usando `Result<T>`), las dependencias a inyectar y los posibles escenarios de falla. No escribas los tests ni la implementación completa aún."
- **Resultado obtenido:** La IA detectó las convenciones del código base (como la clase sellada `Result` y las subclases de `Failure`). Entregó los contratos exactos y definió responsabilidades claras, demostrando que los casos de uso de progreso actúan como *thin wrappers* sobre los repositorios.
- **Modificaciones del equipo: 1. Aplicación del Patrón Planner-Coder:** Se evitó solicitar código de producción inmediatamente para validar primero la lógica arquitectónica. El diseño entregado fue preciso.
- **Verificación:** El diseño respeta el Principio de Inversión de Dependencias (DIP) orquestando interfaces (`IProgressRepository`, `ScoringStrategy`) sin acoplarse a implementaciones concretas ni violar los límites de la capa de Aplicación.

---

### Entrada #[42] — Implementación de Código y Testing (Issue #8)

- **Fecha / autor:** 07-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Senior QA Engineer y Flutter Developer (Coder).
- **Tarea/problema:** Desarrollar la lógica de negocio y las pruebas unitarias para los 3 casos de uso, siguiendo estrictamente el plan arquitectónico definido previamente.
- **Prompt (paráfrasis fiel):** > "Actúa como Senior QA Engineer y Flutter Developer. A partir del diseño arquitectónico, escribe la implementación completa en Dart y el archivo de pruebas unitarias. Usa `flutter_test` puro, crea Fakes manuales en el mismo archivo, sigue el patrón AAA estrictamente con comentarios y usa nomenclatura `snake_case`." *(Nota: Este prompt se repitió de forma aislada por cada caso de uso).*
- **Resultado obtenido:** Kimi generó los archivos de producción y pruebas para los 3 casos de uso. Implementó Fakes manuales (`FakeProgressRepository`, `FakeScoringStrategy`) y validaciones mediante *guard clauses* (ej. validación de parámetros negativos en `CalculateScoreUseCase`).
- **Modificaciones del equipo: 1. Aplicación de Micro-Prompting:** En lugar de solicitar los 3 casos de uso de una vez, se instruyó a la IA caso por caso para mantener el contexto limpio, asegurar el cumplimiento estricto de las convenciones de testing y evitar alucinaciones.
- **Verificación:** Todo el código generado compiló sin errores, pasó las reglas estrictas del linter de Dart (`flutter analyze`) y los tests unitarios pasaron exitosamente confirmando la lógica esperada.

---

### Entrada #[43] — Code Review y Refactorización de Calidad (Issue #8)

- **Fecha / autor:** 07-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelos: Gwen y Kimi K2.7 Code)
- **Rol en el flujo:** Tech Lead / Arquitecta (Auditora) y QA Engineer (Ejecutor).
- **Tarea/problema:** Realizar una auditoría técnica final del código antes de abrir el Pull Request y aplicar refactorizaciones para mejorar la calidad de las pruebas.
- **Prompt (paráfrasis fiel):** > "Actúa como Tech Lead. Realiza un Code Review exhaustivo de los 3 casos de uso evaluando límites arquitectónicos, manejo de errores y calidad de las pruebas. Señala exactamente qué refactorizar." (Posteriormente se usó a Kimi instruyéndole: > "Aplica las sugerencias de la Tech Lead: Extrae la clase Fake duplicada a un archivo helper, agrega el caso de prueba borde faltante y usa Pattern Matching de Dart 3 en los expects").
- **Resultado obtenido:** Gwen aprobó funcionalmente el código pero detectó un *code smell* (duplicación del Fake) y sugirió mejoras de sintaxis moderna. Kimi ejecutó la refactorización exitosamente, centralizando el `FakeProgressRepository` y actualizando los asserts.
- **Modificaciones del equipo: 1. Refactorización Exigida:** Se tomaron las sugerencias de la IA como un estándar de aceptación obligatorio para elevar la calidad del código, integrando el refactor de DRY (Don't Repeat Yourself) y *Pattern Matching* antes de realizar el commit y push final.
- **Verificación:** El código refactorizado mantuvo todos los tests en verde (`flutter test`), demostrando una mayor modularidad y preparación para escalabilidad de pruebas.

---

### Entrada #[44] — Plan de Implementación (Issue #9: Gestión de Niveles)

- **Fecha / autor:** 07-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Gwen)
- **Rol en el flujo:** Arquitecta de Software (Planificadora).
- **Tarea/problema:** Diseñar el plan de implementación detallado para los Casos de Uso del Issue #9 (`GetLevelListUseCase`, `GetLevelDefinitionUseCase` y `UnlockNextLevelUseCase`).
- **Prompt (paráfrasis fiel):** > "Actúa como una Arquitecta de Software experta en Clean Architecture y Domain-Driven Design en Flutter. Diseña un plan de implementación paso a paso para los 3 Casos de Uso. Define firmas (usando `Result<T>`), dependencias inyectadas y escenarios de falla. No escribas los tests ni la implementación completa todavía."
- **Resultado obtenido:** La IA estructuró un plan robusto, identificando la necesidad de crear un nuevo DTO (`LevelSummary`) y un Domain Error (`LevelNotFoundFailure`). Definió claramente cómo orquestar `ILevelRepository` e `IProgressRepository` para calcular qué niveles están desbloqueados.
- **Modificaciones del equipo: 1. Aplicación del Patrón Planner-Coder:** Se evaluó el plan antes de programar y se tomó la decisión arquitectónica de reemplazar un caso de uso antiguo (`LoadLevelUseCase`) por la nueva propuesta validada (`GetLevelDefinitionUseCase`).
- **Verificación:** El diseño respeta los límites de la capa de Aplicación, delegando la lógica de persistencia y definición a las interfaces correspondientes (DIP).

---

### Entrada #[45] — Implementación de Código y Testing (Issue #9)

- **Fecha / autor:** 07-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Senior QA Engineer y Flutter Developer (Coder).
- **Tarea/problema:** Desarrollar los 3 casos de uso de gestión de niveles, el nuevo *Failure*, el DTO y sus respectivas pruebas unitarias bajo el estándar del proyecto.
- **Prompt (paráfrasis fiel):** > "Actúa como un Senior QA Engineer y Flutter Developer. Genera el código en Dart respetando Clean Architecture para los casos de uso y sus pruebas unitarias. Usa `flutter_test` puro, reutiliza los fakes manuales existentes (`FakeLevelRepository`, `FakeProgressRepository`), usa nomenclatura `snake_case` y aplica Pattern Matching de Dart 3 en los asserts." *(Nota: Ejecutado iterativamente por cada caso de uso).*
- **Resultado obtenido:** Kimi generó el código de producción con *guard clauses* (ej. validar ids negativos) y bloques `try/catch`. Construyó las pruebas integrando exitosamente los Fakes compartidos de pruebas anteriores.
- **Modificaciones del equipo: 1. Aplicación de Micro-Prompting:** Se fragmentó la generación de código en tres etapas (cimientos/caso 1, caso 2, caso 3) para garantizar que la IA mantuviera el contexto correcto al inyectar múltiples dependencias en casos complejos como `UnlockNextLevelUseCase`.
- **Verificación:** El código pasó el análisis estático (`flutter analyze`) sin advertencias y todas las pruebas unitarias demostraron el comportamiento correcto en escenarios de éxito y error.

---

### Entrada #[46] — Code Review y Refactorización (Issue #9)

- **Fecha / autor:** 07-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelos: Gwen y Kimi K2.7 Code)
- **Rol en el flujo:** Tech Lead / Arquitecta (Auditora) y QA Engineer (Ejecutor).
- **Tarea/problema:** Realizar una revisión profunda pre-Pull Request y aplicar refactorizaciones de calidad sobre el manejo de errores.
- **Prompt (paráfrasis fiel):** > "Actúa como Tech Lead. Realiza un Code Review exhaustivo de los casos de uso generados evaluando límites arquitectónicos y manejo de errores." (Posteriormente a Kimi): > "Aplica los refactors sugeridos: Propaga los failures originales directamente en los bloques catch/error (en lugar de envolverlos en GenericFailure) y agrega los tests para levelId negativo y para la idempotencia del desbloqueo."
- **Resultado obtenido:** Gwen aprobó la estructura pero detectó que envolver las fallas en `GenericFailure` haría perder el tipo específico (`LevelNotFoundFailure`). Kimi modificó el pattern matching para propagar el error de forma limpia e incluyó los tests de borde (edge cases) faltantes.
- **Modificaciones del equipo: 1. Refactorización Exigida:** Se priorizó mantener la tipificación estricta de las fallas para que, en un futuro Issue (BloCs), la capa de presentación pueda reaccionar específicamente al evento de "no hay más niveles disponibles".
- **Verificación:** Los ajustes mantuvieron el suite de pruebas en verde (`flutter test`), comprobando que los errores específicos se propagan como espera el diseño de dominio.

---

### Entrada #[47] — Resolución de Code Review Automático (Issue #9)

- **Fecha / autor:** 07-07-2026 / Alberto Monasterio
- **Herramienta:** GitHub Copilot (Análisis de PR) y OpenCode (Modelos: Qwen3.7 Plus  y Kimi K2.7 Code)
- **Rol en el flujo:** Revisión de PR (Copilot), Tech Lead / Auditora (Qwen), y Ejecutor (Kimi).
- **Tarea/problema:** Analizar, filtrar e implementar sugerencias automatizadas de Code Review en el Pull Request del Issue #9, discerniendo entre optimizaciones útiles y falsos positivos arquitectónicos.
- **Prompt (paráfrasis fiel):** > (Para Qwen): "Actúa como Tech Lead. Analiza las siguientes 6 sugerencias de Copilot. Dime cuáles apruebas para implementarlas y dame tu postura arquitectónica sobre la ubicación de los casos de uso." / > (Para Kimi): "Refactoriza aplicando estrictamente: cambia el orden de `props` en `LevelNotFoundFailure` y reemplaza el operador `!` por validaciones explícitas lanzando `StateError` en los Fakes si no se configuran."
- **Resultado obtenido:** Qwen actuó como un filtro de calidad de alto nivel: rechazó una micro-optimización prematura (uso de `Set` para O(1) en listas pequeñas) y defendió la arquitectura Clean Architecture frente a un ticket mal redactado. Aprobó mejoras de consistencia y seguridad. Kimi refactorizó el código de manera precisa sin alterar la lógica de negocio.
- **Modificaciones del equipo: 1. Triaje de IA vs IA:** Se utilizó un modelo de razonamiento (Qwen) para auditar críticamente las sugerencias de un modelo de autocompletado (Copilot), evitando que el código se desvíe de las convenciones del proyecto. 2. **Intervención Manual en Git:** Se detectaron y revirtieron manualmente modificaciones no deseadas en archivos autogenerados de plataformas desktop (`generated_plugins.cmake`) para mantener el PR limpio.
- **Verificación:** Los cambios se enviaron al PR exitosamente. El código ahora es más seguro en entornos de prueba, fallando con mensajes descriptivos claros (`StateError`) en lugar de excepciones de aserción nula (`NullThrownError`), mejorando significativamente la Developer Experience (DX).

---

### Entrada #[48] — Resolución de Code Review Automático (Issue #8)

- **Fecha / autor:** 07-07-2026 / Alberto Monasterio
- **Herramienta:** GitHub Copilot (Análisis de PR) y OpenCode (Modelos: Qwen3.7 Plus  y Kimi K2.7 Code)
- **Rol en el flujo:** Revisión de PR (Copilot), Tech Lead / Auditora (Qwen), y Ejecutor (Kimi).
- **Tarea/problema:** Mejorar la Developer Experience (DX) y la robustez de las pruebas unitarias en el Issue #8, refactorizando el manejo de errores en los Fakes (`FakeProgressRepository`, `FakeScoringStrategy`) sugerido por Copilot.
- **Prompt (paráfrasis fiel):** > (Para Kimi): "Refactoriza `FakeProgressRepository` y `FakeScoringStrategy` eliminando el uso de `!`. Agrega una validación explícita que lance un `StateError('Debes configurar [variable] en el Arrange')` si el valor es nulo." / > (Para Qwen): "Revisa la implementación. ¿La lógica previene efectivamente el `NullThrownError`? ¿Los mensajes son claros y sigue el patrón del Issue #9? Confírmame para proceder con el commit."
- **Resultado obtenido:** Kimi eliminó exitosamente los operadores de aserción nula (`!`) implementando las *guard clauses* solicitadas. Qwen (actuando como Tech Lead) auditó el código, confirmó que los mensajes de error eran explícitos y aprobó el cambio (LGTM) garantizando que se mantenía la consistencia arquitectónica con refactorizaciones previas.
- **Modificaciones del equipo: 1. Gestión Estricta de Ramas:** Antes de iniciar el refactor, se realizó un cambio de contexto en Git (`git checkout 8-progress-scoring-use-cases`) para aislar estos cambios del trabajo previo y mantener limpio el historial del PR correspondiente. **2. Auditoría Pre-Commit:** Se instituyó la práctica de exigir una validación final de la IA planificadora (Qwen) sobre el código de la IA ejecutora (Kimi) antes de registrar los cambios en el control de versiones.
- **Verificación:** Los tests locales (`flutter test`) verificaron que los Fakes ahora fallan con mensajes descriptivos claros y controlados. Los cambios fueron pusheados a la rama del Issue #8, actualizando el Pull Request de forma transparente.

---

### Entrada #17 — Definición de Contratos y Mapper (Issue #10: Game State Management)

- **Fecha / autor:** 08-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode(Rol: Kimi K2.7 Code - Coder)
- **Rol en el flujo:** Desarrollador / Arquitecto
- **Tarea/problema:** Definir la interfaz de comunicación de la capa de presentación (Eventos y Estados) y establecer una barrera de protección (Mapper) para no exponer entidades completas del dominio directamente a la UI.
- **Prompt (paráfrasis fiel):** > "Actúa como Senior Flutter Developer. Genera las clases selladas (`sealed class`) para `GameEvent` y `GameState` usando `Equatable` para garantizar la inmutabilidad. Luego, crea un `GameStateMapper` que aplane las entidades del dominio (como `GameSession` y `Score`) hacia propiedades primitivas o seguras para el estado `GamePlaying`, incluyendo protección contra *clock skew* en el cálculo de `elapsedSeconds`."
- **Resultado obtenido:** Archivos generados correctamente: `game_event.dart`, `game_state.dart` y `game_state_mapper.dart`. La IA aplicó correctamente el polimorfismo y creó los estados base (`GameInitial`, `GamePlaying`, `GameVictory`, `GameDefeat`).
- **Modificaciones del equipo:** Se validó que los estados no tuvieran métodos que mutaran la información. Se exigió la creación de pruebas unitarias (`game_state_test.dart` y `game_state_mapper_test.dart`) para verificar la igualdad de valores y la correcta transformación de datos.
- **Verificación:** Ejecución de `flutter test`. Todas las pruebas de `Equatable` y del Mapper pasaron en verde, asegurando una base inmutable y segura.

### Entrada #[49] — Implementación de Pruebas Unitarias (TDD Fase Roja)

- **Fecha / autor:** 08-07-2026 / Alberto Monasterio
- **Herramienta:**  OpenCode(Rol: Kimi K2.7 Code - Coder)
- **Rol en el flujo:** Ingeniero de Calidad / Desarrollador
- **Tarea/problema:** Escribir la suite de pruebas exhaustiva para el `GameBloc` antes de escribir su lógica de producción, siguiendo la metodología Test-Driven Development (TDD).
- **Prompt (paráfrasis fiel):** > "Actúa como Senior Flutter Developer. Escribe las pruebas unitarias para el `GameBloc` usando el paquete `bloc_test`. Debes seguir estrictamente el patrón AAA (Arrange, Act, Assert) y la nomenclatura `should... when...`. Cubre todos los eventos (LoadLevel, TriggerArrowExit, UndoMove, Tick, RetryLevel) simulando los Casos de Uso con *fakes* y controlando los estados emitidos."
- **Resultado obtenido:** La IA generó un archivo extenso de pruebas cubriendo escenarios de éxito, manejo de errores de dominio, rechazo de eventos en estados inválidos y optimización de re-renders (como evitar emitir estado si el `Tick` ocurre en el mismo segundo).
- **Modificaciones del equipo:** **Prevención de Alucinaciones por Contexto:** Debido a la complejidad de los escenarios, se dividió el prompt en dos partes (Parte 1 y Parte 2) para asegurar que el modelo no perdiera el foco ni omitiera casos de prueba por restricciones de longitud de salida.
- **Verificación:** Se ejecutó `flutter test` arrojando errores en todos los escenarios (Fase Roja garantizada) al no existir aún el BLoC, confirmando que las pruebas exigían la implementación correcta.

### Entrada #[50] — Implementación del GameBloc (TDD Fase Verde)

- **Fecha / autor:** 08-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode (Rol: Kimi K2.7 Code- Coder)
- **Rol en el flujo:** Desarrollador
- **Tarea/problema:** Desarrollar el código de producción del `GameBloc` para satisfacer las pruebas escritas en la Fase Roja y conectar la capa de presentación con el dominio.
- **Prompt (paráfrasis fiel):** > "Actúa como Senior Flutter Developer. Implementa el `game_bloc.dart`. Inyecta los 7 Casos de Uso por constructor. Usa `on<Event>` para manejar la lógica de estado, asegurando un *early return* si el evento requiere que el juego esté en curso (`GamePlaying`) pero no lo está. Llama al `GameStateMapper` para emitir los nuevos estados."
- **Resultado obtenido:** Se generó el código del BLoC estructurando limpiamente los *handlers* privados para cada evento.
- **Modificaciones del equipo:** Ninguna en esta fase directa; el código se sometió inmediatamente a evaluación de pruebas.
- **Verificación:** Ejecución de `flutter test`. Las pruebas de la Entrada #18 pasaron a verde, validando que el BLoC cumplía inicialmente con los requisitos de negocio previstos.

### Entrada #[51] — Auditoría Técnica y Refactorización (Code Review)

- **Fecha / autor:** 08-07-2026 / Alberto Monasterio
- **Herramienta:** LLM (Roles: Gwen - Tech Lead / Kimi K2.7 Code - Coder)
- **Rol en el flujo:** Arquitecto / Revisor de Código
- **Tarea/problema:** Someter el BLoC a un Code Review estricto para detectar violaciones arquitectónicas, lógica *hardcodeada* o vulnerabilidades (bugs silenciosos) antes de integrarlo a la rama principal.
- **Prompt (paráfrasis fiel a Gwen):** > "Actúa como Tech Lead. Audita la implementación del Issue #10. ¿Kimi cumplió con Clean Architecture? ¿Hay *code smells*? Emite un veredicto."
- **Resultado obtenido:** La IA (Gwen) detectó 3 *Code Smells* (2 críticos, 1 menor):
    1. Progreso *hardcodeado* al ganar (no usaba `UnlockNextLevelUseCase`).
    2. Omisión de la condición de derrota por bloqueo (`DefeatReason.noMovesAvailable`).
    3. *Workaround* peligroso para falsear el `CommandHistory`, rompiendo el *Single Source of Truth*.
- **Modificaciones del equipo:** 
    1. Se instruyó a la IA (Kimi) a refactorizar, integrando `CollisionValidator` y moviendo el `CommandHistory` de la Sesión directamente al estado `GamePlaying`.
    2. Se exigió la actualización de las pruebas para inyectar los nuevos Casos de Uso y validar el escenario de derrota por bloqueo.
    3. Se resolvieron advertencias del linter manualmente (`no_leading_underscores_for_local_identifiers` en los tests).
    4. **Resolución de Conflictos:** Durante la preparación del Pull Request, se resolvió manualmente un conflicto de fusión en `UnlockNextLevelUseCase` priorizando la versión robusta de la rama `develop`.
- **Verificación:** Nueva auditoría de la Tech Lead obteniendo la aprobación final (LGTM). Ejecución final de `flutter test` (100% verde) y `flutter analyze` (sin *warnings*). Commit final de refactorización y Push exitoso a repositorio remoto.

### Entrada #[52] — Auditoría Automatizada y Refactorización Final (Issue #10)

- **Fecha / autor:** 08-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode(Roles: Gwen - Tech Lead / Kimi K2.7 Code - Coder) y GitHub Copilot
- **Rol en el flujo:** Arquitecto / Desarrollador
- **Tarea/problema:** Evaluar y resolver tres advertencias arquitectónicas detectadas por GitHub Copilot en el `GameBloc` (constructor con parámetros privados, silenciamiento global de errores y resultados de progreso ignorados), y posteriormente reparar la suite de pruebas rota por los cambios de firma.
- **Prompt (paráfrasis fiel):** > "Para Gwen: Analiza 3 sugerencias de Copilot sobre `game_bloc.dart` y proporciona instrucciones de refactorización detalladas. / Para Kimi: Aplica los 3 cambios exigidos por la Tech Lead (constructores públicos, manejo selectivo de errores con `GameError` y log de fallos en el `UnlockNextLevelUseCase`). Luego, actualiza `game_bloc_test.dart` eliminando los guiones bajos en la instanciación."
- **Resultado obtenido:** `GameBloc` refactorizado con inyección de dependencias pública y un manejo de errores robusto que diferencia entre fallos de dominio esperados e inesperados. Las pruebas unitarias fueron actualizadas exitosamente para la nueva firma del constructor.
- **Modificaciones del equipo:** Gestión manual de control de versiones. Se resolvió un commit de fusión (Merge Commit) interactuando directamente con el editor Vim en la terminal para sincronizar la rama local con el repositorio remoto tras detectar un conflicto de desincronización por un `git pull`.
- **Verificación:** Ejecución final de `flutter test` con 100% de éxito y subida exitosa (Push) de los commits finales a la rama `10-game-state-management`.


### Entrada #[53] — Mantenimiento de Tests por Cambio de Firmas (Issue #10)

- **Fecha / autor:** 08-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode (Rol: Kimi K2.7 Code - Coder)
- **Rol en el flujo:** Desarrollador / Ingeniero de Calidad
- **Tarea/problema:** Reparar la suite de pruebas `game_bloc_test.dart`, la cual presentaba errores de compilación tras la refactorización arquitectónica que expuso los parámetros del constructor del `GameBloc` (cambio de variables privadas a públicas).
- **Prompt (paráfrasis fiel):** > "Actúa como Senior Flutter Developer. Actualiza el archivo de pruebas `game_bloc_test.dart` para que la inicialización de `GameBloc` utilice los nuevos nombres de parámetros públicos sin el guion bajo inicial (ej. pasando de `_loadLevelUseCase` a `loadLevelUseCase`). Entrégame el código listo para compilar."
- **Resultado obtenido:** La IA identificó y reemplazó correctamente todos los parámetros de instanciación dentro de los bloques de configuración (*Arrange*) de cada test, adaptando los *mocks* y *fakes* a la nueva firma pública del constructor.
- **Modificaciones del equipo:** Integración del código en el entorno local. Esto se realizó tras la resolución manual de un bloqueo en la terminal (editor Vim) para completar un `git pull` pendiente. 
- **Verificación:** Ejecución exitosa de `flutter test` (pruebas 100% en verde) y validación final mediante `git push` a la rama `10-game-state-management`, cerrando formalmente el desarrollo del Issue.

### Entrada #[54] — Fase 1: Planificación Arquitectónica (Issue #11)

- **Fecha / autor:** 09-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode(Rol: Kimi K2.7 Code - Coder) (Rol: Gwen - Tech Lead)
- **Rol en el flujo:** Arquitecto
- **Tarea/problema:** Diseñar la arquitectura, los contratos (Eventos y Estados) y la estrategia de pruebas para `ProgressBloc` y `MenuBloc`, garantizando el uso de `sealed classes` y `Result<T>`.
- **Prompt (paráfrasis fiel):** > "Actúa como Tech Lead. Genera un Plan de Implementación Arquitectónico detallado para ProgressBloc y MenuBloc. Define el propósito, dependencias, contratos exactos y flujo lógico. Propón también una estrategia de testing AAA con `bloc_test`. No generes código de implementación."
- **Resultado obtenido:** Un documento de diseño exhaustivo con escenarios de prueba precisos y tres propuestas de UX críticas: *early-return* para cargas redundantes de progreso, transiciones sin estado de carga intermedio al completar niveles, y refrescos silenciosos para el menú.
- **Modificaciones del equipo:** Revisión del documento y aprobación de las tres decisiones de diseño para mantener la fluidez en la UI. Se eliminó la sección de preguntas del prompt final para evitar confusiones en el modelo Coder.
- **Verificación:** Aprobación del diseño antes de pasar a la fase de codificación.

---

### Entrada #[55] — Fase 2: Contratos y TDD Rojo (Issue #11)

- **Fecha / autor:** 09-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode(Rol: Kimi K2.7 Code - Coder)
- **Rol en el flujo:** Desarrollador
- **Tarea/problema:** Ejecutar la Fase Roja del TDD creando exclusivamente los contratos inmutables y los archivos de prueba basados en el plan de la Tech Lead.
- **Prompt (paráfrasis fiel):** > "Actúa como Senior Flutter Developer. Basándote en el documento de diseño adjunto y las 3 reglas de UX aprobadas, genera el código de los contratos (eventos y estados para ambos BLoCs) y los 2 archivos de pruebas unitarias implementando los fakes y escenarios AAA. No escribas la implementación de los BLoCs."
- **Resultado obtenido:** 6 archivos generados correctamente: los 4 archivos de contratos utilizando `sealed class` y `Equatable`, y los 2 archivos de prueba configurados con los fakes manuales y las aserciones de estado esperadas.
- **Modificaciones del equipo:** Integración en el entorno local y ejecución de la suite de pruebas para confirmar el fallo esperado.
- **Verificación:** `flutter test` falló como era esperado (Fase Roja confirmada), validando que los tests están listos para guiar el desarrollo.

---

### Entrada #[56] — Fase 3: Implementación y TDD Verde (Issue #11)

- **Fecha / autor:** 09-07-2026 / Alberto Monasterio
- **Herramienta:** LLM (Rol: Kimi K2.7 Code - Coder)
- **Rol en el flujo:** Desarrollador
- **Tarea/problema:** Escribir la lógica de producción de los BLoCs para hacer pasar los tests unitarios, respetando las reglas de UX y la inyección de dependencias.
- **Prompt (paráfrasis fiel):** > "Ejecuta la Fase Verde del TDD. Escribe el código de producción completo para `progress_bloc.dart` y `menu_bloc.dart`. Evalúa de forma exhaustiva los `Result.Success` y `Result.Error` de los Use Cases inyectados. Respeta estrictamente las reglas de idempotencia y refrescos silenciosos."
- **Resultado obtenido:** Implementación completa de ambos BLoCs manejando correctamente los *early-returns* y las emisiones de estado condicionales requeridas por la arquitectura. Los tests pasaron exitosamente.
- **Modificaciones del equipo:** Resolución manual de advertencias detectadas por `flutter analyze`. Se refactorizaron los constructores para usar inicializadores formales (`prefer_initializing_formals`) y se eliminaron importaciones no utilizadas (`unused_import`).
- **Verificación:** Ejecución exitosa de `flutter test` (100% en verde) y validación de código limpio con `flutter analyze`.

---

### Entrada #[57] — Fase 4: Auditoría y Code Review (Issue #11)

- **Fecha / autor:** 09-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode(Gwen - Tech Lead)
- **Rol en el flujo:** Ingeniero de Calidad / Tech Lead
- **Tarea/problema:** Auditar el código de producción generado en la Fase Verde para confirmar que el desarrollador (Kimi) no ignoró las directrices de arquitectura ni las reglas de UX.
- **Prompt (paráfrasis fiel):** > "Actúa como Tech Lead experta en Clean Architecture. Audita el código adjunto de ProgressBloc y MenuBloc. Verifica de forma estricta el cumplimiento de la idempotencia, el manejo fluido de la UX sin pantallas de carga innecesarias y el refresco silencioso. Entréga tu veredicto o correcciones."
- **Resultado obtenido:** Veredicto de "Aprobado". La IA verificó exitosamente que las validaciones de estado previo y los *early-returns* estaban implementados correctamente en los handlers de los eventos.
- **Modificaciones del equipo:** Integración final en GitHub.
- **Verificación:** Apertura exitosa del Pull Request enlazado al Issue #11 a través de GitHub CLI para su posterior squash & merge en `develop`.

---

### Entrada #[58] — Diseño Arquitectónico del Sistema de Audio

- **Fecha / autor:** 12-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode(Qwen 3.7 Max)
- **Rol en el flujo:** Tech Lead / Software Architect.
- **Tarea/problema:** Diseñar el blueprint arquitectónico para el motor de audio (BGM y SFX) del juego garantizando transiciones limpias, persistencia, inyección segura y testing, respetando la Clean Architecture.
- **Prompt (paráfrasis fiel):** > "Actúa como Tech Lead. Genera un Plan de Implementación Arquitectónico detallado para el Issue #6: Audio System usando audioplayers. Define los contratos, enums, persistencia, gestión de estado con Cubit y fakes manuales para los tests."
- **Resultado obtenido:** La IA generó un plan de diseño estructurado que contemplaba 10 archivos nuevos, la ubicación exacta de las inyecciones de dependencias y decisiones arquitectónicas sólidas (ej. granularidad del mute global, evitar librerías de mocks usando fakes manuales, inyección nullable en GameBloc).
- **Modificaciones del equipo:** Ninguna. El plan arquitectónico fue revisado y aprobado tal cual para pasar a la fase de implementación de código.
- **Verificación:** Plan coherente con los principios de Clean Architecture del proyecto, listo para ser consumido por el modelo generador de código.

---

### Entrada #[59] — Generación e Implementación de Código de Producción (Audio)

- **Fecha / autor:** 12-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Generación de código base y suite de pruebas en Flutter/Dart.
- **Tarea/problema:** Traducir el plan arquitectónico del sistema de audio a código funcional en fases para no desbordar el contexto, cubriendo infraestructura (`audioplayers`), manejo de estado (`Cubit`), inyección y pruebas.
- **Prompt (paráfrasis fiel):** > "Actúa como Senior Flutter Developer. Implementa el código de producción del plan arquitectónico en fases: 1. Core e infraestructura, 2. State Management e integración UI, 3. Suite de tests. Sigue estrictamente el patrón AAA y nomenclatura 'when...' para las pruebas."
- **Resultado obtenido:** Generación exitosa de los 10 archivos nuevos y modificación de los archivos existentes solicitados (`app.dart`, `service_locator.dart`, etc.). El código cumplió con la estructura requerida.
- **Modificaciones del equipo:** Durante el Code Review se detectaron omisiones e inconsistencias de la IA, requiriendo las siguientes refactorizaciones e intervenciones:
  1. **Corrección de Triggers Musicales:** Se detectó que la IA definió los temas musicales pero no los disparó en la UI. Se instruyó un parche para disparar explícitamente `playBgm(AudioTrack.menuTheme)` al cargar el menú principal.
  2. **Higiene de Memoria (Lifecycle):** Se agregó manualmente la ejecución de `sl<AudioService>().stopBgm()` en el método `dispose()` de la `VictoryScreen` para evitar fugas de memoria y que las pistas se superpusieran.
  3. **Estabilización de Imports:** Sustitución de rutas relativas (`../../../../`) frágiles generadas por Kimi, por importaciones de paquete absolutas (`package:arrowconmango_front/...`) en el `GameBloc`.
- **Verificación:** Código compilando sin errores, manejo de recursos limpios en el ciclo de vida de los widgets y suite de pruebas en verde.

---

### Entrada #[60]— Planificación y Auditoría de SFX (Flecha Bloqueada)

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** Qwen (Qwen3.7 Max)
- **Rol en el flujo:** Tech Lead / Code Reviewer.
- **Tarea/problema:** Diseñar el plan de acción para inyectar un feedback de audio (`block.wav`) al fallar el trazado de una flecha (`PathBlockedFailure`), y posteriormente auditar la implementación para asegurar que no rompiera la suite de pruebas existente.
- **Prompt (paráfrasis fiel):** > "Planifica cómo agregar el sonido block.wav cuando una flecha está bloqueada, identificando los archivos y líneas exactas. Tras la implementación, verifica leyendo los archivos que los cambios se hayan realizado correctamente según el plan y revisa el impacto en los tests."
- **Resultado obtenido:** Qwen identificó con precisión los 3 archivos a modificar (`sfx_clip.dart`, `game_bloc.dart`, y el nuevo asset). En la fase de auditoría posterior, analizó los archivos locales mediante herramientas de lectura (`Glob`, `Grep`) y determinó que la implementación era correcta, confirmando que el `FakeAudioService` y el archivo `game_bloc_test.dart` no requerían refactorización debido a la inyección nullable del servicio.
- **Modificaciones del equipo:** Ninguna. Se aprobó tanto el plan inicial como el veredicto de la auditoría.
- **Verificación:** Análisis estático y lógica de pruebas validados teóricamente por la IA antes de la confirmación manual.

---

### Entrada #[61] — Implementación de Código y Assets para SFX (Bloqueo)

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Senior Flutter Developer.
- **Tarea/problema:** Ejecutar la implementación del código basándose en el plan de Qwen: modificar el enum, inyectar la llamada al servicio de audio en el BLoC y generar el asset de audio correspondiente.
- **Prompt (paráfrasis fiel):** > "Ejecuta el plan trazado por Qwen: agrega el archivo de audio, modifica el enum SfxClip con su respectivo assetPath, y coloca la llamada '_audioService?.playSfx(SfxClip.block);' exactamente dentro de la condición PathBlockedFailure en el GameBloc."
- **Resultado obtenido:** Kimi modificó `lib/core/audio/sfx_clip.dart` añadiendo el caso `block`, inyectó la línea de código solicitada en la línea 204 de `lib/features/game/presentation/bloc/game_bloc.dart`, y generó el asset de audio de 120 ms (`assets/audio/sfx/block.wav`).
- **Modificaciones del equipo:** Ninguna. El código y el asset generados fueron precisos y se integraron sin necesidad de refactorización manual.
- **Verificación:** Código compilando a la perfección. `flutter analyze` sin errores y `flutter test` aprobando exitosamente la suite de 288 pruebas.



### Entrada #[62] — Diagnóstico y Planificación de Fixes de Audio (Focus y UI)

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode (Qwen 3.7 Max) 
- **Rol en el flujo:** Tech Lead / Diagnóstico.
- **Tarea/problema:** Resolver dos bugs reportados: 1) La música de fondo (BGM) se interrumpía cada vez que sonaba un efecto de sonido (SFX). 2) El activo `SfxClip.click` existía pero el sonido nunca se reproducía al interactuar con la interfaz del usuario.
- **Prompt (paráfrasis fiel):** > "Necesito un plan de acción para solucionar dos problemas relacionados con la gestión de audio en mi proyecto:

Interrupción de audio (Ducking/Prioridades): Actualmente, al reproducir sonidos de efectos (SFX), la música de fondo (Theme) se corta o detiene por completo. Necesito implementar un sistema para que la música se mantenga como capa de fondo mientras los SFX se reproducen simultáneamente sin interrupciones.

Depuración de eventos (Click SFX): El evento de sonido asociado al 'clic' no se escucha en el juego. Necesito un procedimiento paso a paso para verificar dónde está asignado, cómo validar si el archivo de audio está correctamente vinculado en el motor y cómo confirmar si el evento se está disparando correctamente en el código.

Por favor, estructura el plan en: (a) Diagnóstico, (b) Posibles causas técnicas y (c) Pasos para la implementación de la solución."
- **Resultado obtenido:** Qwen diagnosticó correctamente que el paquete `audioplayers` en Android solicita *audio focus* por defecto para cada reproductor, causando la interrupción. Trazó un plan para modificar el `AudioContext` de los SFX a `AudioFocus.none`. Adicionalmente, escaneó el código identificando que `SfxClip.click` era código muerto, y listó las 4 pantallas de UI que requerían la inyección del sonido en sus botones.
- **Modificaciones del equipo:** Ninguna. El plan fue enviado directamente a la IA codificadora.
- **Verificación:** Diagnóstico certero del comportamiento nativo de Android dentro de Flutter.

---

### Entrada #[63] — Ejecución de Fixes de Audio y Autocorrección de API

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Senior Flutter Developer.
- **Tarea/problema:** Ejecutar el plan de fixes para el *audio focus* y el cableado de los sonidos de interfaz en la UI, garantizando que las pruebas no se rompieran.
- **Prompt (paráfrasis fiel):** > "Ejecuta el plan trazado por Qwen: Configura el AudioContext para que el BGM mantenga el focus y los SFX no lo pidan, y agrega el sonido SfxClip.click a todos los botones de las pantallas mencionadas."
- **Resultado obtenido:** Kimi implementó las configuraciones en `audio_service_impl.dart` e inyectó `playSfx(SfxClip.click)` en los `onPressed` de `main_menu_screen`, `victory_screen`, `defeat_screen` y `settings_screen`. Además, actualizó `defeat_screen_test.dart` y `settings_screen_test.dart` envolviéndolos en un `RepositoryProvider<AudioService>` inyectando el `FakeAudioService` para mantener la estabilidad.
- **Modificaciones del equipo:** El modelo Kimi realizó una **autocorrección** del plan original proporcionado por Qwen. Identificó que en la versión 6.8.1 de `audioplayers`, la API correcta es `AndroidAudioFocus` y no `AudioFocus`, aplicando la corrección directamente en el código de producción (`AndroidAudioFocus.gain` y `AndroidAudioFocus.none`).
- **Verificación:** Código compilado sin errores de sintaxis o de obsolescencia de API. `flutter analyze` en verde y la suite completa de 288 tests (`flutter test`) aprobada con éxito.

---

### Entrada #[64] — Diagnóstico y Planificación de Transiciones de Audio

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode(Qwen 3.7 Max) 
- **Rol en el flujo:** Tech Lead / Diagnóstico.
- **Tarea/problema:** Corregir un solapamiento de pistas de audio (el tema musical del nivel continuaba reproduciéndose tras la victoria/derrota y al volver al menú principal) y un sonido de interfaz faltante al seleccionar los niveles.
- **Prompt (paráfrasis fiel):** > "Actúa como un desarrollador de videojuegos experto en Flutter. Estoy experimentando dos fallos en mi sistema de audio que necesito corregir:

Falta de feedback de audio: Al hacer clic en los botones de selección de nivel, el sonido no se reproduce. Necesito ayuda para diagnosticar por qué no se dispara el evento o si hay un error de vinculación en el componente de UI.

Solapamiento de música (Ducking/Persistencia): El tema musical del nivel no se detiene al alcanzar la pantalla de victoria o derrota, ni al volver al menú principal; esto provoca que se superponga con otros sonidos.

¿Podrías ayudarme a estructurar un plan para solucionar esto? Necesito entender cómo implementar un sistema de gestión de audio (o AudioManager) que controle correctamente las transiciones, detenga la música según el estado del juego y corrija el disparo de los sonidos de interfaz."
- **Resultado obtenido:** La IA identificó la causa raíz del solapamiento: los estados finales (`_emitVictoryState` y `_emitDefeatState`) disparaban los SFX pero nunca invocaban explícitamente la detención del BGM. Trazó un plan de tres pasos: inyectar `stopBgm()` en ambos estados dentro del `GameBloc` y agregar el reproductor de SFX en el `onTap` del `LevelCard`.
- **Modificaciones del equipo:** Ninguna. El diagnóstico fue preciso y el plan se envió directamente a la IA codificadora.
- **Verificación:** Auditoría lógica de las transiciones de estados completada correctamente; no se requirieron cambios en la `DefeatScreen` ni `VictoryScreen` para manejar el BGM anterior.

---

### Entrada #[65] — Ejecución de Fixes de Transiciones y UI Audio

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Senior Flutter Developer.
- **Tarea/problema:** Modificar la lógica de negocio y la interfaz de usuario basándose en el plan de diagnóstico para detener el tema musical a tiempo y cablear los sonidos de los botones.
- **Prompt (paráfrasis fiel):** > "Ejecuta los tres fixes del plan de Qwen: Añade la instrucción de detener el BGM en las funciones de victoria y derrota en el GameBloc, y aplica el sonido de click en la selección de niveles."
- **Resultado obtenido:** Kimi ejecutó la implementación añadiendo `_audioService?.stopBgm()` justo antes de los disparadores de efectos en `game_bloc.dart` (líneas 430 y 457 aprox.). Adicionalmente, importó los servicios necesarios en `level_selection_screen.dart` e inyectó `context.read<AudioService>().playSfx(SfxClip.click)` en el evento de navegación hacia el nivel.
- **Modificaciones del equipo:** Ninguna. La ejecución fue exacta y respetó las firmas de los métodos existentes.
- **Verificación:** Código estable e integrado. El análisis estático (`flutter analyze`) no arrojó errores y la ejecución de la suite de 288 pruebas (`flutter test`) fue aprobada sin requerir alteraciones en los fakes ni mocks.




### Entrada #[66] — Diagnóstico de Ciclo de Vida y Race Conditions (Audio)

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode(Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Tech Lead / Diagnóstico Arquitectónico.
- **Tarea/problema:** Resolver dos fallos graves: 1) La música del juego continuaba sonando en segundo plano cuando se minimizaba la aplicación. 2) La música del menú principal no se reproducía al regresar desde la pantalla de victoria/derrota.
- **Prompt (paráfrasis fiel):** > "Actúa como un desarrollador experto en lógica de audio y manejo de estados en aplicaciones. Tengo un problema de gestión de audio: la música de fondo se mantiene sonando incorrectamente cuando navego a los resultados, y la música del menú no se reanuda al regresar desde dichos resultados.

Por favor, realiza lo siguiente:

Análisis de causa raíz: Explica por qué este tipo de conflictos suelen ocurrir en la gestión de estados (Global vs. Local).

Plan de acción técnico: Diseña un flujo lógico (paso a paso) para gestionar las transiciones de audio, asegurando que la música del menú se detenga al entrar a resultados y se reinicie solo al volver.
- **Resultado obtenido:** Qwen trazó un plan de 6 pasos. Para el *background*, diseñó la adición de los métodos `pause()` y `resume()` atados al `AppLifecycleState` de Flutter. Para el problema del menú, diagnosticó una *race condition*: el método `dispose()` de la pantalla saliente ejecutaba un `stopBgm()` que mataba la pista que la pantalla entrante acababa de iniciar. Ordenó eliminar dichos `dispose()`.
- **Modificaciones del equipo:** Ninguna. El diagnóstico fue impecable y abordó el ciclo de vida nativo del framework.
- **Verificación:** Plan coherente y listo para ejecución sin romper la arquitectura.

---

### Entrada #[67] — Ejecución de Fixes de Lifecycle y Limpieza de Pantallas

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Senior Flutter Developer.
- **Tarea/problema:** Codificar la vinculación del sistema de audio al ciclo de vida de la app y refactorizar las pantallas eliminando los métodos que causaban conflictos de estado.
- **Prompt (paráfrasis fiel):** > "Aplica los fixes de audio trazados en el plan: Agrega pause/resume al AudioService y app.dart, actualiza los fakes de los tests, y elimina los bloques dispose() conflictivos de la VictoryScreen y MainMenuScreen."
- **Resultado obtenido:** Kimi modificó 6 archivos exactos. Implementó la lógica de pausa con manejo de excepciones (try/catch), estructuró un `switch` reactivo en `app.dart` para manejar los estados `paused/hidden/resumed/detached`, actualizó el `FakeAudioService` con contadores para las pruebas, y purgó las pantallas de los *overrides* innecesarios.
- **Modificaciones del equipo:** Ninguna. La ejecución respetó estrictamente las reglas del State Management y los principios de testing.
- **Verificación:** Código robusto compilando a la perfección. La herramienta de análisis estático (`flutter analyze`) validó la limpieza y la suite de pruebas (`flutter test`) mantuvo sus 288 tests en verde.


### Entrada #[68] — Diagnóstico de Solapamiento de Audio en Navegación

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode(Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Tech Lead / Diagnóstico.
- **Tarea/problema:** Identificar y solucionar la causa raíz del solapamiento del BGM al navegar hacia el menú principal desde diferentes flujos (partida en curso, victoria y derrota).
- **Prompt (paráfrasis fiel):** > "Estoy enfrentando un problema de solapamiento de audio (Race Condition) al navegar hacia el menú desde múltiples rutas. El audio de fondo anterior no se detiene correctamente o se duplica al entrar.

Tu tarea:

Análisis de arquitectura: Ayúdame a identificar por qué la lógica actual de navegación está permitiendo que múltiples instancias de AudioSource coexistan o por qué los disparadores (triggers) no están limpiando el estado anterior.

Auditoría de flujo: Define una lista de verificación (checklist) para rastrear dónde puede estar fallando el evento de 'detención' del audio durante la transición de rutas.

Propuesta de solución robusta: Diseña una arquitectura basada en un 'Audio Manager Centralizado' que utilice un sistema de 'Prioridades de Estado' o 'Event Bus'.

Prevención de disparos múltiples: Explícame cómo puedo implementar un mecanismo de 'debounce' o verificación de exclusividad para asegurar que, sin importar la ruta de entrada, solo exista un proceso de audio activo."
- **Resultado obtenido:** Qwen identificó que las rutas directas de navegación (`context.go(AppRoutes.menu)`) en `GameScreen`, `VictoryScreen` y `DefeatScreen` no invocaban la detención del audio saliente. Diseñó un plan de 4 pasos para inyectar llamadas a `stopBgm()` en cada botón de navegación, más una capa de seguridad en el `didChangeDependencies()` del `MainMenuScreen` para aniquilar cualquier BGM residual.
- **Modificaciones del equipo:** Ninguna. El diagnóstico cubrió exhaustivamente todas las rutas posibles del usuario.
- **Verificación:** Lógica de navegación validada teóricamente, abordando correctamente el flujo del ciclo de vida de los widgets.

---

### Entrada #[69] — Ejecución de Fixes de Navegación de Audio

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Senior Flutter Developer.
- **Tarea/problema:** Implementar la lógica de detención de audio en los *callbacks* de los botones de navegación y en el ciclo de vida del menú principal, asegurando el acceso seguro al contexto.
- **Prompt (paráfrasis fiel):** > "Aplica el plan de 4 pasos de Qwen: Añade stopBgm() en el didChangeDependencies del menú principal y en los callbacks onPressed de los botones de navegación en GameScreen, VictoryScreen y DefeatScreen."
- **Resultado obtenido:** Kimi modificó los 4 archivos indicados. Importó el `AudioService` donde era necesario, inyectó las llamadas seguras mediante `context.read<AudioService>().stopBgm()` en los botones de salida, y aplicó el operador de cascada (`..stopBgm()..playBgm()`) en la inicialización del menú.
- **Modificaciones del equipo:** Ninguna. La integración fue limpia y respetó la inyección de dependencias de la UI.
- **Verificación:** Código compilado sin incidencias. `flutter analyze` reportó "No issues found", asegurando que no se introdujeron errores de linting o nulos.

---

### Entrada #[70] — Arquitectura Global y Resolución de Conflictos (Audio System)

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode(Qwen 3.7 Max)
- **Rol en el flujo:** Tech Lead / Software Architect.
- **Tarea/problema:** Diseñar la arquitectura completa del motor de audio (BGM y SFX) y diagnosticar/resolver problemas complejos de integración en Flutter (manejo del ciclo de vida, focus de audio nativo en Android y race conditions en la navegación).
- **Prompt (paráfrasis fiel):** > "Planifica la implementación del sistema de audio completo. Diagnostica y resuelve los problemas de interrupción entre BGM y SFX, la persistencia de la música en background, los solapamientos de pistas al cambiar de pantallas y diseña la estructura de tests."
- **Resultado obtenido:** Qwen definió la interfaz `AudioService` y la estrategia con `audioplayers`. Estructuró la persistencia mediante `AudioSettingsCubit` e Hive. Resolvió el conflicto nativo de Android configurando el `AudioFocus` diferenciado (gain para BGM, none para SFX). Además, ideó soluciones defensivas como el "generation counter" y el rediseño de las transiciones de BGM empujando la detención del audio desde los puntos de navegación (`GameBloc`, `MainMenuScreen`, etc.) y atando el reproductor al `AppLifecycleState`.
- **Modificaciones del equipo:** El equipo validó las decisiones arquitectónicas paso a paso, priorizando el enfoque defensivo (ej. matar procesos de audio explícitamente en la navegación) antes de pasar la directriz al modelo generador de código.
- **Verificación:** Arquitectura sólida, escalable y libre de fugas de memoria o deadlocks lógicos.

---

### Entrada #[71] — Implementación Integral del Motor de Audio y Testing

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Senior Flutter Developer.
- **Tarea/problema:** Traducir las directrices arquitectónicas a código de producción robusto, integrando el motor en toda la interfaz de usuario, inyectando dependencias, y generando una suite de pruebas coherente.
- **Prompt (paráfrasis fiel):** > "Implementa el código del sistema de audio según la arquitectura: crea el AudioServiceImpl con audioplayers, el pool de SFX con precaching, maneja el app lifecycle, integra los sonidos en el GameBloc y las pantallas, y crea el FakeAudioService para los tests."
- **Resultado obtenido:** Kimi desarrolló la implementación completa del sistema. Codificó el soporte de BGM en loop y el pool de SFX (`click`, `arrowExit`, `victory`, `defeat`, `block`). Integró exitosamente el control de mute/unmute interactuando con la persistencia local. Añadió los triggers de audio a lo largo de todas las pantallas (`MainMenuScreen`, `VictoryScreen`, `DefeatScreen`) y dentro de la lógica del `GameBloc`. Además, construyó el `FakeAudioService` e implementó logs de depuración temporales para monitorear las transiciones.
- **Modificaciones del equipo:** Se aplicaron autocorrecciones de API (ej. adaptación a `AndroidAudioFocus` específico de la versión de la librería) y se reajustaron importaciones relativas por absolutas durante el proceso de estabilización. Se inyectaron manualmente *placeholders* de audio y el asset real `block.wav`.
- **Verificación:** Compilación exitosa sin incidencias en análisis estático. La suite completa de pruebas (unitarias y de widgets) se ejecutó en verde gracias a la correcta inyección del Fake.

---

### Entrada #[72] — Planificación Arquitectónica de Internacionalización (i18n)

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode(Modelo: Qwen 3.7 Max)
- **Rol en el flujo:** Tech Lead / Software Architect.
- **Tarea/problema:** Diseñar el plan de implementación para el soporte bilingüe (Issue #15) utilizando herramientas nativas, garantizando la seguridad de tipos y preservando la estabilidad de las pruebas existentes.
- **Prompt (paráfrasis fiel):** > "Genera un Plan de Implementación paso a paso para el Issue #15 usando `gen-l10n` y archivos `.arb`. Incluye configuración, estructura de archivos, estrategia de refactorización de pantallas, y una estrategia de testing estricta con el patrón AAA y semántica when... then..."
- **Resultado obtenido:** Qwen entregó un plan exhaustivo en 6 fases. Mapeó con precisión absoluta todas las pantallas y widgets que contenían textos hardcodeados. Diseñó la integración del `LocaleCubit` para el cambio dinámico de idioma en la UI y previó la ruptura en la suite de pruebas, diseñando el helper `pumpLocalizedApp` para inyectar los delegados de localización en los tests de widgets afectados.
- **Modificaciones del equipo:** Ninguna. El plan fue aprobado por su cobertura total de los casos de borde.
- **Verificación:** Plan coherente y listo para ejecución.

---

### Entrada #[73] — Ejecución de Internacionalización y Autocorrección de SDK

- **Fecha / autor:** 14-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Senior Flutter Developer.
- **Tarea/problema:** Ejecutar la refactorización masiva de las pantallas para inyectar las traducciones, implementar los archivos de recursos, y actualizar la suite de pruebas para soportar el nuevo contexto localizado.
- **Prompt (paráfrasis fiel):** > "Ejecuta estrictamente el plan de implementación de Qwen. Crea los archivos `.arb`, refactoriza todas las pantallas sin dejar textos en duro, implementa el patrón AAA en los tests nuevos y actualiza los tests de widget existentes con el helper de localización."
- **Resultado obtenido:** Kimi ejecutó todas las fases correctamente y realizó dos mejoras arquitectónicas clave de forma autónoma. Primero, adaptó la configuración del `l10n.yaml` (`output-dir: lib/l10n`) para evitar dependencias obsoletas con los paquetes sintéticos eliminados en versiones recientes de Flutter. Segundo, creó una extensión limpia (`context.l10n`) para manejar la nulidad de `AppLocalizations.of(context)`. Se refactorizaron exitosamente las 9 pantallas y 2 widgets.
- **Modificaciones del equipo:** Se aplicaron dos parches de configuración manuales para poder compilar el APK de producción: se actualizó la dependencia `connectivity_plus` en el `pubspec.yaml` (de la versión `^6.1.0` a `^7.2.0`), lo cual resolvió automáticamente el `pubspec.lock`, y se añadió la directiva `lint { checkReleaseBuilds = false }` en el archivo `android/app/build.gradle.kts` para evitar que las reglas estrictas de código nativo abortaran el empaquetado.
- **Verificación:** Código compilado sin errores estáticos (`flutter analyze`). La suite de pruebas creció y se mantuvo 100% estable, reportando 333 tests exitosos. Ejecución exitosa del comando de compilación final (`flutter build apk --release`).

---

### Entrada #[74] — Planificación de Inyección de Dependencias Automática (Issue #13)

- **Fecha / autor:** 15-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode(Modelo: Qwen3.7 Plus )
- **Rol en el flujo:** Tech Lead / Software Architect.
- **Tarea/problema:** Diseñar el plan de migración para reemplazar el registro manual de dependencias por generación automática de código utilizando `get_it` e `injectable`.
- **Prompt (paráfrasis fiel):** > "Genera un Plan de Implementación ultra conciso para el Issue #13 usando `get_it` e `injectable`. Ve directo al grano, incluye dependencias, setup base, guía de anotaciones por capa y la generación con `build_runner`."
- **Resultado obtenido:** Qwen analizó la arquitectura y entregó un plan exacto, diferenciando inteligentemente qué clases podían usar anotaciones (`@lazySingleton`, `@injectable`) y cuáles debían mantenerse con registro manual en módulos (como las cajas de Hive o el `AudioService` por sus requerimientos de `dispose`).
- **Modificaciones del equipo:** Ninguna.
- **Verificación:** Plan coherente, estructurado y listo para delegar.

---

### Entrada #[75] — Ejecución de Inyección de Dependencias 

- **Fecha / autor:** 15-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Senior Flutter Developer.
- **Tarea/problema:** Ejecutar la migración masiva de clases anotando Mappers, Repositories, Use Cases y Blocs en toda la arquitectura del proyecto sin consumir exceso de tokens en la respuesta.
- **Prompt (paráfrasis fiel):** > "Ejecuta estrictamente el plan de Qwen. Modifica los archivos correspondientes y corre `build_runner`. NO imprimas código fuente en tu respuesta, solo confirma la finalización."
- **Resultado obtenido:** Kimi ejecutó la refactorización silenciosamente. Generó el archivo de configuración base y añadió las etiquetas correspondientes en las capas de Data, Domain y Presentation.
- **Modificaciones del equipo:** Tras la ejecución inicial, el equipo ejecutó `flutter analyze` y detectó algunas inconsistencias (warnings) y un posible fallo de inyección en una de las clases, lo que requirió una revisión posterior.
- **Verificación:** Refactorización base aplicada correctamente.

---

### Entrada #[76] — Diagnóstico de Errores Post-Generación de DI

- **Fecha / autor:** 15-07-2026 / Alberto Monasterio
- **Herramienta:** Opencode(Qwen3.7 Plus) 
- **Rol en el flujo:** Tech Lead / Software Architect.
- **Tarea/problema:** Analizar los resultados de `flutter analyze` y revisar el código generado por Kimi para detectar y solucionar bugs de inyección y advertencias menores.
- **Prompt (paráfrasis fiel):** > "Revisa los cambios hechos por Kimi e indícame los problemas que surgen al hacer `flutter analyze`. Entrega un plan de corrección para Kimi."
- **Resultado obtenido:** Qwen detectó un fallo crítico de runtime no capturado por el linter: la clase `MoveBasedScoring` estaba intentando inyectar valores enteros (`gh<int>()`) debido a cómo `injectable` maneja los valores por defecto. Entregó un plan para mover esta clase al `register_module.dart`, además de solucionar 3 warnings (variables/imports sin usar) e ignorar reglas de formato en los BLoCs.
- **Modificaciones del equipo:** Ninguna.
- **Verificación:** Diagnóstico preciso y resolución arquitectónica limpia.

---

### Entrada #[77] — Corrección Final de Inyección de Dependencias

- **Fecha / autor:** 15-07-2026 / Alberto Monasterio
- **Herramienta:** OpenCode (Modelo: Kimi K2.7 Code)
- **Rol en el flujo:** Senior Flutter Developer.
- **Tarea/problema:** Aplicar los parches arquitectónicos identificados por Qwen para estabilizar el inyector de dependencias.
- **Prompt (paráfrasis fiel):** > "Ejecuta estrictamente el plan de corrección. Mueve el registro de `MoveBasedScoring`, resuelve los warnings, regenera con `build_runner` y valida."
- **Resultado obtenido:** Kimi limpió los imports innecesarios, ajustó la inicialización de Hive, reubicó el scoring en el módulo manual y agregó los ignoradores de linting necesarios.
- **Modificaciones del equipo:** Ninguna.
- **Verificación:** `flutter analyze` reportó 0 problemas y la suite de pruebas pasó en su totalidad. Feature completada con éxito.
                                      

## Evaluación crítica

### Porcentaje aproximado de código asistido por IA

| Componente | % IA | % Equipo (correcciones) |
|---|---|---|
| Dominio (Entidades v2, Topología, Failures, Repos, Builder, Scoring, Validaciones, Session) | 85% | 15% |
| Data Models & Mappers (5 modelos, 4 mappers, 27 tests) | 90% | 10% |
| Hive Repositories (2 repos, 5 adapters, 8 tests) | 95% | 5% |
| AOP Logging & Error Handling decorators (4 repos, BlocObserver, 6 tests) | 90% | 10% |
| BLoC (Events, States, Mappers) | ~% | ~% |
| Flutter UI (Widgets, Animaciones, Screens) | ~% | ~% |
| Configuración CI/CD (GitHub Actions) | 70% | 30% |
| Pruebas Unitarias (Dominio v2 — 44 tests) | 90% | 10% |

### Casos donde la IA produjo resultados incorrectos o subóptimos

1. **Contaminación del Dominio:** La IA importó `package:flutter/material.dart` dentro de las Entidades puras (Capa 1) para manejar colores de las celdas, violando el aislamiento de Clean Architecture. El equipo lo corrigió mapeando enumeradores a colores solo en la capa de Presentación.
2. **Uso incorrecto de Equatable:** En los estados de BLoC, omitió propiedades clave en el override de `props`, causando que los widgets no reaccionaran a cambios profundos en el tablero.
3. **Inyección de dependencias directa:** En varios componentes UI, sugirió instanciar repositorios directamente con `new HiveLocalStorageAdapter()` en lugar de utilizar el Service Locator (`get_it`), rompiendo el Principio de Inversión de Dependencias (DIP). Fue corregido manualmente en revisión.
4. **Historial de Commands ineficiente:** Guardaba clones profundos (deep copies) de todo el tablero en cada movimiento, lo cual fue optimizado manualmente por el equipo a un enfoque de deltas (guardar solo la celda cambiada).
5. **Constructor const con expresiones no constantes:** En `OverlappingArrowsFailure`, la IA generó un constructor `const` que usaba `arrowIds.join(", ")` en el `super()` call. Dart no permite invocaciones de método en expresiones constantes. Se corrigió eliminando el modificador `const` del constructor.
6. **Imports relativos frágiles en Data Models:** La IA generó imports relativos (`../../domain/entities/...`) en los mappers de la capa de datos. Con estructuras de carpetas profundas en Flutter, estos imports se rompen fácilmente al reorganizar archivos. Se corrigió manualmente usando package imports (`package:arrowconmango_front/features/game/domain/...`) para mayor robustez.
7. **Conflicto de dependencias con hive_generator:** La IA sugirió usar `hive_generator` con `build_runner` para generar TypeAdapters automáticamente, pero `hive_generator: ^2.0.1` requiere `analyzer <7.0.0` mientras que Flutter 3.44+ requiere `analyzer ^12.0.0`. Las constraints son mutuamente excluyentes. Se resolvió escribiendo los adapters manualmente y agregando `dependency_overrides: analyzer: ^12.0.0` en `pubspec.yaml`.

### Reflexión del equipo

El uso de OpenCode en el Frontend fue fundamental para acelerar la escritura de clases repetitivas (como los estados y eventos de BLoC) y armar la estructura inicial del UI en Flutter. 

Sin embargo, las decisiones algorítmicas críticas (como optimizar la búsqueda de vía libre en el grafo o manejar la memoria en el patrón Command) requirieron intervención manual constante. **La lección principal:** La IA es un excelente "tipiador" de patrones, pero no comprende intrínsecamente las reglas estrictas de Clean Architecture a menos que se le fuerce. La revisión cruzada del equipo fue indispensable para mantener las dependencias aisladas.


