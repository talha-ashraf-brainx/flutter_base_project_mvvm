import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/router/app_router.dart';
import '../config/router/app_routes.dart';
import '../viewmodels/theme_provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        AppRouter.pushReplacementNamed(context, AppRoutes.home.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: themeProvider.baseTheme.background,
        child: Center(
          child: Text(
            'Splash',
            style: TextStyle(color: themeProvider.baseTheme.primaryText),
          ),
        ),
      ),
    );
  }
}
