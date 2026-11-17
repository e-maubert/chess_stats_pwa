import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/game_phase_summary.dart';
import 'package:chess_stats_pwa/models/stats_period.dart';
import 'package:chess_stats_pwa/models/year_month.dart';
import 'package:chess_stats_pwa/services/game_phase_service.dart';
import 'package:chess_stats_pwa/services/game_phase_stats_service.dart';
import 'package:chess_stats_pwa/services/game_repository.dart';
import 'package:chess_stats_pwa/services/game_storage_policy.dart';
import 'package:chess_stats_pwa/services/game_store.dart';
import 'package:chess_stats_pwa/services/time_management_service.dart';
import 'package:chess_stats_pwa/services/monthly_games_source.dart';
import 'package:chess_stats_pwa/viewmodels/player_games_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

/// Coups au format chess.com, pendule après chaque demi-coup : 180 s moins
/// le numéro du demi-coup pour les blancs, 170 s moins ce numéro pour les
/// noirs.
String _pgn(List<String> sans) {
  final buffer = StringBuffer('[Event "Live Chess"]\n[White "a"]\n\n');
  for (final (index, san) in sans.indexed) {
    final ply = index + 1;
    final white = index.isEven;
    final seconds = (white ? 180 : 170) - ply;
    buffer.write('${index ~/ 2 + 1}${white ? '.' : '...'} $san {[%clk 0:0${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}]} ');
  }
  buffer.write('1-0');
  return buffer.toString();
}

/// Développement complet au 14e demi-coup (7... Bd7), rois roqués.
const _developed = ['Nf3', 'Nf6', 'g3', 'g6', 'Bg2', 'Bg7', 'O-O', 'O-O', 'Nc3', 'Nc6', 'd3', 'd6', 'Bd2', 'Bd7', 'a3'];

/// Échanges jusqu'à la finale (10... gxf6, 6 pièces), roi blanc jamais
/// déplacé : fin d'ouverture par la règle Lichess (7. Nxd4, 10 pièces).
const _traded = [
  'e4', 'e5', 'Nf3', 'Nc6', 'Bb5', 'a6', 'Bxc6', 'dxc6', 'd4', 'exd4', 'Qxd4', 'Qxd4', 'Nxd4', //
  'Bc5', 'Be3', 'Bxd4', 'Bxd4', 'Nf6', 'Bxf6', 'gxf6', 'Nc3', 'Rg8',
];

CountryGame _game({
  String result = 'win',
  String color = 'white',
  String? moves,
  GamePhaseSummary? phases,
  String? lossCause,
  DateTime? end,
  String url = 'u1',
}) =>
    CountryGame(
      opponent: 'bob',
      timeClass: 'blitz',
      result: result,
      playerColor: color,
      opening: 'Ruy-Lopez',
      lossCause: lossCause,
      baseTime: 180,
      endTime: end,
      url: url,
      moves: moves,
      phases: phases,
    );

class _NoSource implements MonthlyGamesSource {
  @override
  Future<Map<YearMonth, List<CountryGame>>> fetchMonths(String username, List<YearMonth> months) async =>
      {for (final month in months) month: const <CountryGame>[]};
}

