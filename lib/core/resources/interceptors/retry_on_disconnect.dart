import 'dart:async';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RetryOnDisconnectInterceptor extends Interceptor {
  final Dio dio;
  final Connectivity connectivity;

  RetryOnDisconnectInterceptor({required this.dio, required this.connectivity});

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      await _waitForInternet();

      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown;
  }

  Future<void> _waitForInternet() async {
    final completer = Completer<void>();

    final subscription = connectivity.onConnectivityChanged.listen((status) {
      if (!status.contains(ConnectivityResult.none)) {
        completer.complete();
      }
    });

    final status = await connectivity.checkConnectivity();
    if (!status.contains(ConnectivityResult.none) && !completer.isCompleted) {
      completer.complete();
    }

    await completer.future;
    await subscription.cancel();
  }
}
