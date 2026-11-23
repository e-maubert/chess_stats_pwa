import '../models/country_game.dart';
import '../models/stats_period.dart';
import 'opening_stats_service.dart';
import 'stats_period_service.dart';

/// Victoires, nulles et défaites du joueur analysé sur un ensemble de
/// parties.
class GameResults {
  final int wins;
  final int draws;
  final int losses;

  const GameResults({this.wins = 0, this.draws = 0, this.losses = 0});

  factory GameResults.of(Iterable<CountryGame> games) {
    var wins = 0, draws = 0, losses = 0;
    for (final game in games) {
      switch (game.result) {
        case 'win':
          wins++;
        case 'draw':
          draws++;
        default:
          losses++;
      }
    }
    return GameResults(wins: wins, draws: draws, losses: losses);
  }

  int get games => wins + draws + losses;

  /// Part des parties gagnées : le pourcentage affiché.
  double get winRate => games == 0 ? 0 : wins / games;

  /// Score comme en tournoi (victoires + ½ nulles), pour la forme du
  /// moment.
  double get score => games == 0 ? 0 : (wins + draws / 2) / games;

  /// Part des victoires lissée (une victoire et une partie fictives de
  /// chaque côté) pour classer : 100 % sur 5 parties ne passe pas devant
  /// 85 % sur 30.
  double get smoothedWinRate => (wins + 1) / (games + 2);
}

/// Forme du moment d'un joueur, de la pire à la meilleure : chaque niveau a
/// sa pièce (roi renversé, pion, cavalier, reine, double reine) et sa
/// couleur.
enum FormLevel { collapse, slump, steady, good, legendary }

/// Forme du moment dans la cadence analysée.
class PlayerForm {
  final FormLevel level;

  /// Variation du classement sur les [recent] parties (depuis le classement
  /// d'avant la première), null sans partie classée.
  final int? ratingChange;
  final int? currentRating;

  /// Résultats des [ScoutingService.recentGames] dernières parties.
  final GameResults recent;

  const PlayerForm({
    required this.level,
    this.ratingChange,
    this.currentRating,
    required this.recent,
  });
}

/// Ce que dit la diapo des cadences.
enum CadenceCase {
  /// Sa cadence la plus faible est aussi la plus jouée.
  same,

  /// Une autre cadence est plus faible, avec assez de parties pour le dire.
  other,

  /// Une autre cadence semble plus faible, mais sur trop peu de parties.
  otherFewGames,

  /// Il ne joue que dans une cadence.
  single,

  /// Les autres cadences ont trop peu de parties pour être comparées
  /// ([ScoutingService.minHintGames]) : on n'en dit rien.
  focusOnly,
}

/// Cadence la plus faible du joueur, comparée à celle qu'on analyse.
class CadenceInsight {
  final CadenceCase kind;

  /// Cadence la plus faible (= cadence analysée pour [CadenceCase.same] et
  /// [CadenceCase.single]).
  final String weakest;
  final GameResults weakestResults;

  /// Faiblesse établie au taux de victoire (assez de parties dans au moins
  /// deux cadences) ; sinon, au classement le plus bas.
  final bool byWinRate;

  const CadenceInsight({
    required this.kind,
    required this.weakest,
    required this.weakestResults,
    required this.byWinRate,
  });
}

/// Une famille d'ouvertures jouée avec une couleur.
class OpeningRecord {
  final String family;
  final GameResults results;

  const OpeningRecord(this.family, this.results);

  int get games => results.games;
}

/// Un coup d'ouverture (SAN, ex. 'd4') et les résultats du joueur analysé
/// quand il a été joué.
class MoveRecord {
  final String move;
  final GameResults results;

  const MoveRecord(this.move, this.results);

  int get games => results.games;
}

/// Répertoire du joueur avec une couleur, dans la cadence analysée.
///
/// Les conseils ne portent que sur les coups que choisit son adversaire :
/// quand il a les blancs, la réponse à son premier coup habituel
/// ([mainMove]) ; quand il a les noirs, le premier coup des blancs.
class ColorRepertoire {
  final int games;

