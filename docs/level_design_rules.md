# Level Design Rules — ArrowConMango

## 1. Architecture

A level is composed of:

| Component | Type | Description |
|---|---|---|
| `Level` | Entity | Holds `levelId`, `rows`, `cols`, `templateBoard` |
| `BoardSizeModel` | Model | Pair of `rows` × `cols` serialized alongside the level |
| `ArrowModel` | Model | Serialisable arrow with `startNode` + `ArrowTrajectory` |
| `ArrowTrajectory` | Model | Ordered list of `TrajectorySegment`s |
| `TrajectorySegment` | Model | `direction` + `length` (≥0) |

### Data flow

```
level_definitions.dart  (aggregator)
    ├── easy_levels.dart    (levels 1-5)
    ├── medium_levels.dart  (levels 6-10)
    └── hard_levels.dart    (levels 11-15)
```

Each file exports a `List<LevelModel>`. The aggregator re-exports them as `allLevels`, `easyLevels`, `mediumLevels`, `hardLevels`, and a `getById(int id)` lookup.

---

## 2. Board size by difficulty

While there are recommended guidelines, the actual board size can vary by level. For example, some Easy levels might be 6×7 or 7×7, while Hard levels might be 11×10. The `BoardSizeModel` on each `LevelModel` defines the exact size for that specific level.

---

## 3. Arrow format

### 3.1 Helper signature

```dart
ArrowModel arrowHelper(String id, String direction, List<List<int>> cells);
```

- `id` — unique identifier within the level (e.g. `'a1'`, `'a2'`)
- `direction` — the arrow's final heading (`CardinalDirection.right`, `.down`, `.left`, `.up`)
- `cells` — ordered list of `[row, col]` pairs the arrow occupies (tail → head)

### 3.2 Translation

`cells` is converted to:
- **startNode** — `NodeModel(row: cells.first[0], col: cells.first[1])`
- **trajectory segments** — computed from consecutive cell differences

Each consecutive pair `(cell[i], cell[i+1])` is deduplicated into a `TrajectorySegment(direction, length)`. If the arrow has only one cell, a single `TrajectorySegment(direction, 0)` is produced.

### 3.3 Single-node arrows

A single-node arrow (length = 0) is **valid** and represents an arrow that occupies only its start cell. This is used for compact level designs (e.g. the heart shape in level 1).

---

## 4. Arrow budget (max arrows per level)

| Difficulty | Arrow range |
|---|---|
| Easy | 10 – 20 |
| Medium | 21 – 40 |
| Hard | 41 – 70 |

These limits are enforced by `level_definitions_test.dart` to ensure a consistent progression.

---

## 5. Structural constraints

1. **No overlapping arrows** — two arrows must not share any cell. The domain's `BoardState` constructor throws `OverlappingArrowsFailure` if violated.
2. **All nodes within bounds** — every cell `[row, col]` must satisfy `0 ≤ row < rows` and `0 ≤ col < cols`.
3. **No duplicate IDs** — arrow IDs must be unique within a level.
4. **Level IDs** — must be unique across all levels (1-15).
5. **Trajectory continuity** — each segment must pick up where the previous one left off. The helper function guarantees this by construction.

---

## 6. How to add a new level

### 6.1 Define the cells

```dart
// Helper: each inner list is [row, col]
final _myLevel = (
  id: 16,
  name: 'New Level',
  difficulty: 'Hard',
  boardSize: const BoardSizeModel(rows: 8, cols: 8),
  arrows: [
    (id: 'a1', direction: 'right', cells: [
      [0, 0], [0, 1], [0, 2],
    ]),
    // ...
  ],
);
```

### 6.2 Create the LevelModel

```dart
LevelModel(
  id: _myLevel.id,
  name: _myLevel.name,
  difficulty: _myLevel.difficulty,
  boardSize: _myLevel.boardSize,
  boardState: BoardStateModel(
    arrows: _myLevel.arrows.map((a) =>
      arrowHelper(a.id, a.direction, a.cells)
    ).toList(),
  ),
)
```

### 6.3 Place in the correct file

| Level ID | File |
|---|---|
| 1-5 | `lib/features/game/data/level_definitions/easy_levels.dart` |
| 6-10 | `lib/features/game/data/level_definitions/medium_levels.dart` |
| 11+ | `lib/features/game/data/level_definitions/hard_levels.dart` |

### 6.4 Update tests

If you add a level, update the hard-coded `hasLength(15)` expectation in `level_definitions_test.dart` to match the new total number of levels.

---

## 7. File structure

```
lib/features/game/data/level_definitions/
├── arrow_helper.dart          # arrowHelper() shared function
├── easy_levels.dart           # levels 1-5
├── medium_levels.dart         # levels 6-10
├── hard_levels.dart           # levels 11-15
└── level_definitions.dart     # aggregator (allLevels, easyLevels, etc.)

test/data/
└── level_definitions_test.dart  # structural validation tests
```

---

## 8. Conventions

- File names: `snake_case`
- Level IDs: sequential integers starting at 1
- Arrow IDs within a level: `'a1'`, `'a2'`, …, `'aN'`
- Cell coordinates: `[row, col]` where row increases downward (top-left is `[0, 0]`)
- Direction: `CardinalDirection.right` → east, `.down` → south, `.left` → west, `.up` → north
- Always use `arrowHelper()` to create `ArrowModel` instances (never construct them manually in level files)
