import '../models/country_game.dart';
import '../services/time_management_service.dart';
import 'time_class_viewmodel.dart';

class TimeManagementViewModel extends TimeClassFilteredViewModel {
  final List<CountryGame> _games;

  TimeManagementViewModel(List<CountryGame> games, [super.filter]) : _games = games;

  TimeManagementStats get stats => TimeManagementService.aggregate(_games, timeClass: timeClass);
}