  /// Ses 3 familles d'ouvertures les plus jouées (pour savoir à quoi
  /// s'attendre).
  final List<OpeningRecord> top;

  /// Avec les blancs : son premier coup le plus fréquent et sa part ; null
  /// avec les noirs ou sans coups connus.
  final MoveRecord? mainMove;
  final double mainMoveShare;

  /// Coup de l'adversaire (réponse à [mainMove], ou premier coup) assez
  /// joué contre lequel il gagne le moins (moins de 40 % de victoires) : à
  /// jouer.
  final MoveRecord? target;

  /// Coup de l'adversaire assez joué contre lequel il gagne le plus (60 %
  /// de victoires et plus) : à éviter.
  final MoveRecord? avoid;

  const ColorRepertoire({
    required this.games,
    required this.top,
    this.mainMove,
    this.mainMoveShare = 0,
    this.target,
    this.avoid,
  });
}

/// Conseils du plan de jeu final, dans l'ordre d'affichage.
enum ScoutingTip {
  /// Le défier dans sa cadence la plus faible.
  cadence,

  /// Quand il a les blancs : répondre [ColorRepertoire.target].
  whiteTarget,

  /// Quand il a les blancs : ne pas répondre [ColorRepertoire.avoid].
  whiteAvoid,

  /// Quand il a les noirs : ouvrir par [ColorRepertoire.target].
  blackTarget,

  /// Quand il a les noirs : ne pas ouvrir par [ColorRepertoire.avoid].
  blackAvoid,

  /// Conseil lié à sa forme du moment.
  form,
}

/// « Comment battre ce joueur » : ses points faibles dans sa cadence
/// principale, sur le dernier mois (ou 3 mois s'il a trop peu joué).
class ScoutingReport {
  final StatsPeriod period;

  /// Cadence analysée : la plus jouée.
  final String timeClass;

  /// Parties analysées (cadence [timeClass], période [period]).
  final int games;

  final PlayerForm form;
  final CadenceInsight cadence;
  final ColorRepertoire white;
  final ColorRepertoire black;

  /// Les conseils les plus forts, 3 au plus.
  final List<ScoutingTip> plan;

  const ScoutingReport({
    required this.period,
    required this.timeClass,
    required this.games,
    required this.form,
    required this.cadence,
    required this.white,
    required this.black,
    required this.plan,
  });
}

class ScoutingService {
  /// Cadences comparées (les parties par correspondance sont écartées).
  static const List<String> timeClasses = ['bullet', 'blitz', 'rapid'];

  /// Parties minimum dans la cadence analysée sur 1 mois ; en dessous, on
  /// prend 3 mois.
  static const int minFocusGames = 20;

  /// Parties minimum pour comparer les cadences au taux de victoire.
  static const int minCadenceGames = 10;

  /// Parties minimum pour citer une autre cadence, même « à confirmer ».
  static const int minHintGames = 3;

  /// Parties minimum pour juger un coup d'ouverture.
  static const int minMoveGames = 5;

  /// Parties récentes prises pour le score de forme.
  static const int recentGames = 20;

  static const String _unknownOpening = 'Unknown-Opening';

  /// Rapport sur les parties [games] du joueur à la date [now] ; null s'il
  /// n'a aucune partie de bullet, blitz ou rapide sur 3 mois.
  static ScoutingReport? build(List<CountryGame> games, DateTime now) {
    List<CountryGame> inPeriod(StatsPeriod period) => StatsPeriodService.preferRated(
          StatsPeriodService.filter(games, period, now).where((g) => timeClasses.contains(g.timeClass)).toList(),
        );

    var period = StatsPeriod.oneMonth;
    var pool = inPeriod(period);
    var focus = _mostPlayed(pool);
    if (focus == null || pool.where((g) => g.timeClass == focus).length < minFocusGames) {
      period = StatsPeriod.threeMonths;
      pool = inPeriod(period);
      focus = _mostPlayed(pool);
    }
    if (focus == null) return null;

    final focusGames = [
      for (final game in pool)
        if (game.timeClass == focus) game,
    ]..sort(_chronological);

    final form = _form(focusGames);
    final cadence = _cadence(pool, focus);
    final white = _repertoire(focusGames, 'white');
    final black = _repertoire(focusGames, 'black');

    return ScoutingReport(
      period: period,
      timeClass: focus,
      games: focusGames.length,
      form: form,
      cadence: cadence,
      white: white,
      black: black,
      plan: _plan(cadence, white, black),
    );
  }

