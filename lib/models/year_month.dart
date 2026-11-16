/// Un mois calendaire, au sens des archives mensuelles chess.com (UTC).
class YearMonth implements Comparable<YearMonth> {
  final int year;

  /// 1 à 12.
  final int month;

  const YearMonth(this.year, this.month);

  /// Mois (UTC) contenant l'instant [time].
  factory YearMonth.of(DateTime time) {
    final utc = time.toUtc();
    return YearMonth(utc.year, utc.month);
  }

  /// Lit une clé de la forme « 2026-11 » (voir [key]).
  factory YearMonth.parse(String key) {
    final parts = key.split('-');
    return YearMonth(int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Premier instant du mois, en UTC.
  DateTime get start => DateTime.utc(year, month);

  /// Premier instant du mois suivant, en UTC (= fin de ce mois).
  DateTime get end => DateTime.utc(year, month + 1);

  /// Mois décalé de [months] (négatif pour revenir en arrière).
  YearMonth add(int months) {
    final date = DateTime.utc(year, month + months);
    return YearMonth(date.year, date.month);
  }

  /// Clé triable « AAAA-MM », utilisée dans le stockage et l'URL chess.com.
  String get key => '$year-${month.toString().padLeft(2, '0')}';

  @override
  int compareTo(YearMonth other) => year != other.year ? year.compareTo(other.year) : month.compareTo(other.month);

  bool operator <(YearMonth other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) => other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => year * 12 + month;

  @override
  String toString() => key;
}
