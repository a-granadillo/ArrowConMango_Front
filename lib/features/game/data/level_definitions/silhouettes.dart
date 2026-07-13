/// Master list of 2D binary silhouettes (masks) for level generation.
///
/// A '1' represents an occupied slot where an arrow body can be placed.
/// A '0' represents empty space (the background/air).
/// Arrow exit trajectories are allowed to cross empty spaces to escape the board.
abstract final class Silhouettes {
  /// 6x7 Heart shape (Level 1)
  static const List<String> heart = [
    '0110110',
    '1111111',
    '1111111',
    '0111110',
    '0011100',
    '0001000',
  ];

  /// 7x7 Star shape (Level 2)
  static const List<String> star = [
    '0001000',
    '0011100',
    '1111111',
    '0111110',
    '0011100',
    '0110110',
    '1100011',
  ];

  /// 7x7 Arrow pointing Up shape (Level 3)
  static const List<String> arrowUp = [
    '0001000',
    '0011100',
    '0111110',
    '1111111',
    '0011100',
    '0011100',
    '0011100',
  ];

  /// 7x7 House shape (Level 4)
  static const List<String> house = [
    '0001000',
    '0011100',
    '0111110',
    '1111111',
    '1111111',
    '1100111',
    '1100111',
  ];

  /// 7x7 Diamond shape (Level 5)
  static const List<String> diamond = [
    '0001000',
    '0011100',
    '0111110',
    '1111111',
    '0111110',
    '0011100',
    '0001000',
  ];

  /// 9x9 Mango shape (Level 6)
  static const List<String> mango = [
    '000010000',
    '000111000',
    '001111100',
    '011111110',
    '111111111',
    '111111111',
    '011111110',
    '001111100',
    '000010000',
  ];

  /// 9x9 Car shape (Level 7)
  static const List<String> car = [
    '000111000',
    '001111100',
    '011111110',
    '111111111',
    '111111111',
    '111111111',
    '011111110',
    '010000010',
    '000000000',
  ];

  /// 9x9 Spaceship shape (Level 8)
  static const List<String> spaceship = [
    '000010000',
    '000111000',
    '001111100',
    '011111110',
    '111111111',
    '011000110',
    '011000110',
    '111000111',
    '111000111',
  ];

  /// 9x9 Pine Tree shape (Level 9)
  static const List<String> tree = [
    '000010000',
    '000111000',
    '001111100',
    '011111110',
    '111111111',
    '000111000',
    '000111000',
    '000111000',
    '000111000',
  ];

  /// 9x9 Butterfly shape (Level 10)
  static const List<String> butterfly = [
    '111010111',
    '111111111',
    '111111111',
    '011111110',
    '001111100',
    '011111110',
    '111111111',
    '111111111',
    '111010111',
  ];

  /// 12x12 Dragon shape (Level 11)
  static const List<String> dragon = [
    '000000110000',
    '000001111000',
    '000011111100',
    '000111111110',
    '001111111111',
    '011111111111',
    '111111111110',
    '111111111100',
    '111111111000',
    '011111110000',
    '001111100000',
    '000111000000',
  ];

  /// 12x12 Castle shape (Level 12)
  static const List<String> castle = [
    '110110110111',
    '110110110111',
    '111111111111',
    '111111111111',
    '111111111111',
    '111001100111',
    '111001100111',
    '111111111111',
    '111111111111',
    '111111111111',
    '111000000111',
    '111000000111',
  ];

  /// 11x10 Robot shape (Level 13)
  static const List<String> robot = [
    '0011111100',
    '0111111110',
    '0111111110',
    '0011111100',
    '0001111000',
    '1111111111',
    '1111111111',
    '1111111111',
    '1111111111',
    '0011001100',
    '0011001100',
  ];

  /// 12x12 Phoenix shape (Level 14)
  static const List<String> phoenix = [
    '000001100000',
    '000011110000',
    '000111111000',
    '111111111111',
    '111111111111',
    '111111111111',
    '011111111110',
    '001111111100',
    '000111111000',
    '000011110000',
    '000001100000',
    '000000100000',
  ];

  /// 12x12 Geometric Pattern shape (Level 15)
  static const List<String> geometricPattern = [
    '111111111111',
    '111111111111',
    '110000000011',
    '110000000011',
    '110011110011',
    '110011110011',
    '110011110011',
    '110011110011',
    '110000000011',
    '110000000011',
    '111111111111',
    '111111111111',
  ];
}
