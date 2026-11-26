import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';

import '../models/country_game.dart';
import '../models/game_phase_summary.dart';
import '../services/game_repository.dart';
import '../services/opening_move_names.dart';
import '../services/opening_name_service.dart';
import '../services/player_link_service.dart';
import '../services/scouting_service.dart';
import '../viewmodels/scouting_viewmodel.dart';
import '../widgets/form_piece.dart';
import '../widgets/player_app_bar_title.dart';
import '../widgets/result_badges.dart';
import '../widgets/result_bar.dart';
import '../widgets/option_toggle.dart';
import '../widgets/share_player.dart';
import '../widgets/stats_filter_selectors.dart';
import '../widgets/story_slides.dart';
import '../widgets/theme_toggle_button.dart';
import 'player_route.dart';
import 'stats_screen.dart';

/// « Comment battre ce joueur », en diapositives : cadence analysée (et la
/// moins réussie), forme du moment, ouvertures avec les blancs puis les
/// noirs (conseils sur les seuls coups que choisit l'adversaire), et un
/// plan de jeu. Chaque diapositive donne un conseil, pas seulement un
/// chiffre.
class ScoutingScreen extends StatelessWidget {
  final String username;
  final List<CountryGame> games;

  /// [games] viennent d'être téléchargées : pas de mise à jour.
  final bool upToDate;

  /// Ouvert depuis la page des stats : en sortir y ramène.
  final bool fromStats;

  /// Cadence choisie ; null = la plus jouée.
  final String? timeClass;

