import '../services/game_phase_stats_service.dart';
import 'filtered_stats_viewmodel.dart';

class GamePhaseStatsViewModel extends FilteredStatsViewModel {
  GamePhaseStats? _stats;

  GamePhaseStatsViewModel(super.games, {super.timeClassFilter, super.colorFilter, super.openingFilter});

  GamePhaseStats get stats => _stats ??= GamePhaseStatsService.aggregate(filteredGames, timeClass: timeClass);

  @override
  void onFiltersChanged() => _stats = null;
}
