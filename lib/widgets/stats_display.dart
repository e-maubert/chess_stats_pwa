import 'package:flutter/material.dart';
import '../models/chess_stats.dart';
import '../services/layout_service.dart';
import 'app_footer.dart';
import 'color_stats_card.dart';
import 'country_stats_card.dart';
import 'loss_breakdown_card.dart';
import 'opening_stats_card.dart';
import 'rating_history_card.dart';
import 'time_management_card.dart';

/// Page principale des statistiques : les cartes sur une colonne, ou sur
/// deux sur grand écran (contenu centré, largeur limitée), puis le pied de
/// page.
class StatsDisplay extends StatefulWidget {
  final ChessStats stats;

  const StatsDisplay({Key? key, required this.stats}) : super(key: key);

  @override
  State<StatsDisplay> createState() => _StatsDisplayState();
}

class _StatsDisplayState extends State<StatsDisplay> {
  static const double _gap = 24;

  // Une clé par carte : en passant d'une à deux colonnes (fenêtre
  // redimensionnée), chaque carte est déplacée sans être recréée et garde
  // ses filtres et son tri.
  final List<GlobalKey> _cardKeys = List.generate(6, (_) => GlobalKey());

  @override
  Widget build(BuildContext context) {
    final games = widget.stats.countryGames;
    final cards = <Widget>[
      ColorStatsCard(key: _cardKeys[0], games: games),
      RatingHistoryCard(key: _cardKeys[1], games: games),
      LossBreakdownCard(key: _cardKeys[2], games: games),
      TimeManagementCard(key: _cardKeys[3], games: games),
      OpeningStatsCard(key: _cardKeys[4], games: games),
      CountryStatsCard(key: _cardKeys[5], games: games),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = LayoutService.columnCount(constraints.maxWidth);
        final wide = columns > 1;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 16),
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
                          if (index > 0) const SizedBox(width: _gap * 2),
                          Expanded(child: _column(column)),
                        ],
                      ],
                    )
                  else
                    _column(cards),
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

  Widget _column(List<Widget> cards) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, card) in cards.indexed) ...[
            if (index > 0) const SizedBox(height: _gap),
            card,
          ],
        ],
      );
}
