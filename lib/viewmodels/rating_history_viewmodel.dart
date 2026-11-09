import 'package:flutter/foundation.dart';
import '../models/country_game.dart';
import '../services/rating_history_service.dart';

class RatingHistoryViewModel extends ChangeNotifier {
  /// Un classement par cadence : pas de choix « Toutes les parties ».
  static const List<String> timeClasses = ['bullet', 'blitz', 'rapid'];

  final List<CountryGame> _games;
  late String _timeClass;
  late List<RatingPoint> _points;

  /// Commence sur la cadence la plus jouée du mois.
  RatingHistoryViewModel(List<CountryGame> games) : _games = games {
    _timeClass = RatingHistoryService.mostPlayed(games, timeClasses);
    _points = RatingHistoryService.history(games, _timeClass);
  }

  String get timeClass => _timeClass;
  List<RatingPoint> get points => _points;

  /// Classement actuel (après la dernière partie), null sans partie.
  int? get currentRating => _points.isEmpty ? null : _points.last.rating;

  /// Variation depuis la première partie du mois.
  int get change => RatingHistoryService.change(_points);

  void setTimeClass(String? timeClass) {
    if (timeClass == null || timeClass == _timeClass) return;
    _timeClass = timeClass;
    _points = RatingHistoryService.history(_games, _timeClass);
    notifyListeners();
  }
}
