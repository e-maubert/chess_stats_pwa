class OpeningStats {
  final String name;
  final String color;
  int played;
  int won;

  OpeningStats({
    required this.name,
    required this.played,
    required this.won,
    required this.color,
  });

  double get winRate => played > 0 ? won / played : 0;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      'played': played,
      'won': won,
    };
  }

  factory OpeningStats.fromJson(Map<String, dynamic> json) {
    return OpeningStats(
      name: json['name'] as String,
      color: json['color'] as String,
      played: json['played'] as int,
      won: json['won'] as int,
    );
  }
} 