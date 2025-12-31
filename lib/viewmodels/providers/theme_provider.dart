import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../config/theme/base.dart';
import '../../config/theme/dark.dart';
import '../../config/theme/light.dart';
import '../../data/repositories/local/theme.dart';

class ThemeProvider with ChangeNotifier {
  late BaseTheme baseTheme;
  late String themeType;
  final ThemeRepo _themeRepo;

  ThemeProvider(this._themeRepo) {
    final String type = _themeRepo.getTheme();
    baseTheme = type == Config.dark ? DarkTheme() : LightTheme();
    themeType = type;
  }

  void setTheme({required String theme}) async {
    if (theme == themeType) return;
    _themeRepo.setTheme(theme: theme);

    themeType = theme;
    if (theme == Config.dark) {
      baseTheme = DarkTheme();
    } else if (theme == Config.light) {
      baseTheme = LightTheme();
    }

    notifyListeners();
  }
}
