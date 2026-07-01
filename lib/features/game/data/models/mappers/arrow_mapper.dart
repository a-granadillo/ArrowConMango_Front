import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';

/// Converts [ArrowModel] to/from [ArrowEntity].
///
/// This mapper assumes a 2D rectangular board: node models are mapped to
/// [Grid2DNodeId] and direction labels are mapped to [CardinalDirection].
class ArrowMapper {
  const ArrowMapper();

  ArrowEntity toEntity(ArrowModel model) {
    return ArrowEntity(
      id: model.id,
      direction: _parseDirection(model.direction),
      occupiedNodes: model.nodes
          .map((node) => Grid2DNodeId(row: node.row, col: node.col))
          .toList(),
    );
  }

  ArrowModel toModel(ArrowEntity entity) {
    return ArrowModel(
      id: entity.id,
      direction: entity.direction.label,
      nodes: entity.occupiedNodes
          .map((node) {
            final gridNode = node as Grid2DNodeId;
            return NodeModel(row: gridNode.row, col: gridNode.col);
          })
          .toList(),
    );
  }

  CardinalDirection _parseDirection(String label) {
    switch (label) {
      case 'up':
        return CardinalDirection.up;
      case 'right':
        return CardinalDirection.right;
      case 'down':
        return CardinalDirection.down;
      case 'left':
        return CardinalDirection.left;
    }

    throw ArgumentError.value(
      label,
      'direction',
      'Unknown cardinal direction label',
    );
  }
}
