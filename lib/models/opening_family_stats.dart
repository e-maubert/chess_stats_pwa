/// Résultats (victoires / nulles / défaites) pour une famille d'ouvertures.
class OpeningFamilyStats {
  final String name;
  final int wins;
  final int draws;
  final int losses;

  const OpeningFamilyStats({
    required this.name,
    required this.wins,
    required this.draws,
    required this.losses,
  });

  int get totalGames => wins + draws + losses;

  double get winRate => totalGames > 0 ? wins / totalGames : 0;
  double get drawRate => totalGames > 0 ? draws / totalGames : 0;
  double get lossRate => totalGames > 0 ? losses / totalGames : 0;
}
