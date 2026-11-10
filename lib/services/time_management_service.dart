import '../models/country_game.dart';
import 'loss_stats_service.dart';

/// Gestion du temps sur les parties perdues : écart de pendule avec
/// l'adversaire en fin de partie.
class TimeManagementStats {
  /// Défaites dont les pendules sont connues.
  final int losses;

  /// Défaites avec un écart de plus de 10 % du temps initial en notre
  /// défaveur / dans les 10 % / en notre faveur.
  final int behind;
  final int balanced;
  final int ahead;

  /// Écart moyen (notre temps − temps adverse) en secondes, 0 sans défaite.
  final double averageGap;

  /// Abandons, dont ceux sous pression du temps (en retard et moins de
  /// 10 % du temps initial).
  final int resignations;
  final int resignationsUnderPressure;

  const TimeManagementStats({
    required this.losses,
    required this.behind,
    required this.balanced,
    required this.ahead,
    required this.averageGap,
    required this.resignations,
    required this.resignationsUnderPressure,
  });

  double _rate(int count) => losses == 0 ? 0 : count / losses;
  double get behindRate => _rate(behind);
  double get balancedRate => _rate(balanced);
  double get aheadRate => _rate(ahead);
}

class TimeManagementService {
  /// Seuil d'écart « important » : 10 % du temps initial.
  static const double threshold = 0.10;

  static final RegExp _clock =
      RegExp(r'\d+(\.{1,3})\s+\S+\s+\{\[%clk (\d+):(\d+):(\d+(?:\.\d+)?)\]\}');

  /// Dernière pendule des blancs et des noirs dans un PGN chess.com
  /// (`1. e4 {[%clk 0:02:59.9]} 1... e5 {[%clk 0:02:59.1]}`), en secondes.
  /// null pour une couleur qui n'a joué aucun coup.
  static ({double? white, double? black}) lastClocks(String pgn) {
    double? white;
    double? black;
    for (final match in _clock.allMatches(pgn)) {
      final seconds = int.parse(match.group(2)!) * 3600 +
          int.parse(match.group(3)!) * 60 +
          double.parse(match.group(4)!);
      if (match.group(1)!.length == 3) {
        black = seconds;
      } else {
        white = seconds;
      }
    }
    return (white: white, black: black);
  }

  /// Temps initial en secondes depuis `time_control` (« 180 », « 180+2 »).
  /// null pour les parties par correspondance (« 1/86400 ») ou inconnues.
  static int? baseTime(String? timeControl) {
    if (timeControl == null || timeControl.contains('/')) return null;
    final base = int.tryParse(timeControl.split('+').first);
    return base == null || base <= 0 ? null : base;
  }

  /// Écart signé au format m:ss, arrondi à la seconde : « +1:05 »,
  /// « -0:42 », « 0:00 ».
  static String formatGap(double seconds) {
    final rounded = seconds.round();
    final sign = rounded > 0 ? '+' : (rounded < 0 ? '-' : '');
    final abs = rounded.abs();
    return '$sign${abs ~/ 60}:${(abs % 60).toString().padLeft(2, '0')}';
  }

  /// Agrège les défaites de la cadence [timeClass] (null = toutes) dont les
  /// pendules et le temps initial sont connus.
  static TimeManagementStats aggregate(List<CountryGame> games, {String? timeClass}) {
    var losses = 0, behind = 0, balanced = 0, ahead = 0;
    var resignations = 0, underPressure = 0;
    var totalGap = 0.0;

    for (final game in games) {
      if (game.result != 'loss') continue;
      if (timeClass != null && game.timeClass != timeClass) continue;
      final base = game.baseTime;
      final mine = game.playerClock;
      final theirs = game.opponentClock;
      if (base == null || mine == null || theirs == null) continue;

      final limit = base * threshold;
      final gap = mine - theirs;
      losses++;
      totalGap += gap;
      if (gap < -limit) {
        behind++;
      } else if (gap > limit) {
        ahead++;
      } else {
        balanced++;
      }

      if (game.lossCause == LossStatsService.resigned) {
        resignations++;
        if (gap < -limit && mine < limit) underPressure++;
      }
    }

    return TimeManagementStats(
      losses: losses,
      behind: behind,
      balanced: balanced,
      ahead: ahead,
      averageGap: losses == 0 ? 0 : totalGap / losses,
      resignations: resignations,
      resignationsUnderPressure: underPressure,
    );
  }
}
