import 'package:flutter/foundation.dart';

import '../services/game_repository.dart';
import '../services/game_store.dart';

/// Joueurs déjà consultés, proposés dans le champ de recherche.
class RecentPlayersViewModel extends ChangeNotifier {
  final GameRepository _repository;
  List<StoredPlayer> _players = const [];
  bool _disposed = false;

  RecentPlayersViewModel(this._repository);

  /// Du plus récemment consulté au plus ancien.
  List<StoredPlayer> get players => _players;

  /// Relit la liste depuis le stockage local.
  Future<void> load() async {
    _players = await _repository.viewedPlayers();
    if (!_disposed) notifyListeners();
  }

  /// Joueurs dont le pseudo contient [query] (sans tenir compte des
  /// majuscules), dans l'ordre de la liste.
  List<StoredPlayer> matching(String query) => filter(_players, query);

  /// Retire [player] de la liste et supprime ses parties stockées.
  Future<void> remove(StoredPlayer player) async {
    _players = [for (final other in _players) if (other.id != player.id) other];
    notifyListeners();
    await _repository.removePlayer(player.username);
  }

  static List<StoredPlayer> filter(List<StoredPlayer> players, String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return players;
    return [for (final player in players) if (player.id.contains(text)) player];
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
