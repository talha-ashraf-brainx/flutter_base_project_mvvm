import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'app_routes.dart';
import '../../views/splash.dart';
import '../../views/home.dart';
import '../../views/homepage.dart';
import '../../views/search.dart';
import '../../views/settings.dart';
import '../../views/camera.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;

    if (routeName == AppRoutes.splash.path) {
      return CupertinoPageRoute(
        builder: (_) => const Splash(),
        settings: settings,
      );
    } else if (routeName == AppRoutes.home.path) {
      return CupertinoPageRoute(
        builder: (_) => const Home(),
        settings: settings,
      );
    } else if (routeName == AppRoutes.homepage.path) {
      return CupertinoPageRoute(
        builder: (_) => const Homepage(),
        settings: settings,
      );
    } else if (routeName == AppRoutes.search.path) {
      return CupertinoPageRoute(
        builder: (_) => const Search(),
        settings: settings,
      );
    } else if (routeName == AppRoutes.settings.path) {
      return CupertinoPageRoute(
        builder: (_) => const Settings(),
        settings: settings,
      );
    } else if (routeName == AppRoutes.camera.path) {
      final args = settings.arguments as Map<String, dynamic>?;
      final onImageCaptured = args?['onImageCaptured'] as Function(XFile)?;
      return CupertinoPageRoute(
        builder: (_) => CameraView(onImageCaptured: onImageCaptured),
        settings: settings,
      );
    } else {
      return CupertinoPageRoute(
        builder: (_) => const Splash(),
        settings: settings,
      );
    }
  }

  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    return await Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) async {
    return await Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) async {
    return await Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) async {
    return await Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }
}
