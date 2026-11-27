import 'package:chess_stats_pwa/services/eval_store.dart';
import 'package:chess_stats_pwa/services/position_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  const fen = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
  const unknown = '8/8/8/8/8/8/8/K6k w - - 0 1';

  /// Client Lichess simulé : compte les demandes ; [unknown] inconnue.
  MockClient lichess(List<String> asked) => MockClient((request) async {
        final position = request.url.queryParameters['fen']!;
        asked.add(position);
        if (position == unknown) return http.Response('{}', 404);
        return http.Response('{"pvs":[{"moves":"e7e5 g1f3","cp":18}]}', 200);
      });

  test('évaluation gardée : plus de demande à Lichess à la visite suivante', () async {
    final factory = newDatabaseFactoryMemory();
    final asked = <String>[];

    final first = CloudEvalService(client: lichess(asked), store: EvalStore(factory));
    expect((await first.evaluate(fen))!.cp, 18);
    expect(asked, [fen]);

    // Nouvelle visite : nouveau service, même stockage.
    final second = CloudEvalService(client: lichess(asked), store: EvalStore(factory));
    final eval = await second.evaluate(fen);
    expect(eval!.cp, 18);
    expect(eval.bestUci, 'e7e5');
    expect(asked, [fen]);
  });

  test('position inconnue de Lichess : pas gardée, redemandée plus tard', () async {
    final factory = newDatabaseFactoryMemory();
    final asked = <String>[];
    expect(await CloudEvalService(client: lichess(asked), store: EvalStore(factory)).evaluate(unknown), isNull);
    expect(await CloudEvalService(client: lichess(asked), store: EvalStore(factory)).evaluate(unknown), isNull);
    expect(asked, [unknown, unknown]);
  });

  test('stockage : lecture, écriture, mat', () async {
    final store = EvalStore(newDatabaseFactoryMemory());
    expect(await store.get(fen), isNull);
    await store.put(fen, const PositionEval(-PositionEval.mateCp, null));
    final eval = await store.get(fen);
    expect(eval!.cp, -PositionEval.mateCp);
    expect(eval.bestUci, isNull);
  });
}
