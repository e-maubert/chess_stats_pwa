import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';

import '../models/country_game.dart';
import '../services/game_repository.dart';
import '../services/opening_name_service.dart';
import '../services/recap_service.dart';
import '../viewmodels/recap_viewmodel.dart';
import '../services/player_link_service.dart';
import '../widgets/player_app_bar_title.dart';
import '../widgets/result_badges.dart';
import '../widgets/share_player.dart';
import '../widgets/stats_filter_selectors.dart';
import '../widgets/story_slides.dart';
import '../widgets/theme_toggle_button.dart';
import 'stats_screen.dart';

/// Bilan du dernier mois, en diapositives, entre la recherche et la page
/// des stats. Ordre « en entonnoir » : du plus général (parties jouées) au
/// plus fin (point faible).
class RecapScreen extends StatelessWidget {
  final String username;
  final List<CountryGame> games;

  /// [games] viennent d'être téléchargées : pas de mise à jour.
  final bool upToDate;

  /// Bilan revu depuis la page des stats : en sortir y ramène.
  final bool replay;

  const RecapScreen({
    super.key,
    required this.username,
    required this.games,
    this.upToDate = false,
    this.replay = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecapViewModel(
        context.read<GameRepository>(),
        username,
        games: games,
        upToDate: upToDate,
      ),
      child: Consumer<RecapViewModel>(
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
                  slides: _slides(context, l10n, viewModel.recap, openStats),
                  onFinished: openStats,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Remplace le bilan par la page des stats : le retour ramène à la
  /// recherche. Bilan revu depuis les stats : simple retour.
  void _openStats(BuildContext context, RecapViewModel viewModel) {
    if (replay) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: PlayerLinkService.path(username)),
        builder: (_) => StatsScreen(
          username: username,
          initialGames: viewModel.games,
          upToDate: viewModel.upToDate,
        ),
      ),
    );
  }