  const ScoutingScreen({
    super.key,
    required this.username,
    required this.games,
    this.upToDate = false,
    this.fromStats = false,
    this.timeClass,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScoutingViewModel(
        context.read<GameRepository>(),
        username,
        games: games,
        upToDate: upToDate,
        timeClass: timeClass,
      ),
      child: Consumer<ScoutingViewModel>(
        builder: (context, viewModel, _) {
          final l10n = AppLocalizations.of(context)!;
          void openStats() => _openStats(context, viewModel);
          return Scaffold(
            appBar: AppBar(
              title: PlayerAppBarTitle(username: username),
              actions: [
                TextButton(onPressed: openStats, child: Text(l10n.recapSkip)),
                const ThemeToggleButton(),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: StorySlides(
                  // Nouvelle série de diapositives quand le rapport change
                  // (parties mises à jour).
                  key: ObjectKey(viewModel.report),
                  slides: _slides(context, l10n, viewModel, openStats),
                  onFinished: openStats,
                  onPageChanged: viewModel.slideReached,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Page des stats du joueur : simple retour si l'on en vient, sinon elle
  /// remplace cette page (le retour ramène à la recherche).
  void _openStats(BuildContext context, ScoutingViewModel viewModel) {
    if (fromStats) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: PlayerLinkService.path(username)),
        builder: (_) => StatsScreen(username: username, initialGames: viewModel.games, upToDate: viewModel.upToDate),
      ),
    );
  }

  /// Même page dans la cadence [value], à sa propre adresse.
  void _openTimeClass(BuildContext context, ScoutingViewModel viewModel, String value) {
    Navigator.pushReplacement(
      context,
      scoutRoute(
        username,
        viewModel.games,
        upToDate: viewModel.upToDate,
        fromStats: fromStats,
        timeClass: value,
      ),
    );
  }

  List<StorySlide> _slides(
      BuildContext context, AppLocalizations l10n, ScoutingViewModel viewModel, VoidCallback openStats) {
    final report = viewModel.report;
    final percentFormat = NumberFormat.percentPattern(Localizations.localeOf(context).toString());
    String percent(double value) => percentFormat.format(value);
    String opening(String family) =>
        l10n.openingFamilyName(OpeningNameService.key(family), OpeningNameService.fallback(family));
    String timeClass(String value) => FilterLabels.timeClass(value, l10n);

    // Lignes « nom, barre des résultats, parties et taux de victoire ».
    Widget resultsList(List<(String, GameResults)> rows) => _ResultsList(
          rows: rows,
          results: (results) => l10n.scoutOpeningResults(results.games, percent(results.winRate)),
        );

    final seeStats = FilledButton.tonal(onPressed: openStats, child: Text(l10n.scoutSeeStats));

    // Choix de la cadence analysée (au moins deux cadences assez jouées).
    final choosable = viewModel.choosableTimeClasses;
    final analyzedTimeClass = report?.timeClass ?? this.timeClass;
    final Widget? timeClassChoice = choosable.length < 2
        ? null
        // Fond du thème sous le sélecteur : lisible sur la couleur vive
        // de la diapo, en clair comme en sombre (comme les boutons).
        : Material(
            color: Theme.of(context).colorScheme.surface,
            shape: const StadiumBorder(),
            child: OptionToggle<String>(
              options: choosable,
              selected: choosable.contains(analyzedTimeClass) ? analyzedTimeClass! : choosable.first,
              labelOf: timeClass,
              onChanged: (value) {
                if (value != analyzedTimeClass) _openTimeClass(context, viewModel, value);
              },
            ),
          );

    if (report == null) {
      return [
        StorySlide(
          label: l10n.scoutIntroLabel,
          value: l10n.scoutEmpty,
          action: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (timeClassChoice != null) ...[timeClassChoice, const SizedBox(height: 12)],
              seeStats,
            ],
          ),
        ),
      ];
    }

    final focus = timeClass(report.timeClass);
    final form = report.form;
    final cadence = report.cadence;
    final weakest = timeClass(cadence.weakest);

    String formTip() => switch (form.level) {
          FormLevel.collapse => l10n.scoutFormTipCollapse,
          FormLevel.slump => l10n.scoutFormTipSlump,
          FormLevel.steady => l10n.scoutFormTipSteady,
          FormLevel.good => l10n.scoutFormTipGood,
          FormLevel.legendary => l10n.scoutFormTipLegendary,
        };

    // Notation des coups : « 1.d4 » pour les blancs, « 1…e6 » pour les noirs,
    // suivie du nom de l'ouverture quand il est connu (« 1…e6 (défense
    // Horwitz) »).
    String named(String move, String? family) => family == null ? move : l10n.scoutMoveWithName(move, opening(family));
    String whiteMove(String move) => named('1.$move', OpeningMoveNames.firstMove(move));
    String blackMove(String first, String move) => named('1…$move', OpeningMoveNames.reply(first, move));

    // Quand il a les blancs : réponse à son premier coup habituel.
    String? whiteTip() {
      final repertoire = report.white;
      final main = repertoire.mainMove;
      if (main == null) return null;
      final move = '1.${main.move}';
      final target = repertoire.target;
      final avoid = repertoire.avoid;
      if (target != null) {
        return l10n.scoutReplyTarget(
            move, blackMove(main.move, target.move), percent(target.results.winRate), target.games);
      }
      if (avoid != null) {
        return l10n.scoutReplyAvoid(
            move, blackMove(main.move, avoid.move), percent(avoid.results.winRate), avoid.games);
      }
      return l10n.scoutReplyNone(move);
    }

    // Quand il a les noirs : premier coup des blancs.
    String? blackTip() {
      final repertoire = report.black;
      final target = repertoire.target;
      final avoid = repertoire.avoid;
      if (target != null)
        return l10n.scoutFirstMoveTarget(whiteMove(target.move), percent(target.results.winRate), target.games);
      if (avoid != null)
        return l10n.scoutFirstMoveAvoid(whiteMove(avoid.move), percent(avoid.results.winRate), avoid.games);
      return repertoire.games > 0 ? l10n.scoutFirstMoveNone : null;
    }

    StorySlide? repertoireSlide(ColorRepertoire repertoire, String label, String? tip) => repertoire.top.isEmpty
        ? null
        : StorySlide(
            label: label,
            value: opening(repertoire.top.first.family),
            caption: l10n.scoutOpeningFavorite,
            highlight: resultsList([
              for (final (index, record) in repertoire.top.indexed)
                ('${index + 1}. ${opening(record.family)}', record.results),
            ]),
            details: [
              l10n.scoutOpeningGames(repertoire.games),
              if (repertoire.mainMove != null)
                l10n.scoutMainMove(whiteMove(repertoire.mainMove!.move), percent(repertoire.mainMoveShare)),
            ],
            tip: tip,
          );

    // Diapos qui attendent le calcul des phases.
    final phasesReady = viewModel.phasesReady;
    final phase = viewModel.phaseInsight;
    final time = viewModel.timeInsight;
    StorySlide analyzing(String label) => StorySlide(
          label: label,
          value: l10n.scoutAnalyzing,
          smallValue: true,
          highlight: _AnalysisProgress(progress: viewModel.phaseProgress),
        );
    StorySlide notEnough(String label) => StorySlide(label: label, value: l10n.scoutNotEnough, smallValue: true);

    String phaseName(GamePhase value) => switch (value) {
          GamePhase.opening => l10n.phaseOpening,
          GamePhase.middlegame => l10n.phaseMiddlegame,
          GamePhase.endgame => l10n.phaseEndgame,
        };
    String phaseTip(PhaseInsight insight) => !insight.notable
        ? l10n.scoutPhaseTipNone
        : switch (insight.weakest!) {
            GamePhase.opening => l10n.scoutPhaseTipOpening,
            GamePhase.middlegame => l10n.scoutPhaseTipMiddlegame,
            GamePhase.endgame => l10n.scoutPhaseTipEndgame,
          };
    String timeTip(TimeInsight insight) => switch (insight.profile) {
          TimeProfile.slow => l10n.scoutTimeTipSlow,
          TimeProfile.balanced => l10n.scoutTimeTipBalanced,
          TimeProfile.fast => l10n.scoutTimeTipFast,
        };
    String? tiltTip(TiltInsight insight) => switch (insight.kind) {
          TiltKind.tilts => l10n.scoutTiltTipTilts,
          TiltKind.resilient => l10n.scoutTiltTipResilient,
          TiltKind.steady => l10n.scoutTiltTipSteady,
          TiltKind.unknown => null,
        };
    String dayPartRow(DayPart part) => switch (part) {
          DayPart.morning => l10n.scoutDayPartMorningRow,
          DayPart.afternoon => l10n.scoutDayPartAfternoonRow,
          DayPart.evening => l10n.scoutDayPartEveningRow,
          DayPart.night => l10n.scoutDayPartNightRow,
        };
    String hoursTip(HoursInsight insight) {
      if (!insight.notable) return l10n.scoutHoursTipNone;
      final rate = percent(insight.byPart[insight.weakest!]!.winRate);
      return switch (insight.weakest!) {
        DayPart.morning => l10n.scoutHoursTipMorning(rate),
        DayPart.afternoon => l10n.scoutHoursTipAfternoon(rate),
        DayPart.evening => l10n.scoutHoursTipEvening(rate),
        DayPart.night => l10n.scoutHoursTipNight(rate),
      };
    }

    String gap(double value) => value > 0 ? '+${percent(value)}' : percent(value);

    // 5. Phase où il gagne le moins ; null sans conclusion (ou calcul en
    // cours).
    StorySlide? phaseSlide;
    if (phase != null && phase.weakest != null) {
      phaseSlide = StorySlide(
        label: l10n.scoutPhaseLabel,
        // Écart trop faible avec son habitude : pas de phase « fragile ».
        value: phase.notable ? phaseName(phase.weakest!) : l10n.scoutPhaseNone,
        highlight: resultsList([
          for (final value in GamePhase.values)
            if (phase.byPhase[value]!.games > 0) (phaseName(value), phase.byPhase[value]!),
        ]),
        details: [l10n.scoutPhaseExplain],
        tip: phaseTip(phase),
      );
    }

    // 6. Gestion du temps ; null sans conclusion (ou calcul en cours).
    StorySlide? timeSlide;
    if (time != null) {
      timeSlide = StorySlide(
        label: l10n.scoutTimeLabel,
        value: switch (time.profile) {
          TimeProfile.slow => l10n.scoutTimeSlow,
          TimeProfile.balanced => l10n.scoutTimeBalanced,
          TimeProfile.fast => l10n.scoutTimeFast,
        },
        details: [
          l10n.scoutTimeMiddlegame(gap(time.gapAtMiddlegame)),
          if (time.gapAtEndgame != null) l10n.scoutTimeEndgame(gap(time.gapAtEndgame!)),
          if (time.losses > 0) l10n.scoutTimeTimeouts(percent(time.timeoutShare)),
        ],
        tip: timeTip(time),
      );
    }

    // 7. Réaction après une défaite ; null sans conclusion.
    final tilt = report.tilt;
    final tiltSlide = tilt.kind == TiltKind.unknown
        ? null
        : StorySlide(
            label: l10n.scoutTiltLabel,
            value: switch (tilt.kind) {
              TiltKind.tilts => l10n.scoutTiltTilts,
              TiltKind.resilient => l10n.scoutTiltResilient,
              _ => l10n.scoutTiltSteady,
            },
            highlight: resultsList([
              (l10n.scoutTiltAfterRow, tilt.afterLoss),
              (l10n.scoutTiltUsualRow, tilt.overall),
            ]),
            details: [l10n.scoutTiltExplain],
            tip: tiltTip(tilt),
          );

    // 8. Selon l'heure (bonus) ; null sans conclusion.
    final hours = report.hours;
    final hoursSlide = hours.weakest == null
        ? null
        : StorySlide(
            label: l10n.scoutHoursLabel,
            value: !hours.notable
                ? l10n.scoutHoursNone
                : switch (hours.weakest!) {
                    DayPart.morning => l10n.scoutDayPartMorning,
                    DayPart.afternoon => l10n.scoutDayPartAfternoon,
                    DayPart.evening => l10n.scoutDayPartEvening,
                    DayPart.night => l10n.scoutDayPartNight,
                  },
            caption: hours.notable ? l10n.scoutHoursCaption : null,
            highlight: resultsList([
              for (final part in DayPart.values)
                if (hours.byPart[part]!.games > 0) (dayPartRow(part), hours.byPart[part]!),
            ]),
            details: [l10n.scoutHoursExplain],
            tip: hoursTip(hours),
          );

    final cadenceTip = l10n.scoutCadenceTipOther(weakest);
    final white = whiteTip();
    final black = blackTip();
    String planTip(ScoutingTip tip) => switch (tip) {
          ScoutingTip.cadence => cadenceTip,
          ScoutingTip.whiteTarget || ScoutingTip.whiteAvoid => l10n.scoutPlanAsBlack(white!),
          ScoutingTip.blackTarget || ScoutingTip.blackAvoid => l10n.scoutPlanAsWhite(black!),
          ScoutingTip.phase => phaseTip(phase!),
          ScoutingTip.time => timeTip(time!),
          ScoutingTip.tilt => tiltTip(report.tilt)!,
          ScoutingTip.hours => hoursTip(report.hours),
          ScoutingTip.form => formTip(),
        };

    final whiteSlide = repertoireSlide(report.white, l10n.scoutWhiteLabel, white);
    final blackSlide = repertoireSlide(report.black, l10n.scoutBlackLabel, black);

    // 5. à 8. Habitudes : une diapo sans conclusion n'est pas affichée.
    // Phase et temps ne sont connus qu'après le calcul des phases : pas
    // proposées s'il y a trop peu de parties pour conclure ; « analyse en
    // cours » pendant le calcul ; ensuite, sans conclusion, retirées sauf
    // si on les a déjà atteintes (la diapo affichée ne doit pas changer).
    final habits = <StorySlide>[];
    final firstHabit = 2 + (whiteSlide == null ? 0 : 1) + (blackSlide == null ? 0 : 1);
    void addAfterPhases(StorySlide? slide, String label, {required bool possible}) {
      if (!possible) return;
      if (!phasesReady) {
        habits.add(analyzing(label));
      } else if (slide != null) {
        habits.add(slide);
      } else if (firstHabit + habits.length <= viewModel.furthestSlide) {
        habits.add(notEnough(label));
      }
    }

    addAfterPhases(phaseSlide, l10n.scoutPhaseLabel, possible: report.phasesPossible);
    addAfterPhases(timeSlide, l10n.scoutTimeLabel, possible: report.timePossible);
    if (tiltSlide != null) habits.add(tiltSlide);
    if (hoursSlide != null) habits.add(hoursSlide);

    return [
      // 1. Présentation : cadence analysée (la plus jouée) et cadence la
      // moins réussie, pour comprendre tout de suite le choix.
      StorySlide(
        label: l10n.scoutIntroTitle(username),
        value: l10n.scoutIntroTimeClass(report.timeClass),
        smallValue: true,
        details: [
          report.isMain
              ? l10n.scoutIntroBase(report.games, focus, report.period.days)
              : l10n.scoutIntroBaseChosen(report.games, focus, report.period.days),
          if (switch (cadence.kind) {
            CadenceCase.single => l10n.scoutCadenceSingle,
            CadenceCase.focusOnly => null,
            CadenceCase.same => report.isMain
                ? l10n.scoutCadenceSame(percent(cadence.weakestResults.winRate))
                : l10n.scoutCadenceSameChosen(percent(cadence.weakestResults.winRate)),
            CadenceCase.other => cadence.byWinRate
                ? l10n.scoutCadenceOther(weakest, percent(cadence.weakestResults.winRate), cadence.weakestResults.games)
                : l10n.scoutCadenceOtherRating(weakest, cadence.weakestResults.games),
            CadenceCase.otherFewGames => l10n.scoutCadenceFewGames(weakest, cadence.weakestResults.games),
          }
              case final line?)
            line,
        ],
        tip: switch (cadence.kind) {
          CadenceCase.single || CadenceCase.focusOnly => null,
          CadenceCase.same => l10n.scoutCadenceTipSame(focus),
          CadenceCase.other => cadenceTip,
          CadenceCase.otherFewGames => l10n.scoutCadenceTipFewGames(weakest),
        },
        // Cadence analysée au choix ; raccourci vers sa cadence la plus
        // faible quand ce n'est pas celle analysée.
        action: _introAction(
          analyzeWeakest: cadence.weakest != report.timeClass && choosable.contains(cadence.weakest)
              ? FilledButton.tonal(
                  onPressed: () => _openTimeClass(context, viewModel, cadence.weakest),
                  child: Text(l10n.scoutAnalyzeTimeClass(cadence.weakest)),
                )
              : null,
          timeClassChoice: timeClassChoice,
        ),
      ),
      // 2. Forme du moment.
      StorySlide(
        illustration: FormPiece(level: form.level),
        label: l10n.scoutFormLabel,
        value: switch (form.level) {
          FormLevel.collapse => l10n.scoutFormCollapse,
          FormLevel.slump => l10n.scoutFormSlump,
          FormLevel.steady => l10n.scoutFormSteady,
          FormLevel.good => l10n.scoutFormGood,
          FormLevel.legendary => l10n.scoutFormLegendary,
        },
        highlight: ResultBadges(wins: form.recent.wins, draws: form.recent.draws, losses: form.recent.losses),
        details: [
          l10n.scoutFormScore(percent(form.recent.winRate), form.recent.games),
          if (form.ratingChange != null && form.currentRating != null)
            l10n.scoutFormRating(
                form.ratingChange! > 0 ? '+${form.ratingChange}' : '${form.ratingChange}', form.currentRating!, focus),
        ],
        tip: formTip(),
      ),
      // 3. et 4. Ouvertures : à quoi s'attendre, et le coup à jouer.
      if (whiteSlide != null) whiteSlide,
      if (blackSlide != null) blackSlide,
      // 5. à 8. Phase, temps, réaction après une défaite, heure.
      ...habits,
      // Plan de jeu.
      StorySlide(
        label: l10n.scoutPlanLabel,
        value: l10n.scoutPlanTitle,
        highlight: _TipList(tips: [
          for (final tip in ScoutingService.plan(report, phase: phase, time: time)) planTip(tip),
        ]),
        action: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            seeStats,
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => sharePlayer(context, username, page: PlayerPage.scout, timeClass: this.timeClass),
              icon: const Icon(Icons.share_outlined),
              label: Text(l10n.share),
            ),
          ],
        ),
      ),
    ];
  }
}

