# Proyecto Semestral: Desarrollo de Software

**Desarrollo de un clon del juego casual: Arrow Maze — Escape Puzzle**
* **Asignatura:** Desarrollo de Software (NRC 25783)
* **Fecha:** 02-05-2026

### Información General

| Campo | Detalle |
| :--- | :--- |
| **Modalidad** | Grupos de 3 estudiantes |
| **Referencia** | [Arrow Maze - Escape Puzzle · SayGames Ltd. · Google Play](https://play.google.com/store/apps/details?id=com.arrows.escape) |
| **Tecnología** | A definir por el equipo (Flutter, React Native, Unity, Godot, etc.) |
| **Valor total** | 20 puntos (10% de la nota de la práctica) |
| **Fecha de entrega** | Viernes 03 de julio de 2026 |
| **Uso de IA** | **PERMITIDO** con documentación obligatoria (ver Sección 7) |

---

## 1. Descripción del Juego de Referencia
**Arrow Maze — Escape Puzzle** es un juego casual desarrollado por SayGames Ltd., disponible en Google Play (más de 1.000.000 de descargas, calificación 4.7/5).

### 1.1 Mecánicas principales
* Tablero en cuadrícula (grid) con celdas que contienen flechas en cuatro direcciones (arriba, abajo, izquierda, derecha).
* El jugador toca una celda para rotar o activar la dirección de su flecha.
* Dificultad progresiva: niveles fácil, medio y difícil.
* Elementos adicionales: paredes, celdas vacías, coleccionables y tiempo límite en niveles avanzados.
* Sistema de puntuación basado en número de movimientos y tiempo empleado.
* Pantallas: inicio, selección de nivel, juego, victoria y derrota.

---

## 2. Descripción del Proyecto
El objetivo de este proyecto semestral es que los estudiantes, organizados en grupos de 3-4 personas, diseñen e implementen un clon funcional del juego Arrow Maze aplicando los principios y buenas prácticas de ingeniería de software abordados durante el curso. El proyecto contempla dos repositorios independientes:

* **Repositorio del Juego (cliente):** Aplicación móvil que implementa las mecánicas del juego.
* **Repositorio del Backend:** API REST o servicio web que gestiona usuarios, puntuaciones, niveles y progreso de juego.

> **Nota:** Ambos repositorios deben estar alojados en GitHub, con ramas protegidas, pull requests y un historial de commits limpio y semántico. Los `README` deben estar redactados siguiendo las mejores prácticas de la industria (ver Sección 6).

---

## 3. Requisitos Técnicos Obligatorios

### 3.1 Principios SOLID
Todo el código del proyecto debe evidenciar la aplicación de los principios SOLID. Cada principio usado debe estar documentado en el `README` correspondiente con al menos un ejemplo concreto extraído del código del proyecto, indicando la clase o módulo donde se aplica y la justificación de su uso.

* **S — Single Responsibility Principle (SRP):** Cada clase o módulo tiene una única razón de cambio. *(Ejemplo: separar la lógica de movimiento `PlayerMovementService` de la lógica de renderizado `PlayerRenderer` y de persistencia `PlayerRepository`).*
* **O — Open/Closed Principle (OCP):** Las entidades están abiertas a la extensión pero cerradas a la modificación. *(Ejemplo: implementar nuevos tipos de celda mediante nuevas clases que extiendan una interfaz `ICell`, sin alterar el código existente).*
* **L — Liskov Substitution Principle (LSP):** Cualquier subclase puede sustituir a su clase padre sin alterar el comportamiento. *(Ejemplo: `WallCell` y `ArrowCell` deben ser intercambiables donde se espere una `ICell`).*
* **I — Interface Segregation Principle (ISP):** Ninguna clase debe depender de métodos que no utiliza. *(Ejemplo: separar `IRenderable`, `ICollidable` e `IInteractable` en interfaces distintas).*
* **D — Dependency Inversion Principle (DIP):** Los módulos de alto nivel no dependen de los de bajo nivel; ambos dependen de abstracciones. *(Ejemplo: los casos de uso dependen de interfaces de repositorio `ILevelRepository`, no de implementaciones de bases de datos).*

### 3.2 Patrones de Diseño (GoF)
El proyecto debe implementar varios patrones de diseño, distribuidos entre las tres categorías. Se debe justificar su elección, mostrar un fragmento de código representativo y documentarlo en el `README`.

**Patrones Creacionales:**
* **Factory Method / Abstract Factory:** Creación de diferentes tipos de celdas del tablero mediante una fábrica.
* **Builder:** Construcción de niveles complejos a partir de archivos JSON o YAML.
* **Singleton:** Gestores globales de ciclo de vida único (ej. `AudioManager`, `SessionManager`).

**Patrones Estructurales:**
* **Composite:** Representar el tablero como una estructura jerárquica de `BoardGroup` y `Cell`.
* **Decorator:** Agregar comportamientos a las celdas en tiempo de ejecución (ej. `LockedCellDecorator`).
* **Adapter:** Envolver librerías externas de base de datos, análisis o redes.
* **Facade:** Proveer una interfaz simplificada para subsistemas complejos (ej. `GameServiceFacade`).

**Patrones de Comportamiento:**
* **Strategy:** Intercambiar algoritmos de generación de niveles o puntuación.
* **Observer:** Notificar eventos del juego (ej. `LevelCompleted`, `ScoreUpdated`).
* **Command:** Encapsular movimientos para soportar historial (deshacer/rehacer).
* **State:** Gestionar el ciclo de vida (`MenuState`, `PlayingState`, `GameOverState`).
* **Template Method:** Definir el esqueleto del flujo de un nivel en una clase abstracta.

### 3.3 Arquitectura CLEAN
El proyecto debe implementarse siguiendo la *Clean Architecture* de Robert C. Martin. La regla de dependencia establece que **siempre se apunta hacia adentro (hacia el dominio)**. Ninguna capa interna conoce acerca de las capas externas.

* **Capa 1 — Entidades (Domain):** Objetos de negocio fundamentales. Clases puras que no dependen de frameworks ni de capas exteriores.
* **Capa 2 — Casos de Uso (Application Layer):** Lógica de aplicación. Orquesta el flujo de datos. Dependen únicamente de interfaces definidas en esta misma capa.
* **Capa 3 — Adaptadores de Interfaz:** Convierte datos entre el dominio y frameworks externos (Presenters, Controllers, implementaciones de repositorios, Mappers).
* **Capa 4 — Frameworks e Infraestructura:** Detalles volátiles y reemplazables (Motor de juego, UI, Bases de datos locales/remotas, librerías de red).

> **Entregable obligatorio:** Diagrama de Arquitectura CLEAN generado con draw.io, PlantUML o equivalente, mostrando las cuatro capas y respetando la regla de dependencia. Debe incluirse en el `README` y en la carpeta `/docs`.

### 3.4 Programación Orientada a Aspectos (AOP)
Implementar AOP para separar las responsabilidades transversales (*cross-cutting concerns*) del código de negocio. Se debe implementar un mínimo de **un (1) aspecto**:

* **Logging y Trazabilidad:** Registrar entrada, salida y duración de métodos críticos.
* **Manejo Centralizado de Excepciones:** Gestionar fallos de red/persistencia aplicando reintentos.
* **Métricas de Rendimiento / Profiling:** Medir tiempos de ejecución de operaciones costosas.
* **Seguridad y Autorización:** Verificar sesiones activas antes de ejecutar casos de uso.
* **Caché de Resultados:** Memorización automática a consultas costosas.

*Nota: Puede realizarse sin librerías AOP, haciendo uso de estrategias SOLID vistas en clases y documentado en el `README`.*

### 3.5 Casos de Prueba
Se debe aplicar una suite de pruebas completa:

* **Pruebas Unitarias:** Probar entidades, casos de uso y servicios de forma aislada. Usar mocks/stubs. Patrón AAA (Arrange - Act - Assert). Nomenclatura: `should_[resultado_esperado]_when_[condicion]`.
* **Pruebas de Integración:** Verificar interacción entre casos de uso y repositorios reales, y endpoints del backend.
* **Pruebas de Widget / UI:** Verificar renderizado visual y navegación (solo cliente).
* **Pruebas de Contrato (Recomendadas):** Usar Pact o equivalente para contratos cliente-servidor.
* **CI/CD:** Integrar pruebas en GitHub Actions para ejecución en cada Pull Request.

---

## 4. Diagramas Obligatorios
Deben incluirse como imagen en el `README` y como archivo fuente en la carpeta `/docs`.

1. **Diagrama de Clases:** Clases principales (entidades, casos de uso, repositorios), mostrando relaciones de herencia, interfaces y asociaciones. Identificar capas CLEAN y patrones de diseño.
2. **Diagrama de Capas (CLEAN):** Representación visual de las 4 capas, flechas apuntando al centro (Regla de Dependencia) e identificación de puertos/adaptadores.

---

## 5. Funcionalidades Mínimas del Juego

### 5.1 Aplicación (Juego)
1. Pantalla de inicio con nombre, botón jugar y ajustes.
2. Selección de niveles con progreso y bloqueo.
3. Motor de juego: tablero en cuadrícula, flechas rotables, movimientos.
4. Al menos 15 niveles manuales con dificultad progresiva y distintas formas de tableros.
5. Sistema de puntuación basado en criterios definidos por el equipo.
6. Pantalla de victoria con puntuación y opción de siguiente nivel.
7. Pantalla de derrota con opción de reintentar.
8. Persistencia local del progreso.
9. Efectos de sonido y música de fondo con opción de silencio.
10. Soporte para al menos dos idiomas (español e inglés).

### 5.2 Backend (API REST)
1. Autenticación de usuarios con JWT.
2. Endpoint de sincronización de progreso.
3. Tabla de clasificación global (leaderboard).
4. Endpoint para obtener/actualizar la definición de niveles.
5. Documentación Swagger / OpenAPI.
6. Manejo adecuado de errores HTTP.

---

## 6. README y Documentación de Repositorios
Redactados en inglés, claros y profesionales.

### 6.1 Estructura mínima del `README`
* **Project Title & Badges:** Nombre, CI/CD badges, pruebas y licencia.
* **Description:** Qué es y qué tecnologías usa.
* **Demo / Screenshots:** Capturas/GIF del juego (solo repo cliente).
* **Architecture:** Explicación y diagrama de Clean Architecture embebido.
* **Design Patterns:** Tabla descriptiva y enlaces al código.
* **SOLID Principles:** Explicación y ejemplos de código.
* **AOP:** Aspectos implementados y estrategia SOLID.
* **Getting Started:** Instalación y ejecución local.
* **Running Tests:** Comandos de pruebas.
* **AI Usage Documentation:** Documentación obligatoria (Ver Sección 7).
* **Contributing:** Flujo de ramas y PRs.
* **License:** Licencia del proyecto.

### 6.2 Convenciones de Commits
Se debe usar **Conventional Commits** (en inglés). Ejemplos:
* `feat(board): add arrow rotation logic`
* `fix(player): correct movement when hitting wall`
* `test(use-case): add unit tests for MovePlayerUseCase`

---

## 7. Uso de Herramientas de Inteligencia Artificial
El uso de IA generativa está **PERMITIDO y bienvenido** (Claude, ChatGPT, Gemini, Copilot), condicionado a documentación rigurosa.

### 7.1 Documentación Obligatoria (`AI_USAGE.md`)
Cada repositorio debe incluir este archivo en la raíz con:
* **Herramientas utilizadas:** Nombre, modelo específico y rol asignado.
* **Registro por tarea:** Problema abordado, herramienta, prompt literal, resultado, modificaciones manuales realizadas y lecciones aprendidas.
* **Evaluación crítica:** Porcentaje de código asistido, fallos detectados/corregidos y reflexión sobre el impacto en productividad.

### 7.2 Mejores Prácticas (A evaluar)
* Prompt engineering efectivo.
* Revisión crítica del output (cumplimiento SOLID/CLEAN).
* Pruebas del código generado.
* Control de versiones granular (commits frecuentes).
* **Evitar dependencia ciega:** El equipo toma las decisiones arquitectónicas.
* Protección de información sensible.

> **Advertencia:** El uso de IA sin documentación equivale a falta de transparencia académica y será tratado como plagio. Si en la defensa el equipo no puede explicar el código generado, se descontarán puntos.

---

## 8. Entregables

| # | Entregable | Canal / Formato |
| :-: | :--- | :--- |
| **1** | URL del repositorio GitHub del juego (cliente) | Mensaje por Bandeja de Entrada M7 |
| **2** | URL del repositorio GitHub del backend | Mensaje por Bandeja de Entrada M7 |
| **3** | Diagrama de clases | `/docs` del repo (imagen + fuente) |
| **4** | Diagrama de capas Clean Architecture | `/docs` del repo (imagen + fuente) |
| **5** | `README.md` completo en ambos repositorios | En GitHub (rama main) |
| **6** | `AI_USAGE.md` en ambos repositorios | En GitHub (rama main) |
| **7** | Ejecutable funcional del juego (Android o iOS) | Release en GitHub |

---

## 9. Rúbrica de Evaluación (20 Puntos)

| Criterio | Descripción y nivel de logro esperado | Pts |
| :--- | :--- | :---: |
| **1. Funcionalidad del Juego** | Completamente funcional, mecánicas correctas, niveles mínimos implementados. Sin crashes. | 4 |
| **2. Principios SOLID** | Aplicados correctamente y documentados con ejemplos. Explicables en defensa. | 2 |
| **3. Patrones de Diseño** | Implementación de patrones en las 3 categorías GoF. Justificados y defendidos. | 3 |
| **4. Arquitectura CLEAN** | 4 capas respetadas, regla de dependencia estricta, diagrama completo. | 3 |
| **5. AOP** | Separación correcta de responsabilidades transversales, documentado en el README. | 2 |
| **6. Pruebas** | Pruebas unitarias (AAA), integración, contrato. Pipeline CI/CD funcional. | 2 |
| **7. Backend y API REST** | Endpoints requeridos funcionales, documentación Swagger, comunicación exitosa. | 1 |
| **8. Documentación** | READMEs en inglés/español con estructura exigida y diagramas. Conventional Commits. | 0.5 |
| **9. Documentación Uso IA** | `AI_USAGE.md` detallado, honesto, incluye prompts y evaluación crítica. | 0.5 |
| **10. Defensa individual** | Comprensión profunda de decisiones, código propio y generado por IA. | 2 |

---

## 10. Integridad Académica y Trabajo en Equipo
* Queda estrictamente prohibido copiar código de otros grupos o repositorios sin citar. La detección de plagio anula el proyecto.
* El historial de commits verificará la participación individual. Un miembro sin commits significativos recibirá una calificación reducida.

## 11. Referencias Sugeridas
* Martin, R. C. (2017). *Clean Architecture*. Prentice Hall.
* Gamma, E., et al. (1994). *Design Patterns*. Addison-Wesley.
* Martin, R. C. (2008). *Clean Code*. Prentice Hall.
* [Conventional Commits](https://www.conventionalcommits.org)
* [Clean Architecture Blog (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)