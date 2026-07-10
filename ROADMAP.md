# Roadmap de Features - Arrow Maze Frontend

## Resumen Ejecutivo

Este roadmap divide el proyecto en **17 features independientes** organizadas por capas de Clean Architecture. Cada feature puede trabajarse en una rama separada y mergeada a `develop` sin conflictos.

**Estado actual:** Dominio v2 completo (49 tests pasando)

**Features totales:** 17  
**Estimación total:** ~112 horas de desarrollo

---

## 🎯 Features por Capa

### **CAPA 4: Infraestructura (Data Layer)**

#### GitHub #1: Data Models & Mappers
**Scope:** Modelos de datos y mappers para conversión  
**Dependencias:** Ninguna  
**Estimación:** 6 horas  
**Prioridad:** 🔴 CRÍTICA  
**Asignado:** a-granadillo

**Incluye:**
- `LevelModel` - Modelo de nivel persistente
- `BoardStateModel` - Modelo de estado del tablero
- `ArrowModel` - Modelo de flecha
- Mappers: `LevelMapper`, `BoardStateMapper`, `ArrowMapper`

**Archivos:**
```
lib/features/game/data/models/
├── level_model.dart
├── board_state_model.dart
├── arrow_model.dart
└── mappers/
    ├── level_mapper.dart
    ├── board_state_mapper.dart
    └── arrow_mapper.dart
```

**Tests:** 3 archivos de test (mappers)

