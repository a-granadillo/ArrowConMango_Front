import '../../domain/entities/arrow_entity.dart';
import '../../domain/entities/cardinal_direction.dart';
import '../../data/topologies/grid_2d_topology.dart';
import '../models/arrow_model.dart';
import '../models/node_model.dart';

/// Mapper for converting between [ArrowEntity] and [ArrowModel].
///
/// Handles the conversion of domain entities to data models for serialization
/// and vice versa.
class ArrowMapper {
  /// Converts an [ArrowEntity] to an [ArrowModel].
  ///
  /// Assumes all nodes are [Grid2DNodeId] instances.
  static ArrowModel toModel(ArrowEntity entity) {
    return ArrowModel(
      id: entity.id,
      direction: entity.direction.label,
      occupiedNodes: entity.occupiedNodes.map((node) {
        if (node is Grid2DNodeId) {
          return NodeModel(row: node.row, col: node.col);
        }
        throw ArgumentError(
          'Expected Grid2DNodeId, got ${node.runtimeType}',
        );
      }).toList(),
    );
  }

  /// Converts an [ArrowModel] to an [ArrowEntity].
  static ArrowEntity toEntity(ArrowModel model) {
    return ArrowEntity(
      id: model.id,
      direction: _parseDirection(model.direction),
      occupiedNodes: model.occupiedNodes
          .map((node) => Grid2DNodeId(row: node.row, col: node.col))
          .toList(),
    );
  }

  /// Parses a direction string to a [CardinalDirection].
  static CardinalDirection _parseDirection(String direction) {
    switch (direction) {
      case 'up':
        return CardinalDirection.up;
      case 'down':
        return CardinalDirection.down;
      case 'left':
        return CardinalDirection.left;
      case 'right':
        return CardinalDirection.right;
      default:
        throw ArgumentError('Unknown direction: $direction');
    }
  }
}
