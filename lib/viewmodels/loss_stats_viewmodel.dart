import '../models/loss_stats.dart';
import '../services/loss_stats_service.dart';
import 'filtered_stats_viewmodel.dart';

class LossStatsViewModel extends FilteredStatsViewModel {

  LossStatsViewModel(super.games, {super.timeClassFilter, super.colorFilter, super.openingFilter});

  LossStats get stats => LossStatsService.aggregate(filteredGames, timeClass: timeClass);
}
