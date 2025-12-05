import 'package:flutter/material.dart';

import 'language.dart';

/// To add a language in the app, add a translation in csv file placed in assets/translations
/// Then, add a key, local and label below.
/// Set a default language using defaultLanguage variable.
class LanguageConfig {
  static const String _english = 'english';

  // Keys
  static const List<String> _keys = [
    _english,
  ];

  // Locales
  static const Map<String, Locale> _locales = {
    _english: Locale('en', 'US'),
  };

  // Labels
  static const Map<String, String> _labels = {
    _english: "English",
  };

  static Language get defaultLanguage =>
      Language(name: _labels[_english]!, locale: _locales[_english]!);

  static List<Language> get languages => _keys
      .map((key) => Language(name: _labels[key]!, locale: _locales[key]!))
      .toList();
  static List<Locale> get locales => _locales.values.toList();
}
