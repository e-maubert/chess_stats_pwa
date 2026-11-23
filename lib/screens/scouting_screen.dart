import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';

import '../models/country_game.dart';
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
import '../widgets/share_player.dart';
import '../widgets/stats_filter_selectors.dart';
import '../widgets/story_slides.dart';
import '../widgets/theme_toggle_button.dart';
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

  const ScoutingScreen({
    super.key,
    required this.username,
    required this.games,
    this.upToDate = false,
    this.fromStats = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ScoutingViewModel(context.read<GameRepository>(), username, games: games, upToDate: upToDate),
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
                  slides: _slides(context, l10n, viewModel.report, openStats),
                  onFinished: openStats,
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

  List<StorySlide> _slides(
      BuildContext context, AppLocalizations l10n, ScoutingReport? report, VoidCallback openStats) {
    final percentFormat = NumberFormat.percentPattern(Localizations.localeOf(context).toString());
    String percent(double value) => percentFormat.format(value);
    String opening(String family) =>
        l10n.openingFamilyName(OpeningNameService.key(family), OpeningNameService.fallback(family));
    String timeClass(String value) => FilterLabels.timeClass(value, l10n);

    final seeStats = FilledButton.tonal(onPressed: openStats, child: Text(l10n.scoutSeeStats));
    if (report == null) {
      return [StorySlide(label: l10n.scoutIntroLabel, value: l10n.scoutEmpty, action: seeStats)];
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
    String named(String move, String? family) =>
        family == null ? move : l10n.scoutMoveWithName(move, opening(family));
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
        return l10n.scoutReplyTarget(move, blackMove(main.move, target.move), percent(target.results.winRate), target.games);
      }
      if (avoid != null) {
        return l10n.scoutReplyAvoid(move, blackMove(main.move, avoid.move), percent(avoid.results.winRate), avoid.games);
      }
      return l10n.scoutReplyNone(move);
    }

    // Quand il a les noirs : premier coup des blancs.
    String? blackTip() {
      final repertoire = report.black;
      final target = repertoire.target;
      final avoid = repertoire.avoid;
      if (target != null) return l10n.scoutFirstMoveTarget(whiteMove(target.move), percent(target.results.winRate), target.games);
      if (avoid != null) return l10n.scoutFirstMoveAvoid(whiteMove(avoid.move), percent(avoid.results.winRate), avoid.games);
      return repertoire.games > 0 ? l10n.scoutFirstMoveNone : null;
    }

    StorySlide? repertoireSlide(ColorRepertoire repertoire, String label, String? tip) => repertoire.top.isEmpty
        ? null
        : StorySlide(
            label: label,
            value: opening(repertoire.top.first.family),
            caption: l10n.scoutOpeningFavorite,
            highlight: _OpeningList(
              records: repertoire.top,
              name: (record) => opening(record.family),
              results: (record) => l10n.scoutOpeningResults(record.games, percent(record.results.winRate)),
            ),
            details: [
              l10n.scoutOpeningGames(repertoire.games),
              if (repertoire.mainMove != null)
                l10n.scoutMainMove(whiteMove(repertoire.mainMove!.move), percent(repertoire.mainMoveShare)),
            ],
            tip: tip,
          );

    final cadenceTip = l10n.scoutCadenceTipOther(weakest);
    final white = whiteTip();
    final black = blackTip();
    String planTip(ScoutingTip tip) => switch (tip) {
          ScoutingTip.cadence => cadenceTip,
          ScoutingTip.whiteTarget || ScoutingTip.whiteAvoid => l10n.scoutPlanAsBlack(white!),
          ScoutingTip.blackTarget || ScoutingTip.blackAvoid => l10n.scoutPlanAsWhite(black!),
          ScoutingTip.form => formTip(),
        };

    final whiteSlide = repertoireSlide(report.white, l10n.scoutWhiteLabel, white);
    final blackSlide = repertoireSlide(report.black, l10n.scoutBlackLabel, black);

    return [
      // 1. Présentation : cadence analysée (la plus jouée) et cadence la
      // moins réussie, pour comprendre tout de suite le choix.
      StorySlide(
        label: l10n.scoutIntroTitle(username),
        value: l10n.scoutIntroTimeClass(report.timeClass),
        smallValue: true,
        details: [
          l10n.scoutIntroBase(report.games, focus, report.period.days),
          if (switch (cadence.kind) {
            CadenceCase.single => l10n.scoutCadenceSingle,
            CadenceCase.focusOnly => null,
            CadenceCase.same => l10n.scoutCadenceSame(percent(cadence.weakestResults.winRate)),
            CadenceCase.other => cadence.byWinRate
                ? l10n.scoutCadenceOther(
                    weakest, percent(cadence.weakestResults.winRate), cadence.weakestResults.games)
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
      // Plan de jeu.
      StorySlide(
        label: l10n.scoutPlanLabel,
        value: l10n.scoutPlanTitle,
        highlight: _TipList(tips: [for (final tip in report.plan) planTip(tip)]),
        action: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            seeStats,
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => sharePlayer(context, username),
              icon: const Icon(Icons.share_outlined),
              label: Text(l10n.share),
            ),
          ],
        ),
      ),
    ];
  }
}

/// Les 3 ouvertures les plus jouées, numérotées : nom, puis barre des
/// résultats (victoires, nulles, défaites) avec parties et taux de victoire.
class _OpeningList extends StatelessWidget {
  final List<OpeningRecord> records;
  final String Function(OpeningRecord record) name;
  final String Function(OpeningRecord record) results;

  const _OpeningList({required this.records, required this.name, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, record) in records.indexed)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${index + 1}. ${name(record)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                ResultBar(
                  wins: record.results.wins,
                  draws: record.results.draws,
                  losses: record.results.losses,
                  width: 180,
                ),
                const SizedBox(height: 2),
                Text(results(record), style: const TextStyle(fontSize: 13), textAlign: TextAlign.center),
              ],
            ),
          ),
      ],
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
