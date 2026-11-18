import '../models/country_game.dart';
import '../services/game_phase_stats_service.dart';
import 'time_class_viewmodel.dart';

class GamePhaseStatsViewModel extends TimeClassFilteredViewModel {
  final List<CountryGame> _games;
  GamePhaseStats? _stats;

  GamePhaseStatsViewModel(List<CountryGame> games, [super.filter]) : _games = games;

  GamePhaseStats get stats => _stats ??= GamePhaseStatsService.aggregate(_games, timeClass: timeClass);

  @override
  void onTimeClassChanged() => _stats = null;
}
