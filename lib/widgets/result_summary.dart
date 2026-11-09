import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'result_bar.dart';

/// Libellé + nombre de parties, puis barre victoires / nulles / défaites et
/// pourcentages, comme sur la page des statistiques par pays.
class ResultSummary extends StatelessWidget {
  final String label;
  final int wins;
  final int draws;
  final int losses;

  const ResultSummary({
    super.key,
    required this.label,
    required this.wins,
    required this.draws,
    required this.losses,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = wins + draws + losses;
    String percent(int count) => '${(count * 100 / total).toStringAsFixed(0)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(l10n.played(total), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        if (total > 0) ...[
          ResultBar(wins: wins, draws: draws, losses: losses, width: double.infinity),
          const SizedBox(height: 4),
          Text(
            l10n.countryResultRates(percent(wins), percent(draws), percent(losses)),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
