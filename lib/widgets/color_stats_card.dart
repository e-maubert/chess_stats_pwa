import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/color_stats.dart';
import '../models/country_game.dart';
import '../viewmodels/color_stats_viewmodel.dart';
import '../viewmodels/stats_filter_viewmodel.dart';
import 'result_summary.dart';

/// Page principale, « Statistiques de victoire » : victoires / nulles /
/// défaites en barres, pour l'ensemble des parties puis par couleur, ou pour
/// la seule couleur choisie dans l'en-tête.
class ColorStatsCard extends StatelessWidget {
  final List<CountryGame> games;

  const ColorStatsCard({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (context) => ColorStatsViewModel(
        games,
        timeClassFilter: context.read<TimeClassViewModel>(),
        colorFilter: context.read<PlayerColorViewModel>(),
      ),
      child: Consumer<ColorStatsViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.colorStats,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              for (final (index, row) in viewModel.rows.indexed) ...[
                if (index > 0) const SizedBox(height: 16),
                _summary(_label(row.color, l10n), row.stats),
              ],
            ],
          );
        },
      ),
    );
  }

  String _label(String? color, AppLocalizations l10n) => switch (color) {
        PlayerColorViewModel.white => l10n.withWhite,
        PlayerColorViewModel.black => l10n.withBlack,
        _ => l10n.allGames,
      };

  Widget _summary(String label, ColorStats colorStats) => ResultSummary(
        label: label,
        wins: colorStats.wins,
        draws: colorStats.draws,
        losses: colorStats.losses,
      );
}
