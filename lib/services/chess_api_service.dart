import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country_game.dart';
import '../models/year_month.dart';
import 'eco_service.dart';
import 'game_phase_service.dart';
import 'loss_stats_service.dart';
import 'monthly_games_source.dart';
import 'playing_hours_service.dart';
import 'time_management_service.dart';

/// Parties d'un joueur téléchargées depuis les archives mensuelles de l'API
/// publique chess.com, transformées en [CountryGame] (sans le PGN). Le pays
/// des adversaires n'est pas cherché ici (un appel par adversaire) : il
/// l'est ensuite, pour la carte des pays (OpponentCountryService).
class ChessApiService implements MonthlyGamesSource {
  static const String baseUrl = 'https://api.chess.com/pub/player';
  final http.Client _client;

  ChessApiService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<Map<YearMonth, List<CountryGame>>> fetchMonths(String username, List<YearMonth> months) async {
    final player = username.toLowerCase();
    final archives = await Future.wait([for (final month in months) _fetchArchive(player, month)]);
    return {
      for (final (index, month) in months.indexed)
        month: [for (final game in archives[index]) _toCountryGame(game, player)],
    };
  }

  Future<List<dynamic>> _fetchArchive(String player, YearMonth month) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/$player/games/${month.year}/${month.month.toString().padLeft(2, '0')}'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load games of $player for ${month.key}');
    }
    return (json.decode(response.body)['games'] as List<dynamic>?) ?? const [];
  }

  static String _opponent(dynamic game, String username) {
    final isWhite = game['white']['username'].toString().toLowerCase() == username;
    return game[isWhite ? 'black' : 'white']['username'].toString();
  }

  CountryGame _toCountryGame(dynamic game, String username) {
    final isWhite = game['white']['username'].toString().toLowerCase() == username;
    final result = _getGameResult(game, isWhite);
    final opponentUsername = _opponent(game, username);
    final lossCause = result == 'loss'
        ? LossStatsService.lossCause(game[isWhite ? 'white' : 'black']['result']?.toString())
        : null;
    final baseTime = TimeManagementService.baseTime(game['time_control']?.toString());
    final clocks = TimeManagementService.lastClocks(game['pgn'] as String? ?? '');
    // Pendule absente pour une couleur qui n'a pas joué : temps initial.
    final whiteClock = clocks.white ?? baseTime?.toDouble();
    final blackClock = clocks.black ?? baseTime?.toDouble();
    return CountryGame(
      opponent: opponentUsername,
      timeClass: game['time_class']?.toString() ?? '',
      result: result,
      playerColor: isWhite ? 'white' : 'black',
      opening: _extractOpeningName(game),
      lossCause: lossCause,
      rating: (game[isWhite ? 'white' : 'black']['rating'] as num?)?.toInt(),
      endTime: game['end_time'] is num
          ? DateTime.fromMillisecondsSinceEpoch((game['end_time'] as num).toInt() * 1000)
          : null,
      startTime: PlayingHoursService.startTimeFromPgn(game['pgn'] as String? ?? ''),
      rated: game['rated'] as bool? ?? true,
      // Perdue au temps : notre pendule est à 0 (le PGN garde la valeur
      // après notre dernier coup).
      playerClock: lossCause == LossStatsService.timeout
          ? 0
          : (isWhite ? whiteClock : blackClock),
      opponentClock: isWhite ? blackClock : whiteClock,
      baseTime: baseTime,
      url: game['url'] as String?,
      // Coups gardés pour calculer les phases après l'affichage ; pas pour
      // les variantes (Chess960…), dont la position de départ diffère.
      moves: (game['rules'] ?? 'chess') == 'chess' ? GamePhaseService.moveText(game['pgn'] as String?) : null,
    );
  }

  String _getGameResult(Map<String, dynamic> game, bool isWhite) {
    final playerResult = isWhite ? game['white']['result'] : game['black']['result'];
    
    switch (playerResult) {
      case 'win':
        return 'win';
      case 'lose':
      case 'checkmated':
      case 'resigned':
      case 'timeout':
      case 'abandoned':
        return 'loss';
      case 'stalemate':
      case 'draw':
        return 'draw';
      default:
        return 'draw'; // Par défaut, on considère comme un match nul
    }
  }

  // Chess.com : le champ `eco` du JSON contient l'URL de l'ouverture
  // (ex. https://www.chess.com/openings/Sicilian-Defense-...), le vrai code ECO
  // (ex. "B43") se trouve dans l'en-tête PGN [ECO "B43"].
  String _extractOpeningName(Map<String, dynamic> game) {
    final pgn = game['pgn'] as String? ?? '';
    final ecoCode = RegExp(r'\[ECO "([A-E]\d{2})"\]').firstMatch(pgn)?.group(1);
    if (ecoCode != null) {
      final name = EcoService.familyOf(ecoCode);
      if (name != EcoService.unknown) return name;
    }

    // Repli : déduire le nom depuis l'URL de l'ouverture
    final ecoUrl = game['eco'] as String?;
    if (ecoUrl != null && ecoUrl.contains('/openings/')) {
      final slug = ecoUrl.split('/openings/').last;
      // Retirer la partie coups (ex. "...3.Nd2-h6") pour garder le nom
      final nameOnly = slug.split(RegExp(r'-?\d+\.')).first;
      if (nameOnly.isNotEmpty) return nameOnly;
    }

    return EcoService.unknown;
  }
}
