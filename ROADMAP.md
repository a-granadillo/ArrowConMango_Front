# Roadmap de Features - Arrow Maze Frontend

## Resumen Ejecutivo

Este roadmap divide el proyecto en **17 features independientes** organizadas por capas de Clean Architecture. Cada feature puede trabajarse en una rama separada y mergeada a `develop` sin conflictos.

**Estado actual:** Dominio v2 completo (49 tests pasando)

**Features totales:** 17  
**Estimación total:** ~112 horas de desarrollo

---

## 🎯 Features por Capa

### **CAPA 2: Casos de Uso (Application Layer)**

#### Feature #1: Use Cases - Game Flow
**Scope:** Casos de uso para el flujo principal del juego  
**Dependencias:** Ninguna (solo dominio)  
**Estimación:** 8 horas  
**Prioridad:** 🔴 CRÍTICA

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

**GitHub Issue Template:**
```
Title: feat(use-cases): implement game flow use cases
Labels: enhancement, layer-2, priority-critical
Assignee: [Persona A]
```

---

#### Feature #2: Use Cases - Progress & Scoring
**Scope:** Casos de uso para progreso y puntuación  
**Dependencias:** Feature #1 (para EvaluateGameStateUseCase)  
**Estimación:** 5 horas  
**Prioridad:** 🔴 CRÍTICA

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

---

#### Feature #3: Use Cases - Level Management
**Scope:** Casos de uso para gestión de niveles  
**Dependencias:** Ninguna  
**Estimación:** 4 horas  
**Prioridad:** 🟡 ALTA

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

---

### **CAPA 4: Infraestructura (Data Layer)**

#### Feature #4: Data Models & Mappers
**Scope:** DTOs y mappers para serialización  
**Dependencias:** Ninguna  
**Estimación:** 6 horas  
**Prioridad:** 🔴 CRÍTICA

**Incluye:**
- `LevelModel` - DTO para Level
- `BoardStateModel` - DTO para BoardState
- `ArrowEntityModel` - DTO para ArrowEntity
- `AppProgressModel` - DTO para AppProgress
- Mappers: `toEntity()` / `fromEntity()`

**Archivos:**
```
lib/features/game/data/models/
├── level_model.dart
├── board_state_model.dart
├── arrow_entity_model.dart
├── app_progress_model.dart
└── mappers/
    ├── level_mapper.dart
    ├── board_state_mapper.dart
    └── arrow_entity_mapper.dart
```

**Tests:** Tests de mappers (round-trip: entity → model → entity)

---

#### Feature #5: Local Storage - Hive Implementation
**Scope:** Implementación de repositorios con Hive  
**Dependencias:** Feature #4 (models)  
**Estimación:** 8 horas  
**Priority:** 🔴 CRÍTICA

**Incluye:**
- `HiveLocalStorageAdapter` - Adaptador para Hive
- `HiveLevelRepository` - Implementación de ILevelRepository
- `HiveProgressRepository` - Implementación de IProgressRepository
- TypeAdapters para Hive

**Archivos:**
```
lib/features/game/data/repositories/
├── hive_local_storage_adapter.dart
├── hive_level_repository.dart
└── hive_progress_repository.dart

lib/features/game/data/datasources/
└── hive_type_adapters.dart
```

**Tests:** Tests de integración con Hive (mock file system)

---

#### Feature #6: Level Definitions (15 Niveles)
**Scope:** Definiciones JSON de 15 niveles manuales  
**Dependencias:** Feature #4 (models)  
**Estimación:** 10 horas  
**Prioridad:** 🔴 CRÍTICA

**Incluye:**
- 5 niveles Easy (1-5)
- 5 niveles Medium (6-10)
- 5 niveles Hard (11-15)
- Distintas formas de tablero (rectangular, L-shape, etc.)
- Validación de que todos son resolubles

**Archivos:**
```
assets/levels/
├── level_01.json
├── level_02.json
├── ...
└── level_15.json

lib/features/game/data/datasources/
└── level_json_loader.dart
```

**Tests:** Test de carga y validación de cada nivel

---

### **CAPA 3/4: Presentación (BLoC + UI)**

