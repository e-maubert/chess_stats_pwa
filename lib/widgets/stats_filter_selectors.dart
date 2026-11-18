import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
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

/// En-tête de la page des stats, sous la période : choix de la cadence
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