void main() {
  group('GamePhaseService.analyze', () {
    test('fin de l\'ouverture quand pièces mineures et rois ont bougé', () {
      final phases = GamePhaseService.analyze(_pgn(_developed));
      expect(phases.plies, _developed.length);
      expect(phases.developedPly, 14);
      expect(phases.middlegamePly, 14);
      expect(phases.endgamePly, isNull);
    });

    test('règle Lichess en secours, finale à 6 pièces, matériel après l\'échange', () {
      final phases = GamePhaseService.analyze(_pgn(_traded));
      expect(phases.plies, _traded.length);
      expect(phases.developedPly, isNull);
      expect(phases.lichessMiddlegamePly, 13);
      expect(phases.middlegamePly, 13);
      // 10. Bxf6 laisse le fou blanc en f6 (7 pièces) : finale après 10... gxf6.
      expect(phases.endgamePly, 20);
      expect(phases.endgameType, 'rookMinor');
      // Mesuré après 11. Nc3 (pas juste après une prise).
      expect(phases.endgameMaterial, 0);
      expect(phases.clockAt(20, white: true), 180 - 19);
      expect(phases.clockAt(20, white: false), 170 - 20);
    });

    test('s\'arrête au premier coup illisible', () {
      expect(GamePhaseService.analyze('1. e4 {[%clk 0:03:00]} 1... e5 2. Zz9 1-0').plies, 2);
      // Coup illégal (pion en e7) : arrêt aussi.
      expect(GamePhaseService.analyze('1. e4 1... Ke7 2. d4 1-0').plies, 1);
    });

    test('types de finale', () {
      expect(GamePhaseService.endgameTypeOf({}), 'pawn');
      expect(GamePhaseService.endgameTypeOf({'b', 'n'}), 'minor');
      expect(GamePhaseService.endgameTypeOf({'r'}), 'rook');
      expect(GamePhaseService.endgameTypeOf({'r', 'b'}), 'rookMinor');
      expect(GamePhaseService.endgameTypeOf({'q'}), 'queen');
      expect(GamePhaseService.endgameTypeOf({'q', 'r'}), 'queenOther');
    });

    test('résumé vu des noirs : pendules et matériel inversés', () {
      final summary = GamePhaseService.summarize(_game(color: 'black', moves: _pgn(_traded)))!;
      expect(summary.endPhase, GamePhase.endgame);
      expect(summary.playerClockAtEndgame, 170 - 20);
      expect(summary.opponentClockAtEndgame, 180 - 19);
      expect(summary.playerClockAtMiddlegame, 170 - 12);
      expect(summary.endgameMaterial, 0);
      expect(GamePhaseService.summarize(_game()), isNull);
    });
  });

  group('GamePhaseStatsService', () {
    test('résultats par phase, temps restant, finales', () {
      const endgameUp = GamePhaseSummary(
        endPhase: GamePhase.endgame,
        playerClockAtMiddlegame: 150,
        opponentClockAtMiddlegame: 120,
        playerClockAtEndgame: 60,
        opponentClockAtEndgame: 30,
        endgameMaterial: 2,
        endgameType: 'rook',
      );
      const endgameDown = GamePhaseSummary(
        endPhase: GamePhase.endgame,
        playerClockAtMiddlegame: 90,
        opponentClockAtMiddlegame: 120,
        playerClockAtEndgame: 0,
        opponentClockAtEndgame: 60,
        endgameMaterial: -1,
        endgameType: 'rook',
      );
      final stats = GamePhaseStatsService.aggregate([
        _game(phases: endgameUp),
        _game(result: 'loss', lossCause: 'timeout', phases: endgameDown),
        _game(result: 'draw', phases: const GamePhaseSummary(endPhase: GamePhase.opening)),
        _game(), // phases inconnues : ignorée
      ]);
      expect(stats.games, 3);
      expect(stats.byEndPhase[GamePhase.opening]!.draws, 1);
      expect(stats.byEndPhase[GamePhase.endgame]!.timeoutLosses, 1);
      expect(stats.atMiddlegame!.player, closeTo(2 / 3, 1e-9));
      expect(stats.atMiddlegame!.opponent, closeTo(2 / 3, 1e-9));
      expect(stats.atEndgame!.player, closeTo(1 / 6, 1e-9));
      expect(stats.endgamesByMaterial[MaterialBalance.ahead]!.wins, 1);
      expect(stats.endgamesByMaterial[MaterialBalance.behind]!.losses, 1);
      expect(stats.endgamesByType.single.$1, 'rook');
      expect(GamePhaseStatsService.aggregate([_game(phases: endgameUp)], timeClass: 'bullet').games, 0);
    });
  });

  test('couleur du temps restant : écart de plus de 10 % du temps initial', () {
    expect(const ClockShares(player: 0.81, opponent: 0.76, games: 1).gap, TimeGap.balanced);
    expect(const ClockShares(player: 0.54, opponent: 0.40, games: 1).gap, TimeGap.ahead);
    expect(const ClockShares(player: 0.30, opponent: 0.45, games: 1).gap, TimeGap.behind);
  });

  group('Stockage des phases', () {
    const summary = GamePhaseSummary(endPhase: GamePhase.middlegame, endgameType: null);

    test('la fusion garde les phases déjà calculées', () {
      final merged = GameStoragePolicy.merge([_game(phases: summary)], [_game(moves: 'x')]);
      expect(merged.single.phases, isNotNull);
      expect(GameStoragePolicy.merge([_game(moves: 'a')], [_game(moves: 'b')]).single.moves, 'b');
    });

    test('savePhases enregistre les phases et retire les coups', () async {
      final store = GameStore(newDatabaseFactoryMemory());
      final month = YearMonth(2026, 11);
      await store.saveMonth(
        'alice',
        StoredMonth(month: month, fetchedAt: DateTime.utc(2026, 11, 17), games: [_game(moves: 'x'), _game(url: 'u2', moves: 'y')]),
      );
      final repository = GameRepository(store: store, source: _NoSource(), now: () => DateTime.utc(2026, 11, 17));
      await repository.savePhases('alice', {'u1': summary});
      final games = (await store.months('alice')).single.games;
      expect(games[0].phases?.endPhase, GamePhase.middlegame);
      expect(games[0].moves, isNull);
      expect(games[1].phases, isNull);
      expect(games[1].moves, 'y');
    });
  });

  test('PlayerGamesViewModel.phaseGamesIn : null pendant l\'analyse, puis les phases', () async {
    final now = DateTime.utc(2026, 11, 17, 12);
    final repository = GameRepository(store: GameStore(newDatabaseFactoryMemory()), source: _NoSource(), now: () => now);
    final viewModel = PlayerGamesViewModel(
      repository,
      'alice',
      initialGames: [
        _game(moves: _pgn(_traded), end: DateTime.utc(2026, 11, 10)),
        _game(url: 'u2', phases: const GamePhaseSummary(endPhase: GamePhase.opening), end: DateTime.utc(2026, 11, 11)),
      ],
      upToDate: true,
    );
    expect(viewModel.phaseGamesIn(StatsPeriod.oneMonth), isNull);
    await pumpEventQueue();
    final games = viewModel.phaseGamesIn(StatsPeriod.oneMonth)!;
    expect([for (final game in games) game.phases!.endPhase], [GamePhase.endgame, GamePhase.opening]);
    expect(identical(viewModel.phaseGamesIn(StatsPeriod.oneMonth), games), isTrue);
    viewModel.dispose();
  });
}
