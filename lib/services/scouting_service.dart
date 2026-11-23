import '../models/country_game.dart';
import '../models/game_phase_summary.dart';
import '../models/stats_period.dart';
import 'game_phase_stats_service.dart';
import 'loss_stats_service.dart';
import 'opening_stats_service.dart';
import 'playing_hours_service.dart';
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

  /// Phase où il perd le plus ([PhaseInsight.weakest]).
  phase,

  /// Sa gestion du temps, s'il est lent ou rapide ([TimeInsight.profile]).
  time,

  /// Sa réaction après une défaite ([TiltInsight.kind]).
  tilt,

  /// Le moment de la journée où il gagne le moins ([HoursInsight.weakest]).
  hours,

  /// Conseil lié à sa forme du moment.
  form,
}

/// Résultats selon la phase où la partie s'est terminée.
class PhaseInsight {
  final Map<GamePhase, GameResults> byPhase;

  /// Phase assez jouée ([ScoutingService.minPhaseGames]) où il gagne le
  /// moins ; null s'il y en a moins de deux à comparer.
  final GamePhase? weakest;

  /// [weakest] nettement sous son taux de victoire habituel
  /// ([ScoutingService.notableGap]) : conseil du plan de jeu.
  final bool notable;

  const PhaseInsight({required this.byPhase, this.weakest, this.notable = false});
}

/// Rythme de jeu par rapport à ses adversaires.
enum TimeProfile { slow, balanced, fast }

/// Gestion du temps : temps restant par rapport à l'adversaire à la sortie
/// de l'ouverture et à l'entrée en finale (en part du temps initial :
/// -0,1 = 10 % du temps initial de moins), et défaites au temps.
class TimeInsight {
  final TimeProfile profile;
  final double gapAtMiddlegame;
  final double? gapAtEndgame;

  /// Part des défaites perdues au temps.
  final double timeoutShare;
  final int losses;

  const TimeInsight({
    required this.profile,
    required this.gapAtMiddlegame,
    this.gapAtEndgame,
    required this.timeoutShare,
    required this.losses,
  });
}

/// Réaction après une défaite.
enum TiltKind {
  /// Il gagne nettement moins dans la partie qui suit une défaite.
  tilts,

  /// Il gagne autant qu'à son habitude.
  steady,

  /// Il gagne plus : une défaite le remobilise.
  resilient,

  /// Trop peu de parties jouées juste après une défaite.
  unknown,
}

/// Parties jouées dans l'heure qui suit une défaite, comparées à
/// l'ensemble.
class TiltInsight {
  final TiltKind kind;
  final GameResults afterLoss;
  final GameResults overall;

  const TiltInsight({required this.kind, required this.afterLoss, required this.overall});
}

/// Moments de la journée (heure de début, heure de l'appareil).
enum DayPart { morning, afternoon, evening, night }

/// Résultats selon le moment de la journée.
class HoursInsight {
  final Map<DayPart, GameResults> byPart;

  /// Moment assez joué ([ScoutingService.minHoursGames]) où il gagne le
  /// moins ; null s'il y en a moins de deux à comparer.
  final DayPart? weakest;

  /// [weakest] nettement sous son taux de victoire habituel.
  final bool notable;

  const HoursInsight({required this.byPart, this.weakest, this.notable = false});
}

/// « Comment battre ce joueur » : ses points faibles dans sa cadence
/// principale, sur le dernier mois (ou 3 mois s'il a trop peu joué).
class ScoutingReport {
  final StatsPeriod period;

  /// Cadence analysée : la plus jouée.
  final String timeClass;

  /// Parties analysées (cadence [timeClass], période [period]), de la
  /// plus ancienne à la plus récente : leurs phases sont calculées ensuite
  /// pour [ScoutingService.phases] et [ScoutingService.time].
  final List<CountryGame> analyzed;

  final PlayerForm form;
  final CadenceInsight cadence;
  final ColorRepertoire white;
  final ColorRepertoire black;
  final TiltInsight tilt;
  final HoursInsight hours;