  /// Niveau de forme d'après les résultats des dernières parties ([recent])
  /// et la variation du classement sur ces mêmes parties. Jamais « en
  /// forme » avec plus de défaites que de victoires, ni « en difficulté »
  /// avec plus de victoires que de défaites : le niveau ne contredit pas
  /// les pastilles affichées.
  static FormLevel formLevel({required int? ratingChange, required GameResults recent}) {
    final change = ratingChange ?? 0;
    final score = recent.score;
    final winning = recent.wins > recent.losses;
    final losing = recent.losses > recent.wins;
    if (change >= 100 && score >= 0.65 && winning) return FormLevel.legendary;
    if (change <= -80 && score < 0.45 && losing) return FormLevel.collapse;
    // Classement et résultats contradictoires (ex. +50 points mais plus de
    // défaites) : forme stable.
    final up = (change >= 30 || score >= 0.6) && winning && change > -30;
    final down = (change <= -30 || score <= 0.4) && losing && change < 30;
    if (up && !down) return FormLevel.good;
    if (down && !up) return FormLevel.slump;
    return FormLevel.steady;
  }

  static int _chronological(CountryGame a, CountryGame b) => a.endTime!.compareTo(b.endTime!);

  /// Cadence la plus jouée (à égalité : ordre de [timeClasses]).
  static String? _mostPlayed(List<CountryGame> games) {
    String? best;
    var bestCount = 0;
    for (final timeClass in timeClasses) {
      final count = games.where((g) => g.timeClass == timeClass).length;
      if (count > bestCount) {
        best = timeClass;
        bestCount = count;
      }
    }
    return best;
  }

  static PlayerForm _form(List<CountryGame> chronological) {
    final start = chronological.length > recentGames ? chronological.length - recentGames : 0;
    final recent = chronological.sublist(start);
    // Classement sur les mêmes parties que les résultats : depuis celui
    // d'avant la première d'entre elles (s'il est connu), jusqu'au dernier.
    final ratings = [
      for (final game in chronological.sublist(start > 0 ? start - 1 : 0))
        if (game.rated && game.rating != null) game.rating!,
    ];
    final change = ratings.isEmpty ? null : ratings.last - ratings.first;
    final results = GameResults.of(recent);
    return PlayerForm(
      level: formLevel(ratingChange: change, recent: results),
      ratingChange: change,
      currentRating: ratings.isEmpty ? null : ratings.last,
      recent: results,
    );
  }

