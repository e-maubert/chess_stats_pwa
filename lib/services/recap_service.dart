import '../models/country_game.dart';
import '../models/opening_family_stats.dart';
import 'opening_stats_service.dart';
import 'playing_hours_service.dart';

/// Bilan d'un adversaire affronté plusieurs fois.
class OpponentRecord {
  final String name;
  final int wins;
  final int draws;
  final int losses;

  const OpponentRecord({required this.name, this.wins = 0, this.draws = 0, this.losses = 0});

  int get games => wins + draws + losses;

  OpponentRecord _add(String result) => OpponentRecord(
        name: name,
        wins: wins + (result == 'win' ? 1 : 0),
        draws: draws + (result == 'draw' ? 1 : 0),
        losses: losses + (result == 'loss' ? 1 : 0),
      );
}

/// Faits marquants d'un joueur sur une période, façon « bilan de l'année » :
/// quelques chiffres simples, chacun null quand il n'y a pas de quoi le
/// calculer.
class PlayerRecap {
  final int games;
  final int wins;
  final int draws;
  final int losses;

  /// Cadence la plus jouée et son nombre de parties.
  final String? favoriteTimeClass;
  final int favoriteTimeClassGames;

  /// Famille d'ouvertures la plus jouée (ouvertures inconnues écartées).
  final String? favoriteOpening;
  final int favoriteOpeningGames;
  final double favoriteOpeningScore;

  /// Famille la plus réussie parmi celles assez jouées
  /// ([RecapService.minOpeningGames]), si elle diffère de la plus jouée et
  /// rapporte au moins la moitié des points.
  final String? bestOpening;
  final int bestOpeningGames;
  final double bestOpeningScore;

  /// Plus longue série de victoires consécutives.
  final int longestWinStreak;

  /// Classement de la cadence la plus jouée : variation (dernier − premier
  /// classement connu) et plus haut atteint ; null sans parties classées.
  final int? ratingChange;
  final int? peakRating;

  /// Heure de début (0 à 23) la plus fréquente.
  final int? favoriteHour;

  /// Jour le plus chargé et son nombre de parties.
  final DateTime? busiestDay;
  final int busiestDayGames;

  /// Adversaire le plus affronté (au moins deux parties).
  final OpponentRecord? topOpponent;

  /// Point faible : famille la moins réussie parmi celles assez jouées
  /// ([RecapService.minOpeningGames]) ; null s'il y en a moins de deux.
  final String? weakOpening;
  final int weakOpeningGames;
  final double weakOpeningScore;

  const PlayerRecap({
    required this.games,
    required this.wins,
    required this.draws,
    required this.losses,
    this.favoriteTimeClass,
    this.favoriteTimeClassGames = 0,
    this.favoriteOpening,
    this.favoriteOpeningGames = 0,
    this.favoriteOpeningScore = 0,
    this.bestOpening,
    this.bestOpeningGames = 0,
    this.bestOpeningScore = 0,
    this.longestWinStreak = 0,
    this.ratingChange,
    this.peakRating,
    this.favoriteHour,
    this.busiestDay,
    this.busiestDayGames = 0,
    this.topOpponent,
    this.weakOpening,
    this.weakOpeningGames = 0,
    this.weakOpeningScore = 0,
  });

  /// Score comme en tournoi : (victoires + ½ nulles) / parties.
  double get score => games > 0 ? (wins + draws / 2) / games : 0;
}

/// Calcule le bilan simplifié affiché entre la recherche et la page des
/// stats.
class RecapService {
  /// Parties minimum pour qu'une ouverture soit « la plus réussie ».
  static const int minOpeningGames = 5;

  static const String _unknownOpening = 'Unknown-Opening';

