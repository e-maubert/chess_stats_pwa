import 'package:flutter/material.dart';
import '../models/chess_stats.dart';
import '../services/chess_api_service.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../widgets/app_logo.dart';
import '../widgets/stats_display.dart';
import '../widgets/theme_toggle_button.dart';

class StatsScreen extends StatefulWidget {
  final ChessStats stats;

  const StatsScreen({Key? key, required this.stats}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<ChessStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = Future.value(widget.stats);
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = ChessApiService().getPlayerStats(widget.stats.username);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 32, decorative: true),
            const SizedBox(width: 10),
            Text(l10n.appTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStats,
            tooltip: l10n.refresh,
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: FutureBuilder<ChessStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.errorFetchingStats,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshStats,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          return StatsDisplay(stats: snapshot.data!);
        },
      ),
    );
  }
} 