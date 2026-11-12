import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart' show rootBundle;

import '../models/country_stats.dart';

/// Contours des pays projetés (projection Equal Earth), prêts à dessiner.
/// Source : assets/map/world.json, généré par tool/build_world_map.dart.
class WorldMap {
  /// Code ISO alpha-2 → contour, en unités de projection décalées pour que
  /// le coin haut-gauche de la carte soit (0, 0).
  final Map<String, Path> countries;
  final Size size;

  /// Code ISO alpha-2 → point où poser un marqueur (cœur du territoire
  /// principal), dans le même repère que [countries].
  final Map<String, Offset> labels;

  /// Point projeté placé en (0, 0) sur la carte.
  final Offset origin;

  WorldMap._(this.countries, this.labels, this.size, this.origin);

  /// Position sur la carte d'un point donné en degrés.
  Offset locate(double lon, double lat) => project(lon, lat) - origin;

  static const String assetPath = 'assets/map/world.json';
  static Future<WorldMap>? _loaded;

  /// Chargé une seule fois pour toute l'app.
  static Future<WorldMap> load() => _loaded ??= rootBundle.loadString(assetPath).then(WorldMap.parse);

  /// [source] : { "countries": { "FR": [[lon, lat, lon, lat...], ...] },
  /// "labels": { "FR": [lon, lat] } }, en centièmes de degré.
  factory WorldMap.parse(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    final data = json['countries'] as Map<String, dynamic>;
    final rings = <String, List<List<Offset>>>{};
    var minX = double.infinity, minY = double.infinity;
    var maxX = double.negativeInfinity, maxY = double.negativeInfinity;

    data.forEach((code, value) {
      for (final ring in value as List) {
        final coords = (ring as List).cast<num>();
        final points = <Offset>[
          for (var i = 0; i + 1 < coords.length; i += 2) project(coords[i] / 100, coords[i + 1] / 100),
        ];
        for (final p in points) {
          minX = min(minX, p.dx);
          maxX = max(maxX, p.dx);
          minY = min(minY, p.dy);
          maxY = max(maxY, p.dy);
        }
        rings.putIfAbsent(code, () => []).add(points);
      }
    });

    final origin = Offset(minX, minY);
    final countries = <String, Path>{};
    rings.forEach((code, polygons) {
      final path = Path()..fillType = PathFillType.evenOdd;
      for (final ring in polygons) {
        path.addPolygon([for (final p in ring) p - origin], true);
      }
      countries[code] = path;
    });
    final labels = <String, Offset>{
      for (final entry in (json['labels'] as Map<String, dynamic>? ?? {}).entries)
        entry.key: project((entry.value[0] as num) / 100, (entry.value[1] as num) / 100) - origin,
    };
    return WorldMap._(countries, labels, Size(maxX - minX, maxY - minY), origin);
  }

  /// Projection Equal Earth (surfaces respectées, aspect proche de la
  /// Robinson). Longitude/latitude en degrés ; y croît vers le sud.
  static Offset project(double lon, double lat) {
    const a1 = 1.340264, a2 = -0.081106, a3 = 0.000893, a4 = 0.003796;
    final m = sqrt(3) / 2;
    final theta = asin(m * sin(lat * pi / 180));
    final t2 = theta * theta, t6 = t2 * t2 * t2;
    final x = 2 * sqrt(3) * (lon * pi / 180) * cos(theta) / (3 * (9 * a4 * t6 * t2 + 7 * a3 * t6 + 3 * a2 * t2 + a1));
    final y = theta * (a1 + a2 * t2 + t6 * (a3 + a4 * t2));
    return Offset(x, -y);
  }

  /// Pays sous [point] (coordonnées de la carte), null si mer.
  String? countryAt(Offset point) {
    for (final entry in countries.entries) {
      if (entry.value.getBounds().contains(point) && entry.value.contains(point)) {
        return entry.key;
      }
    }
    return null;
  }
}

/// Résultats contre un pays de la carte.
class MapCountryResult {
  final int games;
  final int wins;
  final int draws;
  final int losses;

  const MapCountryResult({required this.games, required this.wins, required this.draws, required this.losses});

  /// Performance, comme un score de tournoi : (victoires + ½ nulles) /
  /// parties, entre 0 et 1. 0,5 = équilibre.
  double get score => games > 0 ? (wins + draws / 2) / games : 0;
}

/// Calculs de la carte des pays : regroupement des codes chess.com par pays
/// dessiné, intensité de couleur, performance.
class WorldMapService {
  /// Codes spéciaux chess.com rattachés au pays de la carte qui les contient.
  /// International ('XX') et pays inconnu n'ont pas de place sur la carte.
  static const Map<String, String> _specialCodes = {
    'XE': 'GB', // Angleterre
    'XS': 'GB', // Écosse
    'XW': 'GB', // Pays de Galles
    'XA': 'ES', // Îles Canaries
    'XB': 'ES', // Pays basque
    'XC': 'ES', // Catalogne
    'XG': 'ES', // Galice
    'XP': 'PS', // Palestine
  };

