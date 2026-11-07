import 'opening_stats.dart';

class OpeningFamily {
  final String name;
  final List<OpeningStats> openings;
  final int totalGames;
  final int totalWins;
  final int totalLosses;
  final int totalDraws;

  OpeningFamily({
    required this.name,
    required this.openings,
  }) : totalGames = openings.fold(0, (sum, opening) => sum + opening.played),
       totalWins = openings.fold(0, (sum, opening) => sum + opening.won),
       totalLosses = openings.fold(0, (sum, opening) => sum + (opening.played - opening.won)),
       totalDraws = 0; // Les nuls ne sont pas encore gérés dans OpeningStats

  double get winRate => totalGames > 0 ? totalWins / totalGames : 0;
  double get lossRate => totalGames > 0 ? totalLosses / totalGames : 0;
  double get drawRate => totalGames > 0 ? totalDraws / totalGames : 0;

  static String getFamilyName(String openingName) {
    final parts = openingName.split('-');
    if (parts.length >= 2) {
      return '${parts[0]}-${parts[1]}';
    }
    return openingName;
  }
} 