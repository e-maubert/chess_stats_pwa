import 'package:flutter/material.dart';
import '../services/theme_preference_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final ThemePreferenceService _preferences;
  ThemeMode _themeMode;

  /// [initialMode] : choix enregistré, ou ThemeMode.system s'il n'y en a pas.
  ThemeViewModel(ThemeMode initialMode, {ThemePreferenceService? preferences})
      : _themeMode = initialMode,
        _preferences = preferences ?? ThemePreferenceService();

  ThemeMode get themeMode => _themeMode;

  /// Passe au thème opposé de celui affiché ([current]), qu'il vienne du
  /// système ou d'un choix précédent, et mémorise ce choix.
  Future<void> toggle(Brightness current) async {
    _themeMode = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _preferences.save(_themeMode);
  }
}
