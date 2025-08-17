import '../utils/responsive.dart';

extension ResponsiveExtension on int {
  double get w => Responsive.w(toDouble()); // width
  double get h => Responsive.h(toDouble()); // height
  double get f => Responsive.f(toDouble()); // font size
  double get d => Responsive.d(toDouble()); // diameter
  double get r => Responsive.r(toDouble()); // radius
}
