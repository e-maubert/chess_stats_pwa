import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';

import '../models/country_game.dart';
import '../services/game_repository.dart';
import '../services/opening_name_service.dart';
import '../services/recap_service.dart';
import '../viewmodels/recap_viewmodel.dart';
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

  const RecapScreen({super.key, required this.username, required this.games, this.upToDate = false});

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
              title: Text(username, maxLines: 1, overflow: TextOverflow.ellipsis),
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
  /// recherche.
  void _openStats(BuildContext context, RecapViewModel viewModel) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
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
      action: FilledButton.tonal(onPressed: openStats, child: Text(l10n.recapSeeStats)),
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
        details: [
          l10n.recapGamesCaption(recap.wins, recap.draws, recap.losses),
          l10n.recapScore(percent(recap.score)),
        ],
      ),
    ];

    // 2. Cadence et classement.
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

    // 3. Série de victoires.
    if (recap.longestWinStreak >= 2) {
      slides.add(StorySlide(
        label: l10n.recapStreakLabel,
        value: '${recap.longestWinStreak}',
        details: [recap.longestWinStreak >= 5 ? l10n.recapStreakCaptionHot : l10n.recapStreakCaption],
      ));
    }

    // 4. Ouvertures.
    if (recap.favoriteOpening != null) {
      slides.add(StorySlide(
        label: l10n.recapOpeningLabel,
        value: opening(recap.favoriteOpening!),
        details: [l10n.recapOpeningCaption(recap.favoriteOpeningGames, percent(recap.favoriteOpeningScore))],
      ));
    }
    if (recap.bestOpening != null) {
      slides.add(StorySlide(
        label: l10n.recapBestOpeningLabel,
        value: opening(recap.bestOpening!),
        details: [l10n.recapOpeningCaption(recap.bestOpeningGames, percent(recap.bestOpeningScore))],
      ));
    }

    // 5. Habitudes de jeu.
    if (recap.favoriteHour != null) {
      final hour = recap.favoriteHour!;
      slides.add(StorySlide(
        label: l10n.recapHourLabel,
        value: l10n.recapHourValue(hour),
        details: [
          if (hour >= 22 || hour < 5) l10n.recapNightOwl,
          if (hour >= 5 && hour < 9) l10n.recapEarlyBird,
          if (recap.busiestDay != null && recap.busiestDayGames >= 2)
            l10n.recapBusiestDay(DateFormat.MMMMEEEEd(locale).format(recap.busiestDay!), recap.busiestDayGames),
        ],
      ));
    }

    // 6. Adversaire le plus affronté.
    final opponent = recap.topOpponent;
    if (opponent != null) {
      slides.add(StorySlide(
        label: l10n.recapOpponentLabel,
        value: opponent.name,
        details: [l10n.recapOpponentCaption(opponent.games, opponent.wins, opponent.draws, opponent.losses)],
      ));
    }

    // 7. Point faible : l'ouverture assez jouée la moins réussie.
    if (recap.weakOpening != null) {
      slides.add(StorySlide(
        label: l10n.recapWeakOpeningLabel,
        value: opening(recap.weakOpening!),
        details: [l10n.recapOpeningCaption(recap.weakOpeningGames, percent(recap.weakOpeningScore))],
      ));
    }

    return slides..add(outro);
  }
}
