import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';

/// Logo de l'application (le roi blanc en e2 noté « !! »).
///
/// Image générée depuis `design/logo.svg` par `tool/generate_icons.ps1`.
/// [decorative] : à `true` quand le logo accompagne déjà le nom de l'appli
/// (barre du haut), pour que les lecteurs d'écran ne l'annoncent pas deux fois.
class AppLogo extends StatelessWidget {
  final double size;
  final bool decorative;

  const AppLogo({super.key, this.size = 120, this.decorative = false});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: decorative,
      semanticLabel: decorative ? null : AppLocalizations.of(context)!.appLogo,
    );
  }
}
