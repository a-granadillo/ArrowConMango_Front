# Workflow de Trabajo - Arrow Maze Frontend

Este documento describe el flujo de trabajo completo para el desarrollo del proyecto usando GitHub Issues, ramas y Pull Requests.

---

## Resumen del Flujo

```
1. Ver issues disponibles → 2. Elegir issue → 3. Crear rama → 4. Trabajar → 5. Abrir PR → 6. Code Review → 7. Merge → 8. Cerrar issue
```

---

## 1. Ver Issues Disponibles

### Ver todos los issues
```bash
gh issue list
```

### Filtrar por asignado a mí
```bash
gh issue list --assignee @me
```

### Filtrar por label
```bash
gh issue list --label "layer-data"
gh issue list --label "priority-critical"
```

### Ver detalles de un issue específico
```bash
gh issue view [NÚMERO]
```

**Ejemplo:**
```bash
gh issue view 1
```

---

## 2. Elegir un Issue

### Criterios de elección

1. **Prioridad**: Empezar por `priority-critical`
2. **Dependencias**: Verificar que las dependencias estén completadas
3. **Asignación**: Trabajar solo en issues asignados a vos
4. **Disponibilidad**: No tomar issues que otro ya esté trabajando

### Verificar dependencias

En el body del issue, buscar la sección "Dependencias". Si dice "Ninguna", podés empezar inmediatamente. Si lista otros issues (ej: "#4, #5"), esos deben estar mergeados primero.

---

## 3. Crear Rama desde el Issue

### Crear rama y cambiar a ella
```bash
git checkout develop
git pull origin develop
git checkout -b [NÚMERO]-[NOMBRE-FEATURE]
```

**Ejemplo:**
```bash
git checkout -b 1-data-models-mappers
```

### Convención de nombres

Formato: `[NÚMERO]-[NOMBRE-FEATURE]`

- Usar el número del issue
- Nombre en kebab-case (minúsculas con guiones)
- Descriptivo pero conciso

**Ejemplos válidos:**
- `1-data-models-mappers`
- `5-hive-repositories`
- `10-game-ui`

---

## 4. Trabajar en la Feature

### Commits atómicos

**Principio:** Un commit = Un cambio lógico

**Formato del mensaje:**
```
tipo(scope): descripción corta

[body opcional con más detalles]
```

**Tipos de commit:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `test`: Agregar o modificar tests
- `refactor`: Refactorización sin cambiar funcionalidad
- `docs`: Documentación
- `chore`: Tareas de mantenimiento

**Ejemplos:**
```bash
git commit -m "feat(data): add LevelModel DTO"
git commit -m "feat(data): add LevelMapper with toEntity/fromEntity"
git commit -m "test(data): add round-trip tests for LevelMapper"
```

### Frecuencia de commits

- Commitear después de cada cambio lógico completo
- No acumular muchos cambios sin commitear
- Cada commit debe compilar y pasar tests

### Ejecutar tests localmente

```bash
# Tests de dominio
flutter test test/domain/

# Todos los tests
flutter test

# Linter
flutter analyze
```

**Regla:** Nunca pushear código que no pase tests localmente.

---

## 5. Subir Cambios y Abrir Pull Request

### Push de la rama
```bash
git push -u origin [NOMBRE-RAMA]
```

**Ejemplo:**
```bash
git push -u origin 1-data-models-mappers
```

### Crear Pull Request

**Opción 1: Desde la terminal (recomendado)**
```bash
gh pr create --base develop --title "feat: [DESCRIPCIÓN]" --body "Closes #[NÚMERO]"
```

**Ejemplo:**
```bash
gh pr create --base develop --title "feat: implement Data Models & Mappers" --body "Closes #1"
```

**Opción 2: Desde GitHub Web**
1. Ir a https://github.com/a-granadillo/ArrowConMango_Front/pulls
2. Click en "New pull request"
3. Base: `develop`
4. Compare: `[tu-rama]`
5. Título: `feat: [descripción]`
6. Body: `Closes #[número]`

### Importancia de "Closes #[NÚMERO]"

Cuando el PR se mergea, GitHub **cierra automáticamente el issue** si el body contiene `Closes #1`, `Fixes #1`, o `Resolves #1`.

---

## 6. Code Review

### Asignar reviewers

En el PR, asignar al menos un reviewer del equipo:
- Abraham Granadillo
- Alberto Monasterio

