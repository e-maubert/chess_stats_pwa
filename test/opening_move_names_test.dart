import 'package:chess_stats_pwa/l10n/app_localizations_en.dart';
import 'package:chess_stats_pwa/l10n/app_localizations_fr.dart';
import 'package:chess_stats_pwa/services/opening_move_names.dart';
import 'package:chess_stats_pwa/services/opening_name_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('premier coup et réponse nommés', () {
    expect(OpeningMoveNames.firstMove('d4'), 'Queens-Pawn');
    expect(OpeningMoveNames.reply('d4', 'e6'), 'Horwitz-Defense');
    expect(OpeningMoveNames.reply('e4', 'c5'), 'Sicilian-Defense');
  });

  test('coup sans nom courant : null', () {
    expect(OpeningMoveNames.firstMove('h4'), isNull);
    expect(OpeningMoveNames.reply('d4', 'a6'), isNull);
    expect(OpeningMoveNames.reply('h4', 'e5'), isNull);
  });

  test('chaque nom est traduit en français et en anglais', () {
    final fr = AppLocalizationsFr();
    final en = AppLocalizationsEn();
    const moves = ['e4', 'd4', 'c4', 'Nf3', 'g3', 'b3', 'f4', 'b4'];
    const replies = ['e5', 'c5', 'e6', 'c6', 'd5', 'Nf6', 'd6', 'g6', 'Nc6', 'b6', 'f5'];
    final families = {
      for (final move in moves) OpeningMoveNames.firstMove(move),
      for (final first in moves)
        for (final reply in replies) OpeningMoveNames.reply(first, reply),
    }.whereType<String>();
    for (final family in families) {
      final key = OpeningNameService.key(family);
      final fallback = OpeningNameService.fallback(family);
      // Le français diffère toujours du nom anglais par défaut ; l'anglais
      // peut lui être identique (« English Opening »), mais jamais avec des
      // tirets retirés à tort (« Kings » au lieu de « King's »).
      expect(fr.openingFamilyName(key, fallback), isNot(fallback), reason: family);
      expect(en.openingFamilyName(key, fallback), isNot(contains('Kings ')), reason: family);
    }
  });
}
