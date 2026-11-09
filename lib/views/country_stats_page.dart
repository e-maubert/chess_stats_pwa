import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../models/country_game.dart';
import '../widgets/country_stats_card.dart';

/// Page dédiée aux statistiques par pays. La page principale affiche
/// désormais directement CountryStatsCard ; cette page n'est plus atteinte
/// que depuis l'ancien écran stats_page.dart (code mort).
class CountryStatsPage extends StatelessWidget {
  final List<CountryGame> games;

  const CountryStatsPage({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.countryStats)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [CountryStatsCard(games: games)],
      ),
    );
  }
}
