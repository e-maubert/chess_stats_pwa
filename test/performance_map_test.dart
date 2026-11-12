import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/country_map_mode.dart';
import 'package:chess_stats_pwa/models/country_stats.dart';
import 'package:chess_stats_pwa/services/world_map_service.dart';
import 'package:chess_stats_pwa/theme/app_theme.dart';
import 'package:chess_stats_pwa/viewmodels/country_stats_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MapCountryResult r(int wins, int draws, int losses) =>
    MapCountryResult(games: wins + draws + losses, wins: wins, draws: draws, losses: losses);

CountryStats c(String name, int wins, int draws, int losses) => CountryStats(
      name: name,
      gamesPlayed: wins + draws + losses,
      gamesWon: wins,
      gamesDrawn: draws,
      gamesLost: losses,
    );

void main() {
  group('MapCountryResult.score', () {
    test('(victoires + ½ nulles) / parties', () {
      expect(r(3, 0, 1).score, 0.75);
      expect(r(1, 2, 1).score, 0.5);
      expect(r(0, 1, 0).score, 0.5);
      expect(r(0, 0, 0).score, 0);
    });
  });

  test('résultats additionnés par pays de la carte (Angleterre + Écosse → GB)', () {
    final results = WorldMapService.resultsByMapCountry([c('XE', 2, 0, 1), c('XS', 0, 1, 0), c('XX', 5, 0, 0)]);
    expect(results.keys, ['GB']);
    final gb = results['GB']!;
    expect([gb.games, gb.wins, gb.draws, gb.losses], [4, 2, 1, 1]);
  });

  test('minimum de parties : 2 jusqu\'à 40 parties dans le mois, 3 au-delà', () {
    expect(WorldMapService.minGamesForPerformance(5), 2);
    expect(WorldMapService.minGamesForPerformance(40), 2);
    expect(WorldMapService.minGamesForPerformance(41), 3);
    expect(WorldMapService.minGamesForPerformance(300), 3);
  });

  group('points forts et points faibles', () {
    test('au-dessus de 50 % / en dessous, 3 au plus, du plus marqué au moins marqué', () {
      final ranking = WorldMapService.strengthsAndWeaknesses({
        'UA': r(9, 0, 1), // 90 %
        'TR': r(4, 0, 1), // 80 %
        'IR': r(3, 0, 1), // 75 %
        'US': r(6, 0, 3), // 67 %
        'DE': r(1, 2, 1), // 50 % : ni l'un ni l'autre
        'IN': r(1, 0, 3), // 25 %
        'RU': r(0, 0, 2), // 0 %
        'FR': r(1, 0, 0), // une seule partie : pas jugé
      }, 2);
      expect(ranking.strengths, ['UA', 'TR', 'IR']);
      expect(ranking.weaknesses, ['RU', 'IN']);
    });

    test('un pays n\'est jamais à la fois point fort et point faible, même avec peu de pays', () {
      final ranking = WorldMapService.strengthsAndWeaknesses({'UA': r(2, 0, 1), 'TR': r(1, 0, 2)}, 2);
      expect(ranking.strengths, ['UA']);
      expect(ranking.weaknesses, ['TR']);
    });

    test('tout gagner : aucun point faible', () {
      final ranking = WorldMapService.strengthsAndWeaknesses({'UA': r(5, 0, 0), 'TR': r(3, 1, 0)}, 2);
      expect(ranking.strengths, ['UA', 'TR']);
      expect(ranking.weaknesses, isEmpty);
    });

    test('à performance égale, le pays le plus joué passe devant', () {
      final ranking = WorldMapService.strengthsAndWeaknesses({'AA': r(2, 0, 0), 'BB': r(6, 0, 0)}, 2);
      expect(ranking.strengths, ['BB', 'AA']);
    });
  });

  group('couleurs de la carte Performance', () {
    test('rouge à 0 %, jaune à 50 %, vert à 100 %', () {
      final low = AppTheme.performanceColor(0);
      final even = AppTheme.performanceColor(0.5);
      final high = AppTheme.performanceColor(1);
      expect(low.r, greaterThan(low.g));
      expect(high.g, greaterThan(high.r));
      expect(even.r, greaterThan(0.9));
      expect(even.g, greaterThan(0.8));
    });

    test('plus on s\'éloigne de 50 %, plus c\'est foncé (lisible malgré le daltonisme)', () {
      double lum(double score) => AppTheme.performanceColor(score).computeLuminance();
      expect(lum(0.5), greaterThan(lum(0.25)));
      expect(lum(0.25), greaterThan(lum(0)));
      expect(lum(0.5), greaterThan(lum(0.75)));
      expect(lum(0.75), greaterThan(lum(1)));
    });
  });

  test('le choix de carte ne change ni le tableau ni sa page', () {
    final games = [
      for (var i = 0; i < 8; i++)
        CountryGame(
          country: 'A${String.fromCharCode(65 + i)}',
          opponent: 'x$i',
          timeClass: 'blitz',
          result: 'win',
          playerColor: 'white',
          opening: 'Italian-Game',
        ),
    ];
    final viewModel = CountryStatsViewModel(games)..setPage(1);
    var notified = 0;
    viewModel.addListener(() => notified++);

    expect(viewModel.mapMode, CountryMapMode.gamesPlayed);
    viewModel.setMapMode(CountryMapMode.performance);
    viewModel.setMapMode(CountryMapMode.performance);
    expect(viewModel.mapMode, CountryMapMode.performance);
    expect(notified, 1);
    expect(viewModel.page, 1);
  });

  testWidgets('gris des pays trop peu joués distinct des autres gris, en clair et en sombre', (tester) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      late BuildContext captured;
      await tester.pumpWidget(Theme(
          data: theme,
          child: Builder(builder: (ctx) {
            captured = ctx;
            return const SizedBox();
          })));
      expect(AppTheme.mapNotEnoughGames(captured), isNot(AppTheme.mapEmptyCountry(captured)));
      expect(AppTheme.mapNotEnoughGames(captured), isNot(AppTheme.mapBackground(captured)));
    }
  });
}
