import '../models/country_game.dart';
import '../models/stats_period.dart';
import '../models/year_month.dart';

/// Règles du stockage local des parties (par joueur et par mois) : mois à
/// télécharger, mois « clos », fusion et purge. Logique pure, sans accès au
/// stockage ni au réseau.
class GameStoragePolicy {
  /// Marge après la fin d'un mois (UTC) avant de le considérer comme clos :
  /// laisse à chess.com le temps de ranger les dernières parties du mois.
  static const Duration closingMargin = Duration(hours: 2);

  /// Un joueur dont les stats n'ont pas été ouvertes depuis plus longtemps
  /// est supprimé du stockage.
  static const Duration playerRetention = Duration(days: 30);

  /// Mois (UTC) couvrant les [days] derniers jours avant [now], du plus
  /// ancien au plus récent (mois en cours compris).
  static List<YearMonth> monthsCovering(DateTime now, int days) {
    final last = YearMonth.of(now);
    final months = <YearMonth>[];
    for (var month = YearMonth.of(now.subtract(Duration(days: days))); !(last < month); month = month.add(1)) {
      months.add(month);
    }
    return months;
  }

  /// Mois nécessaires à la plus longue période proposée, limités aux
  /// [retainedMonthCount] derniers (4 archives au plus pour 90 jours). Seul
  /// cas limité : autour du 1er mai, 90 jours remontent au 30 ou 31 janvier
  /// (février + mars + avril = 89 jours) ; ces quelques heures de janvier
  /// ne sont pas téléchargées.
  static List<YearMonth> monthsNeeded(DateTime now) {
    final months = monthsCovering(now, StatsPeriod.longestDays);
    final count = retainedMonthCount();
    return months.length > count ? months.sublist(months.length - count) : months;
  }

  /// Nombre de mois calendaires gardés par joueur : plus longue période
  /// proposée (en mois de 30 jours, arrondie au-dessus) + le mois entamé.
  /// 90 jours => 4 mois.
  static int retainedMonthCount([int? longestDays]) => ((longestDays ?? StatsPeriod.longestDays) / 30).ceil() + 1;

  /// Plus ancien mois conservé à la date [now].
  static YearMonth oldestRetainedMonth(DateTime now) => YearMonth.of(now).add(1 - retainedMonthCount());

  /// Un mois est clos s'il a été téléchargé après sa fin (+ [closingMargin]) :
  /// il n'a plus besoin d'être téléchargé de nouveau.
  static bool isClosed(YearMonth month, DateTime fetchedAt) =>
      !fetchedAt.toUtc().isBefore(month.end.add(closingMargin));

  /// Joueur à supprimer : stats non ouvertes depuis plus de [playerRetention].
  static bool isPlayerExpired(DateTime lastViewedAt, DateTime now) =>
      now.difference(lastViewedAt) > playerRetention;

  /// Fusionne des parties déjà stockées et des parties fraîchement
  /// téléchargées, sans doublon : une partie est identifiée par son URL (la
  /// version téléchargée l'emporte, sauf si seule la version stockée a déjà
  /// ses phases calculées : une partie finie ne change plus). Triées par
  /// date de fin.
  static List<CountryGame> merge(List<CountryGame> stored, List<CountryGame> fresh) {
    final byKey = <String, CountryGame>{};
    for (final game in stored) {
      byKey[identity(game)] = game;
    }
    for (final game in fresh) {
      final key = identity(game);
      final previous = byKey[key];
      if (previous != null && previous.phases != null && game.phases == null) continue;
      byKey[key] = game;
    }
    final games = byKey.values.toList();
    games.sort((a, b) => (a.endTime ?? DateTime(0)).compareTo(b.endTime ?? DateTime(0)));
    return games;
  }

  /// Identifiant d'une partie : son URL, sinon fin + adversaire + couleur.
  static String identity(CountryGame game) =>
      game.url ?? '${game.endTime?.millisecondsSinceEpoch}|${game.opponent}|${game.playerColor}';
}
