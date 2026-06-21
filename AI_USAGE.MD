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





---

## Evaluación crítica

### Porcentaje aproximado de código asistido por IA

| Componente | % IA | % Equipo (correcciones) |
|---|---|---|
| Dominio (Grafo, Entidades, Command Pattern) | ~% | ~% |
| Casos de Uso y AOP Decorators | ~% | ~% |
| BLoC (Events, States, Mappers) | ~% | ~% |
| Flutter UI (Widgets, Animaciones, Screens) | ~% | ~% |
| Configuración CI/CD (GitHub Actions) | ~% | ~% |

### Casos donde la IA produjo resultados incorrectos o subóptimos

1. **Contaminación del Dominio:** La IA importó `package:flutter/material.dart` dentro de las Entidades puras (Capa 1) para manejar colores de las celdas, violando el aislamiento de Clean Architecture. El equipo lo corrigió mapeando enumeradores a colores solo en la capa de Presentación.
2. **Uso incorrecto de Equatable:** En los estados de BLoC, omitió propiedades clave en el override de `props`, causando que los widgets no reaccionaran a cambios profundos en el tablero.
3. **Inyección de dependencias directa:** En varios componentes UI, sugirió instanciar repositorios directamente con `new HiveLocalStorageAdapter()` en lugar de utilizar el Service Locator (`get_it`), rompiendo el Principio de Inversión de Dependencias (DIP). Fue corregido manualmente en revisión.
4. **Historial de Commands ineficiente:** Guardaba clones profundos (deep copies) de todo el tablero en cada movimiento, lo cual fue optimizado manualmente por el equipo a un enfoque de deltas (guardar solo la celda cambiada).

### Reflexión del equipo

El uso de OpenCode en el Frontend fue fundamental para acelerar la escritura de clases repetitivas (como los estados y eventos de BLoC) y armar la estructura inicial del UI en Flutter. 

Sin embargo, las decisiones algorítmicas críticas (como optimizar la búsqueda de vía libre en el grafo o manejar la memoria en el patrón Command) requirieron intervención manual constante. **La lección principal:** La IA es un excelente "tipiador" de patrones, pero no comprende intrínsecamente las reglas estrictas de Clean Architecture a menos que se le fuerce. La revisión cruzada del equipo fue indispensable para mantener las dependencias aisladas.