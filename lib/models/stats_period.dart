import 'dart:math';

/// Périodes de statistiques proposées : les N derniers jours.
/// La plus longue détermine les mois téléchargés et conservés
/// (voir GameStoragePolicy).
enum StatsPeriod {
  oneMonth(30),
  threeMonths(90);

  const StatsPeriod(this.days);

  final int days;

  /// Durée de la plus longue période proposée, en jours.
  static int get longestDays => values.map((period) => period.days).reduce(max);
}
