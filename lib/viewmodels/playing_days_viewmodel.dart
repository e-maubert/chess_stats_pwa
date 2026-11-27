import '../services/playing_days_service.dart';
import 'filtered_stats_viewmodel.dart';
import 'playing_hours_viewmodel.dart';

/// Case de la grille des jours : colonne [week] (la colonne finale,
/// moyennes, vaut le nombre de semaines) et ligne [row].
typedef DayCell = ({int week, int row});

class PlayingDaysViewModel extends FilteredStatsViewModel {
  /// Premier et dernier jour de la période (dates locales, inclus).
  final DateTime from;
  final DateTime to;

  /// Premier jour de la semaine ([DateTime.monday]… [DateTime.sunday]).
  final int firstWeekday;

  PlayingHoursMode _mode = PlayingHoursMode.activity;
  DayCell? _selected;
  PlayingDaysGrid? _grid;

  PlayingDaysViewModel(
    super.games, {
    required this.from,
    required this.to,
    required this.firstWeekday,
    super.timeClassFilter,
    super.colorFilter,
    super.openingFilter,
  });

  PlayingHoursMode get mode => _mode;

  /// Case dont la bulle de détail est affichée, null si aucune.
  DayCell? get selected => _selected;

  PlayingDaysGrid get grid => _grid ??= PlayingDaysService.build(
        filteredGames,
        from: from,
        to: to,
        firstWeekday: firstWeekday,
        timeClass: timeClass,
      );

  /// Vrai si [cell] est dans la colonne finale (moyenne de la ligne).
  bool isTotalColumn(DayCell cell) => cell.week == grid.weekStarts.length;

  @override
  void onFiltersChanged() {
    _grid = null;
    _selected = null;
  }

  void setMode(PlayingHoursMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  /// Lien « meilleur / moins bon jour » : montre la ligne [row] dans la
  /// colonne finale, en mode Performance, bulle ouverte.
  void showWeekday(int row) {
    _mode = PlayingHoursMode.performance;
    _selected = (week: grid.weekStarts.length, row: row);
    notifyListeners();
  }

  /// Clic sur la grille : ouvre la bulle de [cell], ou la ferme si c'est
  /// déjà celle-ci ou si le clic est hors des cases ([cell] null).
  void tap(DayCell? cell) {
    _selected = cell == _selected ? null : cell;
    notifyListeners();
  }
}
