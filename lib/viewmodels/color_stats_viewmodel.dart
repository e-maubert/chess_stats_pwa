import '../models/color_stats.dart';
import '../models/country_game.dart';
import '../services/color_stats_service.dart';
import 'time_class_viewmodel.dart';

class ColorStatsViewModel extends TimeClassFilteredViewModel {
  final List<CountryGame> _games;

  ColorStatsViewModel(List<CountryGame> games, [super.filter]) : _games = games;

  ({ColorStats white, ColorStats black}) get stats =>
      ColorStatsService.aggregate(_games, timeClass: timeClass);
}
