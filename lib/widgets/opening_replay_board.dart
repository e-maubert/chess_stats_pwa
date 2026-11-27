import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../services/opening_improvement_service.dart';
import '../services/opening_replay_service.dart';
import 'chess_board_view.dart';

/// Échiquier d'un axe d'amélioration qu'on peut rejouer : il montre d'abord
/// la position à corriger (avec ses flèches) ; « Rejouer » repart de la
/// position de départ et joue les coups de l'ouverture un par un, en
/// faisant glisser les pièces, jusqu'à cette position. Les autres boutons
/// avancent ou reculent d'un coup, ou vont au début / à la fin.
class OpeningReplayBoard extends StatefulWidget {
  /// Coups menant à la position à corriger (SAN).
  final List<String> line;

  /// Position à corriger (FEN), montrée à la fin avec [arrows].
  final String fen;
  final bool flipped;
  final List<BoardArrow> arrows;
  final String? semanticLabel;

  const OpeningReplayBoard({
    super.key,
    required this.line,
    required this.fen,
    required this.flipped,
    required this.arrows,
    this.semanticLabel,
  });

  /// Durée du glissement d'une pièce, puis pause avant le coup suivant.
  static const Duration slideDuration = Duration(milliseconds: 350);
  static const Duration pauseBetweenMoves = Duration(milliseconds: 650);

  @override
  State<OpeningReplayBoard> createState() => _OpeningReplayBoardState();
}

class _OpeningReplayBoardState extends State<OpeningReplayBoard> with SingleTickerProviderStateMixin {
  late List<ReplayStep> _steps;
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: OpeningReplayBoard.slideDuration);

  /// Nombre de coups joués : 0 = position de départ, [_steps].length =
  /// position à corriger (affichée au départ).
  late int _index;

  /// Coup en train de glisser, null sinon.
  ReplayStep? _sliding;
  bool _playing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(OpeningReplayBoard old) {
    super.didUpdateWidget(old);
    if (old.fen != widget.fen || old.line.join(' ') != widget.line.join(' ')) {
      _stop();
      _load();
    }
  }

  void _load() {
    _steps = OpeningReplayService.replay(widget.line);
    _index = _steps.length;
  }

  /// La suite est rejouable : non vide et entièrement lisible.
  bool get _replayable => _steps.isNotEmpty && _steps.length == widget.line.length;

  bool get _atEnd => _index >= _steps.length;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Arrête la lecture et le glissement en cours.
  void _stop() {
    _playing = false;
    _timer?.cancel();
    _sliding = null;
    _controller.stop();
  }

  /// Fait glisser le coup suivant, puis appelle [onDone].
  void _slideNext({VoidCallback? onDone}) {
    if (_atEnd || _sliding != null) return;
    final step = _steps[_index];
    setState(() => _sliding = step);
    _controller.forward(from: 0).whenCompleteOrCancel(() {
      // Glissement interrompu (autre bouton, nouvel échiquier) : rien à faire.
      if (!mounted || _sliding != step) return;
      setState(() {
        _sliding = null;
        _index++;
      });
      onDone?.call();
    });
  }

  void _tick() {
    if (!mounted || !_playing) return;
    if (_atEnd) {
      setState(() => _playing = false);
      return;
    }
    _slideNext(onDone: () => _timer = Timer(OpeningReplayBoard.pauseBetweenMoves, _tick));
  }

  void _togglePlay() {
    if (_playing) {
      setState(() => _playing = false);
      _timer?.cancel();
      return;
    }
    final restart = _atEnd;
    setState(() {
      _playing = true;
      if (restart) _index = 0;
    });
    // Depuis la fin : on montre d'abord la position de départ.
    _timer = Timer(restart ? OpeningReplayBoard.pauseBetweenMoves : Duration.zero, _tick);
  }

  void _goTo(int index) => setState(() {
        _stop();
        _index = index.clamp(0, _steps.length);
      });

  void _next() {
    if (_sliding != null || _atEnd) return;
    setState(() {
      _playing = false;
      _timer?.cancel();
    });
    _slideNext();
  }

  @override
  Widget build(BuildContext context) {
    if (!_replayable) {
      return ChessBoardView(
        fen: widget.fen,
        flipped: widget.flipped,
        arrows: widget.arrows,
        semanticLabel: widget.semanticLabel,
      );
    }
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final board = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final sliding = _sliding;
        if (sliding != null) {
          return ChessBoardView(
            fen: sliding.fenBefore,
            flipped: widget.flipped,
            slides: sliding.slides,
            progress: _controller.value,
            highlight: sliding.ply > 0 ? _steps[sliding.ply - 1].move : null,
            semanticLabel: widget.semanticLabel,
          );
        }
        return ChessBoardView(
          fen: _atEnd ? widget.fen : (_index == 0 ? OpeningReplayService.startFen : _steps[_index - 1].fenAfter),
          flipped: widget.flipped,
          arrows: _atEnd ? widget.arrows : const [],
          highlight: _index > 0 ? _steps[_index - 1].move : null,
          semanticLabel: widget.semanticLabel,
        );
      },
    );

    final letters = l10n.sanPieceLetters;
    final String label;
    if (_atEnd) {
      label = l10n.openingReplayMistake;
    } else if (_index == 0) {
      label = l10n.openingReplayStart;
    } else {
      final step = _steps[_index - 1];
      label = OpeningImprovementService.numbered(step.ply, step.san, letters: letters);
    }

    final busy = _sliding != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        board,
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: l10n.openingReplayStart,
              icon: const Icon(Icons.first_page),
              onPressed: _index == 0 && !busy ? null : () => _goTo(0),
            ),
            IconButton(
              tooltip: l10n.openingReplayPrevious,
              icon: const Icon(Icons.chevron_left),
              onPressed: _index == 0 && !busy ? null : () => _goTo(_index - 1),
            ),
            IconButton.filledTonal(
              tooltip: _playing ? l10n.openingReplayPause : l10n.openingReplayPlay,
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlay,
            ),
            IconButton(
              tooltip: l10n.openingReplayNext,
              icon: const Icon(Icons.chevron_right),
              onPressed: _atEnd || busy ? null : _next,
            ),
            IconButton(
              tooltip: l10n.openingReplayMistake,
              icon: const Icon(Icons.last_page),
              onPressed: _atEnd ? null : () => _goTo(_steps.length),
            ),
          ],
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
