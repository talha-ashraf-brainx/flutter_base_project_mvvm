import '../utils/responsive.dart';

extension ResponsiveExtension on double {
  double get w => Responsive.w(this); // width
  double get h => Responsive.h(this); // height
  double get f => Responsive.f(this); // font size
  double get d => Responsive.d(this); // diameter
  double get r => Responsive.r(this); // radius
}
