import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chess_stats.dart';
import '../models/opening_stats.dart';
import '../models/country_stats.dart';
import '../models/color_stats.dart';
import '../models/country_game.dart';
import 'cache_service.dart';
import 'loss_stats_service.dart';

class ChessApiService {
  static const String baseUrl = 'https://api.chess.com/pub/player';
  final _cacheService = CacheService();

  Future<String> _getPlayerCountry(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/$username'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final countryUrl = data['country'] as String;
      return countryUrl.split('/').last; // Récupère le code pays (ex: 'FR', 'US', etc.)
    }
    return 'Unknown';
  }

  Future<ChessStats> getPlayerStats(String username) async {
    // Essayer de récupérer les données du cache
    final cachedStats = await _cacheService.getCachedStats(username);
    if (cachedStats != null) {
      return cachedStats;
    }

    // Si pas de cache valide, faire l'appel API
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    
    final response = await http.get(
      Uri.parse('$baseUrl/$username/games/$year/$month'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final stats = await _processGameData(data['games'], username.toLowerCase());
      
      // Mettre en cache les nouvelles données
      await _cacheService.cacheStats(username, stats);
      
      return stats;
    } else {
      throw Exception('Failed to load player stats');
    }
  }

  Future<void> clearCache(String username) async {
    await _cacheService.clearCache(username);
  }

  Future<String> _updateCountryStats(
    Map<String, CountryStats> stats, 
    String opponentUsername, 
    String result
  ) async {
    final country = await _getPlayerCountry(opponentUsername);
    
    if (!stats.containsKey(country)) {
      stats[country] = CountryStats(
        name: country,
        gamesPlayed: 0,
        gamesWon: 0,
        gamesLost: 0,
        gamesDrawn: 0,
      );
    }
    
    final countryStat = stats[country]!;
    countryStat.gamesPlayed++;
    switch (result) {
      case 'win':
        countryStat.gamesWon++;
        break;
      case 'loss':
        countryStat.gamesLost++;
        break;
      case 'draw':
        countryStat.gamesDrawn++;
        break;
    }
    return country;
  }

  Future<ChessStats> _processGameData(List<dynamic> games, String username) async {
    final openingStats = <String, OpeningStats>{};
    final countryStats = <String, CountryStats>{};
    final countryGames = <CountryGame>[];

    int whiteWins = 0;
    int whiteLosses = 0;
    int whiteDraws = 0;
    
    int blackWins = 0;
    int blackLosses = 0;
    int blackDraws = 0;

    for (var game in games) {
      final isWhite = game['white']['username'].toString().toLowerCase() == username;
      final result = _getGameResult(game, isWhite);
      final opponentUsername = game[isWhite ? 'black' : 'white']['username'].toString();
      
      // Update color-specific stats
      if (isWhite) {
        switch (result) {
          case 'win':
            whiteWins++;
            break;
          case 'loss':
            whiteLosses++;
            break;
          case 'draw':
            whiteDraws++;
            break;
        }
      } else {
        switch (result) {
          case 'win':
            blackWins++;
            break;
          case 'loss':
            blackLosses++;
            break;
          case 'draw':
            blackDraws++;
            break;
        }
      }

      // Update opening stats
      final openingName = _extractOpeningName(game);
      _updateOpeningStats(openingStats, openingName, result, isWhite ? 'white' : 'black');

      // Update country stats
      final country = await _updateCountryStats(countryStats, opponentUsername, result);
      countryGames.add(CountryGame(
        country: country,
        opponent: opponentUsername,
        timeClass: game['time_class']?.toString() ?? '',
        result: result,
        playerColor: isWhite ? 'white' : 'black',
        opening: openingName,
        lossCause: result == 'loss'
            ? LossStatsService.lossCause(game[isWhite ? 'white' : 'black']['result']?.toString())
            : null,
      ));
    }

    final whiteStats = ColorStats(
      wins: whiteWins,
      losses: whiteLosses,
      draws: whiteDraws,
    );

    final blackStats = ColorStats(
      wins: blackWins,
      losses: blackLosses,
      draws: blackDraws,
    );

    return ChessStats(
      username: username,
      whiteStats: whiteStats,
      blackStats: blackStats,
      openings: openingStats,
      countryStats: countryStats,
      countryGames: countryGames,
      totalGames: games.length,
      wins: whiteWins + blackWins,
      losses: whiteLosses + blackLosses,
      draws: whiteDraws + blackDraws,
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
      final name = _getOpeningName(ecoCode);
      if (name != 'Unknown-Opening') return name;
    }

    // Repli : déduire le nom depuis l'URL de l'ouverture
    final ecoUrl = game['eco'] as String?;
    if (ecoUrl != null && ecoUrl.contains('/openings/')) {
      final slug = ecoUrl.split('/openings/').last;
      // Retirer la partie coups (ex. "...3.Nd2-h6") pour garder le nom
      final nameOnly = slug.split(RegExp(r'-?\d+\.')).first;
      if (nameOnly.isNotEmpty) return nameOnly;
    }

    return 'Unknown-Opening';
  }

  void _updateOpeningStats(Map<String, OpeningStats> stats, String openingName, String result, String color) {
    if (!stats.containsKey(openingName)) {
      stats[openingName] = OpeningStats(name: openingName, played: 0, won: 0, color: color);
    }
    
    final openingStat = stats[openingName]!;
    openingStat.played++;
    if (result == 'win') openingStat.won++;
  }

  String _getOpeningName(String eco) {
    // Table de conversion des codes ECO en noms d'ouvertures
    final Map<String, String> ecoToName = {
      'A00': 'Anderssen-Opening',
      'A01': 'Nimzowitsch-Larsen-Attack',
      'A02': 'Birds-Opening',
      'A03': 'Birds-Opening',
      'A04': 'Reti-Opening',
      'A05': 'Reti-Opening',
      'A06': 'Reti-Opening',
      'A07': 'Kings-Indian-Attack',
      'A08': 'Kings-Indian-Attack',
      'A09': 'Reti-Accepted',
      'A10': 'English-Opening',
      'A11': 'English-Opening',
      'A12': 'English-Opening',
      'A13': 'English-Opening',
      'A14': 'English-Opening',
      'A15': 'English-Opening',
      'A16': 'English-Opening',
      'A17': 'English-Opening',
      'A18': 'English-Opening',
      'A19': 'English-Opening',
      'A20': 'English-Opening',
      'A21': 'English-Opening',
      'A22': 'English-Opening',
      'A23': 'English-Opening',
      'A24': 'English-Opening',
      'A25': 'English-Opening',
      'A26': 'English-Opening',
      'A27': 'English-Opening',
      'A28': 'English-Opening',
      'A29': 'English-Opening',
      'A30': 'English-Opening',
      'A31': 'English-Opening',
      'A32': 'English-Opening',
      'A33': 'English-Opening',
      'A34': 'English-Opening',
      'A35': 'English-Opening',
      'A36': 'English-Opening',
      'A37': 'English-Opening',
      'A38': 'English-Opening',
      'A39': 'English-Opening',
      'A40': 'Queens-Pawn-Game',
      'A41': 'Queens-Pawn-Game',
      'A42': 'Queens-Pawn-Game',
      'A43': 'Queens-Pawn-Game',
      'A44': 'Queens-Pawn-Game',
      'A45': 'Queens-Pawn-Game',
      'A46': 'Queens-Pawn-Game',
      'A47': 'Queens-Pawn-Game',
      'A48': 'Queens-Pawn-Game',
      'A49': 'Queens-Pawn-Game',
      'A50': 'Queens-Pawn-Game',
      'A51': 'Queens-Pawn-Game',
      'A52': 'Queens-Pawn-Game',
      'A53': 'Queens-Pawn-Game',
      'A54': 'Queens-Pawn-Game',
      'A55': 'Queens-Pawn-Game',
      'A56': 'Queens-Pawn-Game',
      'A57': 'Queens-Pawn-Game',
      'A58': 'Queens-Pawn-Game',
      'A59': 'Queens-Pawn-Game',
      'A60': 'Queens-Pawn-Game',
      'A61': 'Queens-Pawn-Game',
      'A62': 'Queens-Pawn-Game',
      'A63': 'Queens-Pawn-Game',
      'A64': 'Queens-Pawn-Game',
      'A65': 'Queens-Pawn-Game',
      'A66': 'Queens-Pawn-Game',
      'A67': 'Queens-Pawn-Game',
      'A68': 'Queens-Pawn-Game',
      'A69': 'Queens-Pawn-Game',
      'A70': 'Queens-Pawn-Game',
      'A71': 'Queens-Pawn-Game',
      'A72': 'Queens-Pawn-Game',
      'A73': 'Queens-Pawn-Game',
      'A74': 'Queens-Pawn-Game',
      'A75': 'Queens-Pawn-Game',
      'A76': 'Queens-Pawn-Game',
      'A77': 'Queens-Pawn-Game',
      'A78': 'Queens-Pawn-Game',
      'A79': 'Queens-Pawn-Game',
      'A80': 'Dutch-Defense',
      'A81': 'Dutch-Defense',
      'A82': 'Dutch-Defense',
      'A83': 'Dutch-Defense',
      'A84': 'Dutch-Defense',
      'A85': 'Dutch-Defense',
      'A86': 'Dutch-Defense',
      'A87': 'Dutch-Defense',
      'A88': 'Dutch-Defense',
      'A89': 'Dutch-Defense',
      'A90': 'Dutch-Defense',
      'A91': 'Dutch-Defense',
      'A92': 'Dutch-Defense',
      'A93': 'Dutch-Defense',
      'A94': 'Dutch-Defense',
      'A95': 'Dutch-Defense',
      'A96': 'Dutch-Defense',
      'A97': 'Dutch-Defense',
      'A98': 'Dutch-Defense',
      'A99': 'Dutch-Defense',
      'B00': 'Kings-Pawn-Game',
      'B01': 'Scandinavian-Defense',
      'B02': 'Alekhines-Defense',
      'B03': 'Alekhines-Defense',
      'B04': 'Alekhines-Defense',
      'B05': 'Alekhines-Defense',
      'B06': 'Robatsch-Defense',
      'B07': 'Pirc-Defense',
      'B08': 'Pirc-Defense',
      'B09': 'Pirc-Defense',
      'B10': 'Caro-Kann-Defense',
      'B11': 'Caro-Kann-Defense',
      'B12': 'Caro-Kann-Defense',
      'B13': 'Caro-Kann-Defense',
      'B14': 'Caro-Kann-Defense',
      'B15': 'Caro-Kann-Defense',
      'B16': 'Caro-Kann-Defense',
      'B17': 'Caro-Kann-Defense',
      'B18': 'Caro-Kann-Defense',
      'B19': 'Caro-Kann-Defense',
      'B20': 'Sicilian-Defense',
      'B21': 'Sicilian-Defense',
      'B22': 'Sicilian-Defense',
      'B23': 'Sicilian-Defense',
      'B24': 'Sicilian-Defense',
      'B25': 'Sicilian-Defense',
      'B26': 'Sicilian-Defense',
      'B27': 'Sicilian-Defense',
      'B28': 'Sicilian-Defense',
      'B29': 'Sicilian-Defense',
      'B30': 'Sicilian-Defense',
      'B31': 'Sicilian-Defense',
      'B32': 'Sicilian-Defense',
      'B33': 'Sicilian-Defense',
      'B34': 'Sicilian-Defense',
      'B35': 'Sicilian-Defense',
      'B36': 'Sicilian-Defense',
      'B37': 'Sicilian-Defense',
      'B38': 'Sicilian-Defense',
      'B39': 'Sicilian-Defense',
      'B40': 'Sicilian-Defense',
      'B41': 'Sicilian-Defense',
      'B42': 'Sicilian-Defense',
      'B43': 'Sicilian-Defense',
      'B44': 'Sicilian-Defense',
      'B45': 'Sicilian-Defense',
      'B46': 'Sicilian-Defense',
      'B47': 'Sicilian-Defense',
      'B48': 'Sicilian-Defense',
      'B49': 'Sicilian-Defense',
      'B50': 'Sicilian-Defense',
      'B51': 'Sicilian-Defense',
      'B52': 'Sicilian-Defense',
      'B53': 'Sicilian-Defense',
      'B54': 'Sicilian-Defense',
      'B55': 'Sicilian-Defense',
      'B56': 'Sicilian-Defense',
      'B57': 'Sicilian-Defense',
      'B58': 'Sicilian-Defense',
      'B59': 'Sicilian-Defense',
      'B60': 'Sicilian-Defense',
      'B61': 'Sicilian-Defense',
      'B62': 'Sicilian-Defense',
      'B63': 'Sicilian-Defense',
      'B64': 'Sicilian-Defense',
      'B65': 'Sicilian-Defense',
      'B66': 'Sicilian-Defense',
      'B67': 'Sicilian-Defense',
      'B68': 'Sicilian-Defense',
      'B69': 'Sicilian-Defense',
      'B70': 'Sicilian-Defense',
      'B71': 'Sicilian-Defense',
      'B72': 'Sicilian-Defense',
      'B73': 'Sicilian-Defense',
      'B74': 'Sicilian-Defense',
      'B75': 'Sicilian-Defense',
      'B76': 'Sicilian-Defense',
      'B77': 'Sicilian-Defense',
      'B78': 'Sicilian-Defense',
      'B79': 'Sicilian-Defense',
      'B80': 'Sicilian-Defense',
      'B81': 'Sicilian-Defense',
      'B82': 'Sicilian-Defense',
      'B83': 'Sicilian-Defense',
      'B84': 'Sicilian-Defense',
      'B85': 'Sicilian-Defense',
      'B86': 'Sicilian-Defense',
      'B87': 'Sicilian-Defense',
      'B88': 'Sicilian-Defense',
      'B89': 'Sicilian-Defense',
      'B90': 'Sicilian-Defense',
      'B91': 'Sicilian-Defense',
      'B92': 'Sicilian-Defense',
      'B93': 'Sicilian-Defense',
      'B94': 'Sicilian-Defense',
      'B95': 'Sicilian-Defense',
      'B96': 'Sicilian-Defense',
      'B97': 'Sicilian-Defense',
      'B98': 'Sicilian-Defense',
      'B99': 'Sicilian-Defense',
      'C00': 'French-Defense',
      'C01': 'French-Defense',
      'C02': 'French-Defense',
      'C03': 'French-Defense',
      'C04': 'French-Defense',
      'C05': 'French-Defense',
      'C06': 'French-Defense',
      'C07': 'French-Defense',
      'C08': 'French-Defense',
      'C09': 'French-Defense',
      'C10': 'French-Defense',
      'C11': 'French-Defense',
      'C12': 'French-Defense',
      'C13': 'French-Defense',
      'C14': 'French-Defense',
      'C15': 'French-Defense',
      'C16': 'French-Defense',
      'C17': 'French-Defense',
      'C18': 'French-Defense',
      'C19': 'French-Defense',
      'C20': 'Kings-Pawn-Game',
      'C21': 'Center-Game',
      'C22': 'Center-Game',
      'C23': 'Bishops-Opening',
      'C24': 'Bishops-Opening',
      'C25': 'Vienna-Game',
      'C26': 'Vienna-Game',
      'C27': 'Vienna-Game',
      'C28': 'Vienna-Game',
      'C29': 'Vienna-Game',
      'C30': 'Kings-Gambit',
      'C31': 'Kings-Gambit',
      'C32': 'Kings-Gambit',
      'C33': 'Kings-Gambit',
      'C34': 'Kings-Gambit',
      'C35': 'Kings-Gambit',
      'C36': 'Kings-Gambit',
      'C37': 'Kings-Gambit',
      'C38': 'Kings-Gambit',
      'C39': 'Kings-Gambit',
      'C40': 'Kings-Knights-Game',
      'C41': 'Philidor-Defense',
      'C42': 'Petrov-Defense',
      'C43': 'Petrov-Defense',
      'C44': 'Kings-Pawn-Game',
      'C45': 'Scotch-Game',
      'C46': 'Kings-Knights-Game',
      'C47': 'Four-Knights-Game',
      'C48': 'Four-Knights-Game',
      'C49': 'Four-Knights-Game',
      'C50': 'Giuoco-Piano',
      'C51': 'Giuoco-Piano',
      'C52': 'Giuoco-Piano',
      'C53': 'Giuoco-Piano',
      'C54': 'Giuoco-Piano',
      'C55': 'Two-Knights-Defense',
      'C56': 'Two-Knights-Defense',
      'C57': 'Two-Knights-Defense',
      'C58': 'Two-Knights-Defense',
      'C59': 'Two-Knights-Defense',
      'C60': 'Ruy-Lopez',
      'C61': 'Ruy-Lopez',
      'C62': 'Ruy-Lopez',
      'C63': 'Ruy-Lopez',
      'C64': 'Ruy-Lopez',
      'C65': 'Ruy-Lopez',
      'C66': 'Ruy-Lopez',
      'C67': 'Ruy-Lopez',
      'C68': 'Ruy-Lopez',
      'C69': 'Ruy-Lopez',
      'C70': 'Ruy-Lopez',
      'C71': 'Ruy-Lopez',
      'C72': 'Ruy-Lopez',
      'C73': 'Ruy-Lopez',
      'C74': 'Ruy-Lopez',
      'C75': 'Ruy-Lopez',
      'C76': 'Ruy-Lopez',
      'C77': 'Ruy-Lopez',
      'C78': 'Ruy-Lopez',
      'C79': 'Ruy-Lopez',
      'C80': 'Ruy-Lopez',
      'C81': 'Ruy-Lopez',
      'C82': 'Ruy-Lopez',
      'C83': 'Ruy-Lopez',
      'C84': 'Ruy-Lopez',
      'C85': 'Ruy-Lopez',
      'C86': 'Ruy-Lopez',
      'C87': 'Ruy-Lopez',
      'C88': 'Ruy-Lopez',
      'C89': 'Ruy-Lopez',
      'C90': 'Ruy-Lopez',
      'C91': 'Ruy-Lopez',
      'C92': 'Ruy-Lopez',
      'C93': 'Ruy-Lopez',
      'C94': 'Ruy-Lopez',
      'C95': 'Ruy-Lopez',
      'C96': 'Ruy-Lopez',
      'C97': 'Ruy-Lopez',
      'C98': 'Ruy-Lopez',
      'C99': 'Ruy-Lopez',
      'D00': 'Queens-Pawn-Game',
      'D01': 'Queens-Pawn-Game',
      'D02': 'Queens-Pawn-Game',
      'D03': 'Queens-Pawn-Game',
      'D04': 'Queens-Pawn-Game',
      'D05': 'Queens-Pawn-Game',
      'D06': 'Queens-Gambit',
      'D07': 'Queens-Gambit',
      'D08': 'Queens-Gambit',
      'D09': 'Queens-Gambit',
      'D10': 'Queens-Gambit',
      'D11': 'Queens-Gambit',
      'D12': 'Queens-Gambit',
      'D13': 'Queens-Gambit',
      'D14': 'Queens-Gambit',
      'D15': 'Queens-Gambit',
      'D16': 'Queens-Gambit',
      'D17': 'Queens-Gambit',
      'D18': 'Queens-Gambit',
      'D19': 'Queens-Gambit',
      'D20': 'Queens-Gambit',
      'D21': 'Queens-Gambit',
      'D22': 'Queens-Gambit',
      'D23': 'Queens-Gambit',
      'D24': 'Queens-Gambit',
      'D25': 'Queens-Gambit',
      'D26': 'Queens-Gambit',
      'D27': 'Queens-Gambit',
      'D28': 'Queens-Gambit',
      'D29': 'Queens-Gambit',
      'D30': 'Queens-Gambit',
      'D31': 'Queens-Gambit',
      'D32': 'Queens-Gambit',
      'D33': 'Queens-Gambit',
      'D34': 'Queens-Gambit',
      'D35': 'Queens-Gambit',
      'D36': 'Queens-Gambit',
      'D37': 'Queens-Gambit',
      'D38': 'Queens-Gambit',
      'D39': 'Queens-Gambit',
      'D40': 'Queens-Gambit',
      'D41': 'Queens-Gambit',
      'D42': 'Queens-Gambit',
      'D43': 'Queens-Gambit',
      'D44': 'Queens-Gambit',
      'D45': 'Queens-Gambit',
      'D46': 'Queens-Gambit',
      'D47': 'Queens-Gambit',
      'D48': 'Queens-Gambit',
      'D49': 'Queens-Gambit',
      'D50': 'Queens-Gambit',
      'D51': 'Queens-Gambit',
      'D52': 'Queens-Gambit',
      'D53': 'Queens-Gambit',
      'D54': 'Queens-Gambit',
      'D55': 'Queens-Gambit',
      'D56': 'Queens-Gambit',
      'D57': 'Queens-Gambit',
      'D58': 'Queens-Gambit',
      'D59': 'Queens-Gambit',
      'D60': 'Queens-Gambit',
      'D61': 'Queens-Gambit',
      'D62': 'Queens-Gambit',
      'D63': 'Queens-Gambit',
      'D64': 'Queens-Gambit',
      'D65': 'Queens-Gambit',
      'D66': 'Queens-Gambit',
      'D67': 'Queens-Gambit',
      'D68': 'Queens-Gambit',
      'D69': 'Queens-Gambit',
      'D70': 'Queens-Gambit',
      'D71': 'Queens-Gambit',
      'D72': 'Queens-Gambit',
      'D73': 'Queens-Gambit',
      'D74': 'Queens-Gambit',
      'D75': 'Queens-Gambit',
      'D76': 'Queens-Gambit',
      'D77': 'Queens-Gambit',
      'D78': 'Queens-Gambit',
      'D79': 'Queens-Gambit',
      'D80': 'Queens-Gambit',
      'D81': 'Queens-Gambit',
      'D82': 'Queens-Gambit',
      'D83': 'Queens-Gambit',
      'D84': 'Queens-Gambit',
      'D85': 'Queens-Gambit',
      'D86': 'Queens-Gambit',
      'D87': 'Queens-Gambit',
      'D88': 'Queens-Gambit',
      'D89': 'Queens-Gambit',
      'D90': 'Queens-Gambit',
      'D91': 'Queens-Gambit',
      'D92': 'Queens-Gambit',
      'D93': 'Queens-Gambit',
      'D94': 'Queens-Gambit',
      'D95': 'Queens-Gambit',
      'D96': 'Queens-Gambit',
      'D97': 'Queens-Gambit',
      'D98': 'Queens-Gambit',
      'D99': 'Queens-Gambit',
      'E00': 'Queens-Pawn-Game',
      'E01': 'Queens-Pawn-Game',
      'E02': 'Queens-Pawn-Game',
      'E03': 'Queens-Pawn-Game',
      'E04': 'Queens-Pawn-Game',
      'E05': 'Queens-Pawn-Game',
      'E06': 'Queens-Pawn-Game',
      'E07': 'Queens-Pawn-Game',
      'E08': 'Queens-Pawn-Game',
      'E09': 'Queens-Pawn-Game',
      'E10': 'Queens-Pawn-Game',
      'E11': 'Queens-Pawn-Game',
      'E12': 'Queens-Pawn-Game',
      'E13': 'Queens-Pawn-Game',
      'E14': 'Queens-Pawn-Game',
      'E15': 'Queens-Pawn-Game',
      'E16': 'Queens-Pawn-Game',
      'E17': 'Queens-Pawn-Game',
      'E18': 'Queens-Pawn-Game',
      'E19': 'Queens-Pawn-Game',
      'E20': 'Queens-Pawn-Game',
      'E21': 'Queens-Pawn-Game',
      'E22': 'Queens-Pawn-Game',
      'E23': 'Queens-Pawn-Game',
      'E24': 'Queens-Pawn-Game',
      'E25': 'Queens-Pawn-Game',
      'E26': 'Queens-Pawn-Game',
      'E27': 'Queens-Pawn-Game',
      'E28': 'Queens-Pawn-Game',
      'E29': 'Queens-Pawn-Game',
      'E30': 'Queens-Pawn-Game',
      'E31': 'Queens-Pawn-Game',
      'E32': 'Queens-Pawn-Game',
      'E33': 'Queens-Pawn-Game',
      'E34': 'Queens-Pawn-Game',
      'E35': 'Queens-Pawn-Game',
      'E36': 'Queens-Pawn-Game',
      'E37': 'Queens-Pawn-Game',
      'E38': 'Queens-Pawn-Game',
      'E39': 'Queens-Pawn-Game',
      'E40': 'Queens-Pawn-Game',
      'E41': 'Queens-Pawn-Game',
      'E42': 'Queens-Pawn-Game',
      'E43': 'Queens-Pawn-Game',
      'E44': 'Queens-Pawn-Game',
      'E45': 'Queens-Pawn-Game',
      'E46': 'Queens-Pawn-Game',
      'E47': 'Queens-Pawn-Game',
      'E48': 'Queens-Pawn-Game',
      'E49': 'Queens-Pawn-Game',
      'E50': 'Queens-Pawn-Game',
      'E51': 'Queens-Pawn-Game',
      'E52': 'Queens-Pawn-Game',
      'E53': 'Queens-Pawn-Game',
      'E54': 'Queens-Pawn-Game',
      'E55': 'Queens-Pawn-Game',
      'E56': 'Queens-Pawn-Game',
      'E57': 'Queens-Pawn-Game',
      'E58': 'Queens-Pawn-Game',
      'E59': 'Queens-Pawn-Game',
      'E60': 'Queens-Pawn-Game',
      'E61': 'Queens-Pawn-Game',
      'E62': 'Queens-Pawn-Game',
      'E63': 'Queens-Pawn-Game',
      'E64': 'Queens-Pawn-Game',
      'E65': 'Queens-Pawn-Game',
      'E66': 'Queens-Pawn-Game',
      'E67': 'Queens-Pawn-Game',
      'E68': 'Queens-Pawn-Game',
      'E69': 'Queens-Pawn-Game',
      'E70': 'Queens-Pawn-Game',
      'E71': 'Queens-Pawn-Game',
      'E72': 'Queens-Pawn-Game',
      'E73': 'Queens-Pawn-Game',
      'E74': 'Queens-Pawn-Game',
      'E75': 'Queens-Pawn-Game',
      'E76': 'Queens-Pawn-Game',
      'E77': 'Queens-Pawn-Game',
      'E78': 'Queens-Pawn-Game',
      'E79': 'Queens-Pawn-Game',
      'E80': 'Queens-Pawn-Game',
      'E81': 'Queens-Pawn-Game',
      'E82': 'Queens-Pawn-Game',
      'E83': 'Queens-Pawn-Game',
      'E84': 'Queens-Pawn-Game',
      'E85': 'Queens-Pawn-Game',
      'E86': 'Queens-Pawn-Game',
      'E87': 'Queens-Pawn-Game',
      'E88': 'Queens-Pawn-Game',
      'E89': 'Queens-Pawn-Game',
      'E90': 'Queens-Pawn-Game',
      'E91': 'Queens-Pawn-Game',
      'E92': 'Queens-Pawn-Game',
      'E93': 'Queens-Pawn-Game',
      'E94': 'Queens-Pawn-Game',
      'E95': 'Queens-Pawn-Game',
      'E96': 'Queens-Pawn-Game',
      'E97': 'Queens-Pawn-Game',
      'E98': 'Queens-Pawn-Game',
      'E99': 'Queens-Pawn-Game',
    };

    return ecoToName[eco] ?? 'Unknown-Opening';
  }
} 