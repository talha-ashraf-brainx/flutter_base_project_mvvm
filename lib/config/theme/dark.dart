import 'package:flutter/material.dart';

import '../config.dart';
import 'base.dart';

class DarkTheme implements BaseTheme {
  @override
  final Color primary = const Color(0xFF2DAE77);
  @override
  final Color onPrimary = const Color(0xFFFFFFFF);
  @override
  final Color background = const Color(0xFF1E1E1E);
  @override
  final Color primaryText = const Color(0xFFFFFFFF);
  @override
  final Color surface = const Color(0xFF292E3A);
  @override
  final Color onSurface = const Color(0xFF8E9FC7);
  @override
  final Color overlay = const Color(0xFF000000).withOpacity(0.2);

  @override
  final SettingsColors settings = SettingsColorsImpl();
  @override
  final BottomNavBarColors bottomNavBar = BottomNavBarColorsImpl();

  @override
  late final ThemeData themeData = ThemeData(
      fontFamily: Config.fontFamily,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: primary));
}

class SettingsColorsImpl implements SettingsColors {
  @override
  final iconBackground = const Color(0xFF485166).withOpacity(0.32);
  @override
  final icon = const Color(0xFF98A6A0);

  @override
  Color get tileTitle => const Color(0xFFEEEEEF);

  @override
  Color get switchThumb => const Color(0xFF333836);
}

class BottomNavBarColorsImpl implements BottomNavBarColors {
  @override
  Color get background => const Color(0xFF343946).withOpacity(0.32);
  @override
  Color get foreground => const Color(0xFFFFFFFF);
  @override
  Color get indicator => const Color(0xFFC981C8);
}
