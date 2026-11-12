import 'dart:io';

import 'package:chess_stats_pwa/l10n/app_localizations_en.dart';
import 'package:chess_stats_pwa/l10n/app_localizations_fr.dart';
import 'package:chess_stats_pwa/main.dart';
import 'package:chess_stats_pwa/services/changelog_service.dart';
import 'package:chess_stats_pwa/services/layout_service.dart';
import 'package:chess_stats_pwa/theme/app_theme.dart';
import 'package:chess_stats_pwa/viewmodels/changelog_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('LayoutService', () {
    test('une colonne sous 1000 px, deux au-delà', () {
      expect(LayoutService.columnCount(400), 1);
      expect(LayoutService.columnCount(999), 1);
      expect(LayoutService.columnCount(1000), 2);
      expect(LayoutService.columnCount(1920), 2);
    });

    test('répartit les cartes en gardant l\'ordre de lecture', () {
      expect(LayoutService.splitIntoColumns([1, 2, 3, 4, 5, 6], 2), [
        [1, 3, 5],
        [2, 4, 6],
      ]);
      expect(LayoutService.splitIntoColumns([1, 2, 3], 2), [
        [1, 3],
        [2],
      ]);
      expect(LayoutService.splitIntoColumns([1, 2, 3], 1), [
        [1, 2, 3],
      ]);
    });
  });

  test('titre de la barre du haut centré dans les deux thèmes', () {
    expect(AppTheme.light.appBarTheme.centerTitle, isTrue);
    expect(AppTheme.dark.appBarTheme.centerTitle, isTrue);
  });

  group('ChangelogService', () {
    test('la version actuelle est celle de pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final version = RegExp(r'^version:\s*([^+\s]+)', multiLine: true).firstMatch(pubspec)!.group(1);
      expect(ChangelogService.currentVersion, version);
    });

    test('versions de la plus récente à la plus ancienne, sans doublon', () {
      final entries = ChangelogService.entries;
      expect(entries.map((e) => e.version).toSet().length, entries.length);
      for (var i = 1; i < entries.length; i++) {
        expect(entries[i - 1].date.isBefore(entries[i].date), isFalse);
      }
    });

    test('chaque version a au moins une nouveauté, en anglais et en français', () {
      for (final entry in ChangelogService.entries) {
        expect(entry.changes(AppLocalizationsEn()), isNotEmpty);
        expect(entry.changes(AppLocalizationsFr()), isNotEmpty);
        expect(entry.changes(AppLocalizationsFr()).length, entry.changes(AppLocalizationsEn()).length);
      }
    });

    test('mémorise la dernière version consultée', () async {
      final service = ChangelogService();
      expect(await service.loadLastSeen(), isNull);
      await service.saveLastSeen('1.1.0');
      expect(await service.loadLastSeen(), '1.1.0');
    });
  });

  group('ChangelogViewModel', () {
    test('pastille tant que la version actuelle n\'a pas été consultée', () async {
      expect(ChangelogViewModel(null).hasUnseenChanges, isTrue);
      expect(ChangelogViewModel('0.9.0').hasUnseenChanges, isTrue);
      expect(ChangelogViewModel(ChangelogService.currentVersion).hasUnseenChanges, isFalse);
    });

    test('markSeen enlève la pastille et l\'enregistre', () async {
      final viewModel = ChangelogViewModel(null);
      var notified = 0;
      viewModel.addListener(() => notified++);
      await viewModel.markSeen();
      expect(viewModel.hasUnseenChanges, isFalse);
      expect(notified, 1);
      expect(await ChangelogService().loadLastSeen(), ChangelogService.currentVersion);
    });
  });

  testWidgets('pied de page : version, puis journal des nouveautés', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Version ${ChangelogService.currentVersion}'), findsOneWidget);
    await tester.tap(find.text('What\'s new'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Version ${ChangelogService.currentVersion} –'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
