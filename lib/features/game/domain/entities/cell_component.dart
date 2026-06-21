/// Leaf or composite node in the board's object-graph (Composite pattern).
///
/// Both [Cell] (leaf) and [Board] (composite) implement this interface so
/// that client code can treat individual cells and groupings uniformly.
abstract class CellComponent {
  /// Executes the component's primary action.
  ///
  /// For a leaf [Cell] this typically means rotating an arrow.
  /// For a composite [Board] it may trigger a collective evaluation.
  ///
  /// Returns a **new** instance (immutability contract) reflecting the
  /// post-action state.
  CellComponent executeAction();
}
