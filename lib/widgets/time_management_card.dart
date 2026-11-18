import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/time_management_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/time_management_viewmodel.dart';
import '../viewmodels/stats_filter_viewmodel.dart';

/// Page principale : sur les parties perdues, écart de pendule avec
/// l'adversaire en fin de partie, répartition des défaites selon cet écart
/// et abandons sous pression du temps. Filtrable par cadence.
class TimeManagementCard extends StatelessWidget {
  final List<CountryGame> games;

  const TimeManagementCard({super.key, required this.games});

  // Sur une défaite, aucun écart n'est « bon » : en retard = rouge,
  // en avance (on a peut-être joué trop vite) = ambre, équilibré = gris.
  static const Color _behindColor = Colors.red;
  static const Color _balancedColor = Colors.grey;
  static const Color _aheadColor = Colors.amber;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (context) => TimeManagementViewModel(
        games,
        timeClassFilter: context.read<TimeClassViewModel>(),
        colorFilter: context.read<PlayerColorViewModel>(),
      ),
      child: Consumer<TimeManagementViewModel>(
        builder: (context, viewModel, child) {
          final stats = viewModel.stats;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.timeManagement,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (stats.losses == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text(l10n.noLossData)),
                )
              else ...[
                _averageGap(context, stats, l10n),
                const SizedBox(height: 16),
                _gapBar(stats),
                const SizedBox(height: 8),
                _legendRow(context, l10n.timeBehind, stats.behind, stats.behindRate, _behindColor, l10n),
                _legendRow(context, l10n.timeBalanced, stats.balanced, stats.balancedRate, _balancedColor, l10n),
                _legendRow(context, l10n.timeAhead, stats.ahead, stats.aheadRate, _aheadColor, l10n),
                Text(l10n.timeThresholdNote, style: textTheme.bodySmall),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Écart moyen en gros, coloré avec le même seuil de 10 % que la barre :
  /// rouge en retard, ambre en avance, gris si équilibré (teintes adaptées
  /// au thème clair / sombre, voir AppTheme).
  Widget _averageGap(BuildContext context, TimeManagementStats stats, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final color = switch (stats.averageCategory) {
      TimeGap.behind => AppTheme.negativeText(context),
      TimeGap.ahead => AppTheme.warningText(context),
      TimeGap.balanced => Theme.of(context).colorScheme.onSurfaceVariant,
    };

    // Libellé puis valeur dans le même paragraphe : la valeur suit le texte
    // qui l'explique et passe à la ligne avec lui sur écran étroit.
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${l10n.timeGapAverage} ', style: textTheme.bodyLarge),
          TextSpan(
            text: TimeManagementService.formatGap(stats.averageGap),
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  /// Barre en trois couleurs : en retard / équilibré / en avance au temps.
  Widget _gapBar(TimeManagementStats stats) {
    Widget segment(int flex, Color color) =>
        flex > 0 ? Expanded(flex: flex, child: Container(color: color)) : const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: SizedBox(
        height: 12,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              segment(stats.behind, _behindColor),
              segment(stats.balanced, _balancedColor),
              segment(stats.ahead, _aheadColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendRow(
    BuildContext context,
    String label,
    int count,
    double rate,
    Color color,
    AppLocalizations l10n,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            Text(
              l10n.lossCauseValue(count, '${(rate * 100).toStringAsFixed(0)}%'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
