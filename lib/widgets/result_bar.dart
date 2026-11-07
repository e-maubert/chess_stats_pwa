import 'package:flutter/material.dart';

/// Barre horizontale en trois couleurs : victoires (vert), nulles (gris),
/// défaites (rouge), proportionnelles au nombre de parties.
class ResultBar extends StatelessWidget {
  final int wins;
  final int draws;
  final int losses;
  final double width;

  const ResultBar({
    super.key,
    required this.wins,
    required this.draws,
    required this.losses,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    Widget segment(int flex, Color color) =>
        flex > 0 ? Expanded(flex: flex, child: Container(color: color)) : const SizedBox.shrink();

    return SizedBox(
      width: width,
      height: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: [
            segment(wins, Colors.green),
            segment(draws, Colors.grey),
            segment(losses, Colors.red),
          ],
        ),
      ),
    );
  }
}
