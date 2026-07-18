import 'package:arrowconmango_front/features/game/domain/services/arrow_blocking_graph.dart';
import 'package:test/test.dart';

void main() {
  group('ArrowBlockingGraph', () {
    late ArrowBlockingGraph graph;

    setUp(() {
      graph = ArrowBlockingGraph();
    });

    test('should_start_empty', () {
      expect(graph.nodeCount, equals(0));
      expect(graph.nodes, isEmpty);
      expect(graph.getFreeArrows(), isEmpty);
    });

    test('should_add_nodes_correctly', () {
      graph.addNode('a1');
      graph.addNode('a2');

      expect(graph.nodeCount, equals(2));
      expect(graph.nodes, containsAll(['a1', 'a2']));
      expect(graph.getFreeArrows(), containsAll(['a1', 'a2']));
    });

    test('should_add_directed_blockages_correctly', () {
      // a1 blocks a2 (a1 -> a2)
      graph.addBlockage(from: 'a1', to: 'a2');

      expect(graph.nodeCount, equals(2));
      expect(graph.getFreeArrows(), equals(['a1'])); // a2 is blocked by a1
    });

    test('should_detect_no_cycles_in_DAG', () {
      graph.addBlockage(from: 'a1', to: 'a2');
      graph.addBlockage(from: 'a2', to: 'a3');

      expect(graph.hasCycle(), isFalse);
      expect(graph.topologicalSort(), equals(['a1', 'a2', 'a3']));
    });

    test('should_detect_direct_cycles', () {
      // a1 blocks a2 and a2 blocks a1 (deadlock)
      graph.addBlockage(from: 'a1', to: 'a2');
      graph.addBlockage(from: 'a2', to: 'a1');

      expect(graph.hasCycle(), isTrue);
      expect(graph.topologicalSort(), isNull);
    });

    test('should_detect_indirect_cycles', () {
      // a1 -> a2 -> a3 -> a1
      graph.addBlockage(from: 'a1', to: 'a2');
      graph.addBlockage(from: 'a2', to: 'a3');
      graph.addBlockage(from: 'a3', to: 'a1');

      expect(graph.hasCycle(), isTrue);
      expect(graph.topologicalSort(), isNull);
    });

    test('should_calculate_max_depth_correctly', () {
      // Parallel blockages:
      // a1 -> a2
      // a1 -> a3
      graph.addBlockage(from: 'a1', to: 'a2');
      graph.addBlockage(from: 'a1', to: 'a3');
      expect(graph.getMaxDepth(), equals(2)); // Path is just [a1, a2] or [a1, a3]

      // Sequential blockages:
      // a1 -> a2 -> a3 -> a4
      graph.addBlockage(from: 'a2', to: 'a3');
      graph.addBlockage(from: 'a3', to: 'a4');
      expect(graph.getMaxDepth(), equals(4)); // Path is [a1, a2, a3, a4]
    });

    test('should_return_0_depth_on_cycles', () {
      graph.addBlockage(from: 'a1', to: 'a2');
      graph.addBlockage(from: 'a2', to: 'a1');

      expect(graph.getMaxDepth(), equals(0));
    });

    test('should_remove_node_and_update_dependencies', () {
      // a1 -> a2 -> a3
      graph.addBlockage(from: 'a1', to: 'a2');
      graph.addBlockage(from: 'a2', to: 'a3');

      expect(graph.getFreeArrows(), equals(['a1']));

      // Removing a1 should free a2
      final nextGraph = graph.removeNode('a1');
      expect(nextGraph.nodeCount, equals(2));
      expect(nextGraph.getFreeArrows(), equals(['a2']));
    });
  });
}
