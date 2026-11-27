import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/country_game.dart';
import '../services/layout_service.dart';
import 'app_footer.dart';
import 'color_stats_card.dart';
import 'country_stats_card.dart';
import 'game_phase_card.dart';
import 'opening_stats_card.dart';
import 'playing_days_card.dart';
import 'playing_hours_card.dart';
import 'rating_history_card.dart';
import 'time_management_card.dart';

/// Page principale des statistiques : les cartes sur une colonne, ou sur
/// deux sur grand écran (contenu centré, largeur limitée), puis le pied de
/// page.
class StatsDisplay extends StatefulWidget {
  final List<CountryGame> games;

  /// [games] avec le pays des adversaires ; null tant qu'il est cherché (la
  /// carte des pays attend, les autres s'affichent tout de suite).
  final List<CountryGame>? countryGames;

  /// [games] avec leurs phases ; null pendant l'analyse (avancement dans
  /// [phaseProgress]).
  final List<CountryGame>? phaseGames;
  final ValueListenable<double>? phaseProgress;

  const StatsDisplay({
    Key? key,
    required this.games,
    this.countryGames,
    this.phaseGames,
    this.phaseProgress,
  }) : super(key: key);

  @override
  State<StatsDisplay> createState() => _StatsDisplayState();
}

class _StatsDisplayState extends State<StatsDisplay> {
  /// Espace entre deux encadrés (et entre les colonnes sur grand écran).
  static const double _gap = 16;

  // Une clé par carte : en passant d'une à deux colonnes (fenêtre
  // redimensionnée), chaque carte est déplacée sans être recréée et garde
  // ses filtres et son tri.
  final List<GlobalKey> _cardKeys = List.generate(9, (_) => GlobalKey());

  @override
  Widget build(BuildContext context) {
    final games = widget.games;
    final cards = <Widget>[
      ColorStatsCard(key: _cardKeys[0], games: games),
      RatingHistoryCard(key: _cardKeys[1], games: games),
      TimeManagementCard(key: _cardKeys[3], games: games),
      GamePhaseCard(key: _cardKeys[7], games: widget.phaseGames, progress: widget.phaseProgress),
      OpeningStatsCard(key: _cardKeys[5], games: games),
      PlayingHoursCard(key: _cardKeys[4], games: games),
      PlayingDaysCard(key: _cardKeys[8], games: games),
      CountryStatsCard(key: _cardKeys[6], games: widget.countryGames),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = LayoutService.columnCount(constraints.maxWidth);
        final wide = columns > 1;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 12, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: LayoutService.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final (index, column) in LayoutService.splitIntoColumns(cards, columns).indexed) ...[
                          if (index > 0) const SizedBox(width: _gap),
                          Expanded(child: _column(column, wide: true)),
                        ],
                      ],
                    )
                  else
                    _column(cards, wide: false),
                  const SizedBox(height: _gap),
                  const AppFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _column(List<Widget> cards, {required bool wide}) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, card) in cards.indexed) ...[
            if (index > 0) const SizedBox(height: _gap),
            StatsFrame(padding: wide ? 20 : 14, child: card),
          ],
        ],
      );
}

/// Encadré d'une catégorie de stats : fond légèrement teinté, bord fin et
/// coins arrondis, pour bien voir où chaque catégorie commence et finit.
class StatsFrame extends StatelessWidget {
  final double padding;
  final Widget child;

  const StatsFrame({super.key, required this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}
