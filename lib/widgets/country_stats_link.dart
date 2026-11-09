import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../models/chess_stats.dart';
import '../views/country_stats_page.dart';

/// Lien depuis la page principale des stats vers la page dédiée
/// aux statistiques par pays des adversaires.
class CountryStatsLink extends StatelessWidget {
  final ChessStats stats;

  const CountryStatsLink({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.public),
        title: Text(l10n.countryStats),
        subtitle: Text(l10n.countryStatsLink),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CountryStatsPage(games: stats.countryGames),
          ),
        ),
      ),
    );
  }
}
