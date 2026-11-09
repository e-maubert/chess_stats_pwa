import 'package:flutter/material.dart';
import '../models/chess_stats.dart';
import 'color_stats_card.dart';
import 'country_stats_card.dart';
import 'loss_breakdown_card.dart';
import 'opening_stats_card.dart';
import 'rating_history_card.dart';

class StatsDisplay extends StatelessWidget {
  final ChessStats stats;

  const StatsDisplay({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ColorStatsCard(games: stats.countryGames),
        const SizedBox(height: 24),
        RatingHistoryCard(games: stats.countryGames),
        const SizedBox(height: 24),
        LossBreakdownCard(games: stats.countryGames),
        const SizedBox(height: 24),
        OpeningStatsCard(games: stats.countryGames),
        const SizedBox(height: 24),
        CountryStatsCard(games: stats.countryGames),
      ],
    );
  }
}