  static CadenceInsight _cadence(List<CountryGame> pool, String focus) {
    final byClass = {
      for (final timeClass in timeClasses) timeClass: pool.where((g) => g.timeClass == timeClass).toList(),
    }..removeWhere((_, games) => games.isEmpty);

    CadenceInsight insight(CadenceCase kind, String timeClass, {required bool byWinRate}) => CadenceInsight(
          kind: kind,
          weakest: timeClass,
          weakestResults: GameResults.of(byClass[timeClass]!),
          byWinRate: byWinRate,
        );

    if (byClass.length < 2) return insight(CadenceCase.single, focus, byWinRate: true);

    // Assez de parties dans au moins deux cadences : comparaison au taux de
    // victoire.
    final enough = byClass.keys.where((c) => byClass[c]!.length >= minCadenceGames).toList();
    if (enough.length >= 2) {
      double winRate(String timeClass) => GameResults.of(byClass[timeClass]!).winRate;
      final weakest = enough.reduce((a, b) => winRate(b) < winRate(a) ? b : a);
      return insight(weakest == focus ? CadenceCase.same : CadenceCase.other, weakest, byWinRate: true);
    }

    // Sinon : le classement actuel le plus bas.
    int? currentRating(String timeClass) {
      final rated = byClass[timeClass]!.where((g) => g.rated && g.rating != null).toList()..sort(_chronological);
      return rated.isEmpty ? null : rated.last.rating;
    }

    final comparable = [
      for (final timeClass in byClass.keys)
        if (timeClass == focus || byClass[timeClass]!.length >= minHintGames) timeClass,
    ];
    if (comparable.length < 2) return insight(CadenceCase.focusOnly, focus, byWinRate: false);

    String? weakest;
    for (final timeClass in comparable) {
      final rating = currentRating(timeClass);
      if (rating == null) continue;
      if (weakest == null || rating < currentRating(weakest)!) weakest = timeClass;
    }
    if (weakest == null || weakest == focus) return insight(CadenceCase.same, focus, byWinRate: false);
    final few = byClass[weakest]!.length < minCadenceGames;
    return insight(few ? CadenceCase.otherFewGames : CadenceCase.other, weakest, byWinRate: false);
  }

  static ColorRepertoire _repertoire(List<CountryGame> games, String color) {
    final withColor = games.where((g) => g.playerColor == color).toList();
    final top = OpeningStatsService.aggregate(withColor)
        .where((o) => o.name != _unknownOpening)
        .take(3)
        .map((o) => OpeningRecord(o.name, GameResults(wins: o.wins, draws: o.draws, losses: o.losses)))
        .toList();

    final known = withColor.where((g) => g.openingMoves != null).toList();
    MoveRecord? mainMove;
    var share = 0.0;
    List<CountryGame> judged;
    int ply;
    if (color == 'white') {
      // Son premier coup habituel, puis les réponses de l'adversaire.
      final firstMoves = _byMove(known, 0);
      if (firstMoves.isEmpty) return ColorRepertoire(games: withColor.length, top: top);
      mainMove = firstMoves.reduce((a, b) => b.games > a.games ? b : a);
      share = mainMove.games / known.length;
      final main = mainMove.move;
      judged = known.where((g) => g.openingMoves![0] == main).toList();
      ply = 1;
    } else {
      // Premier coup des blancs (l'adversaire).
      judged = known;
      ply = 0;
    }

    double smoothed(MoveRecord m) => m.results.smoothedWinRate;
    MoveRecord? target;
    MoveRecord? avoid;
    for (final move in _byMove(judged, ply).where((m) => m.games >= minMoveGames)) {
      final winRate = move.results.winRate;
      if (winRate < 0.4 && (target == null || smoothed(move) < smoothed(target))) target = move;
      if (winRate >= 0.6 && (avoid == null || smoothed(move) > smoothed(avoid))) avoid = move;
    }

    return ColorRepertoire(
      games: withColor.length,
      top: top,
      mainMove: mainMove,
      mainMoveShare: share,
      target: target,
      avoid: avoid,
    );
  }

  /// Parties regroupées par leur demi-coup [ply] (0 = premier coup des
  /// blancs), avec les résultats du joueur analysé.
  static List<MoveRecord> _byMove(List<CountryGame> games, int ply) {
    final groups = <String, List<CountryGame>>{};
    for (final game in games) {
      final moves = game.openingMoves!;
      if (moves.length > ply) groups.putIfAbsent(moves[ply], () => []).add(game);
    }
    return [for (final entry in groups.entries) MoveRecord(entry.key, GameResults.of(entry.value))];
  }

  static List<ScoutingTip> _plan(CadenceInsight cadence, ColorRepertoire white, ColorRepertoire black) => [
        if (cadence.kind == CadenceCase.other) ScoutingTip.cadence,
        if (white.target != null) ScoutingTip.whiteTarget else if (white.avoid != null) ScoutingTip.whiteAvoid,
        if (black.target != null) ScoutingTip.blackTarget else if (black.avoid != null) ScoutingTip.blackAvoid,
        ScoutingTip.form,
      ].take(3).toList();
}
