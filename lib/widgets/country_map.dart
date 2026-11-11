import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../models/country_stats.dart';
import '../services/country_name_service.dart';
import '../services/world_map_service.dart';
import '../theme/app_theme.dart';

/// Carte du monde des pays rencontrés : plus on a joué contre un pays, plus
/// son bleu est intense. Un clic sur un pays affiche une bulle avec le
/// nombre de parties. Zoom au pincement ou avec les boutons.
class CountryMap extends StatefulWidget {
  /// Statistiques par pays déjà filtrées par cadence.
  final List<CountryStats> countries;

  const CountryMap({super.key, required this.countries});

  @override
  State<CountryMap> createState() => _CountryMapState();
}

class _CountryMapState extends State<CountryMap> {
  static const double _maxScale = 8;

  final TransformationController _controller = TransformationController();
  late final Future<WorldMap> _map = WorldMap.load();

  /// Pays sélectionné et point touché, en coordonnées de la carte non zoomée.
  String? _selected;
  Offset? _tapPosition;

  /// Souris au-dessus de la carte : InteractiveViewer zoome à la molette
  /// sans laisser la page défiler, on coupe donc le zoom par geste (les
  /// boutons restent) tant que la souris est là. Le pincement tactile
  /// n'est pas concerné.
  bool _mouseOver = false;

