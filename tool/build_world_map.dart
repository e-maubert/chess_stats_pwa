// Génère assets/map/world.json (contours simplifiés des pays) à partir des
// contours Natural Earth 1:50m (domaine public, https://www.naturalearthdata.com).
//
//   curl -L -o ne50.geojson https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_50m_admin_0_countries.geojson
//   C:\src\flutter\bin\dart.bat run tool/build_world_map.dart ne50.geojson assets/map/world.json
//
// Format produit :
//   { "countries": { "FR": [[lon0, lat0, lon1, lat1, ...], ...], ... },
//     "labels": { "FR": [lon, lat], ... } }
// Clé = code ISO 3166-1 alpha-2 ; chaque anneau = coordonnées en centièmes
// de degré (entiers), à plat. « labels » = point d'étiquette de Natural
// Earth (LABEL_X / LABEL_Y), placé au cœur du territoire principal ; il sert
// à poser les marqueurs du classement. L'Antarctique est retiré.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Tolérance de simplification (Douglas-Peucker), en degrés.
const double tolerance = 0.08;

/// Les îles dont la boîte englobante est plus petite (en degrés) sont
/// retirées, sauf si c'est la plus grande terre du pays.
const double minRingSize = 0.25;

/// Territoires sans code ISO dans Natural Earth, rattachés au pays ISO.
const Map<String, String> unnamed = {'Somaliland': 'SO', 'N. Cyprus': 'CY'};

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('Usage : dart run tool/build_world_map.dart <entrée.geojson> <sortie.json>');
    exit(64);
  }
  final data = jsonDecode(File(args[0]).readAsStringSync()) as Map<String, dynamic>;
  final result = <String, List<List<int>>>{};
  final labels = <String, List<int>>{};
  final labelSizes = <String, double>{};

  for (final feature in data['features'] as List) {
    final props = feature['properties'] as Map<String, dynamic>;
    final code =
        RegExp(r'^[A-Z]{2}$').hasMatch('${props['ISO_A2_EH']}') ? props['ISO_A2_EH'] as String : unnamed[props['NAME']];
    if (code == null || code == 'AQ') continue;

    final geometry = feature['geometry'] as Map<String, dynamic>;
    final polygons = geometry['type'] == 'Polygon'
        ? [geometry['coordinates'] as List]
        : (geometry['coordinates'] as List).cast<List>();

    // Contour extérieur de chaque polygone seulement : les trous (lacs,
    // enclaves) sont dessinés par le pays qui les occupe.
    final rings = <List<Point<double>>>[
      for (final polygon in polygons)
        [for (final p in polygon.first as List) Point((p[0] as num).toDouble(), (p[1] as num).toDouble())],
    ];
    final kept = _keepRings(rings);

    // Plusieurs entités pour un même code (Australie et ses îlots,
    // Somaliland...) : on garde l'étiquette de la plus étendue, hors
    // territoires rattachés.
    final size = rings.map(_size).reduce(max);
    if (!unnamed.containsKey(props['NAME']) && size > (labelSizes[code] ?? -1)) {
      labelSizes[code] = size;
      labels[code] = [
        ((props['LABEL_X'] as num) * 100).round(),
        ((props['LABEL_Y'] as num) * 100).round(),
      ];
    }
    result.putIfAbsent(code, () => []).addAll([
      for (final ring in kept)
        [
          for (final p in _simplify(ring)) ...[(p.x * 100).round(), (p.y * 100).round()]
        ],
    ]);
  }

  final keys = result.keys.toList()..sort();
  final out = {
    'countries': {for (final k in keys) k: result[k]},
    'labels': {
      for (final k in keys)
        if (labels.containsKey(k)) k: labels[k]
    },
  };
  File(args[1])
    ..createSync(recursive: true)
    ..writeAsStringSync(jsonEncode(out));
  stdout.writeln('${keys.length} pays, ${File(args[1]).lengthSync()} octets');
}

double _size(List<Point<double>> ring) {
  final xs = ring.map((p) => p.x), ys = ring.map((p) => p.y);
  return max(xs.reduce(max) - xs.reduce(min), ys.reduce(max) - ys.reduce(min));
}

List<List<Point<double>>> _keepRings(List<List<Point<double>>> rings) {
  final largest = rings.reduce((a, b) => _size(a) >= _size(b) ? a : b);
  return [
    for (final r in rings)
      if (identical(r, largest) || _size(r) >= minRingSize) r
  ];
}

/// Douglas-Peucker ; garde au moins 4 points pour que les petits pays
/// restent visibles.
List<Point<double>> _simplify(List<Point<double>> ring) {
  if (ring.length <= 4) return ring;
  final keep = List<bool>.filled(ring.length, false);
  keep[0] = keep[ring.length - 1] = true;
  void recurse(int start, int end) {
    var maxDist = 0.0;
    var index = -1;
    for (var i = start + 1; i < end; i++) {
      final d = _distance(ring[i], ring[start], ring[end]);
      if (d > maxDist) {
        maxDist = d;
        index = i;
      }
    }
    if (index != -1 && maxDist > tolerance) {
      keep[index] = true;
      recurse(start, index);
      recurse(index, end);
    }
  }

  // Anneau fermé : on coupe au point le plus éloigné du premier.
  var far = 1;
  for (var i = 1; i < ring.length; i++) {
    if (ring[i].distanceTo(ring[0]) > ring[far].distanceTo(ring[0])) far = i;
  }
  keep[far] = true;
  recurse(0, far);
  recurse(far, ring.length - 1);
  final simplified = [
    for (var i = 0; i < ring.length; i++)
      if (keep[i]) ring[i]
  ];
  return simplified.length >= 4 ? simplified : ring;
}

double _distance(Point<double> p, Point<double> a, Point<double> b) {
  final dx = b.x - a.x, dy = b.y - a.y;
  final len2 = dx * dx + dy * dy;
  if (len2 == 0) return p.distanceTo(a);
  final t = (((p.x - a.x) * dx + (p.y - a.y) * dy) / len2).clamp(0.0, 1.0);
  return p.distanceTo(Point(a.x + t * dx, a.y + t * dy));
}