  /// Code du pays de la carte pour un code chess.com, null s'il n'y figure pas.
  static String? mapCode(String chessCode) {
    final upper = chessCode.toUpperCase();
    final special = _specialCodes[upper];
    if (special != null) return special;
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(upper) || upper.startsWith('X') && upper != 'XK') {
      return null;
    }
    return upper;
  }

  /// Nombre de parties par pays de la carte.
  static Map<String, int> gamesByMapCountry(List<CountryStats> countries) =>
      resultsByMapCountry(countries).map((code, result) => MapEntry(code, result.games));

  /// Résultats (victoires, nulles, défaites) par pays de la carte : les
  /// codes rattachés à un même pays (ex. Angleterre et Écosse → GB) sont
  /// additionnés.
  static Map<String, MapCountryResult> resultsByMapCountry(List<CountryStats> countries) {
    final results = <String, MapCountryResult>{};
    for (final country in countries) {
      final code = mapCode(country.name);
      if (code == null || country.gamesPlayed == 0) continue;
      final previous = results[code];
      results[code] = MapCountryResult(
        games: (previous?.games ?? 0) + country.gamesPlayed,
        wins: (previous?.wins ?? 0) + country.gamesWon,
        draws: (previous?.draws ?? 0) + country.gamesDrawn,
        losses: (previous?.losses ?? 0) + country.gamesLost,
      );
    }
    return results;
  }

  /// Nombre minimum de parties contre un pays pour juger la performance :
  /// 2 tant que le mois compte au plus [smallMonthMaxGames] parties, 3
  /// au-delà. Avec une seule partie, 0 % ou 100 % ne veulent rien dire.
  static int minGamesForPerformance(int totalGames) => totalGames <= smallMonthMaxGames ? 2 : 3;

  static const int smallMonthMaxGames = 40;

  /// Points forts (performance au-dessus de 50 %, la meilleure d'abord) et
  /// points faibles (en dessous de 50 %, la plus faible d'abord), parmi les
  /// pays d'au moins [minGames] parties. Au plus [count] de chaque côté ;
  /// un pays à 50 % n'est ni l'un ni l'autre, et aucun pays ne peut être
  /// les deux. À performance égale, le pays le plus joué passe devant,
  /// puis l'ordre alphabétique des codes.
  static ({List<String> strengths, List<String> weaknesses}) strengthsAndWeaknesses(
    Map<String, MapCountryResult> results,
    int minGames, {
    int count = 3,
  }) {
    final judged = results.entries.where((e) => e.value.games >= minGames).toList();
    int byGamesThenCode(MapEntry<String, MapCountryResult> a, MapEntry<String, MapCountryResult> b) {
      final cmp = b.value.games.compareTo(a.value.games);
      return cmp != 0 ? cmp : a.key.compareTo(b.key);
    }

    final strengths = judged.where((e) => e.value.score > 0.5).toList()
      ..sort((a, b) {
        final cmp = b.value.score.compareTo(a.value.score);
        return cmp != 0 ? cmp : byGamesThenCode(a, b);
      });
    final weaknesses = judged.where((e) => e.value.score < 0.5).toList()
      ..sort((a, b) {
        final cmp = a.value.score.compareTo(b.value.score);
        return cmp != 0 ? cmp : byGamesThenCode(a, b);
      });
    return (
      strengths: strengths.take(count).map((e) => e.key).toList(),
      weaknesses: weaknesses.take(count).map((e) => e.key).toList(),
    );
  }

  /// Les [count] pays les plus joués, du premier au dernier. À égalité,
  /// ordre alphabétique des codes, pour un classement stable.
  static List<String> topCountries(Map<String, int> games, {int count = 3}) {
    final codes = games.keys.toList()
      ..sort((a, b) {
        final cmp = games[b]!.compareTo(games[a]!);
        return cmp != 0 ? cmp : a.compareTo(b);
      });
    return codes.take(count).toList();
  }

  /// Intensité de couleur entre 0 (1 partie) et 1 (pays le plus joué).
  /// Échelle logarithmique : un pays très dominant (ex. 300 parties contre
  /// 2 ou 3 ailleurs) n'écrase pas toutes les autres nuances.
  static double intensity(int games, int maxGames) {
    if (games <= 1 || maxGames <= 1) return maxGames <= 1 && games >= 1 ? 1 : 0;
    return (log(games) / log(maxGames)).clamp(0.0, 1.0);
  }
}
