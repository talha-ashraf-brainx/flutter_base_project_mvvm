import 'package:flutter/material.dart';

import '../config.dart';
import 'base.dart';

class LightTheme implements BaseTheme {
  @override
  final Color primary = const Color(0xFF2DAE77);
  @override
  final Color onPrimary = const Color(0xFFFFFFFF);
  @override
  final Color background = const Color(0xFFF2F3F6);
  @override
  final Color primaryText = const Color(0xFF000000);
  @override
  final Color surface = const Color(0xFFFFFFFF);
  @override
  final Color onSurface = const Color(0xFF505B7D);
  @override
  final Color overlay = const Color(0xFF000000).withOpacity(0.1);

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
  final iconBackground = const Color(0xFFF2F3F6);
  @override
  final icon = const Color(0xFF5E6984);

  @override
  Color get tileTitle => const Color(0xFF000000);

  @override
  Color get switchThumb => const Color(0xFFFFFFFF);
}

class BottomNavBarColorsImpl implements BottomNavBarColors {
  @override
  Color get background => const Color(0xFF2DAE77).withOpacity(0.08);
  @override
  Color get foreground => const Color(0xFF2DAE77);
  @override
  Color get indicator => const Color(0xFF2DAE77);
}
