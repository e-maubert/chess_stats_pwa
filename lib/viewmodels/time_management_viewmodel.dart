import '../services/time_management_service.dart';
import 'filtered_stats_viewmodel.dart';

class TimeManagementViewModel extends FilteredStatsViewModel {

  TimeManagementViewModel(super.games, {super.timeClassFilter, super.colorFilter, super.openingFilter});

  TimeManagementStats get stats => TimeManagementService.aggregate(filteredGames, timeClass: timeClass);
}