  /// Bilan des [games] (déjà limitées à la période) ; null s'il n'y en a
  /// aucune. [hourOf] et [dayOf] donnent l'heure et le jour d'une partie
  /// (par défaut en heure locale).
  static PlayerRecap? build(
    List<CountryGame> games, {
    int? Function(CountryGame)? hourOf,
    DateTime? Function(CountryGame)? dayOf,
  }) {
    if (games.isEmpty) return null;

    int count(String result) => games.where((g) => g.result == result).length;

    // Cadence la plus jouée (à égalité : ordre alphabétique, stable).
    final byTimeClass = _countBy(games, (g) => g.timeClass);
    final favoriteTimeClass = _maxKey(byTimeClass);

    // Ouvertures : la plus jouée, puis la plus réussie.
    final openings = OpeningStatsService.aggregate(games).where((o) => o.name != _unknownOpening).toList();
    double scoreOf(OpeningFamilyStats o) => (o.wins + o.draws / 2) / o.totalGames;
    final favorite = openings.isEmpty ? null : openings.first;
    final candidates = openings.where((o) => o.totalGames >= minOpeningGames).toList()
      ..sort((a, b) {
        final byScore = scoreOf(b).compareTo(scoreOf(a));
        return byScore != 0 ? byScore : b.totalGames.compareTo(a.totalGames);
      });
    final best = candidates.isEmpty ? null : candidates.first;
    final showBest = best != null && best.name != favorite?.name && scoreOf(best) >= 0.5;
    // La moins réussie : dernière du classement (à score égal, la plus
    // jouée), à condition d'en avoir au moins deux à comparer.
    final weak = candidates.length < 2
        ? null
        : candidates.reduce((a, b) {
            final byScore = scoreOf(a).compareTo(scoreOf(b));
            if (byScore != 0) return byScore < 0 ? a : b;
            return a.totalGames >= b.totalGames ? a : b;
          });
    final showWeak = weak != null && scoreOf(weak) < scoreOf(best!);

    // Ordre chronologique pour la série et le classement.
    final chronological = games.where((g) => g.endTime != null).toList()
      ..sort((a, b) => a.endTime!.compareTo(b.endTime!));

    var streak = 0;
    var longest = 0;
    for (final game in chronological) {
      streak = game.result == 'win' ? streak + 1 : 0;
      if (streak > longest) longest = streak;
    }

    final ratings = [
      for (final game in chronological)
        if (game.timeClass == favoriteTimeClass && game.rated && game.rating != null) game.rating!,
    ];

    // Heure favorite.
    final hours = PlayingHoursService.aggregate(games, hourOf: hourOf);
    final favoriteHour = hours.every((h) => h.games == 0)
        ? null
        : hours.reduce((a, b) => b.games > a.games ? b : a).hour;

    // Jour le plus chargé.
    DateTime? localDay(CountryGame g) {
      final end = g.endTime?.toLocal();
      return end == null ? null : DateTime(end.year, end.month, end.day);
    }

    final byDay = <DateTime, int>{};
    for (final game in games) {
      final day = (dayOf ?? localDay)(game);
      if (day != null) byDay[day] = (byDay[day] ?? 0) + 1;
    }
    DateTime? busiestDay;
    for (final entry in byDay.entries) {
      final current = busiestDay == null ? 0 : byDay[busiestDay]!;
      // À égalité, le jour le plus récent.
      if (entry.value > current || (entry.value == current && entry.key.isAfter(busiestDay!))) {
        busiestDay = entry.key;
      }
    }

    // Adversaire le plus affronté (pseudo sans distinction de casse).
    final opponents = <String, OpponentRecord>{};
    for (final game in games) {
      final key = game.opponent.toLowerCase();
      opponents[key] = (opponents[key] ?? OpponentRecord(name: game.opponent))._add(game.result);
    }
    OpponentRecord? topOpponent;
    for (final record in opponents.values) {
      if (record.games < 2) continue;
      if (topOpponent == null ||
          record.games > topOpponent.games ||
          (record.games == topOpponent.games && record.name.toLowerCase().compareTo(topOpponent.name.toLowerCase()) < 0)) {
        topOpponent = record;
      }
    }

    return PlayerRecap(
      games: games.length,
      wins: count('win'),
      draws: count('draw'),
      losses: count('loss'),
      favoriteTimeClass: favoriteTimeClass,
      favoriteTimeClassGames: favoriteTimeClass == null ? 0 : byTimeClass[favoriteTimeClass]!,
      favoriteOpening: favorite?.name,
      favoriteOpeningGames: favorite?.totalGames ?? 0,
      favoriteOpeningScore: favorite == null ? 0 : scoreOf(favorite),
      bestOpening: showBest ? best.name : null,
      bestOpeningGames: showBest ? best.totalGames : 0,
      bestOpeningScore: showBest ? scoreOf(best) : 0,
      longestWinStreak: longest,
      ratingChange: ratings.isEmpty ? null : ratings.last - ratings.first,
      peakRating: ratings.isEmpty ? null : ratings.reduce((a, b) => a > b ? a : b),
      favoriteHour: favoriteHour,
      busiestDay: busiestDay,
      busiestDayGames: busiestDay == null ? 0 : byDay[busiestDay]!,
      topOpponent: topOpponent,
      weakOpening: showWeak ? weak.name : null,
      weakOpeningGames: showWeak ? weak.totalGames : 0,
      weakOpeningScore: showWeak ? scoreOf(weak) : 0,
    );
  }

  static Map<String, int> _countBy(List<CountryGame> games, String Function(CountryGame) key) {
    final counts = <String, int>{};
    for (final game in games) {
      counts[key(game)] = (counts[key(game)] ?? 0) + 1;
    }
    return counts;
  }

  /// Clé la plus fréquente (à égalité : la première dans l'ordre
  /// alphabétique) ; null si [counts] est vide.
  static String? _maxKey(Map<String, int> counts) {
    String? best;
    for (final entry in counts.entries) {
      if (best == null ||
          entry.value > counts[best]! ||
          (entry.value == counts[best]! && entry.key.compareTo(best) < 0)) {
        best = entry.key;
      }
    }
    return best;
  }
}
