import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Une version publiée : numéro, date et nouveautés (une par ligne dans le
/// texte traduit).
class ChangelogEntry {
  final String version;
  final DateTime date;
  final String Function(AppLocalizations l10n) _text;

  const ChangelogEntry(this.version, this.date, this._text);

  List<String> changes(AppLocalizations l10n) =>
      _text(l10n).split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
}

/// Numéro de version et journal des nouveautés affichés dans le pied de
/// page.
///
/// Nouvelle version : incrémenter `version` dans `pubspec.yaml`, ajouter
/// une entrée EN TÊTE de [entries] avec la même version, et son texte
/// (clé `changelogV<version sans points>`) dans chaque fichier `.arb`.
class ChangelogService {
  static final List<ChangelogEntry> entries = [
    ChangelogEntry('1.9.0', DateTime(2026, 11, 23), (l10n) => l10n.changelogV190),
    ChangelogEntry('1.8.0', DateTime(2026, 11, 23), (l10n) => l10n.changelogV180),
    ChangelogEntry('1.7.0', DateTime(2026, 11, 19), (l10n) => l10n.changelogV170),
    ChangelogEntry('1.6.0', DateTime(2026, 11, 19), (l10n) => l10n.changelogV160),
    ChangelogEntry('1.5.0', DateTime(2026, 11, 17), (l10n) => l10n.changelogV150),
    ChangelogEntry('1.4.0', DateTime(2026, 11, 16), (l10n) => l10n.changelogV140),
    ChangelogEntry('1.3.0', DateTime(2026, 11, 13), (l10n) => l10n.changelogV130),
    ChangelogEntry('1.2.1', DateTime(2026, 11, 12), (l10n) => l10n.changelogV121),
    ChangelogEntry('1.2.0', DateTime(2026, 11, 12), (l10n) => l10n.changelogV120),
    ChangelogEntry('1.1.0', DateTime(2026, 11, 12), (l10n) => l10n.changelogV110),
    ChangelogEntry('1.0.0', DateTime(2026, 11, 11), (l10n) => l10n.changelogV100),
  ];

  /// Version actuelle de l'application (la plus récente du journal).
  static String get currentVersion => entries.first.version;

  static const String _lastSeenKey = 'changelog_last_seen_version';

  /// Dernière version dont l'utilisateur a consulté les nouveautés.
  Future<String?> loadLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSeenKey);
  }

  Future<void> saveLastSeen(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenKey, version);
  }
}
