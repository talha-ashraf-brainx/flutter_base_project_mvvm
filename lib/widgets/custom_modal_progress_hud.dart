import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/providers/custom_modal_progress_hud.dart';
import '../viewmodels/theme_provider.dart';

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
        showOverlay(themeProvider),
      ],
    );
  }

  ValueListenableBuilder showOverlay(ThemeProvider themeProvider) {
    return ValueListenableBuilder(
        valueListenable: inAsyncCall ?? ValueNotifier(false),
        builder: (context, value, _) {
          if (!value) {
            return Consumer<CustomModalProgressHudProvider>(
                builder: (context, provider, _) {
              if (!provider.inAsyncCall) return const SizedBox();
              return overlay(themeProvider);
            });
          }
          return overlay(themeProvider);
        });
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
