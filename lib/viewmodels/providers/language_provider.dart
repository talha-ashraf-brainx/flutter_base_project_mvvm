import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../config/languages/language.dart';
import '../../config/languages/language_config.dart';
import '../../data/repositories/local/language.dart';

class LanguageProvider with ChangeNotifier {
  final List<Language> languages = LanguageConfig.languages;
  late Language selectedLanguage;
  final LanguageRepo _languageRepo;

  LanguageProvider(this._languageRepo) {
    selectedLanguage = _languageRepo.getLanguage();
  }

  void setLanguage(BuildContext context, Language language) async {
    context.setLocale(language.locale);
    selectedLanguage = language;
    await _languageRepo.setLanguage(language: language);

    notifyListeners();
  }
}
