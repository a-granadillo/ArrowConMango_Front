# AI Usage Documentation

Este documento registra el uso de herramientas de IA en el desarrollo de ArrowConMango, siguiendo las mejores prácticas de transparencia y documentación.

## Herramientas Utilizadas

- **Claude AI (Anthropic)**: Asistente de desarrollo para arquitectura, implementación y debugging
- **OpenCode**: Plataforma de desarrollo asistido por IA
- **Gentle AI**: Framework SDD (Spec-Driven Development) para planificación estructurada

---

## Sesiones de Desarrollo

### Sesión 1: Refactoring a Arquitectura Basada en Grafos

**Fecha**: 2026-06-24  
**Rama**: `feat/graph-topology`  
**PR**: Por crear

#### Contexto
El profesor recomendó usar grafos para modelar el tablero y las flechas. Originalmente, `Grid2DTopology` usaba aritmética de coordenadas (row, col) directamente, lo cual era un comportamiento de grafo implícito.

#### Trabajo Realizado
1. **Creación de abstracción `Graph<V>`** en domain layer
   - Archivo: `lib/features/game/domain/services/graph.dart`
   - Interfaz genérica para cualquier topología basada en grafos

2. **Implementación de `GridGraph`**
   - Archivo: `lib/features/game/data/topologies/grid_graph.dart`
   - Grafo explícito con listas de adyacencia precomputadas
   - Lookups O(1) para vecinos y boundaries

3. **Refactoring de `Grid2DTopology`**
   - Archivo: `lib/features/game/data/topologies/grid_2d_topology.dart`
   - Ahora delega a `GridGraph` internamente (patrón Adapter)
   - Mantiene la misma interfaz pública

4. **Movimiento de `CardinalDirection` a domain**
   - De: `lib/features/game/data/topologies/grid_2d_topology.dart`
   - A: `lib/features/game/domain/entities/cardinal_direction.dart`
   - Razón: Dependency Inversion Principle (DIP)

5. **Actualización de tests**
   - 5 archivos de test actualizados
   - Cambio de `const` a `late final` (Grid2DTopology ya no es const-constructible)
   - Imports corregidos para usar `CardinalDirection` desde domain

#### Decisiones Técnicas
- **Separación de responsabilidades**: `Graph<V>` en domain, `GridGraph` en data
- **Precomputación**: Listas de adyacencia se construyen una vez en el constructor
- **Adapter Pattern**: `Grid2DTopology` adapta la interfaz `Topology` a operaciones de `Graph`

#### Archivos Modificados
- `lib/features/game/domain/services/graph.dart` (nuevo)
- `lib/features/game/data/topologies/grid_graph.dart` (nuevo)
- `lib/features/game/data/topologies/grid_2d_topology.dart` (refactored)
- `lib/features/game/domain/entities/cardinal_direction.dart` (movido)
- `test/domain/board_state_test.dart` (actualizado)
- `test/domain/collision_validator_test.dart` (actualizado)
- `test/domain/game_session_test.dart` (actualizado)
- `test/domain/grid_2d_topology_test.dart` (actualizado)
- `test/domain/level_builder_test.dart` (actualizado)

#### Lecciones Aprendidas
- Los sub-agentes SDD no funcionaron en el entorno, requiriendo trabajo manual
- Los conflictos de merge al aplicar stashes pueden ser complejos de resolver
- Es mejor crear ramas limpias desde develop que intentar separar cambios mezclados

---

### Sesión 2: Issue #1 - Data Models & Mappers

**Fecha**: 2026-06-24  
**Rama**: `feat/data-models`  
**Issue**: #1  
**PR**: Por crear

#### Contexto
Implementar modelos de datos (DTOs) y mappers para serialización, permitiendo persistencia y comunicación entre capas.

#### Trabajo Realizado

##### Modelos de Datos (5 archivos)
1. **`NodeModel`** (`lib/features/game/data/models/node_model.dart`)
   - Representa coordenadas (row, col)
   - Serialización JSON con `toMap()` y `fromMap()`
   - Override de `==`, `hashCode`, y `toString()`

2. **`ArrowModel`** (`lib/features/game/data/models/arrow_model.dart`)
   - Representa una flecha con id, dirección y nodos ocupados
   - Dirección almacenada como string (nombre del enum)
   - Lista de `NodeModel` para nodos ocupados

3. **`BoardStateModel`** (`lib/features/game/data/models/board_state_model.dart`)
   - Representa el estado del tablero
   - Lista de `ArrowModel`

4. **`LevelModel`** (`lib/features/game/data/models/level_model.dart`)
   - Representa un nivel con ID y tablero template
   - Compuesto por `BoardStateModel`

5. **`AppProgressModel`** (`lib/features/game/data/models/app_progress_model.dart`)
   - Representa el progreso del jugador
   - Lista de niveles desbloqueados y token actual

##### Mappers (4 archivos)
1. **`ArrowMapper`** (`lib/features/game/data/models/mappers/arrow_mapper.dart`)
   - Convierte `ArrowEntity` ↔ `ArrowModel`
   - Maneja conversión de `CardinalDirection` (enum ↔ string)
   - Convierte `Grid2DNodeId` ↔ `NodeModel`

2. **`BoardStateMapper`** (`lib/features/game/data/models/mappers/board_state_mapper.dart`)
   - Convierte `BoardState` ↔ `BoardStateModel`
   - Usa `ArrowMapper` para conversión de flechas

