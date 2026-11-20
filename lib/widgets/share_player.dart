import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';

import '../services/player_link_service.dart';
import '../services/share_service.dart';

/// Partage le lien vers la page de [username] ; « Lien copié » quand il n'y
/// a pas de menu de partage.
Future<void> sharePlayer(BuildContext context, String username) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final url = PlayerLinkService.link(username);
  final outcome = await ShareService.share(text: l10n.shareText(username), url: url);
  switch (outcome) {
    case ShareOutcome.shared:
      break;
    case ShareOutcome.copied:
      messenger.showSnackBar(SnackBar(content: Text(l10n.shareCopied)));
    case ShareOutcome.failed:
      // Copie refusée : le lien est affiché, sélectionnable.
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.shareLinkTitle),
          content: SelectableText(url.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ],
        ),
      );
  }
}

/// Bouton de partage de la barre du haut.
class SharePlayerButton extends StatelessWidget {
  final String username;

  const SharePlayerButton({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share_outlined),
      tooltip: AppLocalizations.of(context)!.share,
      onPressed: () => sharePlayer(context, username),
    );
  }
}
