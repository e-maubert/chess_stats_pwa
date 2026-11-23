/// Nom de l'ouverture désignée par le premier coup des blancs, ou par ce
/// coup et la réponse des noirs (ex. 1.e4 c5 = défense sicilienne), pour
/// nommer les coups conseillés dans « Comment battre ce joueur ».
///
/// Les noms sont des familles traduites dans les .arb (`openingFamilyName`,
/// voir OpeningNameService) ; null pour un coup sans nom courant.
class OpeningMoveNames {
  static const Map<String, String> _firstMoves = {
    'e4': 'Kings-Pawn',
    'd4': 'Queens-Pawn',
    'c4': 'English-Opening',
    'Nf3': 'Zukertort-Opening',
    'g3': 'Kings-Fianchetto',
    'b3': 'Nimzowitsch-Larsen',
    'f4': 'Birds-Opening',
    'b4': 'Polish-Opening',
  };

  static const Map<String, Map<String, String>> _replies = {
    'e4': {
      'e5': 'Open-Game',
      'c5': 'Sicilian-Defense',
      'e6': 'French-Defense',
      'c6': 'Caro-Kann',
      'd5': 'Scandinavian-Defense',
      'Nf6': 'Alekhines-Defense',
      'd6': 'Pirc-Defense',
      'g6': 'Modern-Defense',
      'Nc6': 'Nimzowitsch-Defense',
      'b6': 'Owens-Defense',
    },
    'd4': {
      'd5': 'Closed-Game',
      'Nf6': 'Indian-Game',
      'e6': 'Horwitz-Defense',
      'f5': 'Dutch-Defense',
      'g6': 'Modern-Defense',
      'c5': 'Old-Benoni',
      'e5': 'Englund-Gambit',
    },
    'c4': {
      'e5': 'Reversed-Sicilian',
      'c5': 'Symmetrical-English',
      'Nf6': 'Anglo-Indian',
    },
  };

  /// Nom du premier coup des blancs [move] (SAN, ex. 'd4').
  static String? firstMove(String move) => _firstMoves[move];

  /// Nom de la réponse [reply] des noirs au premier coup [first].
  static String? reply(String first, String reply) => _replies[first]?[reply];
}
