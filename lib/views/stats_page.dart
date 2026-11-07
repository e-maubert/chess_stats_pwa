import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/chess_stats_viewmodel.dart';
import '../models/chess_stats.dart';
import '../widgets/country_stats_link.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Statistics'),
      ),
      body: Consumer<ChessStatsViewModel>(
        builder: (context, viewModel, child) {
          final stats = viewModel.stats;
          if (stats == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorStats(stats),
                const SizedBox(height: 24),
                _buildOpeningsStats(stats),
                const SizedBox(height: 24),
                _buildCountryStats(stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorStats(ChessStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Win Rate by Color',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: stats.whiteWinRate * 100,
                      title: 'White\n${(stats.whiteWinRate * 100).toStringAsFixed(1)}%',
                      color: Colors.white,
                    ),
                    PieChartSectionData(
                      value: stats.blackWinRate * 100,
                      title: 'Black\n${(stats.blackWinRate * 100).toStringAsFixed(1)}%',
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningsStats(ChessStats stats) {
    final topOpenings = stats.topOpenings.take(5).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Openings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topOpenings.length,
              itemBuilder: (context, index) {
                final opening = topOpenings[index];
                return ListTile(
                  title: Text(opening.name),
                  subtitle: Text('Played: ${opening.played}'),
                  trailing: Text(
                    '${(opening.winRate * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Les statistiques par pays sont sur une page dédiée (demande client).
  Widget _buildCountryStats(ChessStats stats) {
    return CountryStatsLink(stats: stats);
  }
} 