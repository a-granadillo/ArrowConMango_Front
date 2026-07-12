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
- **Herramienta:** Kimi (Modelo: Programador)
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

## Evaluación crítica

### Porcentaje aproximado de código asistido por IA

| Componente | % IA | % Equipo (correcciones) |
|---|---|---|
| Dominio (Entidades v2, Topología, Failures, Repos, Builder, Scoring, Validaciones, Session) | 85% | 15% |
| Data Models & Mappers (5 modelos, 4 mappers, 27 tests) | 90% | 10% |
| Hive Repositories (2 repos, 5 adapters, 8 tests) | 95% | 5% |
| Casos de Uso y AOP Decorators | ~% | ~% |
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