  @override
  void didUpdateWidget(CountryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Autre cadence : la bulle ouverte ne correspondrait plus aux chiffres.
    if (!mapEquals(
      WorldMapService.gamesByMapCountry(oldWidget.countries),
      WorldMapService.gamesByMapCountry(widget.countries),
    )) {
      _selected = null;
      _tapPosition = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(WorldMap map, double scale, Offset localPosition) {
    final code = map.countryAt(localPosition / scale);
    setState(() {
      if (code == null || code == _selected) {
        _selected = null;
        _tapPosition = null;
      } else {
        _selected = code;
        _tapPosition = localPosition;
      }
    });
  }

  /// Zoom par les boutons, centré sur le milieu de la vue.
  void _zoom(double factor, Size viewport) {
    final current = _controller.value.getMaxScaleOnAxis();
    final target = (current * factor).clamp(1.0, _maxScale);
    if (target == 1.0) {
      _controller.value = Matrix4.identity();
      return;
    }
    final center = viewport.center(Offset.zero);
    final f = target / current;
    _controller.value = Matrix4.translationValues(center.dx * (1 - f), center.dy * (1 - f), 0)
      ..multiply(Matrix4.diagonal3Values(f, f, 1))
      ..multiply(_controller.value);
  }

  /// La molette fait défiler la page, pas zoomer la carte : sinon la page
  /// resterait bloquée dès que la souris passe sur la carte.
  void _forwardScroll(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (e) {
      position.pointerScroll((e as PointerScrollEvent).scrollDelta.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final games = WorldMapService.gamesByMapCountry(widget.countries);
    final maxGames = games.values.fold(0, (a, b) => a > b ? a : b);
    final notShown = [
      for (final c in widget.countries)
        if (WorldMapService.mapCode(c.name) == null)
          l10n.countryMapNotShownItem(CountryNameService.countryName(l10n, c.name), c.gamesPlayed),
    ];

    return FutureBuilder<WorldMap>(
      future: _map,
      builder: (context, snapshot) {
        final map = snapshot.data;
        if (map == null) {
          // Erreur de chargement : on n'affiche simplement pas la carte,
          // le tableau reste disponible juste en dessous.
          if (snapshot.hasError) return const SizedBox.shrink();
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.countryMapHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              final scale = width / map.size.width;
              final viewport = Size(width, map.size.height * scale);
              return _buildViewer(context, l10n, map, games, maxGames, scale, viewport);
            }),
            const SizedBox(height: 8),
            _Legend(maxGames: maxGames, label: l10n.countryMapLegend),
            if (notShown.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                l10n.countryMapNotShown(notShown.join(', ')),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildViewer(
    BuildContext context,
    AppLocalizations l10n,
    WorldMap map,
    Map<String, int> games,
    int maxGames,
    double scale,
    Size viewport,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.fromSize(
        size: viewport,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: AppTheme.mapBackground(context))),
            MouseRegion(
              onEnter: (event) {
                if (event.kind == PointerDeviceKind.mouse) setState(() => _mouseOver = true);
              },
              onExit: (_) {
                if (_mouseOver) setState(() => _mouseOver = false);
              },
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 1,
                maxScale: _maxScale,
                scaleEnabled: !_mouseOver,
                child: Listener(
                  onPointerSignal: _forwardScroll,
                  child: GestureDetector(
                    onTapUp: (details) => _onTap(map, scale, details.localPosition),
                    child: CustomPaint(
                      size: viewport,
                      painter: _MapPainter(
                        map: map,
                        scale: scale,
                        zoom: _controller,
                        fills: {
                          for (final e in games.entries)
                            e.key: AppTheme.mapCountryColor(
                              WorldMapService.intensity(e.value, maxGames),
                            ),
                        },
                        emptyColor: AppTheme.mapEmptyCountry(context),
                        borderColor: AppTheme.mapBackground(context),
                        selected: _selected,
                        selectedColor: AppTheme.mapSelectedBorder(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Marqueurs des 3 pays les plus rencontrés, qui suivent le zoom.
            // Un clic dessus ouvre la bulle du pays, comme un clic sur le pays.
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final top = WorldMapService.topCountries(games);
                return Stack(
                  children: [
                    for (var i = top.length - 1; i >= 0; i--)
                      if (map.labels[top[i]] case final label?)
                        _RankMarker(
                          anchor: MatrixUtils.transformPoint(_controller.value, label * scale),
                          rank: i + 1,
                          tooltip: l10n.countryMapTopRank('${i + 1}'),
                          onTap: () => setState(() {
                            _selected = top[i];
                            _tapPosition = label * scale;
                          }),
                        ),
                  ],
                );
              },
            ),
            if (_selected != null && _tapPosition != null)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => _Bubble(
                  anchor: MatrixUtils.transformPoint(_controller.value, _tapPosition!),
                  viewport: viewport,
                  flag: CountryNameService.getFlag(_selected!),
                  text: l10n.countryMapGames(
                    CountryNameService.countryName(l10n, _selected!),
                    games[_selected] ?? 0,
                  ),
                ),
              ),
            Positioned(
              right: 4,
              bottom: 4,
              child: _ZoomButtons(
                onZoomIn: () => _zoom(2, viewport),
                onZoomOut: () => _zoom(0.5, viewport),
                onReset: () => _controller.value = Matrix4.identity(),
                l10n: l10n,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final WorldMap map;
  final double scale;
  final TransformationController zoom;
  final Map<String, Color> fills;
  final Color emptyColor;
  final Color borderColor;
  final String? selected;
  final Color selectedColor;

  _MapPainter({
    required this.map,
    required this.scale,
    required this.zoom,
    required this.fills,
    required this.emptyColor,
    required this.borderColor,
    required this.selected,
    required this.selectedColor,
  }) : super(repaint: zoom);

  @override
  void paint(Canvas canvas, Size size) {
    // Traits d'épaisseur constante à l'écran, quel que soit le zoom.
    final zoomFactor = zoom.value.getMaxScaleOnAxis();
    canvas.save();
    canvas.scale(scale);
    final fill = Paint()..style = PaintingStyle.fill;
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..strokeWidth = 0.6 / (scale * zoomFactor)
      ..strokeJoin = StrokeJoin.round;
    map.countries.forEach((code, path) {
      fill.color = fills[code] ?? emptyColor;
      canvas.drawPath(path, fill);
      canvas.drawPath(path, border);
    });
    final selectedPath = map.countries[selected];
    if (selectedPath != null) {
      canvas.drawPath(
        selectedPath,
        border
          ..color = selectedColor
          ..strokeWidth = 1.5 / (scale * zoomFactor),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.map != map ||
      old.scale != scale ||
      old.selected != selected ||
      old.emptyColor != emptyColor ||
      old.borderColor != borderColor ||
      old.selectedColor != selectedColor ||
      !_sameFills(old.fills, fills);

  static bool _sameFills(Map<String, Color> a, Map<String, Color> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
}

/// Bulle au-dessus du point touché, gardée dans les limites de la carte.
class _Bubble extends StatelessWidget {
  final Offset anchor;
  final Size viewport;
  final String flag;
  final String text;

  const _Bubble({required this.anchor, required this.viewport, required this.flag, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const maxWidth = 260.0;
    const height = 36.0;
    final left = (anchor.dx - maxWidth / 2).clamp(4.0, (viewport.width - maxWidth - 4).clamp(4.0, double.infinity));
    final above = anchor.dy - height - 8;
    final top = above >= 4 ? above : anchor.dy + 12;
    return Positioned(
      left: left,
      top: top,
      width: maxWidth,
      child: IgnorePointer(
        child: Center(
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(6),
            color: theme.colorScheme.inverseSurface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Largeur fixe : la largeur mesurée d'un drapeau emoji
                  // varie selon la police de repli (comme dans le tableau).
                  SizedBox(
                    width: 26,
                    child:
                        Text(flag, style: const TextStyle(fontSize: 18), softWrap: false, overflow: TextOverflow.clip),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      text,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onInverseSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Marqueur d'un des pays les plus rencontrés : icône de classement
/// (colonnes) et rang, dans une étiquette dont la pointe désigne le pays.
class _RankMarker extends StatelessWidget {
  static const double _width = 52;
  static const double _height = 34; // étiquette 28 + pointe 6

  final Offset anchor;
  final int rank;
  final String tooltip;
  final VoidCallback onTap;

  const _RankMarker({required this.anchor, required this.rank, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: anchor.dx - _width / 2,
      top: anchor.dy - _height,
      width: _width,
      height: _height,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: CustomPaint(
            // Or, argent, bronze : mêmes teintes dans les deux thèmes, contenu
            // et liseré blancs.
            painter: _PinPainter(color: AppTheme.podiumColors[rank - 1], border: Colors.white),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.leaderboard, size: 16, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fond du marqueur : rectangle arrondi et pointe vers le bas.
class _PinPainter extends CustomPainter {
  final Color color;
  final Color border;

  _PinPainter({required this.color, required this.border});

  @override
  void paint(Canvas canvas, Size size) {
    const tip = 6.0;
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height - tip), const Radius.circular(8));
    final path = Path()
      ..addRRect(body)
      ..moveTo(size.width / 2 - tip, size.height - tip)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + tip, size.height - tip)
      ..close();
    final outline = Path.combine(PathOperation.union, path, Path());
    canvas.drawShadow(outline, Colors.black, 2, false);
    canvas.drawPath(outline, Paint()..color = color);
    canvas.drawPath(
      outline,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_PinPainter old) => old.color != color || old.border != border;
}

class _ZoomButtons extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;
  final AppLocalizations l10n;

  const _ZoomButtons({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, String tooltip, VoidCallback onPressed) => IconButton(
          icon: Icon(icon, size: 18),
          tooltip: tooltip,
          onPressed: onPressed,
          visualDensity: VisualDensity.compact,
        );
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(Icons.remove, l10n.countryMapZoomOut, onZoomOut),
          button(Icons.center_focus_strong, l10n.countryMapReset, onReset),
          button(Icons.add, l10n.countryMapZoomIn, onZoomIn),
        ],
      ),
    );
  }
}

/// Dégradé du pays le moins joué (1 partie) au plus joué.
class _Legend extends StatelessWidget {
  final int maxGames;
  final String label;

  const _Legend({required this.maxGames, required this.label});

  @override
  Widget build(BuildContext context) {
    if (maxGames == 0) return const SizedBox.shrink();
    final small = Theme.of(context).textTheme.bodySmall;
    return Row(
      children: [
        Text(label, style: small),
        const SizedBox(width: 8),
        Text('1', style: small),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(colors: [
                for (var i = 0; i <= 4; i++) AppTheme.mapCountryColor(i / 4),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text('$maxGames', style: small),
      ],
    );
  }
}