3. **`LevelMapper`** (`lib/features/game/data/models/mappers/level_mapper.dart`)
   - Convierte `Level` ↔ `LevelModel`
   - Usa `BoardStateMapper` para conversión del tablero

4. **`AppProgressMapper`** (`lib/features/game/data/models/mappers/app_progress_mapper.dart`)
   - Convierte `AppProgress` ↔ `AppProgressModel`
   - Conversión directa de primitivos

##### Tests (4 archivos, 18 tests totales)
1. **`arrow_mapper_test.dart`** (5 tests)
   - toModel, toEntity, roundtrip, serialization, invalid direction

2. **`board_state_mapper_test.dart`** (4 tests)
   - toModel, toEntity, roundtrip, serialization

3. **`level_mapper_test.dart`** (4 tests)
   - toModel, toEntity, roundtrip, serialization

4. **`app_progress_mapper_test.dart`** (5 tests)
   - toModel, toEntity, roundtrip, serialization, empty levels

#### Decisiones Técnicas
- **Package imports**: Usar `package:arrowconmango_front/...` en lugar de relative imports
- **Mappers estáticos**: Métodos `toModel()` y `toEntity()` como static para simplicidad
- **Dirección como string**: Almacenar `CardinalDirection` como string en `ArrowModel` para serialización
- **Composición de mappers**: Mappers compuestos usan otros mappers internamente

#### Archivos Creados
- `lib/features/game/data/models/node_model.dart`
- `lib/features/game/data/models/arrow_model.dart`
- `lib/features/game/data/models/board_state_model.dart`
- `lib/features/game/data/models/level_model.dart`
- `lib/features/game/data/models/app_progress_model.dart`
- `lib/features/game/data/models/mappers/arrow_mapper.dart`
- `lib/features/game/data/models/mappers/board_state_mapper.dart`
- `lib/features/game/data/models/mappers/level_mapper.dart`
- `lib/features/game/data/models/mappers/app_progress_mapper.dart`
- `test/data/models/mappers/arrow_mapper_test.dart`
- `test/data/models/mappers/board_state_mapper_test.dart`
- `test/data/models/mappers/level_mapper_test.dart`
- `test/data/models/mappers/app_progress_mapper_test.dart`

#### Problemas Encontrados y Soluciones

**Problema 1: Imports relativos incorrectos**
- **Síntoma**: Errores de "Method not found" y "Type not found"
- **Causa**: Imports relativos como `'../../domain/entities/...'` no funcionaban
- **Solución**: Cambiar a package imports: `'package:arrowconmango_front/features/game/domain/entities/...'`

**Problema 2: CardinalDirection no encontrado**
- **Síntoma**: Error "Undefined name 'CardinalDirection'"
- **Causa**: `CardinalDirection` está en `grid_2d_topology.dart`, no en domain
- **Solución**: Importar desde `grid_2d_topology.dart` en lugar de domain

**Problema 3: Imports faltantes en tests**
- **Síntoma**: Error "Method not found: 'ArrowModel'"
- **Causa**: Tests no importaban `ArrowModel` y `BoardStateModel`
- **Solución**: Agregar imports faltantes en `board_state_mapper_test.dart` y `level_mapper_test.dart`

#### Lecciones Aprendidas
- Los package imports son más robustos que relative imports en proyectos Dart/Flutter
- Es importante verificar que todos los tipos usados estén importados, incluso si parecen obvios
- Los mappers compuestos requieren importar tanto el mapper como los modelos que usan
- Documentar problemas y soluciones ayuda a evitar repetir errores en el futuro

---

## Métricas de Uso de AI

### Código Generado
- **Archivos creados**: 22 archivos (9 modelos/mappers + 4 tests + 9 archivos de refactoring de grafos)
- **Líneas de código**: ~816 líneas (Issue #1) + ~393 líneas (refactoring grafos)
- **Tests escritos**: 18 tests (Issue #1)

### Tipos de Asistencia
1. **Arquitectura**: Diseño de abstracciones y patrones
2. **Implementación**: Escritura de código siguiendo mejores prácticas
3. **Debugging**: Identificación y corrección de errores de compilación
4. **Refactoring**: Mejora de código existente
5. **Testing**: Escritura de tests unitarios comprehensivos
6. **Documentación**: Creación y mantenimiento de documentación técnica

### Decisiones Humanas vs AI
- **Humanas**: Selección de issues, revisión de PRs, decisiones de merge
- **AI**: Implementación técnica, debugging, escritura de tests
- **Colaborativas**: Diseño de arquitectura, revisión de código

---

## Próximas Sesiones

### Issue #2: Local Storage - Hive Implementation
- Implementar repositorios con Hive para persistencia local
- Crear TypeAdapters para los modelos
- Implementar `HiveLevelRepository` y `HiveProgressRepository`

### Issue #3: Level Definitions (15 Niveles)
- Definir 15 niveles con dificultad progresiva
- Crear archivos JSON para cada nivel
- Implementar validación de niveles

---

## Notas sobre Transparencia

Este documento se mantiene actualizado para:
1. **Transparencia**: Documentar claramente qué trabajo fue asistido por AI
2. **Aprendizaje**: Registrar lecciones aprendidas y problemas encontrados
3. **Trazabilidad**: Mantener historial de decisiones técnicas
4. **Mejora continua**: Identificar patrones de uso efectivo de AI

**Última actualización**: 2026-06-24
