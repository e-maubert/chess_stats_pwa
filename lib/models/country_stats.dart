class CountryStats {
  final String name;
  int gamesPlayed;
  int gamesWon;
  int gamesLost;
  int gamesDrawn;

  /// Nombre d'adversaires différents rencontrés dans ce pays.
  int opponentsCount;

  CountryStats({
    required this.name,
    required this.gamesPlayed,
    required this.gamesWon,
    this.gamesLost = 0,
    this.gamesDrawn = 0,
    this.opponentsCount = 0,
  });

  double get winRate => gamesPlayed > 0 ? gamesWon / gamesPlayed : 0;
  double get lossRate => gamesPlayed > 0 ? gamesLost / gamesPlayed : 0;
  double get drawRate => gamesPlayed > 0 ? gamesDrawn / gamesPlayed : 0;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'gamesDrawn': gamesDrawn,
      'opponentsCount': opponentsCount,
    };
  }

  factory CountryStats.fromJson(Map<String, dynamic> json) {
    return CountryStats(
      name: json['name'] as String,
      gamesPlayed: json['gamesPlayed'] as int,
      gamesWon: json['gamesWon'] as int,
      gamesLost: json['gamesLost'] as int? ?? 0,
      gamesDrawn: json['gamesDrawn'] as int? ?? 0,
      opponentsCount: json['opponentsCount'] as int? ?? 0,
    );
  }
} 