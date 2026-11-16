import 'package:shared_preferences/shared_preferences.dart';

import '../models/stats_period.dart';

/// Mémorise la période choisie (« 1 mois » / « 3 mois »), comme le thème.
/// Sans choix enregistré : « 1 mois ».
class PeriodPreferenceService {
  static const String _key = 'stats_period';
  static const StatsPeriod defaultPeriod = StatsPeriod.oneMonth;

  Future<StatsPeriod> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key);
    return StatsPeriod.values.where((period) => period.name == name).firstOrNull ?? defaultPeriod;
  }

  Future<void> save(StatsPeriod period) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, period.name);
  }
}
