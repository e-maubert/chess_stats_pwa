import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/opening_filter_service.dart';
import '../services/opening_name_service.dart';
import '../viewmodels/stats_filter_viewmodel.dart';
import 'option_toggle.dart';

/// Libellés des choix des filtres de l'en-tête.
class FilterLabels {
  /// Libellé d'une cadence (null = toutes).
  static String timeClass(String? timeClass, AppLocalizations l10n) => switch (timeClass) {
        'bullet' => l10n.timeClassBullet,
        'blitz' => l10n.timeClassBlitz,
        'rapid' => l10n.timeClassRapid,
        _ => l10n.timeClassAll,
      };

  /// Libellé d'une couleur (null = les deux).
  static String color(String? color, AppLocalizations l10n) => switch (color) {
        PlayerColorViewModel.white => l10n.colorFilterWhite,
        PlayerColorViewModel.black => l10n.colorFilterBlack,
        _ => l10n.colorFilterBoth,
      };
}

/// En-tête de la page des stats, sous la période : parties classées
/// seulement (par défaut) ou toutes les parties.
class RatedSelector extends StatelessWidget {
  const RatedSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<RatedFilterViewModel>();
    return SizedBox(
      height: filterRowHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Center(
          child: Semantics(
            label: l10n.ratedFilterLabel,
            container: true,
            child: OptionToggle<bool>(
              options: const [true, false],
              selected: viewModel.ratedOnly,
              labelOf: (ratedOnly) => ratedOnly ? l10n.ratedFilterRated : l10n.ratedFilterAll,
              onChanged: viewModel.select,
            ),
          ),
        ),
      ),
    );
  }
}

/// En-tête de la page des stats, sous les parties classées : choix de la cadence
/// (Toutes / Bullet / Blitz / Rapide), commun à toutes les cartes.
class TimeClassSelector extends StatelessWidget {
  const TimeClassSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _FilterRow(
      semanticLabel: l10n.timeClassLabel,
      viewModel: context.watch<TimeClassViewModel>(),
      labelOf: (timeClass) => FilterLabels.timeClass(timeClass, l10n),
    );
  }
}

/// En-tête de la page des stats, sous la cadence : couleur jouée
/// (Les deux / Blancs / Noirs), commune à toutes les cartes.
class PlayerColorSelector extends StatelessWidget {
  const PlayerColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _FilterRow(
      semanticLabel: l10n.colorFilterLabel,
      viewModel: context.watch<PlayerColorViewModel>(),
      labelOf: (color) => FilterLabels.color(color, l10n),
    );
  }
}

/// En-tête de la page des stats, sous la couleur : menu des ouvertures
/// jouées dans [games] (parties de la période) avec la cadence et la couleur
/// choisies, de la plus jouée à la moins jouée, avec leur nombre de
/// parties : « Toutes les ouvertures », les 5 premières, « Autres
/// ouvertures », puis les suivantes une par une.
///
/// Une ouverture choisie reste proposée (avec « (0) ») même si les autres
/// filtres ne lui laissent aucune partie : le choix ne change pas tout seul.
class OpeningSelector extends StatelessWidget {
  final List<CountryGame> games;

  const OpeningSelector({super.key, required this.games});

  static const String _divider = '#divider';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final viewModel = context.watch<OpeningFilterViewModel>();
    final options = OpeningFilterService.options(
      games,
      timeClass: context.watch<TimeClassViewModel>().timeClass,
      color: context.watch<PlayerColorViewModel>().color,
    );
    final selected = viewModel.opening;
    final (:top, :othersGames, :rest) = OpeningFilterService.menu(options, selected);

    String familyName(String family) =>
        l10n.openingFamilyName(OpeningNameService.key(family), OpeningNameService.fallback(family));
    DropdownMenuItem<String?> item(String? value, String label) =>
        DropdownMenuItem(value: value, child: Text(label, overflow: TextOverflow.ellipsis));

    final items = [
      item(null, l10n.openingFilterAll),
      for (final option in top) item(option.family, l10n.openingOptionCount(familyName(option.family), option.games)),
      if (othersGames != null)
        item(OpeningFilterService.others, l10n.openingOptionCount(l10n.openingFilterOthers, othersGames)),
      if (rest.isNotEmpty) ...[
        const DropdownMenuItem(value: _divider, enabled: false, child: Divider()),
        for (final option in rest)
          item(option.family, l10n.openingOptionCount(familyName(option.family), option.games)),
      ],
    ];

    return SizedBox(
      height: filterRowHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Center(
          child: Container(
            height: OptionToggle.height,
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: selected == null ? null : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(OptionToggle.height / 2),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Semantics(
              label: l10n.openingFilterLabel,
              container: true,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: selected,
                  items: items,
                  isDense: true,
                  isExpanded: true,
                  // Après un choix, le menu garde le focus : sans cela, un
                  // rectangle gris (plus petit que le champ arrondi) restait
                  // affiché, visible surtout sur « Toutes les ouvertures ».
                  focusColor: Colors.transparent,
                  menuMaxHeight: 420,
                  borderRadius: BorderRadius.circular(12),
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface),
                  onChanged: (value) {
                    if (value != _divider) viewModel.select(value);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hauteur d'une ligne de filtre de l'en-tête, marges comprises.
const double filterRowHeight = OptionToggle.height + 8;

class _FilterRow extends StatelessWidget {
  final String semanticLabel;
  final ChoiceFilterViewModel viewModel;
  final String Function(String?) labelOf;

  const _FilterRow({required this.semanticLabel, required this.viewModel, required this.labelOf});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: filterRowHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Center(
          child: Semantics(
            label: semanticLabel,
            container: true,
            child: OptionToggle<String?>(
              options: viewModel.options,
              selected: viewModel.value,
              labelOf: labelOf,
              onChanged: viewModel.select,
            ),
          ),
        ),
      ),
    );
  }
}
