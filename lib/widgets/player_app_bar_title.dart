import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';

import 'app_logo.dart';

/// Titre de la barre du haut des pages d'un joueur (bilan, stats) : logo,
/// nom de l'app en petit, puis le pseudo dessous, qui a toute la largeur
/// pour lui et ne se fait pas rogner sur mobile.
class PlayerAppBarTitle extends StatelessWidget {
  final String username;

  const PlayerAppBarTitle({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Semantics(
      label: l10n.statsTitle(username),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogo(size: 32, decorative: true),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  username,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
