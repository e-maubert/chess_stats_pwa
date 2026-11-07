/// Une partie jouée, vue sous l'angle du pays de l'adversaire.
/// Sert à recalculer les statistiques par pays selon la cadence choisie.
class CountryGame {
  /// Code pays chess.com (ex. 'FR'), ou 'Unknown' si introuvable.
  final String country;
  final String opponent;

  /// Cadence chess.com : 'bullet', 'blitz', 'rapid', 'daily'...
  final String timeClass;

  /// 'win', 'loss' ou 'draw'.
  final String result;

  /// Cause de la défaite ('timeout', 'checkmated', 'resigned', 'other'),
  /// null si la partie n'est pas une défaite. Voir LossStatsService.
  final String? lossCause;

  const CountryGame({
    required this.country,
    required this.opponent,
    required this.timeClass,
    required this.result,
    this.lossCause,
  });

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'opponent': opponent,
      'timeClass': timeClass,
      'result': result,
      'lossCause': lossCause,
    };
  }

  factory CountryGame.fromJson(Map<String, dynamic> json) {
    return CountryGame(
      country: json['country'] as String,
      opponent: json['opponent'] as String,
      timeClass: json['timeClass'] as String,
      result: json['result'] as String,
      lossCause: json['lossCause'] as String?,
    );
  }
}
