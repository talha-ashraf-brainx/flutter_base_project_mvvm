import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/providers/theme_provider.dart';

class CustomModalProgressHUD extends StatelessWidget {
  const CustomModalProgressHUD(
      {super.key,
      required this.child,
      this.inAsyncCall,
      this.overlayColor,
      this.height = double.maxFinite});

  final ValueNotifier<bool>? inAsyncCall;
  final Color? overlayColor;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    return Stack(
      children: [
        child,
        overlay(themeProvider),
      ],
    );
  }

  Container overlay(ThemeProvider themeProvider) {
    return Container(
      color: themeProvider.baseTheme.overlay,
      height: height,
      child: Center(
        child: CircularProgressIndicator(
          color: themeProvider.baseTheme.primary,
        ),
      ),
    );
  }
}
