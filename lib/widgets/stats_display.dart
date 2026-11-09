import 'package:flutter/material.dart';
import '../models/chess_stats.dart';
import 'color_stats_card.dart';
import 'country_stats_link.dart';
import 'loss_breakdown_card.dart';
import 'opening_stats_card.dart';

class StatsDisplay extends StatelessWidget {
  final ChessStats stats;

  const StatsDisplay({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        CountryStatsLink(stats: stats),
        const SizedBox(height: 24),
        ColorStatsCard(games: stats.countryGames),
        const SizedBox(height: 24),
        LossBreakdownCard(games: stats.countryGames),
        const SizedBox(height: 24),
        OpeningStatsCard(games: stats.countryGames),
      ],
    );
  }
}
