import 'package:chess/chess.dart';
import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/opening_improvement_service.dart';
import 'package:chess_stats_pwa/services/position_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame _game(List<String> moves,
        {String color = 'white', String result = 'loss', String opening = 'Scotch-Game', String timeClass = 'blitz'}) =>
    CountryGame(
      opponent: 'x',
      timeClass: timeClass,
      result: result,
      playerColor: color,
      opening: opening,
      openingMoves: moves,
    );

String _fenAfter(List<String> moves) {
  final board = Chess();
  for (final m in moves) {
    board.move(m);
  }
  return board.fen;
}

/// Évaluations données à l'avance (FEN → évaluation), le reste inconnu.
class _FakeEvaluator implements PositionEvaluator {
  final Map<String, PositionEval> evals;
  final List<String> asked = [];

  _FakeEvaluator(this.evals);

  @override
  Future<PositionEval?> evaluate(String fen) async {
    asked.add(fen);
    return evals[fen];
  }
}

void main() {
  const scotch = ['e4', 'e5', 'Nf3', 'Nc6', 'd4', 'exd4', 'Bc4', 'Bc5', 'c3', 'dxc3', 'Bxf7+', 'Kf8', 'Bxg8'];

  group('mainTimeClass / mainOpening', () {
    test('cadence et ouverture les plus jouées, par couleur', () {
      final games = [
        _game(['e4'], timeClass: 'blitz'),
        _game(['e4'], timeClass: 'blitz', opening: 'Italian-Game'),
        _game(['e4'], timeClass: 'rapid'),
        _game(['d4', 'e5'], color: 'black', opening: 'Englund-Gambit'),
      ];
      expect(OpeningImprovementService.mainTimeClass(games), 'blitz');
      final white = OpeningImprovementService.mainOpening(games, white: true)!;
      expect(white.opening, 'Scotch-Game');
      expect(white.games, hasLength(2));
      expect(OpeningImprovementService.mainOpening(games, white: false)!.opening, 'Englund-Gambit');
    });

    test('sans coups connus : pas d\'ouverture', () {
      const game = CountryGame(opponent: 'x', timeClass: 'blitz', result: 'win', playerColor: 'white', opening: 'X');
      expect(OpeningImprovementService.mainOpening([game], white: true), isNull);
    });
  });

  group('candidates', () {
    test('coups du joueur rejoués au moins 3 fois, avec les défaites', () {
      final games = [
        for (var i = 0; i < 3; i++) _game(scotch, result: i == 0 ? 'win' : 'loss'),
        _game(['e4', 'e5', 'Nf3', 'Nc6', 'Bc4']),
      ];
      final found = OpeningImprovementService.candidates(games, white: true);
      // Coups des blancs seulement.
      expect(found.every((c) => c.ply.isEven), isTrue);
      final e4 = found.firstWhere((c) => c.san == 'e4');
      expect(e4.count, 4);
      expect(e4.losses, 3);
      final bxg8 = found.firstWhere((c) => c.san == 'Bxg8');
      expect(bxg8.count, 3);
      expect(bxg8.losses, 2);
      expect(bxg8.ply, 12);
      expect(bxg8.line, scotch.sublist(0, 12));
      // Bc4 au 3e coup : une seule fois.
      expect(found.where((c) => c.san == 'Bc4' && c.ply == 4), isEmpty);
    });

    test('positions identiques atteintes par des chemins différents regroupées', () {
      final games = [
        _game(['e4', 'e5', 'Nf3', 'Nc6', 'Bc4']),
        _game(['Nf3', 'Nc6', 'e4', 'e5', 'Bc4']),
        _game(['e4', 'Nc6', 'Nf3', 'e5', 'Bc4']),
      ];
      final bc4 = OpeningImprovementService.candidates(games, white: true).where((c) => c.san == 'Bc4');
      expect(bc4.single.count, 3);
    });
  });

  group('findMistake', () {
    final before = _fenAfter(scotch.sublist(0, 12));
    final after = _fenAfter(scotch);
    final candidate =
        OpeningCandidate(fen: before, san: 'Bxg8', ply: 12, line: scotch.sublist(0, 12), count: 4, losses: 3);

    test('perte du point de vue du joueur, meilleur coup et flèches', () async {
      final evaluator = _FakeEvaluator({
        before: const PositionEval(220, 'f7b3'),
        after: const PositionEval(100, 'h8g8'),
      });
      final mistake = await OpeningImprovementService.findMistake([candidate], white: true, evaluator: evaluator);
      expect(mistake, isNotNull);
      expect(mistake!.loss, 120);
      expect(mistake.bestSan, 'Bb3');
      expect(mistake.move, ('f7', 'g8'));
      expect(mistake.best, ('f7', 'b3'));
    });

    test('perte trop faible ou coup du moteur : rien à corriger', () async {
      final small = _FakeEvaluator({before: const PositionEval(120, 'f7b3'), after: const PositionEval(100, null)});
      expect(await OpeningImprovementService.findMistake([candidate], white: true, evaluator: small), isNull);

      final engine = _FakeEvaluator({before: const PositionEval(220, 'f7g8')});
      expect(await OpeningImprovementService.findMistake([candidate], white: true, evaluator: engine), isNull);
      // Position suivante pas demandée.
      expect(engine.asked, [before]);
    });

    test('noirs : évaluation inversée ; classement perte × fréquence', () async {
      final start = _fenAfter(['e4', 'e5', 'd4']);
      final nc6 = _fenAfter(['e4', 'e5', 'd4', 'Nc6']);
      final rare =
          OpeningCandidate(fen: start, san: 'Nc6', ply: 3, line: const ['e4', 'e5', 'd4'], count: 3, losses: 2);
      final evaluator = _FakeEvaluator({
        start: const PositionEval(-10, 'e5d4'),
        nc6: const PositionEval(70, 'd4d5'),
      });
      final mistake = await OpeningImprovementService.findMistake([rare], white: false, evaluator: evaluator);
      expect(mistake!.evalBefore, 10);
      expect(mistake.evalAfter, -70);
      expect(mistake.loss, 80);
      expect(mistake.bestSan, 'exd4');
    });

    test('roque au format Lichess (roi prend la tour)', () {
      final fen = _fenAfter(['e4', 'e5', 'Nf3', 'Nc6', 'Bc4', 'Bc5']);
      expect(OpeningImprovementService.moveFromUci(fen, 'e1h1')!.san, 'O-O');
      expect(OpeningImprovementService.moveFromUci(fen, 'e1g1')!.san, 'O-O');
    });
  });

  group('notation', () {
    test('coups numérotés et lettres des pièces traduites', () {
      expect(OpeningImprovementService.numbered(12, 'Bxg8'), '7.Bxg8');
      expect(OpeningImprovementService.numbered(3, 'Nc6', letters: 'CFTDR'), '2...Cc6');
      expect(OpeningImprovementService.formatLine(['e4', 'e5', 'Nf3'], letters: 'CFTDR'), '1.e4 e5 2.Cf3');
      expect(OpeningImprovementService.localizeSan('exd8=Q+', 'CFTDR'), 'exd8=D+');
      expect(OpeningImprovementService.localizeSan('O-O', 'CFTDR'), 'O-O');
    });
  });

  test('CloudEvalService.parse : centipions, mat et meilleur coup', () {
    expect(CloudEvalService.parse('{"pvs":[{"moves":"e7e5 g1f3","cp":18}]}')!.cp, 18);
    expect(CloudEvalService.parse('{"pvs":[{"moves":"e7e5 g1f3","cp":18}]}')!.bestUci, 'e7e5');
    expect(CloudEvalService.parse('{"pvs":[{"moves":"d8h4","mate":-1}]}')!.cp, -PositionEval.mateCp);
    expect(CloudEvalService.parse('{"pvs":[]}'), isNull);
  });
}
