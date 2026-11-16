import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';

/// Petit titre « Cadence », puis puces de choix : Toutes / Bullet / Blitz /
/// Rapide. Sans coche et en version compacte, elles tiennent sur une ligne
/// même sur un téléphone.
class TimeClassFilter extends StatelessWidget {
  /// Cadences proposées (null = toutes les parties).
  final List<String?> timeClasses;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const TimeClassFilter({
    super.key,
    required this.timeClasses,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.timeClassLabel,
          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: timeClasses
              .map((timeClass) => ChoiceChip(
                    label: Text(_label(timeClass, l10n)),
                    selected: selected == timeClass,
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    onSelected: (_) => onSelected(timeClass),
                  ))
              .toList(),
        ),
      ],
    );
  }

  String _label(String? timeClass, AppLocalizations l10n) {
    switch (timeClass) {
      case 'bullet':
        return l10n.timeClassBullet;
      case 'blitz':
        return l10n.timeClassBlitz;
      case 'rapid':
        return l10n.timeClassRapid;
      default:
        return l10n.timeClassAll;
    }
  }
}