### Responder a comentarios

1. Leer los comentarios del reviewer
2. Hacer los cambios solicitados
3. Commitear y pushear a la misma rama
4. Responder en el PR indicando que se resolvieron los comentarios

**Ejemplo:**
```bash
# Hacer cambios solicitados
vim lib/features/game/data/models/level_model.dart

# Commit y push
git add .
git commit -m "fix(data): address review comments on LevelModel"
git push
```

El PR se actualiza automáticamente con los nuevos commits.

### Aprobar PR

Cuando el reviewer aprueba, el PR queda listo para merge.

---

## 7. Merge del Pull Request

### Verificar antes de mergear

- ✅ Todos los checks de CI pasaron (verde)
- ✅ Al menos un reviewer aprobó
- ✅ No hay conflictos con develop
- ✅ El código está actualizado con develop

### Hacer merge

**Opción 1: Desde la terminal (recomendado)**
```bash
gh pr merge [NÚMERO-PR] --squash --delete-branch
```

**Ejemplo:**
```bash
gh pr merge 19 --squash --delete-branch
```

**Opción 2: Desde GitHub Web**
1. Ir al PR
2. Click en "Merge pull request"
3. Seleccionar "Squash and merge"
4. Confirmar

### ¿Por qué Squash Merge?

**Squash merge** combina todos los commits de la rama en UN SOLO commit en develop.

**Ventajas:**
- Historial de develop limpio y legible
- Cada feature = 1 commit
- Fácil de revertir si hay problemas
- No ensucia develop con commits de trabajo en progreso

**Ejemplo:**
```
Antes del squash:
develop: A → B → C
feature:         C → D → E → F (4 commits)

Después del squash:
develop: A → B → C → G (1 commit que contiene D+E+F)
```

---

## 8. Cerrar Issue

### Cierre automático

Si el PR contiene `Closes #[NÚMERO]` en el body, GitHub cierra el issue automáticamente al mergear.

### Cierre manual (si es necesario)

```bash
gh issue close [NÚMERO]
```

### Verificar cierre

```bash
gh issue view [NÚMERO]
```

Debe mostrar: `State: closed`

---

## 9. Actualizar Rama Local

Después de mergear un PR, actualizar develop local:

```bash
git checkout develop
git pull origin develop
```

Esto trae los cambios mergeados y elimina la rama feature si usaste `--delete-branch`.

---

## Resolución de Conflictos

### Cuando develop avanza mientras trabajás

Si alguien mergea cambios a develop mientras trabajás en tu feature:

```bash
# 1. Actualizar develop
git checkout develop
git pull origin develop

# 2. Volver a tu rama
git checkout [NOMBRE-RAMA]

# 3. Rebase sobre develop
git rebase develop

# 4. Resolver conflictos (si los hay)
# Editar archivos en conflicto
git add [ARCHIVOS-RESUELTOS]
git rebase --continue

# 5. Push forzado (necesario después de rebase)
git push --force-with-lease
```

### ¿Por qué rebase y no merge?

**Rebase** reescribe el historial de tu rama para que parezca que empezaste a trabajar desde el último commit de develop.

**Ventajas:**
- Historial lineal y limpio
- Más fácil de entender
- Evita commits de merge innecesarios

**Desventajas:**
- Requiere push forzado
- Puede ser confuso si no estás familiarizado

---

## Labels y su Significado

### Labels de capa (layer)

| Label | Descripción |
|-------|-------------|
| `layer-data` | Capa de datos (models, repositories, datasources) |
| `layer-usecases` | Casos de uso (lógica de aplicación) |
| `layer-bloc` | BLoC (manejo de estado) |
| `layer-ui` | UI (screens, widgets) |
| `layer-core` | Core (DI, AOP, i18n, audio) |
| `layer-docs` | Documentación |

### Labels de prioridad (priority)

| Label | Descripción |
|-------|-------------|
| `priority-critical` | Bloquea otras features, hacer primero |
| `priority-high` | Importante, hacer pronto |
| `priority-medium` | Puede esperar |
| `priority-low` | Nice to have |

### Labels especiales

| Label | Descripción |
|-------|-------------|
| `independent` | No tiene dependencias, puede empezar en cualquier momento |
| `blocked` | Bloqueado por otra issue o problema externo |
| `bug` | Error en código existente |
| `enhancement` | Mejora o nueva funcionalidad |

