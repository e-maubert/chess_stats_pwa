import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../services/pagination_service.dart';

/// Sous un tableau : « 11–20 sur 37 » et boutons page précédente / suivante.
/// Rien n'est affiché quand tout tient sur une page.
class PaginationControls extends StatelessWidget {
  /// Page affichée, à partir de 0.
  final int page;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    super.key,
    required this.page,
    required this.totalItems,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pageCount = PaginationService.pageCount(totalItems);
    if (pageCount <= 1) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final first = PaginationService.firstRank(page, totalItems);
    final last = (first + PaginationService.pageSize - 1).clamp(1, totalItems);

    // Aligné à gauche, sous le début du tableau : reste visible sur mobile
    // quand le tableau, plus large que l'écran, défile horizontalement.
    return Row(
      children: [
        const SizedBox(width: 8),
        Text(
          l10n.paginationRange(first, last, totalItems),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: l10n.previousPage,
          onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: l10n.nextPage,
          onPressed: page < pageCount - 1 ? () => onPageChanged(page + 1) : null,
        ),
      ],
    );
  }
}
