import 'package:flutter/cupertino.dart';

class AppRouter {
  static Future<T?> push<T extends Object?>(BuildContext context, Widget page) async {
    return await Navigator.push<T>(
      context,
      CupertinoPageRoute(builder: (_) => page),
    );
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    TO? result,
  }) async {
    return await Navigator.pushReplacement<T, TO>(
      context,
      CupertinoPageRoute(builder: (_) => page),
      result: result,
    );
  }

  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Widget page, {
    bool Function(Route<dynamic>)? predicate,
  }) async {
    return await Navigator.pushAndRemoveUntil<T>(
      context,
      CupertinoPageRoute(builder: (_) => page),
      predicate ?? (route) => false,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }
}