/// Actions de la diapo de présentation : bouton vers la cadence la plus
/// faible, puis choix de la cadence ; null s'il n'y a ni l'un ni l'autre.
Widget? _introAction({Widget? analyzeWeakest, Widget? timeClassChoice}) {
  if (analyzeWeakest == null && timeClassChoice == null) return null;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (analyzeWeakest != null) analyzeWeakest,
      if (analyzeWeakest != null && timeClassChoice != null) const SizedBox(height: 12),
      if (timeClassChoice != null) timeClassChoice,
    ],
  );
}

/// Lignes de résultats : nom, barre (victoires, nulles, défaites), puis
/// parties et taux de victoire.
class _ResultsList extends StatelessWidget {
  final List<(String, GameResults)> rows;
  final String Function(GameResults results) results;

  const _ResultsList({required this.rows, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (name, row) in rows)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                ResultBar(wins: row.wins, draws: row.draws, losses: row.losses, width: 180),
                const SizedBox(height: 2),
                Text(results(row), style: const TextStyle(fontSize: 13), textAlign: TextAlign.center),
              ],
            ),
          ),
      ],
    );
  }
}

/// Avancement du calcul des phases des parties.
class _AnalysisProgress extends StatelessWidget {
  final ValueListenable<double> progress;

  const _AnalysisProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color;
    return SizedBox(
      width: 180,
      child: ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          color: color,
          backgroundColor: color?.withValues(alpha: 0.25),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

/// Conseils du plan de jeu, numérotés.
class _TipList extends StatelessWidget {
  final List<String> tips;

  const _TipList({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, tip) in tips.indexed)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(width: 12),
                Expanded(child: Text(tip, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
      ],
    );
  }
}
