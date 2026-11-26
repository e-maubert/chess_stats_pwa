import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/country_game.dart';
import '../services/game_repository.dart';
import '../services/layout_service.dart';
import '../services/opening_improvement_service.dart';
import '../services/opening_name_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/opening_improvement_viewmodel.dart';
import 'app_footer.dart';
import 'chess_board_view.dart';
import 'stats_display.dart';
import 'stats_filter_selectors.dart';

/// Onglet « Axes d'amélioration » : pour l'instant la carte « Améliorer son
/// ouverture ». Lance l'analyse des parties [games] (toutes celles chargées).
class ImprovementDisplay extends StatefulWidget {
  final List<CountryGame> games;

  const ImprovementDisplay({super.key, required this.games});

  @override
  State<ImprovementDisplay> createState() => _ImprovementDisplayState();
}

class _ImprovementDisplayState extends State<ImprovementDisplay> {
  /// Lance l'analyse des parties affichées, après la construction (elle
  /// prévient ses auditeurs) ; sans effet si elles sont déjà analysées.
  void _analyze() {
    final games = widget.games;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OpeningImprovementViewModel>().analyze(games, context.read<GameRepository>().now);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _analyze();
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = LayoutService.columnCount(constraints.maxWidth) > 1;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 12, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StatsFrame(padding: wide ? 20 : 14, child: const OpeningImprovementCard()),
                  const SizedBox(height: 16),
                  const AppFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Carte « Améliorer son ouverture » : pour chaque couleur, le coup que le
/// joueur rejoue dans son ouverture la plus jouée et qui lui coûte le plus,
/// sur un échiquier avec le meilleur coup.
class OpeningImprovementCard extends StatelessWidget {
  const OpeningImprovementCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final viewModel = context.watch<OpeningImprovementViewModel>();
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final timeClass = viewModel.timeClass;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.openingImprovementTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (timeClass != null)
          Text(
            l10n.openingImprovementScope(
                timeClass == 'daily' ? l10n.recapTimeClassDaily : FilterLabels.timeClass(timeClass, l10n)),
            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
          ),
        const SizedBox(height: 8),
        Text(l10n.openingImprovementIntro, style: muted),
        const SizedBox(height: 16),
        if (timeClass == null && !viewModel.loading)
          Text(l10n.openingImprovementNoGames, style: muted)
        else if (viewModel.loading)
          _Loading(progress: viewModel.progress)
        else if (viewModel.failed)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.openingImprovementError, style: muted),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => viewModel.retry(context.read<GameRepository>().now),
                child: Text(l10n.retry),
              ),
            ],
          )
        else ...[
          _ColorSection(white: true, result: viewModel.white),
          const Divider(height: 32),
          _ColorSection(white: false, result: viewModel.black),
          const SizedBox(height: 12),
          Text(l10n.openingImprovementSource,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  final ValueNotifier<double> progress;

  const _Loading({required this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (context, value, child) => Column(
            children: [
              CircularProgressIndicator(value: value > 0 ? value : null),
              const SizedBox(height: 16),
              Text(
                l10n.openingImprovementLoading('${(value * 100).round()}%'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Résultat pour une couleur.
class _ColorSection extends StatelessWidget {
  final bool white;
  final ColorImprovement? result;

  const _ColorSection({required this.white, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final result = this.result;
    final colorName = white ? l10n.colorFilterWhite : l10n.colorFilterBlack;

    if (result == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(colorName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(l10n.openingImprovementNoColorGames, style: muted),
        ],
      );
    }

    final opening = result.opening.opening;
    final openingName = l10n.openingFamilyName(OpeningNameService.key(opening), OpeningNameService.fallback(opening));
    final header = Text(
      l10n.openingImprovementColorHeader(colorName, openingName, result.opening.games.length),
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
    final mistake = result.mistake;

    if (mistake == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(result.notEnoughGames ? Icons.info_outline : Icons.verified_outlined,
                  color: result.notEnoughGames ? theme.colorScheme.onSurfaceVariant : AppTheme.positiveText(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.notEnoughGames ? l10n.openingImprovementNotEnough : l10n.openingImprovementSolid,
                  style: muted,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final board = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: _MistakeBoard(mistake: mistake, white: white),
            );
            final text = _MistakeText(mistake: mistake);
            if (constraints.maxWidth >= 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 320, child: board),
                  const SizedBox(width: 24),
                  Expanded(child: text),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Center(child: board), const SizedBox(height: 16), text],
            );
          },
        ),
      ],
    );
  }
}

/// Couleurs des flèches (fixes, sur l'échiquier).
const Color _yourMoveColor = Color(0xCCD32F2F);
const Color _bestMoveColor = Color(0xCC2E7D32);

class _MistakeBoard extends StatelessWidget {
  final OpeningMistake mistake;
  final bool white;

  const _MistakeBoard({required this.mistake, required this.white});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final letters = l10n.sanPieceLetters;
    final candidate = mistake.candidate;
    return ChessBoardView(
      fen: candidate.fen,
      flipped: !white,
      arrows: [
        BoardArrow(mistake.move.$1, mistake.move.$2, _yourMoveColor),
        BoardArrow(mistake.best.$1, mistake.best.$2, _bestMoveColor),
      ],
      semanticLabel: l10n.openingImprovementBoardLabel(
        OpeningImprovementService.localizeSan(candidate.san, letters),
        OpeningImprovementService.localizeSan(mistake.bestSan, letters),
      ),
    );
  }
}

class _MistakeText extends StatelessWidget {
  final OpeningMistake mistake;

  const _MistakeText({required this.mistake});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final letters = l10n.sanPieceLetters;
    final candidate = mistake.candidate;
    final yourMove = OpeningImprovementService.numbered(candidate.ply, candidate.san, letters: letters);
    final bestMove = OpeningImprovementService.numbered(candidate.ply, mistake.bestSan, letters: letters);
    final pawns = NumberFormat('+0.0;-0.0', Localizations.localeOf(context).toString());
    final body = theme.textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          candidate.line.isEmpty
              ? l10n.openingImprovementAtStart
              : l10n.openingImprovementAfter(OpeningImprovementService.formatLine(candidate.line, letters: letters)),
          style: body,
        ),
        const SizedBox(height: 8),
        _MoveLine(
          color: _yourMoveColor,
          text: l10n.openingImprovementYouPlay(yourMove),
          detail: l10n.openingImprovementRepeats(candidate.count, candidate.losses),
          textColor: AppTheme.negativeText(context),
        ),
        const SizedBox(height: 8),
        _MoveLine(
          color: _bestMoveColor,
          text: l10n.openingImprovementBetter(bestMove),
          textColor: AppTheme.positiveText(context),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.openingImprovementEval(pawns.format(mistake.evalBefore / 100), pawns.format(mistake.evalAfter / 100)),
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Ligne « coup » avec la pastille de la couleur de sa flèche.
class _MoveLine extends StatelessWidget {
  final Color color;
  final String text;
  final String? detail;
  final Color textColor;

  const _MoveLine({required this.color, required this.text, this.detail, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
              width: 14, height: 6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold)),
              if (detail != null)
                Text(detail!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
