import 'package:flutter/material.dart';
import 'dart:math';

import '../../config/config.dart';
import '../../main.dart';

class Responsive {
  static double w(double designWidthUnit) => _scaleWidth(designWidthUnit);
  static double h(double designHeightUnit) => _scaleHeight(designHeightUnit);
  static double d(double designUnit) =>
      min(_scaleWidth(designUnit), _scaleHeight(designUnit));
  static double r(double designUnit) => d(designUnit) / 2;

  static double f(
    double designFontSize, {
    double widthBreakpoint = 600.0,
    double heightBreakpoint = 900.0,
  }) {
    final (double w, double h) = _size();
    final cappedWidth = w > widthBreakpoint ? widthBreakpoint : w;
    final cappedHeight = h > heightBreakpoint ? heightBreakpoint : h;

    const designWidth = Config.designScreenWidth;
    const designHeight = Config.designScreenHeight;

    final designDiagonal =
        sqrt(designWidth * designWidth + designHeight * designHeight);
    final deviceDiagonal =
        sqrt(cappedWidth * cappedWidth + cappedHeight * cappedHeight);

    return (designFontSize / designDiagonal) * deviceDiagonal;
  }

  static double _scaleWidth(double designWidthUnit) {
    final (double w, _) = _size();
    return designWidthUnit * w / Config.designScreenWidth;
  }

  static double _scaleHeight(double designHeightUnit) {
    final (_, double h) = _size();
    return designHeightUnit * h / Config.designScreenHeight;
  }

  static (double w, double h) _size() {
    final context = navigatorKey.currentContext!;
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    final height = size.height - padding.vertical;
    final width = size.width - padding.horizontal;

    return (width, height);
  }
}
