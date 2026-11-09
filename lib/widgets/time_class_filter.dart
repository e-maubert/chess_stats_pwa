import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';

/// Puces de choix de cadence : Toutes les parties / Bullet / Blitz / Rapide.
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: timeClasses
          .map((timeClass) => ChoiceChip(
                label: Text(_label(timeClass, l10n)),
                selected: selected == timeClass,
                onSelected: (_) => onSelected(timeClass),
              ))
          .toList(),
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
