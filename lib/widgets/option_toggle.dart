import 'package:flutter/material.dart';

/// Sélecteur compact en forme de pilule : une pastille glisse sous l'option
/// choisie. Accepte un nombre quelconque d'options, toutes de même largeur
/// (celle du libellé le plus long), ou toute la largeur disponible avec
/// [expanded].
class OptionToggle<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T> onChanged;

  /// Occupe toute la largeur disponible ; un libellé trop long est réduit.
  final bool expanded;

  static const double height = 32;

  const OptionToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelLarge;
    final index = options.indexOf(selected);
    final count = options.length;

    final toggle = Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment(count == 1 ? 0 : -1 + 2 * index / (count - 1), 0),
              child: FractionallySizedBox(
                widthFactor: 1 / count,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final option in options)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: option == selected,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(height / 2),
                      onTap: () => onChanged(option),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: expanded ? 6 : 14),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              labelOf(option),
                              maxLines: 1,
                              style: textStyle?.copyWith(
                                color: option == selected ? colors.onSecondaryContainer : colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
    return expanded ? toggle : IntrinsicWidth(child: toggle);
  }
}
