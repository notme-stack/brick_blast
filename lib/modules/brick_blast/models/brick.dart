class Brick {
  const Brick({
    required this.id,
    required this.row,
    required this.col,
    required this.hp,
    required this.colorTier,
  });

  final int id;
  final int row;
  final int col;
  final int hp;
  final int colorTier;

  Brick copyWith({int? id, int? row, int? col, int? hp, int? colorTier}) {
    return Brick(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      hp: hp ?? this.hp,
      colorTier: colorTier ?? this.colorTier,
    );
  }
}
