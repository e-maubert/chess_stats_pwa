import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mémorise le thème choisi avec le bouton clair / sombre.
/// Sans choix enregistré : thème du système.
class ThemePreferenceService {
  static const String _key = 'theme_mode';

  Future<ThemeMode> load() async {
    final prefs = await SharedPreferences.getInstance();
    return switch (prefs.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> save(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.system) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
    }
  }
}
