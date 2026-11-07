import '../models/country_game.dart';
import '../models/loss_stats.dart';

class LossStatsService {
  static const String timeout = 'timeout';
  static const String checkmated = 'checkmated';
  static const String resigned = 'resigned';
  static const String other = 'other';

  /// Cause d'une défaite à partir du résultat chess.com du joueur.
  /// `abandoned` (déconnexion) est fusionné avec `resigned`.
  static String lossCause(String? chessComResult) {
    switch (chessComResult) {
      case 'timeout':
        return timeout;
      case 'checkmated':
        return checkmated;
      case 'resigned':
      case 'abandoned':
        return resigned;
      default:
        return other;
    }
  }

  /// Compte les défaites par cause. [timeClass] null = toutes les cadences.
  static LossStats aggregate(List<CountryGame> games, {String? timeClass}) {
    var timeoutCount = 0;
    var checkmatedCount = 0;
    var resignedCount = 0;
    var otherCount = 0;

    for (final game in games) {
      if (game.result != 'loss') continue;
      if (timeClass != null && game.timeClass != timeClass) continue;
      switch (game.lossCause) {
        case timeout:
          timeoutCount++;
          break;
        case checkmated:
          checkmatedCount++;
          break;
        case resigned:
          resignedCount++;
          break;
        default:
          otherCount++;
      }
    }

    return LossStats(
      timeout: timeoutCount,
      checkmated: checkmatedCount,
      resigned: resignedCount,
      other: otherCount,
    );
  }
}