  List<StorySlide> _slides(BuildContext context, AppLocalizations l10n, PlayerRecap? recap, VoidCallback openStats) {
    final locale = Localizations.localeOf(context).toString();
    final percentFormat = NumberFormat.percentPattern(locale);
    String percent(double value) => percentFormat.format(value);
    String opening(String family) =>
        l10n.openingFamilyName(OpeningNameService.key(family), OpeningNameService.fallback(family));

    final outro = StorySlide(
      label: recap == null ? null : l10n.recapOutroLabel,
      value: recap == null ? l10n.recapEmptyTitle : l10n.recapOutroTitle,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.tonal(onPressed: openStats, child: Text(l10n.recapSeeStats)),
          if (recap != null) ...[
            const SizedBox(height: 12),
            // Moment où l'on a envie de partager : lien vers ce joueur.
            FilledButton.tonalIcon(
              onPressed: () => sharePlayer(context, username),
              icon: const Icon(Icons.share_outlined),
              label: Text(l10n.share),
            ),
          ],
        ],
      ),
    );
    if (recap == null) return [outro];

    final slides = <StorySlide>[
      StorySlide(
        label: l10n.recapIntroLabel,
        value: l10n.recapIntroTitle(username),
        details: [l10n.recapIntroHint],
      ),
      // 1. Vue d'ensemble.
      StorySlide(
        label: l10n.recapGamesLabel,
        value: '${recap.games}',
        details: [_volumePhrase(l10n, recap.games)],
      ),
      // 2. Résultats.
      StorySlide(
        label: l10n.recapScoreLabel,
        value: percent(recap.winRate),
        caption: l10n.recapScoreCaption,
        highlight: ResultBadges(wins: recap.wins, draws: recap.draws, losses: recap.losses),
        details: [_scorePhrase(l10n, recap.score)],
      ),
    ];

    // 3. Cadence et classement.
    if (recap.favoriteTimeClass != null) {
      final change = recap.ratingChange;
      slides.add(StorySlide(
        label: l10n.recapTimeClassLabel,
        value: recap.favoriteTimeClass == 'daily'
            ? l10n.recapTimeClassDaily
            : FilterLabels.timeClass(recap.favoriteTimeClass, l10n),
        details: [
          l10n.recapGamesCount(recap.favoriteTimeClassGames),
          if (change != null) l10n.recapRatingChange(change > 0 ? '+$change' : '$change'),
          if (recap.peakRating != null) l10n.recapPeakRating(recap.peakRating!),
        ],
      ));
    }

    // 4. Série de victoires.
    if (recap.longestWinStreak >= 2) {
      slides.add(StorySlide(
        label: l10n.recapStreakLabel,
        value: '${recap.longestWinStreak}',
        details: [recap.longestWinStreak >= 5 ? l10n.recapStreakCaptionHot : l10n.recapStreakCaption],
      ));
    }

    // 5. Ouvertures.
    if (recap.favoriteOpening != null) {
      slides.add(StorySlide(
        label: l10n.recapOpeningLabel,
        value: opening(recap.favoriteOpening!),
        details: [l10n.recapOpeningCaption(recap.favoriteOpeningGames, percent(recap.favoriteOpeningWinRate))],
      ));
    }
    if (recap.bestOpening != null) {
      slides.add(StorySlide(
        label: l10n.recapBestOpeningLabel,
        value: opening(recap.bestOpening!),
        details: [l10n.recapOpeningCaption(recap.bestOpeningGames, percent(recap.bestOpeningWinRate))],
      ));
    }

    // 6. Habitudes de jeu.
    if (recap.favoriteHour != null) {
      final hour = recap.favoriteHour!;
      slides.add(StorySlide(
        label: l10n.recapHourLabel,
        value: l10n.recapHourValue(hour),
        details: [
          _hourPhrase(l10n, hour),
          if (recap.busiestDay != null && recap.busiestDayGames >= 2)
            l10n.recapBusiestDay(DateFormat.MMMMEEEEd(locale).format(recap.busiestDay!), recap.busiestDayGames),
        ],
      ));
    }

    // 7. Adversaire le plus affronté.
    final opponent = recap.topOpponent;
    if (opponent != null) {
      slides.add(StorySlide(
        label: l10n.recapOpponentLabel,
        value: opponent.name,
        details: [l10n.recapOpponentCaption(opponent.games, opponent.wins, opponent.draws, opponent.losses)],
      ));
    }

    // 8. Point faible : l'ouverture assez jouée la moins réussie.
    if (recap.weakOpening != null) {
      slides.add(StorySlide(
        label: l10n.recapWeakOpeningLabel,
        value: opening(recap.weakOpening!),
        details: [l10n.recapOpeningCaption(recap.weakOpeningGames, percent(recap.weakOpeningWinRate))],
      ));
    }

    return slides..add(outro);
  }

  // Une phrase par ambiance (voir RecapService) : chaque ambiance pourra
  // aussi avoir sa propre illustration.

  static String _volumePhrase(AppLocalizations l10n, int games) {
    final days = RecapViewModel.period.days;
    return switch (RecapService.volumeMood(games)) {
      VolumeMood.casual => l10n.recapVolumeCasual,
      VolumeMood.regular => l10n.recapVolumeRegular(RecapService.perWeek(games, days)),
      VolumeMood.everyDay => l10n.recapVolumeEveryDay,
      VolumeMood.enthusiast => l10n.recapVolumeEnthusiast(RecapService.perDay(games, days)),
      VolumeMood.nonStop => l10n.recapVolumeNonStop,
    };
  }

  static String _scorePhrase(AppLocalizations l10n, double score) => switch (RecapService.scoreMood(score)) {
        ScoreMood.dominant => l10n.recapScoreDominant,
        ScoreMood.winning => l10n.recapScoreWinning,
        ScoreMood.balanced => l10n.recapScoreBalanced,
        ScoreMood.tough => l10n.recapScoreTough,
        ScoreMood.learning => l10n.recapScoreLearning,
      };

  static String _hourPhrase(AppLocalizations l10n, int hour) => switch (RecapService.hourMood(hour)) {
        HourMood.earlyBird => l10n.recapHourEarlyBird,
        HourMood.morning => l10n.recapHourMorning,
        HourMood.lunch => l10n.recapHourLunch,
        HourMood.afternoon => l10n.recapHourAfternoon,
        HourMood.evening => l10n.recapHourEvening,
        HourMood.nightOwl => l10n.recapHourNightOwl,
      };
}
