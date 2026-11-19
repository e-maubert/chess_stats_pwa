/// Cause d'une défaite (temps, mat, abandon), lue dans le résultat
/// chess.com : sert à repérer les défaites au temps.
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
}
