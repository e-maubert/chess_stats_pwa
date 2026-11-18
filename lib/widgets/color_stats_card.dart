import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/color_stats.dart';
import '../models/country_game.dart';
import '../viewmodels/color_stats_viewmodel.dart';
import '../viewmodels/time_class_viewmodel.dart';
import 'result_summary.dart';

/// Page principale : victoires / nulles / défaites avec les blancs et avec
/// les noirs, en barres comme sur la page des pays, filtrables par cadence.
class ColorStatsCard extends StatelessWidget {
  final List<CountryGame> games;

  const ColorStatsCard({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (context) => ColorStatsViewModel(games, context.read<TimeClassViewModel>()),
      child: Consumer<ColorStatsViewModel>(
        builder: (context, viewModel, child) {
          final stats = viewModel.stats;

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
              _summary(l10n.withWhite, stats.white),
              const SizedBox(height: 16),
              _summary(l10n.withBlack, stats.black),
            ],
          );
        },
      ),
    );
  }

  Widget _summary(String label, ColorStats colorStats) => ResultSummary(
        label: label,
        wins: colorStats.wins,
        draws: colorStats.draws,
        losses: colorStats.losses,
      );
}