#### Feature #7: BLoC - Game State Management
**Scope:** BLoC para manejo de estado del juego  
**Dependencias:** Feature #1, #2 (use cases)  
**Estimación:** 12 horas  
**Prioridad:** 🔴 CRÍTICA

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

---

#### Feature #8: BLoC - Progress & Menu State
**Scope:** BLoC para progreso y menús  
**Dependencias:** Feature #3 (use cases)  
**Estimación:** 6 horas  
**Prioridad:** 🟡 ALTA

**Incluye:**
- `ProgressBloc` - BLoC de progreso
- `ProgressEvent` / `ProgressState`
- `MenuBloc` - BLoC de menú principal

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

---

#### Feature #9: UI - Menu Screens
**Scope:** Pantallas de menú  
**Dependencias:** Feature #8 (BLoC)  
**Estimación:** 6 horas  
**Prioridad:** 🟡 ALTA

**Incluye:**
- `SplashScreen` - Pantalla de carga
- `MainMenuScreen` - Menú principal
- `LevelSelectionScreen` - Selección de niveles
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

---

#### Feature #10: UI - Game Screen
**Scope:** Pantalla principal del juego  
**Dependencias:** Feature #7 (GameBloc)  
**Estimación:** 15 horas  
**Prioridad:** 🔴 CRÍTICA

**Incluye:**
- `GameScreen` - Pantalla de juego
- `BoardGridWidget` - Renderizado del tablero
- `ArrowWidget` - Renderizado de flechas
- `GameControlsWidget` - Botones de control (undo, restart)
- Animaciones de movimiento de flechas

**Archivos:**
```
lib/features/game/presentation/screens/
└── game_screen.dart

lib/features/game/presentation/widgets/
├── board_grid_widget.dart
├── arrow_widget.dart
├── game_controls_widget.dart
└── animations/
    ├── arrow_exit_animation.dart
    └── victory_animation.dart
```

**Tests:** Widget tests + golden tests

---

#### Feature #11: UI - Result Screens
**Scope:** Pantallas de resultado  
**Dependencias:** Feature #7 (GameBloc)  
**Estimación:** 4 horas  
**Prioridad:** 🟡 ALTA

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

---

### **FEATURES TRANSVERSALES**

#### Feature #12: Dependency Injection (get_it + injectable)
**Scope:** Configuración de inyección de dependencias  
**Dependencias:** Features #1-5 (use cases + repos)  
**Estimación:** 4 horas  
**Prioridad:** 🔴 CRÍTICA

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

---

#### Feature #13: AOP - Logging & Error Handling
**Scope:** Aspectos transversales (logging, manejo de errores)  
**Dependencias:** Feature #12 (DI)  
**Estimación:** 6 horas  
**Prioridad:** 🟡 ALTA

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

---

#### Feature #14: Internationalization (i18n)
**Scope:** Soporte para español e inglés  
**Dependencias:** Ninguna  
**Estimación:** 4 horas  
**Prioridad:** 🟢 MEDIA

**Incluye:**
- Configuración de flutter_localizations
- Archivos de traducción (es.json, en.json)
- `AppLocalizations` class
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

---

#### Feature #15: Audio System
**Scope:** Música y efectos de sonido  
**Dependencias:** Ninguna  
**Estimación:** 4 horas  
**Prioridad:** 🟢 MEDIA

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

---

### **DOCUMENTACIÓN**

#### Feature #16: Diagramas Obligatorios
**Scope:** Diagramas de clases y capas  
**Dependencias:** Features #1-15 (todo implementado)  
**Estimación:** 6 horas  
**Prioridad:** 🔴 CRÍTICA

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

---

#### Feature #17: README & AI_USAGE Final
**Scope:** Documentación final completa  
**Dependencias:** Features #1-16  
**Estimación:** 4 horas  
**Prioridad:** 🔴 CRÍTICA

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

---

## 📊 Matriz de Dependencias

