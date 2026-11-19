import 'package:chess_stats_pwa/services/recap_seen_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('bilan montré une seule fois par joueur, casse ignorée', () async {
    final service = RecapSeenService();
    expect(await service.hasSeen('Hikaru'), isFalse);

    await service.markSeen('Hikaru');
    expect(await service.hasSeen('hikaru'), isTrue);
    expect(await service.hasSeen(' HIKARU '), isTrue);
    // Les autres joueurs auront encore leur bilan.
    expect(await service.hasSeen('MagnusCarlsen'), isFalse);

    // Pas de doublon.
    await service.markSeen('hikaru');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('recap_seen_players'), ['hikaru']);
  });
}
