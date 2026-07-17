# Arrow con Mango — Frontend

Cliente Flutter para *Arrow con Mango*, un puzzle de flechas al estilo
*Arrow Maze*: recolecta mangos despejando el tablero, saca las flechas por
el borde sin que choquen entre sí. Modo Campaña (15 niveles congelados),
Modo Supervivencia (niveles infinitos generados en el dispositivo), ranking
global y sincronización offline-first con el backend.

**Stack:** Flutter · BLoC (`flutter_bloc`) · GetIt + Injectable (DI) · Hive
(persistencia local) · Dio (HTTP) · go_router · Clean Architecture (4 capas)

---

## Arquitectura

4 capas por feature (`lib/features/{game,leaderboard,player}/`), regla de
dependencia hacia adentro:

```
presentation/  → Widgets, BLoC/Cubit, mappers de estado
application/   → Use cases (orquestan repos de dominio)
domain/        → Entidades, value objects, puertos (interfaces de repo)
data/          → Implementaciones de los puertos: Hive, Dio, generador de niveles
```

El dominio no importa Flutter/Hive/Dio — solo las capas `data/` y
`presentation/` lo hacen. Los repositorios "Synced" (`SyncedProgressRepository`,
`SyncedLevelRepository`) decoran una implementación Hive con sincronización
al backend: las lecturas siempre vienen de Hive (offline-first), y una
sincronización en segundo plano sobrescribe con la copia del backend cuando
hay red.

### Composition root

`lib/core/di/service_locator.dart` — la mayoría del grafo se genera con
`injectable`/`get_it` (`sl.init()`); las dependencias que necesitan estado en
tiempo de ejecución (Dio autenticado, identidad de invitado, decoradores AOP)
se cablean a mano alrededor de esa llamada.

---

## Getting Started

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Generar código (DI + localización) — necesario tras clonar o tras tocar
#    cualquier @injectable/@lazySingleton o los .arb
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n

# 3a. Correr contra un backend local (emulador Android)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1

# 3b. Correr contra un backend local (dispositivo físico en la misma red)
flutter run --dart-define=API_BASE_URL=http://<IP-LAN-de-tu-PC>:3000/api/v1

# 3c. Chrome (verificar visualmente sin dispositivo/emulador)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1

# 4. Tests (450+)
flutter test

# 5. Análisis estático (igual que corre el CI)
flutter analyze
```

`API_BASE_URL` por defecto apunta a `http://10.0.2.2:3000/api/v1` (el alias
que usa el emulador Android para `localhost` del host) si no se pasa
`--dart-define`. `10.0.2.2` **no** funciona desde un dispositivo físico ni
desde Chrome — usa la IP LAN de la máquina que corre el backend.

---

## Features

| Carpeta | Qué hace |
|---|---|
| `game/` | Tablero, generador de niveles (Campaña congelada + Supervivencia infinita), progreso, puntuación |
| `leaderboard/` | Ranking global (`GET /leaderboard/global`) |
| `player/` | Identidad de invitado (Guest-First), nombre de jugador |

---

## Persistencia y sincronización

- **Hive** guarda niveles (`levels_v2`), progreso (`progress`) y datos del
  jugador — todo offline-first.
- `_seedLevels` en el composition root siembra el catálogo de campaña la
  primera vez, y **re-siembra si `LevelDefinitions.catalogVersion` cambió**
  desde la última vez — así un fix del generador llega a instalaciones
  existentes en vez de quedar atascado detrás de un caché viejo.
- `SyncedProgressRepository` / `SyncedLevelRepository` intentan sincronizar
  con el backend en segundo plano (con timeout corto) y nunca bloquean una
  lectura ni una jugada por falta de red.

---

## Verificación end-to-end (integración con el backend)

### 1 — Levantar el backend

```bash
cd ../../backend   # o donde tengas el repo del backend
git checkout integration/full-verification   # o master una vez mergeado
npm ci --legacy-peer-deps
npm run seed        # puebla los 15 niveles de campaña
npm run build && npm run start:prod
```

Confirma: `http://localhost:3000/api/docs` (Swagger) carga, y
`curl http://localhost:3000/api/v1/levels` devuelve 15 niveles.

### 2 — Levantar el frontend

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1   # emulador
```

### 3 — Checklist manual por funcionalidad

| Qué probar | Cómo | Qué esperar |
|---|---|---|
| Modo Supervivencia | Gana varios niveles seguidos | El contador de "niveles" sube de 1 en 1 (no de 2 en 2) |
| Selector de niveles | Completa un nivel con distinto desempeño | El recuadro muestra los mangos reales de tu mejor corrida en *ese* nivel, no siempre 3/3 |
| Nivel 15 (el último) | Complétalo | Se marca como completado igual que cualquier otro nivel |
| Colisión de flechas | Toca una flecha bloqueada por otra | Destello rojo de impacto sobre ambas flechas, en Campaña y Supervivencia |
| Progreso online | Gana un nivel con red | `GET /progress` en el backend muestra `best` poblado para ese nivel |
| Progreso offline | Modo avión → gana un nivel → reconecta | El progreso offline aparece sincronizado al reconectar |
| Nombre de jugador | Ajustes → editar nombre | El nombre nuevo se refleja en el ranking global |
| Ranking global | Abre la pantalla de Clasificación | Jugadores reales con mangos = Σ estrellas por nivel completado (rango 0–45), no los 7 nombres inventados del mock |
| Niveles desde el backend | Juega cualquier nivel de campaña normalmente | Apaga el backend y reabre la app → los niveles siguen jugables (catálogo local de respaldo) |

### 4 — Regresión automática

```bash
flutter analyze   # No issues found
flutter test      # 450+ passed
```

---

## Decisiones de diseño

Ver las ADRs del backend (compartidas porque documentan decisiones que
atraviesan ambos repos):

- [Ranking en el dominio, no en SQL; mangos = Σ estrellas](https://github.com/a-granadillo/ArrowConMango_Backend/blob/master/docs/adr/0001-ranking-in-domain.md)
- [El generador de niveles se queda en Dart](https://github.com/a-granadillo/ArrowConMango_Backend/blob/master/docs/adr/0003-generator-stays-in-frontend.md)
- [Solvabilidad de niveles de comunidad: confiada al cliente](https://github.com/a-granadillo/ArrowConMango_Backend/blob/master/docs/adr/0004-community-level-solvability-client-trusted.md)

Reglas de diseño de niveles (silhouettes, ratios de forma, `minGraphDepth`):
[`docs/level_design_rules.md`](docs/level_design_rules.md).