  const ScoutingReport({
    required this.period,
    required this.timeClass,
    required this.analyzed,
    required this.form,
    required this.cadence,
    required this.white,
    required this.black,
    required this.tilt,
    required this.hours,
  });

  int get games => analyzed.length;
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

  /// Parties minimum par phase, par moment de la journée, et juste après
  /// une défaite, pour en tirer un conseil.
  static const int minPhaseGames = 8;
  static const int minHoursGames = 10;
  static const int minTiltGames = 8;

  /// Parties chronométrées minimum pour juger la gestion du temps.
  static const int minClockGames = 10;

  /// Écart minimum (en points de taux de victoire) avec son habitude pour
  /// qu'une phase ou un moment de la journée fasse un conseil ; le double
  /// pour l'après-défaite.
  static const double notableGap = 0.05;

  /// Délai maximum entre une défaite et le début de la partie suivante pour
  /// parler de réaction à chaud.
  static const Duration tiltWindow = Duration(hours: 1);

  /// Conseils au plus dans le plan de jeu.
  static const int planSize = 4;

  static const String _unknownOpening = 'Unknown-Opening';

  /// Rapport sur les parties [games] du joueur à la date [now] ; null s'il
  /// n'a aucune partie de bullet, blitz ou rapide sur 3 mois.
  /// [hourOf] donne l'heure de début d'une partie (par défaut l'heure de
  /// l'appareil, voir PlayingHoursService.localHour).
  static ScoutingReport? build(List<CountryGame> games, DateTime now, {int? Function(CountryGame)? hourOf}) {
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
      analyzed: focusGames,
      form: form,
      cadence: cadence,
      white: white,
      black: black,
      tilt: _tilt(focusGames),
      hours: _hours(focusGames, hourOf ?? PlayingHoursService.localHour),
    );
  }

  /// Résultats selon la phase de fin de partie, sur les parties [games]
  /// dont les phases sont connues ; null si aucune ne l'est.
  static PhaseInsight? phases(List<CountryGame> games) {
    final withPhases = games.where((g) => g.phases != null).toList();
    if (withPhases.isEmpty) return null;
    final byPhase = {
      for (final phase in GamePhase.values) phase: GameResults.of(withPhases.where((g) => g.phases!.endPhase == phase)),
    };
    final weakest = _weakest(byPhase, minPhaseGames);
    return PhaseInsight(
      byPhase: byPhase,
      weakest: weakest,
      notable: weakest != null && _isNotable(byPhase[weakest]!, GameResults.of(withPhases)),
    );
  }

  /// Gestion du temps sur les parties [games] dont les phases sont
  /// connues ; null s'il y a trop peu de parties chronométrées.
  static TimeInsight? time(List<CountryGame> games) {
    final stats = GamePhaseStatsService.aggregate(games);
    final middle = stats.atMiddlegame;
    final end = stats.atEndgame;
    if (middle == null || middle.games < minClockGames) return null;
    final gapMiddle = middle.player - middle.opponent;
    final gapEnd = end == null || end.games < minPhaseGames ? null : end.player - end.opponent;
    final losses = games.where((g) => g.result == 'loss').toList();
    final timeouts = losses.where((g) => g.lossCause == LossStatsService.timeout).length;
    final timeoutShare = losses.isEmpty ? 0.0 : timeouts / losses.length;

    final gap = gapEnd ?? gapMiddle;
    final TimeProfile profile;
    if (gap <= -0.10 || timeoutShare >= 0.3) {
      profile = TimeProfile.slow;
    } else if (gap >= 0.10 && timeoutShare < 0.15) {
      profile = TimeProfile.fast;
    } else {
      profile = TimeProfile.balanced;
    }
    return TimeInsight(
      profile: profile,
      gapAtMiddlegame: gapMiddle,
      gapAtEndgame: gapEnd,
      timeoutShare: timeoutShare,
      losses: losses.length,
    );
  }

  /// Les conseils les plus forts pour le plan de jeu, [planSize] au plus :
  /// d'abord les plus concrets (cadence, coups d'ouverture), puis phase,
  /// temps, réaction après une défaite, moment de la journée et forme.
  /// [phase] et [time] restent null tant que les phases ne sont pas
  /// calculées.
  static List<ScoutingTip> plan(ScoutingReport report, {PhaseInsight? phase, TimeInsight? time}) => [
        if (report.cadence.kind == CadenceCase.other) ScoutingTip.cadence,
        if (report.white.target != null)
          ScoutingTip.whiteTarget
        else if (report.white.avoid != null)
          ScoutingTip.whiteAvoid,
        if (report.black.target != null)
          ScoutingTip.blackTarget
        else if (report.black.avoid != null)
          ScoutingTip.blackAvoid,
        if (phase != null && phase.notable) ScoutingTip.phase,
        if (time != null && time.profile != TimeProfile.balanced) ScoutingTip.time,
        if (report.tilt.kind == TiltKind.tilts || report.tilt.kind == TiltKind.resilient) ScoutingTip.tilt,
        if (report.hours.notable) ScoutingTip.hours,
        ScoutingTip.form,
      ].take(planSize).toList();

  /// Clé assez jouée ([minGames]) au plus faible taux de victoire ; null
  /// s'il y en a moins de deux à comparer.
  static K? _weakest<K>(Map<K, GameResults> results, int minGames) {
    final candidates = results.entries.where((e) => e.value.games >= minGames).toList();
    if (candidates.length < 2) return null;
    return candidates.reduce((a, b) => b.value.winRate < a.value.winRate ? b : a).key;
  }

  static bool _isNotable(GameResults part, GameResults overall) => part.winRate <= overall.winRate - notableGap;

  /// Parties commencées dans l'heure qui suit une défaite ([chronological] :
  /// de la plus ancienne à la plus récente).
  static TiltInsight _tilt(List<CountryGame> chronological) {
    final after = <CountryGame>[];
    for (var i = 1; i < chronological.length; i++) {
      final previous = chronological[i - 1];
      if (previous.result != 'loss') continue;
      final game = chronological[i];
      final start = game.startTime ?? game.endTime!;
      if (start.difference(previous.endTime!) <= tiltWindow) after.add(game);
    }
    final afterLoss = GameResults.of(after);
    final overall = GameResults.of(chronological);
    final TiltKind kind;
    if (afterLoss.games < minTiltGames) {
      kind = TiltKind.unknown;
    } else if (afterLoss.winRate <= overall.winRate - 2 * notableGap) {
      kind = TiltKind.tilts;
    } else if (afterLoss.winRate >= overall.winRate + notableGap) {
      kind = TiltKind.resilient;
    } else {
      kind = TiltKind.steady;
    }
    return TiltInsight(kind: kind, afterLoss: afterLoss, overall: overall);
  }

  /// Moment de la journée d'une heure de début : matin 5 h - 12 h,
  /// après-midi 12 h - 18 h, soirée 18 h - 22 h, nuit 22 h - 5 h.
  static DayPart dayPart(int hour) {
    if (hour >= 5 && hour < 12) return DayPart.morning;
    if (hour >= 12 && hour < 18) return DayPart.afternoon;
    if (hour >= 18 && hour < 22) return DayPart.evening;
    return DayPart.night;
  }

  static HoursInsight _hours(List<CountryGame> games, int? Function(CountryGame) hourOf) {
    final groups = {for (final part in DayPart.values) part: <CountryGame>[]};
    for (final game in games) {
      final hour = hourOf(game);
      if (hour != null) groups[dayPart(hour)]!.add(game);
    }
    final byPart = {for (final entry in groups.entries) entry.key: GameResults.of(entry.value)};
    final weakest = _weakest(byPart, minHoursGames);
    return HoursInsight(
      byPart: byPart,
      weakest: weakest,
      notable: weakest != null && _isNotable(byPart[weakest]!, GameResults.of(games)),
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
}
