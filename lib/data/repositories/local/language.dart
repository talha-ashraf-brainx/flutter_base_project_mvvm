import 'dart:convert';

import '../../../config/languages/language.dart';
import '../../../config/languages/language_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../managers/local/local_storage.dart';

class LanguageRepo {
  final LocalStorageManager _manager;
  const LanguageRepo(this._manager);

  Language getLanguage() {
    final String? storedLanguage =
        _manager.getString(key: AppConstants.language);
    if (storedLanguage == null) {
      return LanguageConfig.defaultLanguage;
    }
    return Language.fromJson(jsonDecode(storedLanguage));
  }

  Future<void> setLanguage({required Language language}) async {
    await _manager.setString(
        key: AppConstants.language, value: jsonEncode(language.toJson()));
  }
}
