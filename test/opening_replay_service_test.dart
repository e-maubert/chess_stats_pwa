import 'package:chess_stats_pwa/services/opening_replay_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Partie « placement des pièces » d'une FEN (sans le trait ni les droits).
String placement(String fen) => fen.split(' ').first;

void main() {
  test('rejoue la suite depuis la position de départ', () {
    final steps = OpeningReplayService.replay(['e4', 'e5', 'Nf3']);
    expect(steps.length, 3);
    expect(steps[0].fenBefore, OpeningReplayService.startFen);
    expect(steps[0].move, (from: 'e2', to: 'e4'));
    expect(steps[1].move, (from: 'e7', to: 'e5'));
    expect(steps[2].move, (from: 'g1', to: 'f3'));
    expect(steps[2].ply, 2);
    expect(steps[1].fenAfter, steps[2].fenBefore);
    expect(placement(steps[2].fenAfter), 'rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R');
  });

  test('roque : le roi et la tour glissent', () {
    final steps = OpeningReplayService.replay(['e4', 'e5', 'Nf3', 'Nc6', 'Bc4', 'Bc5', 'O-O', 'd6', 'd4', 'Bg4', 'Nc3', 'Qd7', 'Be3', 'O-O-O']);
    expect(steps[6].slides, [(from: 'e1', to: 'g1'), (from: 'h1', to: 'f1')]);
    expect(steps.last.slides, [(from: 'e8', to: 'c8'), (from: 'a8', to: 'd8')]);
  });

  test('prise, échec et désambiguïsation', () {
    final steps = OpeningReplayService.replay(['e4', 'd5', 'exd5', 'Qxd5', 'Nc3', 'Qa5', 'Nf3', 'Nf6', 'Bc4', 'Bg4', 'Bxf7+']);
    expect(steps.length, 11);
    expect(steps[2].move, (from: 'e4', to: 'd5'));
    expect(steps.last.move, (from: 'c4', to: 'f7'));
  });

  test('coup illisible : la suite s\'arrête avant', () {
    expect(OpeningReplayService.replay(['e4', 'Ke2', 'Nf3']).length, 1);
    expect(OpeningReplayService.replay([]), isEmpty);
  });
}
