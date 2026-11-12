import 'package:flutter/foundation.dart';
import '../services/changelog_service.dart';

/// Pastille « nouveautés » du pied de page : affichée tant que les
/// nouveautés de la version actuelle n'ont pas été ouvertes.
class ChangelogViewModel extends ChangeNotifier {
  final ChangelogService _service;
  String? _lastSeenVersion;

  ChangelogViewModel(this._lastSeenVersion, {ChangelogService? service}) : _service = service ?? ChangelogService();

  bool get hasUnseenChanges => _lastSeenVersion != ChangelogService.currentVersion;

  /// À appeler à l'ouverture du journal des nouveautés.
  Future<void> markSeen() async {
    if (!hasUnseenChanges) return;
    _lastSeenVersion = ChangelogService.currentVersion;
    notifyListeners();
    await _service.saveLastSeen(ChangelogService.currentVersion);
  }
}
