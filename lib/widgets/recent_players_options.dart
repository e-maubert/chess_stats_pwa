import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../services/game_store.dart';
import '../viewmodels/recent_players_viewmodel.dart';

/// Liste déroulante des joueurs déjà consultés, sous le champ de recherche
/// (vue des options de RawAutocomplete). Suit la liste du viewmodel, pour
/// qu'un joueur retiré avec la croix disparaisse tout de suite.
class RecentPlayersOptions extends StatelessWidget {
  final RecentPlayersViewModel viewModel;

  /// Champ de recherche : le texte saisi filtre la liste.
  final TextEditingController controller;
  final ValueChanged<StoredPlayer> onSelected;

  const RecentPlayersOptions({super.key, required this.viewModel, required this.controller, required this.onSelected});

  static const double _maxHeight = 280;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, controller]),
      builder: (context, child) {
        final players = viewModel.matching(controller.text);
        // Aucun joueur (ou plus aucun après une suppression) : pas de liste
        // vide.
        if (players.isEmpty) return const SizedBox.shrink();
        final highlighted = AutocompleteHighlightedOption.of(context);

        return Material(
          elevation: 4,
          // Se détache du fond de page dans les deux thèmes.
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: _maxHeight),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return ListTile(
                  dense: true,
                  selected: index == highlighted,
                  leading: const Icon(Icons.history),
                  title: Text(player.username),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.removeRecentPlayer(player.username),
                    onPressed: () => viewModel.remove(player),
                  ),
                  onTap: () => onSelected(player),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
