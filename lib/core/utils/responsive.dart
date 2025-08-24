import 'package:flutter/material.dart';
import 'dart:math';

import '../../config/config.dart';
import '../../main.dart';

class Responsive {
  static double w(double pixels) => _scaleWidth(pixels);
  static double h(double pixels) => _scaleHeight(pixels);
  static double d(double pixels) =>
      min(_scaleWidth(pixels), _scaleHeight(pixels));
  static double r(double pixels) => d(pixels) / 2;

  static double f(double pixels) {
    final (double w, double h) = _size();
    final (double dw, double dh) =
        (Config.designScreenWidth, Config.designScreenHeight);

    final deviceDiagonal = sqrt(w * w + h * h);
    final designDiagonal = sqrt(dw * dw + dh * dh);

    return (pixels / designDiagonal) * deviceDiagonal;
  }

  static double _scaleWidth(double pixels) {
    final (double w, _) = _size();
    return pixels * w / Config.designScreenWidth;
  }

  static double _scaleHeight(double pixels) {
    final (_, double h) = _size();
    return pixels * h / Config.designScreenHeight;
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
