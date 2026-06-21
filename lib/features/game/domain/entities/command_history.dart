import 'move_command.dart';

/// Stores an ordered history of [MoveCommand]s for undo/redo support.
///
/// This class is **immutable**: [push] and [pop] return new instances
/// so the BLoC can track history changes.
class CommandHistory {
  /// Ordered list of executed commands (most recent last).
  final List<MoveCommand> _commands;

  /// Creates an empty history.
  const CommandHistory() : _commands = const [];

  const CommandHistory._(this._commands);

  /// Returns an unmodifiable view of all commands.
  List<MoveCommand> get commands => List<MoveCommand>.unmodifiable(_commands);

  /// Whether there are commands available to undo.
  bool get canUndo => _commands.isNotEmpty;

  /// Number of commands in the history.
  int get length => _commands.length;

  /// Returns a new [CommandHistory] with [command] appended.
  CommandHistory push(MoveCommand command) {
    return CommandHistory._([..._commands, command]);
  }

  /// Returns the most recently added [MoveCommand], or `null` if empty.
  MoveCommand? get last => _commands.isEmpty ? null : _commands.last;

  /// Returns a new [CommandHistory] with the most recent command removed,
  /// paired with the removed command for the caller to apply the undo.
  ///
  /// If the history is empty returns `null`.
  (CommandHistory, MoveCommand)? pop() {
    if (_commands.isEmpty) return null;
    final newHistory = CommandHistory._(_commands.sublist(0, _commands.length - 1));
    return (newHistory, _commands.last);
  }

  @override
  String toString() => 'CommandHistory(length: ${_commands.length})';
}
