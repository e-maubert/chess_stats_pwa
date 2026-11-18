import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../viewmodels/time_class_viewmodel.dart';
import 'option_toggle.dart';

/// En-tête de la page des stats, sous la période : choix de la cadence
/// (Toutes / Bullet / Blitz / Rapide), commun à toutes les cartes.
class TimeClassSelector extends StatelessWidget {
  const TimeClassSelector({super.key});

  /// Hauteur de la ligne, marges comprises.
  static const double height = OptionToggle.height + 8;

  /// Libellé d'une cadence (null = toutes).
  static String labelOf(String? timeClass, AppLocalizations l10n) => switch (timeClass) {
        'bullet' => l10n.timeClassBullet,
        'blitz' => l10n.timeClassBlitz,
        'rapid' => l10n.timeClassRapid,
        _ => l10n.timeClassAll,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<TimeClassViewModel>();

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Center(
          child: Semantics(
            label: l10n.timeClassLabel,
            container: true,
            child: OptionToggle<String?>(
              options: TimeClassViewModel.timeClasses,
              selected: viewModel.timeClass,
              labelOf: (timeClass) => labelOf(timeClass, l10n),
              onChanged: viewModel.select,
            ),
          ),
        ),
      ),
    );
  }
}
