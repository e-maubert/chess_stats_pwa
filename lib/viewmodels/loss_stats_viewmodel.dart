import '../models/country_game.dart';
import '../models/loss_stats.dart';
import '../services/loss_stats_service.dart';
import 'time_class_viewmodel.dart';

class LossStatsViewModel extends TimeClassFilteredViewModel {
  final List<CountryGame> _games;

  LossStatsViewModel(List<CountryGame> games, [super.filter]) : _games = games;

  LossStats get stats => LossStatsService.aggregate(_games, timeClass: timeClass);
}