```
Feature #1 (Game Flow Use Cases) ─────────────┐
Feature #2 (Progress Use Cases) ──────────────┤
Feature #3 (Level Management Use Cases) ──────┤
                                              │
Feature #4 (Data Models) ─────────────────────┤
                                              │
Feature #5 (Hive Repos) ──────────────────────┤
                                              │
Feature #6 (15 Niveles) ──────────────────────┤
                                              │
Feature #7 (Game BLoC) ◄──────────────────────┤
Feature #8 (Progress BLoC) ◄──────────────────┤
                                              │
Feature #9 (Menu UI) ◄────────────────────────┤
Feature #10 (Game UI) ◄───────────────────────┤
Feature #11 (Result UI) ◄─────────────────────┤
                                              │
Feature #12 (DI) ◄────────────────────────────┤
Feature #13 (AOP) ◄───────────────────────────┤
                                              │
Feature #14 (i18n) ───────────────────────────┤
Feature #15 (Audio) ──────────────────────────┤
                                              │
Feature #16 (Diagramas) ◄─────────────────────┤
Feature #17 (README) ◄────────────────────────┘
```

---

## 👥 División de Trabajo Sugerida

### **Persona A: Data Layer & Infrastructure**
**Features asignadas:** #4, #5, #6, #12  
**Horas estimadas:** 28 horas  
**Ramas:**
- `feat/data-models`
- `feat/hive-repositories`
- `feat/level-definitions`
- `feat/dependency-injection`

### **Persona B: Use Cases & BLoC**
**Features asignadas:** #1, #2, #3, #7, #8  
**Horas estimadas:** 35 horas  
**Ramas:**
- `feat/game-use-cases`
- `feat/progress-use-cases`
- `feat/level-use-cases`
- `feat/game-bloc`
- `feat/progress-bloc`

### **Persona C: UI & Features Transversales**
**Features asignadas:** #9, #10, #11, #13, #14, #15  
**Horas estimadas:** 39 horas  
**Ramas:**
- `feat/menu-ui`
- `feat/game-ui`
- `feat/result-ui`
- `feat/aop`
- `feat/i18n`
- `feat/audio`

### **Compartido (ambos):**
**Features:** #16, #17  
**Horas estimadas:** 10 horas

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
- Persona A: Features #4, #5
- Persona B: Features #1, #2, #3
- Persona C: Feature #14 (i18n - independiente)

### **Semana 3-4: Capa 3/4 (BLoC)**
- Persona A: Feature #6 (15 niveles)
- Persona B: Features #7, #8
- Persona C: Feature #15 (Audio - independiente)

### **Semana 5-6: UI**
- Persona A: Feature #12 (DI)
- Persona B: Soporte a Persona C
- Persona C: Features #9, #10, #11

### **Semana 7: Features Transversales**
- Persona A: Feature #13 (AOP)
- Persona B: Testing general
- Persona C: Pulir UI

### **Semana 8: Documentación**
- Todos: Features #16, #17
- Testing final
- Preparación de defensa

---

## ⚠️ Notas Importantes

1. **Features #14 y #15 son completamente independientes** - Pueden empezarse en cualquier momento
2. **Feature #12 (DI) debe hacerse después de Features #1-5** - Necesita todas las clases registradas
3. **Feature #6 (15 niveles) puede hacerse en paralelo** - Solo necesita Feature #4 (models)
4. **Testing continuo** - Cada feature debe incluir sus tests antes de merge
5. **CI/CD ya configurado** - GitHub Actions corre tests automáticamente en cada PR

---

## 📋 Checklist de Completitud

- [ ] Feature #1: Game Flow Use Cases
- [ ] Feature #2: Progress Use Cases
- [ ] Feature #3: Level Management Use Cases
- [ ] Feature #4: Data Models & Mappers
- [ ] Feature #5: Hive Implementation
- [ ] Feature #6: 15 Level Definitions
- [ ] Feature #7: Game BLoC
- [ ] Feature #8: Progress BLoC
- [ ] Feature #9: Menu UI
- [ ] Feature #10: Game UI
- [ ] Feature #11: Result UI
- [ ] Feature #12: Dependency Injection
- [ ] Feature #13: AOP
- [ ] Feature #14: i18n
- [ ] Feature #15: Audio
- [ ] Feature #16: Diagrams
- [ ] Feature #17: README & AI_USAGE

---

**Total: 17 features | ~112 horas | 8 semanas**
