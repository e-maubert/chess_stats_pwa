import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';

import '../theme/app_theme.dart';

/// Victoires, nulles et défaites en trois pastilles (vert, gris, rouge),
/// lisibles sur n'importe quel fond : diapositives du bilan et de
/// « Comment battre ce joueur ».
class ResultBadges extends StatelessWidget {
  final int wins;
  final int draws;
  final int losses;

  const ResultBadges({super.key, required this.wins, required this.draws, required this.losses});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _Badge(l10n.recapWins(wins), AppTheme.winBadge),
        _Badge(l10n.recapDraws(draws), AppTheme.drawBadge),
        _Badge(l10n.recapLosses(losses), AppTheme.lossBadge),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
