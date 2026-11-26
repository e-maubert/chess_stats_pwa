import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/opening_filter_service.dart';
import '../services/opening_name_service.dart';
import '../viewmodels/stats_filter_viewmodel.dart';
import '../viewmodels/stats_filters.dart';
import '../viewmodels/stats_period_viewmodel.dart';
import '../viewmodels/stats_tab_viewmodel.dart';
import 'period_selector.dart';
import 'stats_filter_selectors.dart';

/// Filtres de la page des stats (période, parties classées, cadence,
/// couleur, ouverture) lus dans les providers.
StatsFilters _filters(BuildContext context) => StatsFilters(
      period: context.read<StatsPeriodViewModel>(),
      rated: context.read<RatedFilterViewModel>(),
      timeClass: context.read<TimeClassViewModel>(),
      color: context.read<PlayerColorViewModel>(),
      opening: context.read<OpeningFilterViewModel>(),
    );

/// Onglet « Axes d'amélioration » affiché (false hors de la page d'un
/// joueur).
bool _improvementTab(BuildContext context) => context.watch<StatsTabViewModel?>()?.tab == StatsTab.improvement;

/// Panneau des filtres de la page des stats, un titre par filtre : fixe à
/// gauche sur grand écran, dans le tiroir glissant (menu) sur mobile et
/// tablette, suivi alors de la section « Plus » ([more]).
class StatsFilterPanel extends StatelessWidget {
  /// Parties de la période (pour le menu des ouvertures).
  final List<CountryGame> games;

  /// Date de référence (fin de la période).
  final DateTime now;

  /// Fermeture du tiroir (bouton « Voir les stats ») ; null pour le panneau
  /// fixe.
  final VoidCallback? onDone;

  /// Titre du panneau (« Filtres » par défaut).
  final String? title;

  /// Actions affichées sous les filtres, dans une section « Plus » séparée.
  final List<Widget> more;

  const StatsFilterPanel({
    super.key,
    required this.games,
    required this.now,
    this.onDone,
    this.title,
    this.more = const [],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Surveille tous les filtres : le bouton « Réinitialiser » s'active dès
    // que l'un d'eux est modifié.
    context.watch<StatsPeriodViewModel>();
    context.watch<RatedFilterViewModel>();
    context.watch<TimeClassViewModel>();
    context.watch<PlayerColorViewModel>();
    context.watch<OpeningFilterViewModel>();
    final filters = _filters(context);
    // Onglet « Axes d'amélioration » : filtres affichés mais pas encore
    // utilisés (analyse de la cadence la plus jouée sur 3 mois).
    final disabled = _improvementTab(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 16, onDone == null ? 20 : 8, 8),
          child: Row(
            children: [
              Icon(Icons.tune, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(title ?? l10n.filtersTitle, style: theme.textTheme.titleLarge)),
              if (onDone != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: onDone,
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              if (disabled)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    l10n.improvementFiltersNote,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              IgnorePointer(
                ignoring: disabled,
                child: Opacity(
                  opacity: disabled ? 0.38 : 1,
                  child: ExcludeSemantics(
                    excluding: disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FilterSection(label: l10n.periodLabel, child: PeriodSelector(now: now)),
                        _FilterSection(label: l10n.ratedFilterLabel, child: const RatedSelector()),
                        _FilterSection(label: l10n.timeClassLabel, child: const TimeClassSelector()),
                        _FilterSection(label: l10n.colorFilterLabel, child: const PlayerColorSelector()),
                        _FilterSection(label: l10n.openingFilterLabel, child: OpeningSelector(games: games)),
                      ],
                    ),
                  ),
                ),
              ),
              if (more.isNotEmpty) ...[
                const Divider(height: 8),
                const SizedBox(height: 12),
                ExcludeSemantics(
                  child: Text(
                    l10n.menuMoreSection,
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 4),
                ...more,
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: Text(l10n.filtersReset),
                onPressed: disabled || filters.activeCount == 0 ? null : filters.resetAll,
              ),
              const Spacer(),
              if (onDone != null) FilledButton(onPressed: onDone, child: Text(l10n.filtersDone)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _FilterSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Bouton de la barre du haut qui ouvre le menu (filtres et section
/// « Plus », mobile et tablette), avec le nombre de filtres modifiés en
/// pastille.
class StatsFilterButton extends StatelessWidget {
  const StatsFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    context.watch<StatsPeriodViewModel>();
    context.watch<RatedFilterViewModel>();
    context.watch<TimeClassViewModel>();
    context.watch<PlayerColorViewModel>();
    context.watch<OpeningFilterViewModel>();
    final count = _filters(context).activeCount;
    return IconButton(
      icon: Badge.count(count: count, isLabelVisible: count > 0, child: const Icon(Icons.menu)),
      tooltip: l10n.filtersOpen,
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}

/// Résumé des filtres sous la barre du haut (mobile et tablette) : la
/// période, puis chaque filtre modifié (ex. « 3 mois · Blitz · Noirs »).
/// Un appui ouvre le tiroir des filtres.
class StatsFilterSummary extends StatelessWidget {
  static const double height = 36;

  const StatsFilterSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final period = context.watch<StatsPeriodViewModel>().period;
    final ratedOnly = context.watch<RatedFilterViewModel>().ratedOnly;
    final timeClass = context.watch<TimeClassViewModel>().timeClass;
    final color = context.watch<PlayerColorViewModel>().color;
    final opening = context.watch<OpeningFilterViewModel>().opening;

    final parts = _improvementTab(context)
        ? [l10n.improvementFiltersSummary]
        : [
            PeriodSelector.labelOf(period, l10n),
            if (!ratedOnly) l10n.ratedFilterAll,
            if (timeClass != null) FilterLabels.timeClass(timeClass, l10n),
            if (color != null) FilterLabels.color(color, l10n),
            if (opening != null)
              opening == OpeningFilterService.others
                  ? l10n.openingFilterOthers
                  : l10n.openingFamilyName(OpeningNameService.key(opening), OpeningNameService.fallback(opening)),
          ];

    return SizedBox(
      height: height,
      child: InkWell(
        onTap: () => Scaffold.of(context).openDrawer(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.tune, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  parts.join(' · '),
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
