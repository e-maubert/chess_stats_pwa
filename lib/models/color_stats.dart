class ColorStats {
  final int wins;
  final int losses;
  final int draws;
  final int totalGames;

  ColorStats({
    required this.wins,
    required this.losses,
    required this.draws,
  }) : totalGames = wins + losses + draws;

  double get winRate => totalGames > 0 ? wins / totalGames : 0;
  double get lossRate => totalGames > 0 ? losses / totalGames : 0;
  double get drawRate => totalGames > 0 ? draws / totalGames : 0;

  Map<String, dynamic> toJson() {
    return {
      'wins': wins,
      'losses': losses,
      'draws': draws,
    };
  }

  factory ColorStats.fromJson(Map<String, dynamic> json) {
    return ColorStats(
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      draws: json['draws'] as int,
    );
  }
} 