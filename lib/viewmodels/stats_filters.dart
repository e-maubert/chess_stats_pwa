import 'stats_filter_viewmodel.dart';
import 'stats_period_viewmodel.dart';

/// Ensemble des filtres de la page des stats (période, parties classées,
/// cadence, couleur, ouverture), pour le panneau des filtres : nombre de
/// filtres modifiés et remise à zéro de tous.
class StatsFilters {
  final StatsPeriodViewModel period;
  final RatedFilterViewModel rated;
  final TimeClassViewModel timeClass;
  final PlayerColorViewModel color;
  final OpeningFilterViewModel opening;

  const StatsFilters({
    required this.period,
    required this.rated,
    required this.timeClass,
    required this.color,
    required this.opening,
  });

  /// Nombre de filtres différents de leur valeur par défaut.
  int get activeCount => [period.isActive, rated.isActive, timeClass.isActive, color.isActive, opening.isActive]
      .where((active) => active)
      .length;

  /// Remet tous les filtres à leur valeur par défaut.
  void resetAll() {
    period.reset();
    rated.reset();
    timeClass.reset();
    color.reset();
    opening.reset();
  }
}
