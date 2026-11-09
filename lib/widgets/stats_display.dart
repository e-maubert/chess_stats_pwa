import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chess_stats.dart';
import '../l10n/translations.dart';
import 'color_stats_card.dart';
import 'country_stats_link.dart';
import 'loss_breakdown_card.dart';

class StatsDisplay extends StatelessWidget {
  final ChessStats stats;

  const StatsDisplay({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translations = Provider.of<Translations>(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        CountryStatsLink(stats: stats),
        const SizedBox(height: 24),
        ColorStatsCard(games: stats.countryGames),
        const SizedBox(height: 24),
        LossBreakdownCard(games: stats.countryGames),
        const SizedBox(height: 24),
        _buildSection(
          context,
          translations.playedOpenings,
          stats.openingFamilies.map((family) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                family.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatRow(context, translations.totalGames, family.totalGames.toString()),
              _buildStatRow(context, translations.wins, family.totalWins.toString()),
              _buildStatRow(context, translations.losses, family.totalLosses.toString()),
              _buildStatRow(context, translations.draws, family.totalDraws.toString()),
              _buildStatRow(context, translations.winRate, '${(family.winRate * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
            ],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 