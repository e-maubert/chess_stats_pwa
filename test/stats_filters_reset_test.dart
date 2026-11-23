import 'package:chess_stats_pwa/models/stats_period.dart';
import 'package:chess_stats_pwa/viewmodels/stats_filter_viewmodel.dart';
import 'package:chess_stats_pwa/viewmodels/stats_filters.dart';
import 'package:chess_stats_pwa/viewmodels/stats_period_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  StatsFilters create() => StatsFilters(
        period: StatsPeriodViewModel(),
        rated: RatedFilterViewModel(),
        timeClass: TimeClassViewModel(),
        color: PlayerColorViewModel(),
        opening: OpeningFilterViewModel(),
      );

  test('valeurs par défaut : aucun filtre modifié', () {
    expect(create().activeCount, 0);
  });

  test('chaque filtre modifié est compté', () {
    final filters = create();
    filters.period.select(StatsPeriod.threeMonths);
    filters.rated.select(false);
    expect(filters.activeCount, 2);
    filters.timeClass.select('blitz');
    filters.color.select(PlayerColorViewModel.black);
    filters.opening.select('SicilianDefense');
    expect(filters.activeCount, 5);
  });

  test('remise à zéro : tous les filtres reviennent à leur valeur par défaut', () {
    final filters = create();
    filters.period.select(StatsPeriod.threeMonths);
    filters.rated.select(false);
    filters.timeClass.select('rapid');
    filters.color.select(PlayerColorViewModel.white);
    filters.opening.select('FrenchDefense');

    filters.resetAll();

    expect(filters.activeCount, 0);
    expect(filters.period.period, StatsPeriodViewModel.defaultPeriod);
    expect(filters.rated.ratedOnly, isTrue);
    expect(filters.timeClass.timeClass, isNull);
    expect(filters.color.color, isNull);
    expect(filters.opening.opening, isNull);
  });
}