---

## Buenas Prácticas

### Antes de empezar

1. ✅ Leer completamente el issue
2. ✅ Verificar dependencias
3. ✅ Asegurarse de que nadie más esté trabajando en eso
4. ✅ Entender el scope y los entregables

### Durante el desarrollo

1. ✅ Commits atómicos y frecuentes
2. ✅ Mensajes de commit descriptivos
3. ✅ Tests para todo código nuevo
4. ✅ Ejecutar `flutter analyze` antes de pushear
5. ✅ Mantener la rama actualizada con develop

### Al abrir PR

1. ✅ Título claro y descriptivo
2. ✅ Body con `Closes #[NÚMERO]`
3. ✅ Asignar reviewers
4. ✅ Verificar que CI pasó (checks verdes)
5. ✅ Responder comentarios rápidamente

### Code Review

1. ✅ Ser constructivo en los comentarios
2. ✅ Explicar el "por qué" de las sugerencias
3. ✅ Aprobar solo cuando el código esté listo
4. ✅ No aprobar código sin tests
5. ✅ Verificar que cumple con Clean Architecture

---

## Checklist Rápido

### Antes de pushear

- [ ] Código compila sin errores
- [ ] `flutter analyze` no reporta warnings
- [ ] Todos los tests pasan localmente
- [ ] Commits son atómicos y descriptivos
- [ ] Rama está actualizada con develop

### Antes de abrir PR

- [ ] Push exitoso a la rama
- [ ] Título del PR es claro
- [ ] Body contiene `Closes #[NÚMERO]`
- [ ] Reviewers asignados
- [ ] Descripción de cambios en el PR

### Antes de mergear

- [ ] CI pasó (todos los checks verdes)
- [ ] Al menos un reviewer aprobó
- [ ] No hay conflictos con develop
- [ ] Código fue probado localmente
- [ ] Issue se cerrará automáticamente

---

## Comandos Útiles

### GitHub CLI (gh)

```bash
# Ver issues
gh issue list
gh issue view [NÚMERO]

# Crear PR
gh pr create --base develop --title "..." --body "Closes #[NÚMERO]"

# Ver PRs
gh pr list
gh pr view [NÚMERO]

# Merge PR
gh pr merge [NÚMERO] --squash --delete-branch

# Ver status de CI
gh run list
gh run view [ID]
```

### Git

```bash
# Crear rama
git checkout -b [NOMBRE]

# Commits
git add .
git commit -m "tipo(scope): mensaje"

# Push
git push -u origin [RAMA]

# Rebase
git rebase develop
git push --force-with-lease

# Actualizar
git checkout develop
git pull origin develop
```

### Flutter

```bash
# Tests
flutter test
flutter test test/domain/

# Linter
flutter analyze

# Build
flutter build apk
```

---

## Preguntas Frecuentes

### ¿Puedo trabajar en múltiples issues a la vez?

**No recomendado.** Enfocate en un issue a la vez para evitar conflictos y mantener el contexto.

### ¿Qué hago si me trabo en un issue?

1. Comentar en el issue explicando el bloqueo
2. Agregar label `blocked`
3. Pedir ayuda al equipo
4. Mientras tanto, trabajar en otro issue independiente

### ¿Puedo mergear mi propio PR?

**No.** Siempre necesitás aprobación de al menos un reviewer del equipo.

### ¿Qué pasa si el CI falla?

1. Ver logs del CI: `gh run view [ID]`
2. Identificar el error
3. Arreglar localmente
4. Commit y push
5. CI se ejecuta automáticamente de nuevo

### ¿Cuándo debo hacer rebase?

Cuando develop haya avanzado significativamente mientras trabajabas en tu feature (3+ commits nuevos en develop).

---

## Recursos Adicionales

- **ROADMAP.md**: Plan completo de 17 features
- **design.md**: Arquitectura y decisiones técnicas
- **AI_USAGE.md**: Registro de uso de IA
- **GitHub Docs**: https://docs.github.com/en/issues
- **GitHub CLI Docs**: https://cli.github.com/manual/

---

## Contacto

Para dudas sobre el workflow:
- Abraham Granadillo (@a-granadillo)
- Alberto Monasterio (@AlbertoMonasterio)

---

**Última actualización:** 21 de junio, 2026
