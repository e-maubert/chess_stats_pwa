import 'package:flutter/material.dart';
import 'translations.dart';

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<Translations> load(Locale locale) async {
    return Translations(locale);
  }

  @override
  bool shouldReload(TranslationsDelegate old) => false;
} 