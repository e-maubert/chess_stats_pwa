import '../models/country_game.dart';
import '../models/game_phase_summary.dart';
import 'loss_stats_service.dart';
import 'time_management_service.dart';

/// Matériel à l'entrée en finale, par rapport à l'adversaire.
enum MaterialBalance { ahead, equal, behind }

/// Victoires / nulles / défaites d'un groupe de parties.
class ResultCounts {
  int wins = 0;
  int draws = 0;
  int losses = 0;

  /// Défaites au temps (comprises dans [losses]).
  int timeoutLosses = 0;

  int get total => wins + draws + losses;

  void add(CountryGame game) {
    switch (game.result) {
      case 'win':
        wins++;
      case 'draw':
        draws++;
      case 'loss':
        losses++;
        if (game.lossCause == LossStatsService.timeout) timeoutLosses++;
    }
  }
}

/// Temps restant moyen, en part du temps initial (1 = tout le temps
/// initial ; peut dépasser 1 avec l'incrément), le nôtre et celui de
/// l'adversaire, sur [games] parties.
class ClockShares {
  final double player;
  final double opponent;
  final int games;

  const ClockShares({required this.player, required this.opponent, required this.games});

  /// Notre temps par rapport à l'adversaire, avec le seuil de la gestion du
  /// temps (écart de plus de 10 % du temps initial).
  TimeGap get gap => TimeManagementService.classify(player - opponent, TimeManagementService.threshold);
}

class GamePhaseStats {
  /// Résultats selon la phase où la partie s'est terminée.
  final Map<GamePhase, ResultCounts> byEndPhase;

  /// Temps restant à la fin de l'ouverture et à l'entrée en finale ; null
  /// sans partie chronométrée concernée.
  final ClockShares? atMiddlegame;
  final ClockShares? atEndgame;

  /// Parties arrivées en finale : résultats selon le matériel à l'entrée en
  /// finale et selon le type de finale (du plus joué au moins joué).
  final Map<MaterialBalance, ResultCounts> endgamesByMaterial;
  final List<(String, ResultCounts)> endgamesByType;

  const GamePhaseStats({
    required this.byEndPhase,
    required this.atMiddlegame,
    required this.atEndgame,
    required this.endgamesByMaterial,
    required this.endgamesByType,
  });

  int get games => byEndPhase.values.fold(0, (sum, counts) => sum + counts.total);
  int get endgames => byEndPhase[GamePhase.endgame]!.total;
}

class GamePhaseStatsService {
  /// Statistiques des parties de [games] dont les phases sont connues.
  /// [timeClass] null = toutes les cadences.
  static GamePhaseStats aggregate(List<CountryGame> games, {String? timeClass}) {
    final byEndPhase = {for (final phase in GamePhase.values) phase: ResultCounts()};
    final byMaterial = {for (final balance in MaterialBalance.values) balance: ResultCounts()};
    final byType = <String, ResultCounts>{};
    final middlegameClocks = _ClockSum();
    final endgameClocks = _ClockSum();

    for (final game in games) {
      final phases = game.phases;
      if (phases == null) continue;
      if (timeClass != null && game.timeClass != timeClass) continue;
      byEndPhase[phases.endPhase]!.add(game);
      middlegameClocks.add(game.baseTime, phases.playerClockAtMiddlegame, phases.opponentClockAtMiddlegame);
      if (phases.endPhase != GamePhase.endgame) continue;
      endgameClocks.add(game.baseTime, phases.playerClockAtEndgame, phases.opponentClockAtEndgame);
      final material = phases.endgameMaterial;
      if (material != null) byMaterial[balanceOf(material)]!.add(game);
      final type = phases.endgameType;
      if (type != null) byType.putIfAbsent(type, ResultCounts.new).add(game);
    }

    final types = [for (final entry in byType.entries) (entry.key, entry.value)]
      ..sort((a, b) => b.$2.total != a.$2.total ? b.$2.total.compareTo(a.$2.total) : a.$1.compareTo(b.$1));
    return GamePhaseStats(
      byEndPhase: byEndPhase,
      atMiddlegame: middlegameClocks.shares,
      atEndgame: endgameClocks.shares,
      endgamesByMaterial: byMaterial,
      endgamesByType: types,
    );
  }

  /// En avance dès un pion de plus, en retard dès un pion de moins.
  static MaterialBalance balanceOf(int material) => material > 0
      ? MaterialBalance.ahead
      : material < 0
          ? MaterialBalance.behind
          : MaterialBalance.equal;
}

class _ClockSum {
  double player = 0;
  double opponent = 0;
  int games = 0;

  /// Parties chronométrées seulement (temps initial connu).
  void add(int? baseTime, double? playerClock, double? opponentClock) {
    if (baseTime == null || playerClock == null || opponentClock == null) return;
    player += playerClock / baseTime;
    opponent += opponentClock / baseTime;
    games++;
  }

  ClockShares? get shares =>
      games == 0 ? null : ClockShares(player: player / games, opponent: opponent / games, games: games);
}
