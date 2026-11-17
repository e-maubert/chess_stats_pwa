import 'game_phase_summary.dart';

/// Une partie jouée, vue sous l'angle du pays de l'adversaire.
/// Sert à recalculer les statistiques par pays selon la cadence choisie.
class CountryGame {
  /// Code pays chess.com (ex. 'FR'), ou 'Unknown' si introuvable ; null
  /// tant qu'il n'a pas été cherché. Il n'est pas demandé au téléchargement
  /// des parties (un appel par adversaire, coûteux) mais ensuite, pour la
  /// seule carte des pays : voir OpponentCountryService.
  final String? country;
  final String opponent;

  /// Cadence chess.com : 'bullet', 'blitz', 'rapid', 'daily'...
  final String timeClass;

  /// 'win', 'loss' ou 'draw'.
  final String result;

  /// Couleur jouée par le joueur : 'white' ou 'black'.
  final String playerColor;

  /// Nom de l'ouverture (ex. 'Sicilian-Defense-Najdorf'), 'Unknown-Opening'
  /// si inconnue. Regroupée par famille via OpeningFamily.getFamilyName.
  final String opening;

  /// Cause de la défaite ('timeout', 'checkmated', 'resigned', 'other'),
  /// null si la partie n'est pas une défaite. Voir LossStatsService.
  final String? lossCause;

  /// Classement du joueur après la partie (champ `rating` de chess.com),
  /// null si absent.
  final int? rating;

  /// Fin de la partie (champ `end_time`), null si absente.
  final DateTime? endTime;

  /// Début de la partie, lu dans le PGN (`[UTCDate]` + `[UTCTime]`, en UTC),
  /// null si absent. Voir PlayingHoursService.
  final DateTime? startTime;

  /// Partie classée (champ `rated`) : seules celles-ci font varier le
  /// classement.
  final bool rated;

  /// Temps restant en fin de partie (secondes), lu dans le PGN : le nôtre
  /// (0 si perdue au temps) et celui de l'adversaire. null si inconnu.
  final double? playerClock;
  final double? opponentClock;

  /// Temps initial de la cadence en secondes (« 180+2 » => 180), null pour
  /// les parties par correspondance.
  final int? baseTime;

  /// Adresse de la partie sur chess.com (champ `url`) : identifie la partie
  /// pour éviter les doublons dans le stockage local. null si absente.
  final String? url;

  /// Coups de la partie (partie « coups » du PGN, avec les pendules),
  /// gardés seulement jusqu'au calcul de [phases] : null ensuite.
  final String? moves;

  /// Phases de la partie, calculées après l'affichage des stats (voir
  /// PlayerGamesViewModel.phaseGamesIn) ; null tant qu'elles ne le sont pas.
  final GamePhaseSummary? phases;

  const CountryGame({
    this.country,
    required this.opponent,
    required this.timeClass,
    required this.result,
    required this.playerColor,
    required this.opening,
    this.lossCause,
    this.rating,
    this.endTime,
    this.startTime,
    this.rated = true,
    this.playerClock,
    this.opponentClock,
    this.baseTime,
    this.url,
    this.moves,
    this.phases,
  });

  /// Même partie, avec le pays de l'adversaire.
  CountryGame withCountry(String country) => _copy(country: country, moves: moves, phases: phases);

  /// Même partie, avec ses phases ; les coups, devenus inutiles, sont
  /// retirés.
  CountryGame withPhases(GamePhaseSummary phases) => _copy(country: country, moves: null, phases: phases);

  CountryGame _copy({required String? country, required String? moves, required GamePhaseSummary? phases}) =>
      CountryGame(
        country: country,
        opponent: opponent,
        timeClass: timeClass,
        result: result,
        playerColor: playerColor,
        opening: opening,
        lossCause: lossCause,
        rating: rating,
        endTime: endTime,
        startTime: startTime,
        rated: rated,
        playerClock: playerClock,
        opponentClock: opponentClock,
        baseTime: baseTime,
        url: url,
        moves: moves,
        phases: phases,
      );

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'opponent': opponent,
      'timeClass': timeClass,
      'result': result,
      'playerColor': playerColor,
      'opening': opening,
      'lossCause': lossCause,
      'rating': rating,
      'endTime': endTime?.millisecondsSinceEpoch,
      'startTime': startTime?.millisecondsSinceEpoch,
      'rated': rated,
      'playerClock': playerClock,
      'opponentClock': opponentClock,
      'baseTime': baseTime,
      'url': url,
      'moves': moves,
      'phases': phases?.toJson(),
    };
  }

  factory CountryGame.fromJson(Map<String, dynamic> json) {
    return CountryGame(
      country: json['country'] as String?,
      opponent: json['opponent'] as String,
      timeClass: json['timeClass'] as String,
      result: json['result'] as String,
      playerColor: json['playerColor'] as String,
      opening: json['opening'] as String,
      lossCause: json['lossCause'] as String?,
      rating: json['rating'] as int?,
      endTime: json['endTime'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int),
      startTime: json['startTime'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int, isUtc: true),
      rated: json['rated'] as bool? ?? true,
      playerClock: (json['playerClock'] as num?)?.toDouble(),
      opponentClock: (json['opponentClock'] as num?)?.toDouble(),
      baseTime: json['baseTime'] as int?,
      url: json['url'] as String?,
      moves: json['moves'] as String?,
      phases: json['phases'] == null
          ? null
          : GamePhaseSummary.fromJson(Map<String, dynamic>.from(json['phases'] as Map)),
    );
  }
}
