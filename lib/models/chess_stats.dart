import 'opening_stats.dart';
import 'country_stats.dart';
import 'country_game.dart';
import 'color_stats.dart';
import 'opening_family.dart';

class ChessStats {
  final String username;
  final ColorStats whiteStats;
  final ColorStats blackStats;
  final Map<String, OpeningStats> openings;
  final Map<String, CountryStats> countryStats;
  final List<CountryGame> countryGames;
  final int totalGames;
  final int wins;
  final int losses;
  final int draws;

  ChessStats({
    required this.username,
    required this.whiteStats,
    required this.blackStats,
    required this.openings,
    required this.countryStats,
    this.countryGames = const [],
    required this.totalGames,
    required this.wins,
    required this.losses,
    required this.draws,
  });

  double get winRate => totalGames > 0 ? wins / totalGames : 0;
  double get lossRate => totalGames > 0 ? losses / totalGames : 0;
  double get drawRate => totalGames > 0 ? draws / totalGames : 0;

  double get whiteWinRate => whiteStats.winRate;
  double get blackWinRate => blackStats.winRate;

  List<OpeningFamily> get openingFamilies {
    final Map<String, List<OpeningStats>> familyMap = {};
    
    for (final opening in openings.values) {
      final familyName = OpeningFamily.getFamilyName(opening.name);
      if (!familyMap.containsKey(familyName)) {
        familyMap[familyName] = [];
      }
      familyMap[familyName]!.add(opening);
    }

    return familyMap.entries
        .map((entry) => OpeningFamily(name: entry.key, openings: entry.value))
        .toList()
      ..sort((a, b) => b.totalGames.compareTo(a.totalGames));
  }

  List<CountryStats> get topCountries {
    return countryStats.values.toList()
      ..sort((a, b) => b.winRate.compareTo(a.winRate));
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'whiteStats': whiteStats.toJson(),
      'blackStats': blackStats.toJson(),
      'openings': openings.map((key, value) => MapEntry(key, value.toJson())),
      'countryStats': countryStats.map((key, value) => MapEntry(key, value.toJson())),
      'countryGames': countryGames.map((game) => game.toJson()).toList(),
      'totalGames': totalGames,
      'wins': wins,
      'losses': losses,
      'draws': draws,
    };
  }

  factory ChessStats.fromJson(Map<String, dynamic> json) {
    return ChessStats(
      username: json['username'] as String,
      whiteStats: ColorStats.fromJson(json['whiteStats'] as Map<String, dynamic>),
      blackStats: ColorStats.fromJson(json['blackStats'] as Map<String, dynamic>),
      openings: (json['openings'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, OpeningStats.fromJson(value as Map<String, dynamic>)),
      ),
      countryStats: (json['countryStats'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, CountryStats.fromJson(value as Map<String, dynamic>)),
      ),
      countryGames: (json['countryGames'] as List<dynamic>? ?? [])
          .map((game) => CountryGame.fromJson(game as Map<String, dynamic>))
          .toList(),
      totalGames: json['totalGames'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      draws: json['draws'] as int,
    );
  }
} 