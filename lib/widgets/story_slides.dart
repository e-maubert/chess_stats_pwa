import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';

/// Une diapositive : un petit titre, une grande valeur (chiffre ou nom),
/// puis quelques lignes de détail. [action] (ex. un bouton) s'affiche
/// dessous.
class StorySlide {
  final String? label;
  final String value;
  final List<String> details;
  final Widget? action;

  const StorySlide({this.label, required this.value, this.details = const [], this.action});
}

/// Diapositives plein écran façon « bilan de l'année » : barre
/// d'avancement en haut, une couleur vive par diapositive. On avance en
/// touchant la droite (ou en faisant glisser, ou avec les flèches du
/// clavier) et on recule en touchant le tiers gauche.
///
/// Composant générique, sans logique métier : réutilisable pour d'autres
/// séries de faits marquants.
class StorySlides extends StatefulWidget {
  final List<StorySlide> slides;

  /// Appelé quand on avance depuis la dernière diapositive.
  final VoidCallback? onFinished;

  /// Largeur maximale : sur ordinateur, les diapositives gardent un format
  /// de téléphone au centre de l'écran.
  static const double maxWidth = 520;

  const StorySlides({super.key, required this.slides, this.onFinished});

  @override
  State<StorySlides> createState() => _StorySlidesState();
}

class _StorySlidesState extends State<StorySlides> {
  final _controller = PageController();
  int _index = 0;

  static const Duration _transition = Duration(milliseconds: 300);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < widget.slides.length - 1) {
      _controller.nextPage(duration: _transition, curve: Curves.easeOut);
    } else {
      widget.onFinished?.call();
    }
  }

  void _previous() {
    if (_index > 0) _controller.previousPage(duration: _transition, curve: Curves.easeOut);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _next();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _previous();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Couleurs de fond / texte de la diapositive [index], prises dans le
  /// thème : lisibles en clair comme en sombre.
  static (Color, Color) _colors(ColorScheme scheme, int index) => switch (index % 4) {
        0 => (scheme.primary, scheme.onPrimary),
        1 => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
        2 => (scheme.tertiary, scheme.onTertiary),
        _ => (scheme.primaryContainer, scheme.onPrimaryContainer),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = _colors(scheme, _index);

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: StorySlides.maxWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: _transition,
              color: background,
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) =>
                          details.localPosition.dx < constraints.maxWidth / 3 ? _previous() : _next(),
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: widget.slides.length,
                        onPageChanged: (index) => setState(() => _index = index),
                        itemBuilder: (context, index) => _SlideContent(
                          slide: widget.slides[index],
                          color: _colors(scheme, index).$2,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: _Progress(count: widget.slides.length, index: _index, color: foreground),
                  ),
                  // Flèches pour la souris et les lecteurs d'écran.
                  Positioned(
                    left: 4,
                    bottom: 8,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left),
                      color: foreground,
                      tooltip: l10n.slidesPrevious,
                      onPressed: _index > 0 ? _previous : null,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 8,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right),
                      color: foreground,
                      tooltip: l10n.slidesNext,
                      onPressed: _index < widget.slides.length - 1 || widget.onFinished != null ? _next : null,
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

/// Segments d'avancement en haut, un par diapositive.
class _Progress extends StatelessWidget {
  final int count;
  final int index;
  final Color color;

  const _Progress({required this.count, required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < count; i++)
            Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: i <= index ? 0.9 : 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final StorySlide slide;
  final Color color;

  const _SlideContent({required this.slide, required this.color});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 64),
      // Entrée de la valeur en grossissant, à chaque diapositive.
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.85, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (slide.label != null)
                  Text(
                    slide.label!,
                    style: text.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                Text(
                  slide.value,
                  style: (slide.value.length <= 6 ? text.displayLarge : text.displaySmall)
                      ?.copyWith(color: color, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                for (final detail in slide.details) ...[
                  const SizedBox(height: 12),
                  Text(
                    detail,
                    style: text.titleMedium?.copyWith(color: color),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (slide.action != null) ...[
                  const SizedBox(height: 32),
                  slide.action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
