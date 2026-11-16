import '../models/country_game.dart';
import '../models/year_month.dart';

/// Source des parties d'un joueur, mois par mois. Aujourd'hui l'API
/// publique chess.com (ChessApiService) ; demain, éventuellement, un serveur
/// à nous, sans changer le reste de l'app.
abstract class MonthlyGamesSource {
  /// Parties de [username] pour chacun des [months]. Lève une exception si
  /// un mois n'a pas pu être téléchargé (joueur inconnu, réseau…).
  Future<Map<YearMonth, List<CountryGame>>> fetchMonths(String username, List<YearMonth> months);
}
