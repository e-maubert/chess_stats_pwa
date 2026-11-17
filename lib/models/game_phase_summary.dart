/// Phases d'une partie d'échecs.
enum GamePhase { opening, middlegame, endgame }

/// Ce qu'on retient d'une partie une fois ses coups rejoués (voir
/// GamePhaseService) : phase où elle s'est terminée, pendules aux deux
/// moments clés, matériel et type de finale. Vu du côté du joueur.
class GamePhaseSummary {
  /// Phase dans laquelle la partie s'est terminée.
  final GamePhase endPhase;

  /// Pendules (secondes) à la fin de l'ouverture ; null si la partie s'est
  /// terminée avant ou si la pendule est absente.
  final double? playerClockAtMiddlegame;
  final double? opponentClockAtMiddlegame;

  /// Pendules (secondes) à l'entrée en finale ; null sans finale.
  final double? playerClockAtEndgame;
  final double? opponentClockAtEndgame;

  /// Matériel à l'entrée en finale, le nôtre moins celui de l'adversaire
  /// (pion 1, cavalier et fou 3, tour 5, dame 9) ; null sans finale.
  final int? endgameMaterial;

  /// Type de finale (GamePhaseService.endgameTypeOf) ; null sans finale.
  final String? endgameType;

  const GamePhaseSummary({
    required this.endPhase,
    this.playerClockAtMiddlegame,
    this.opponentClockAtMiddlegame,
    this.playerClockAtEndgame,
    this.opponentClockAtEndgame,
    this.endgameMaterial,
    this.endgameType,
  });

  Map<String, dynamic> toJson() => {
        'endPhase': endPhase.name,
        'playerClockAtMiddlegame': playerClockAtMiddlegame,
        'opponentClockAtMiddlegame': opponentClockAtMiddlegame,
        'playerClockAtEndgame': playerClockAtEndgame,
        'opponentClockAtEndgame': opponentClockAtEndgame,
        'endgameMaterial': endgameMaterial,
        'endgameType': endgameType,
      };

  factory GamePhaseSummary.fromJson(Map<String, dynamic> json) => GamePhaseSummary(
        endPhase: GamePhase.values.byName(json['endPhase'] as String),
        playerClockAtMiddlegame: (json['playerClockAtMiddlegame'] as num?)?.toDouble(),
        opponentClockAtMiddlegame: (json['opponentClockAtMiddlegame'] as num?)?.toDouble(),
        playerClockAtEndgame: (json['playerClockAtEndgame'] as num?)?.toDouble(),
        opponentClockAtEndgame: (json['opponentClockAtEndgame'] as num?)?.toDouble(),
        endgameMaterial: json['endgameMaterial'] as int?,
        endgameType: json['endgameType'] as String?,
      );
}
