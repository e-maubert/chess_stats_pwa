import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../models/game_phase_summary.dart';
import '../services/game_phase_stats_service.dart';
import '../services/time_management_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/game_phase_stats_viewmodel.dart';
import 'clock_pie.dart';
import 'result_summary.dart';
import 'time_class_filter.dart';

/// Phases de la partie (fin de l'ouverture, entrée en finale) : où se
/// terminent les parties, temps restant à ces deux moments, résultats en
/// finale selon le matériel et le type de finale. Filtrable par cadence.
class GamePhaseCard extends StatelessWidget {
  /// Parties avec leurs phases ; null pendant l'analyse : la carte affiche
  /// alors l'avancement ([progress], de 0 à 1).
  final List<CountryGame>? games;
  final ValueListenable<double>? progress;

  const GamePhaseCard({super.key, required this.games, this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final games = this.games;

    if (games == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(context, l10n.gamePhases),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: ValueListenableBuilder<double>(
                valueListenable: progress ?? const AlwaysStoppedAnimation(0),
                builder: (context, value, child) => Column(
                  children: [
                    CircularProgressIndicator(value: value > 0 ? value : null),
                    const SizedBox(height: 16),
                    Text(
                      l10n.gamePhasesLoading('${(value * 100).round()}%'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (_) => GamePhaseStatsViewModel(games),
      child: Consumer<GamePhaseStatsViewModel>(
        builder: (context, viewModel, child) {
          final stats = viewModel.stats;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context, l10n.gamePhases),
              TimeClassFilter(
                timeClasses: GamePhaseStatsViewModel.timeClasses,
                selected: viewModel.timeClass,
                onSelected: viewModel.setTimeClass,
              ),
              const SizedBox(height: 16),
              if (stats.games == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text(l10n.noPhaseData)),
                )
              else
                ..._content(context, stats, l10n),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _content(BuildContext context, GamePhaseStats stats, AppLocalizations l10n) {
    final endgameTypes = [
      for (final (type, counts) in stats.endgamesByType)
        if (counts.total > 0) (type, counts)
    ];
    return [
      _subtitle(context, l10n.phaseEndTitle),
      for (final phase in GamePhase.values)
        if (stats.byEndPhase[phase]!.total > 0) _phaseRow(context, phase, stats.byEndPhase[phase]!, l10n),
      if (stats.atMiddlegame != null || stats.atEndgame != null) ...[
        const SizedBox(height: 8),
        _subtitle(context, l10n.phaseClockTitle),
        Center(
          child: Wrap(
            spacing: 32,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              if (stats.atMiddlegame != null) _clockPie(context, l10n.phaseClockMiddlegame, stats.atMiddlegame!, l10n),
              if (stats.atEndgame != null) _clockPie(context, l10n.phaseClockEndgame, stats.atEndgame!, l10n),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _clockLegend(context, l10n),
        const SizedBox(height: 4),
        Text(l10n.phaseClockNote, style: Theme.of(context).textTheme.bodySmall),
      ],
      if (stats.endgames > 0) ...[
        const SizedBox(height: 16),
        _subtitle(context, l10n.endgameMaterialTitle),
        for (final balance in MaterialBalance.values)
          if (stats.endgamesByMaterial[balance]!.total > 0)
            _summary(_balanceLabel(balance, l10n), stats.endgamesByMaterial[balance]!),
        if (endgameTypes.isNotEmpty) ...[
          const SizedBox(height: 8),
          _subtitle(context, l10n.endgameTypeTitle),
          for (final (type, counts) in endgameTypes) _summary(_typeLabel(type, l10n), counts),
        ],
      ],
    ];
  }

  Widget _title(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      );

  Widget _subtitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      );

  Widget _summary(String label, ResultCounts counts) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ResultSummary(label: label, wins: counts.wins, draws: counts.draws, losses: counts.losses),
        ),
      );

  /// Résultats d'une phase, puis les défaites au temps s'il y en a.
  Widget _phaseRow(BuildContext context, GamePhase phase, ResultCounts counts, AppLocalizations l10n) {
    final label = switch (phase) {
      GamePhase.opening => l10n.phaseOpening,
      GamePhase.middlegame => l10n.phaseMiddlegame,
      GamePhase.endgame => l10n.phaseEndgame,
    };
    if (counts.timeoutLosses == 0) return _summary(label, counts);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summary(label, counts),
        Transform.translate(
          offset: const Offset(0, -8),
          child: Text(
            l10n.phaseTimeoutLosses(counts.timeoutLosses),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.negativeText(context)),
          ),
        ),
      ],
    );
  }

  // Notre temps restant : vert en avance, jaune si équilibré, rouge en
  // retard (écart de plus de 10 % du temps initial).
  static const Map<TimeGap, Color> _gapColors = {
    TimeGap.ahead: Colors.green,
    TimeGap.balanced: Colors.amber,
    TimeGap.behind: Colors.red,
  };

  /// Titre du moment, « Vous 62 % » au-dessus du camembert (notre moitié
  /// est en haut), « Adversaire 58 % » en dessous. Notre valeur est colorée
  /// comme le camembert, en version lisible sur le thème.
  Widget _clockPie(BuildContext context, String label, ClockShares shares, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final gap = shares.gap;
    final textColor = switch (gap) {
      TimeGap.ahead => AppTheme.positiveText(context),
      TimeGap.balanced => AppTheme.warningText(context),
      TimeGap.behind => AppTheme.negativeText(context),
    };
    String percent(double value) => '${(value * 100).round()}%';
    Widget value(String name, double share, Color? color) => ExcludeSemantics(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$name ', style: textTheme.bodyMedium),
                TextSpan(
                  text: percent(share),
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        );
    return SizedBox(
      width: 160,
      child: Column(
        children: [
          Text(label, style: textTheme.titleSmall, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          value(l10n.phaseClockPlayer, shares.player, textColor),
          const SizedBox(height: 4),
          ClockPie(
            player: shares.player,
            opponent: shares.opponent,
            playerColor: _gapColors[gap]!,
            semanticsLabel: '$label : ${l10n.phaseClockPlayer} ${percent(shares.player)}, '
                '${l10n.phaseClockOpponent} ${percent(shares.opponent)}',
          ),
          const SizedBox(height: 4),
          value(l10n.phaseClockOpponent, shares.opponent, null),
        ],
      ),
    );
  }

  /// Légende des camemberts : notre temps restant, avec le sens de chaque
  /// couleur, puis celui de l'adversaire (gris) et le temps écoulé
  /// (hachuré).
  Widget _clockLegend(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    Widget dot(Color color) => Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
    Widget item(List<Widget> swatches, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final swatch in swatches) Padding(padding: const EdgeInsets.only(right: 2), child: swatch),
            const SizedBox(width: 6),
            Text(text, style: textTheme.bodySmall),
          ],
        );
    final gapLabels = {
      TimeGap.ahead: l10n.phaseClockLegendAhead,
      TimeGap.balanced: l10n.phaseClockLegendBalanced,
      TimeGap.behind: l10n.phaseClockLegendBehind,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.phaseClockLegendPlayer, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        for (final MapEntry(key: gap, value: color) in _gapColors.entries)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: item([dot(color)], gapLabels[gap]!),
          ),
        const SizedBox(height: 4),
        item([dot(Theme.of(context).colorScheme.outline)], l10n.phaseClockLegendOpponent),
        const SizedBox(height: 6),
        item([const HatchedSwatch()], l10n.phaseClockLegendElapsed),
      ],
    );
  }

  String _balanceLabel(MaterialBalance balance, AppLocalizations l10n) => switch (balance) {
        MaterialBalance.ahead => l10n.endgameMaterialAhead,
        MaterialBalance.equal => l10n.endgameMaterialEqual,
        MaterialBalance.behind => l10n.endgameMaterialBehind,
      };

  String _typeLabel(String type, AppLocalizations l10n) => switch (type) {
        'pawn' => l10n.endgameTypePawn,
        'minor' => l10n.endgameTypeMinor,
        'rook' => l10n.endgameTypeRook,
        'rookMinor' => l10n.endgameTypeRookMinor,
        'queen' => l10n.endgameTypeQueen,
        _ => l10n.endgameTypeQueenOther,
      };
}