**GitHub Issue:** [#1](https://github.com/a-granadillo/ArrowConMango_Front/issues/1)

---

#### GitHub #2: Local Storage - Hive Implementation
**Scope:** Persistencia local con Hive  
**Dependencias:** GitHub #1 (Data Models)  
**Estimación:** 8 horas  
**Prioridad:** 🔴 CRÍTICA  
**Asignado:** a-granadillo

**Incluye:**
- `HiveLevelRepository` - Repositorio de niveles
- `HiveProgressRepository` - Repositorio de progreso
- Configuración de Hive boxes
- TypeAdapters para modelos

**Archivos:**
```
lib/features/game/data/repositories/
├── hive_level_repository.dart
└── hive_progress_repository.dart

lib/core/database/
└── hive_config.dart
```

**Tests:** 2 archivos de test (repositories)

**GitHub Issue:** [#2](https://github.com/a-granadillo/ArrowConMango_Front/issues/2)

---

#### GitHub #3: Level Definitions (15 Niveles)
**Scope:** Definición de 15 niveles de dificultad progresiva  
**Dependencias:** GitHub #1 (Data Models)  
**Estimación:** 10 horas  
**Prioridad:** 🟡 ALTA  
**Asignado:** a-granadillo

**Incluye:**
- 5 niveles Easy (3-4 flechas)
- 5 niveles Medium (5-6 flechas)
- 5 niveles Hard (7-8 flechas)
- `LevelDefinitions` - Clase con todas las definiciones

**Archivos:**
```
lib/features/game/data/level_definitions/
├── level_definitions.dart
├── easy_levels.dart
├── medium_levels.dart
└── hard_levels.dart
```

**Tests:** 1 archivo de test (validación de niveles)

**GitHub Issue:** [#3](https://github.com/a-granadillo/ArrowConMango_Front/issues/3)

---

### **CAPA 2: Casos de Uso (Application Layer)**

#### GitHub #7: Use Cases - Game Flow
**Scope:** Casos de uso para el flujo principal del juego  
**Dependencias:** Ninguna (solo dominio)  
**Estimación:** 8 horas  
**Prioridad:** 🔴 CRÍTICA  
**Asignado:** AlbertoMonasterio

**Incluye:**
- `LoadLevelUseCase` - Cargar nivel desde repositorio
- `StartGameSessionUseCase` - Iniciar sesión de juego
- `TriggerArrowExitUseCase` - Disparar salida de flecha
- `UndoMoveUseCase` - Deshacer último movimiento
- `EvaluateGameStateUseCase` - Evaluar victoria/derrota

**Archivos:**
```
lib/features/game/domain/use_cases/
├── load_level_use_case.dart
├── start_game_session_use_case.dart
├── trigger_arrow_exit_use_case.dart
├── undo_move_use_case.dart
└── evaluate_game_state_use_case.dart
```

**Tests:** 5 archivos de test (patrón AAA, mocks de repositorios)

**GitHub Issue:** [#7](https://github.com/a-granadillo/ArrowConMango_Front/issues/7)

---

#### GitHub #8: Use Cases - Progress & Scoring
**Scope:** Casos de uso para progreso y puntuación  
**Dependencias:** GitHub #7 (para EvaluateGameStateUseCase)  
**Estimación:** 5 horas  
**Prioridad:** 🔴 CRÍTICA  
**Asignado:** AlbertoMonasterio

**Incluye:**
- `SaveLocalProgressUseCase` - Guardar progreso local
- `LoadProgressUseCase` - Cargar progreso
- `CalculateScoreUseCase` - Calcular puntuación final

**Archivos:**
```
lib/features/game/domain/use_cases/
├── save_local_progress_use_case.dart
├── load_progress_use_case.dart
└── calculate_score_use_case.dart
```

**Tests:** 3 archivos de test

**GitHub Issue:** [#8](https://github.com/a-granadillo/ArrowConMango_Front/issues/8)

---

#### GitHub #9: Use Cases - Level Management
**Scope:** Casos de uso para gestión de niveles  
**Dependencias:** Ninguna  
**Estimación:** 4 horas  
**Prioridad:** 🟡 ALTA  
**Asignado:** AlbertoMonasterio

**Incluye:**
- `GetLevelListUseCase` - Obtener lista de niveles
- `GetLevelDefinitionUseCase` - Obtener definición de nivel
- `UnlockNextLevelUseCase` - Desbloquear siguiente nivel

**Archivos:**
```
lib/features/game/domain/use_cases/
├── get_level_list_use_case.dart
├── get_level_definition_use_case.dart
└── unlock_next_level_use_case.dart
```

**Tests:** 3 archivos de test

**GitHub Issue:** [#9](https://github.com/a-granadillo/ArrowConMango_Front/issues/9)

---

### **CAPA 3/4: Presentación (BLoC + UI)**

#### GitHub #10: BLoC - Game State Management
**Scope:** BLoC para manejo de estado del juego  
**Dependencias:** GitHub #7, #8 (use cases)  
**Estimación:** 12 horas  
**Prioridad:** 🔴 CRÍTICA  
**Asignado:** AlbertoMonasterio

**Incluye:**
- `GameBloc` - BLoC principal
- `GameEvent` - Eventos (LoadLevel, TriggerExit, Undo, etc.)
- `GameState` - Estados (Initial, Loading, Playing, Victory, Defeat)
- Mappers: domain → presentation state

**Archivos:**
```
lib/features/game/presentation/bloc/
├── game_bloc.dart
├── game_event.dart
├── game_state.dart
└── mappers/
    └── game_state_mapper.dart
```

**Tests:** Tests de BLoC con bloc_test

**GitHub Issue:** [#10](https://github.com/a-granadillo/ArrowConMango_Front/issues/10)

---

#### GitHub #11: BLoC - Progress & Menu State
**Scope:** BLoC para progreso y menús  
**Dependencias:** GitHub #9 (Level Management Use Cases)  
**Estimación:** 6 horas  
**Prioridad:** 🟡 ALTA  
**Asignado:** AlbertoMonasterio

**Incluye:**
- `ProgressBloc` - BLoC de progreso
- `ProgressEvent` / `ProgressState`
- `MenuBloc` - BLoC de menú principal
- `MenuEvent` / `MenuState`

**Archivos:**
```
lib/features/game/presentation/bloc/
├── progress_bloc.dart
├── progress_event.dart
├── progress_state.dart
├── menu_bloc.dart
├── menu_event.dart
└── menu_state.dart
```

**Tests:** Tests de BLoC

**GitHub Issue:** [#11](https://github.com/a-granadillo/ArrowConMango_Front/issues/11)

---

#### GitHub #4: UI - Menu Screens
**Scope:** Pantallas de menú (Splash, MainMenu, LevelSelection, Settings)  
**Dependencias:** GitHub #11 (MenuBloc)  
**Estimación:** 6 horas  
**Prioridad:** 🟡 ALTA  
**Asignado:** a-granadillo

**Incluye:**
- `SplashScreen` - Pantalla de carga
- `MainMenuScreen` - Menú principal
- `LevelSelectionScreen` - Selección de nivel
- `SettingsScreen` - Configuración

**Archivos:**
```
lib/features/game/presentation/screens/
├── splash_screen.dart
├── main_menu_screen.dart
├── level_selection_screen.dart
└── settings_screen.dart
```

**Tests:** Widget tests

**GitHub Issue:** [#4](https://github.com/a-granadillo/ArrowConMango_Front/issues/4)

---

#### GitHub #5: UI - Game Screen
**Scope:** Pantalla principal del juego con animaciones  
**Dependencias:** GitHub #10 (GameBloc)  
**Estimación:** 15 horas  
**Prioridad:** 🔴 CRÍTICA  
**Asignado:** a-granadillo

**Incluye:**
- `GameScreen` - Pantalla de juego
- `BoardGrid` - Widget del tablero
- `ArrowWidget` - Widget de flecha con animaciones
- `GameControls` - Botones de control (undo, reset, etc.)
- Animaciones de deslizamiento

**Archivos:**
```
lib/features/game/presentation/screens/
└── game_screen.dart

lib/features/game/presentation/widgets/
├── board_grid.dart
├── arrow_widget.dart
└── game_controls.dart
```

**Tests:** Widget tests + animation tests

**GitHub Issue:** [#5](https://github.com/a-granadillo/ArrowConMango_Front/issues/5)

---

#### GitHub #12: UI - Result Screens
**Scope:** Pantallas de resultado (victoria y derrota)  
**Dependencias:** GitHub #10 (GameBloc)  
**Estimación:** 4 horas  
**Prioridad:** 🟡 ALTA  
**Asignado:** AlbertoMonasterio

**Incluye:**
- `VictoryScreen` - Pantalla de victoria
- `DefeatScreen` - Pantalla de derrota
- Animaciones de celebración

**Archivos:**
```
lib/features/game/presentation/screens/
├── victory_screen.dart
└── defeat_screen.dart
```

**Tests:** Widget tests

**GitHub Issue:** [#12](https://github.com/a-granadillo/ArrowConMango_Front/issues/12)

---

### **CAPA 1: Core (Transversales)**

#### GitHub #13: Dependency Injection (get_it + injectable)
**Scope:** Configuración de inyección de dependencias con get_it  
**Dependencias:** GitHub #7, #8, #9 (Use Cases), GitHub #1, #2 (Data Layer)  
**Estimación:** 4 horas  
**Prioridad:** 🔴 CRÍTICA  
**Asignado:** ambos

**Incluye:**
- `ServiceLocator` - Configuración de get_it
- Registro de use cases
- Registro de repositorios
- Registro de BLoCs

**Archivos:**
```
lib/core/di/
├── service_locator.dart
└── injection.config.dart (generado)
```

**Tests:** Test de que todas las dependencias se resuelven

**GitHub Issue:** [#13](https://github.com/a-granadillo/ArrowConMango_Front/issues/13)

---

#### GitHub #14: AOP - Logging & Error Handling
**Scope:** Aspectos transversales (logging, manejo de errores)  
**Dependencias:** GitHub #13 (Dependency Injection)  
**Estimación:** 6 horas  
**Prioridad:** 🟡 ALTA  
**Asignado:** ambos

**Incluye:**
- `LoggingDecorator` - Decorador para logging
- `ErrorHandlingDecorator` - Manejo centralizado de errores
- Interceptor de BLoC para logging

**Archivos:**
```
lib/core/aop/
├── logging_decorator.dart
├── error_handling_decorator.dart
└── bloc_interceptor.dart
```

**Tests:** Tests de decorators

**GitHub Issue:** [#14](https://github.com/a-granadillo/ArrowConMango_Front/issues/14)

---

#### GitHub #15: Internationalization (i18n)
**Scope:** Soporte para español e inglés  
**Dependencias:** Ninguna (independiente)  
**Estimación:** 4 horas  
**Prioridad:** 🟢 MEDIA  
**Asignado:** ambos

**Incluye:**
- Configuración de flutter_localizations
- Archivos de traducción (es.json, en.json)
- AppLocalizations class
- Actualización de todas las pantallas

**Archivos:**
```
lib/core/i18n/
├── app_localizations.dart
├── es.json
└── en.json

lib/l10n/
└── app_en.arb
└── app_es.arb
```

**Tests:** Test de que todas las keys existen en ambos idiomas

**GitHub Issue:** [#15](https://github.com/a-granadillo/ArrowConMango_Front/issues/15)

---

#### GitHub #6: Audio System
**Scope:** Sistema de audio (música y efectos)  
**Dependencias:** Ninguna (independiente)  
**Estimación:** 4 horas  
**Prioridad:** 🟢 MEDIA  
**Asignado:** a-granadillo

**Incluye:**
- `AudioManager` - Gestor de audio (Singleton)
- Música de fondo (menú, juego, victoria)
- Efectos de sonido (click, flecha sale, victoria, derrota)
- Toggle de mute en Settings

**Archivos:**
```
lib/core/audio/
└── audio_manager.dart

assets/audio/
├── music/
│   ├── menu_theme.mp3
│   ├── game_theme.mp3
│   └── victory_theme.mp3
└── sfx/
    ├── click.wav
    ├── arrow_exit.wav
    ├── victory.wav
    └── defeat.wav
```

**Tests:** Test de que AudioManager inicializa correctamente

**GitHub Issue:** [#6](https://github.com/a-granadillo/ArrowConMango_Front/issues/6)

---

### **DOCUMENTACIÓN**

#### GitHub #16: Diagramas Obligatorios
**Scope:** Diagramas de clases y capas Clean Architecture  
**Dependencias:** GitHub #1-#15 (todo implementado)  
**Estimación:** 6 horas  
**Prioridad:** 🔴 CRÍTICA  
**Asignado:** ambos

**Incluye:**
- Diagrama de clases (PlantUML o draw.io)
- Diagrama de capas Clean Architecture
- Actualización de design.md con v2

**Archivos:**
```
docs/
├── class_diagram.puml
├── class_diagram.png
├── clean_architecture_diagram.puml
└── clean_architecture_diagram.png
```

**GitHub Issue:** [#16](https://github.com/a-granadillo/ArrowConMango_Front/issues/16)

---

#### GitHub #17: README & AI_USAGE Final
**Scope:** Documentación final completa  
**Dependencias:** GitHub #1-#16  
**Estimación:** 4 horas  
**Prioridad:** 🔴 CRÍTICA  
**Asignado:** ambos

**Incluye:**
- README.md completo (estructura del enunciado)
- AI_USAGE.md actualizado con todas las entradas
- Ejemplos de SOLID y patrones GoF
- Screenshots/GIFs del juego

**Archivos:**
```
README.md
AI_USAGE.md
docs/screenshots/
├── menu.png
├── game.png
└── victory.png
```

**GitHub Issue:** [#17](https://github.com/a-granadillo/ArrowConMango_Front/issues/17)

---

## 📊 Matriz de Dependencias

```
GitHub #7 (Use Cases - Game Flow) ─────────────┐
GitHub #8 (Use Cases - Progress) ──────────────┤
GitHub #9 (Use Cases - Level Management) ──────┤
                                               │
GitHub #1 (Data Models) ───────────────────────┤
                                               │
GitHub #2 (Hive Repos) ────────────────────────┤
                                               │
GitHub #3 (15 Niveles) ────────────────────────┤
                                               │
GitHub #10 (BLoC - Game) ◄─────────────────────┤
GitHub #11 (BLoC - Progress) ◄─────────────────┤
                                               │
GitHub #4 (UI - Menu) ◄────────────────────────┤
GitHub #5 (UI - Game) ◄────────────────────────┤
GitHub #12 (UI - Result) ◄─────────────────────┤
                                               │
GitHub #13 (DI) ◄──────────────────────────────┤
GitHub #14 (AOP) ◄─────────────────────────────┤
                                               │
GitHub #15 (i18n) ─────────────────────────────┤
GitHub #6 (Audio) ─────────────────────────────┤
                                               │
GitHub #16 (Diagramas) ◄───────────────────────┤
GitHub #17 (README) ◄──────────────────────────┘
```  
**Dependencias:** Feature #12 (DI)  
---

## 👥 División de Trabajo Sugerida

### **Persona A (a-granadillo): Data Layer & UI**
**Features asignadas:** GitHub #1, #2, #3, #4, #5, #6  
**Horas estimadas:** 34 horas  
**Ramas:**
- `feat/data-models` (GitHub #1)
- `feat/hive-repositories` (GitHub #2)
- `feat/level-definitions` (GitHub #3)
- `feat/menu-ui` (GitHub #4)
- `feat/game-ui` (GitHub #5)
- `feat/audio` (GitHub #6)

### **Persona B (AlbertoMonasterio): Use Cases & BLoC**
**Features asignadas:** GitHub #7, #8, #9, #10, #11, #12  
**Horas estimadas:** 35 horas  
**Ramas:**
- `feat/game-use-cases` (GitHub #7)
- `feat/progress-use-cases` (GitHub #8)
- `feat/level-use-cases` (GitHub #9)
- `feat/game-bloc` (GitHub #10)
- `feat/progress-bloc` (GitHub #11)
- `feat/result-ui` (GitHub #12)

### **Compartido (ambos):**
**Features:** GitHub #13, #14, #15, #16, #17  
**Horas estimadas:** 24 horas

---

## 🚀 Flujo de Trabajo con GitHub Issues

### 1. Crear Issues
```bash
# Para cada feature, crear issue con template:
gh issue create \
  --title "feat: [Nombre Feature]" \
  --body "[Descripción del scope]" \
  --label "enhancement,layer-X,priority-Y" \
  --assignee "[persona]"
```

### 2. Crear Ramas desde Issues
```bash
# Desde el issue, GitHub sugiere el nombre de rama
gh issue develop [issue-number] --checkout
```

### 3. Trabajar en Feature
```bash
# Commits atómicos
git add .
git commit -m "feat([scope]): [descripción]"

# Push
git push -u origin feat/[nombre-feature]
```

### 4. Crear Pull Request
```bash
gh pr create \
  --base develop \
  --title "feat: [Nombre Feature]" \
  --body "Closes #[issue-number]"
```

### 5. Code Review
- Persona A revisa PRs de Persona B y viceversa
- Aprobar antes de merge

### 6. Merge a develop
```bash
gh pr merge [pr-number] --squash --delete-branch
```

---

## 📅 Cronograma Sugerido

### **Semana 1-2: Capas 2 y 4**
- a-granadillo: GitHub #1 (Data Models), #2 (Hive)
- AlbertoMonasterio: GitHub #7, #8, #9 (Use Cases)
- Ambos: GitHub #15 (i18n - independiente)

### **Semana 3-4: Capa 3/4 (BLoC)**
- a-granadillo: GitHub #3 (15 niveles)
- AlbertoMonasterio: GitHub #10, #11 (BLoC)
- Ambos: GitHub #6 (Audio - independiente)

### **Semana 5-6: UI**
- a-granadillo: GitHub #4, #5 (Menu UI, Game UI)
- AlbertoMonasterio: GitHub #12 (Result UI), soporte a a-granadillo
- Ambos: GitHub #13 (DI)

### **Semana 7: Features Transversales**
- a-granadillo: Testing general
- AlbertoMonasterio: GitHub #14 (AOP)
- Ambos: Pulir UI

### **Semana 8: Documentación**
- Ambos: GitHub #16, #17 (Diagramas, README)
- Testing final
- Preparación de defensa

---

## ⚠️ Notas Importantes

1. **GitHub #15 y #6 son completamente independientes** - Pueden empezarse en cualquier momento
2. **GitHub #13 (DI) debe hacerse después de #1-#5** - Necesita todas las clases registradas
3. **GitHub #3 (15 niveles) puede hacerse en paralelo** - Solo necesita #1 (models)
4. **Testing continuo** - Cada feature debe incluir sus tests antes de merge
5. **CI/CD ya configurado** - GitHub Actions corre tests automáticamente en cada PR

---

## 📋 Checklist de Completitud

- [ ] GitHub #1: Data Models & Mappers (a-granadillo)
- [ ] GitHub #2: Local Storage - Hive (a-granadillo)
- [ ] GitHub #3: Level Definitions (a-granadillo)
- [ ] GitHub #4: UI - Menu Screens (a-granadillo)
- [ ] GitHub #5: UI - Game Screen (a-granadillo)
- [ ] GitHub #6: Audio System (a-granadillo)
- [ ] GitHub #7: Use Cases - Game Flow (AlbertoMonasterio)
- [ ] GitHub #8: Use Cases - Progress & Scoring (AlbertoMonasterio)
- [ ] GitHub #9: Use Cases - Level Management (AlbertoMonasterio)
- [ ] GitHub #10: BLoC - Game State Management (AlbertoMonasterio)
- [x] GitHub #11: BLoC - Progress & Menu State (AlbertoMonasterio)
- [ ] GitHub #12: UI - Result Screens (AlbertoMonasterio)
- [ ] GitHub #13: Dependency Injection (ambos)
- [ ] GitHub #14: AOP - Logging & Error Handling (ambos)
- [ ] GitHub #15: Internationalization (ambos)
- [ ] GitHub #16: Diagrams (ambos)
- [ ] GitHub #17: README & AI_USAGE (ambos)

---

**Total: 17 features | ~112 horas | 8 semanas**
