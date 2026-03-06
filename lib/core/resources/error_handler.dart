import 'dart:async';

import '../constants/view_constants.dart';
import '../utils/helpers.dart';
import 'custom_exceptions.dart';
import 'data_state.dart';

class ErrorHandler {
  static Future<DataState<T>> onNetworkRequest<T>({
    required Future<dynamic> Function() fetch,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final response = await fetch().timeout(
        timeout,
        onTimeout: () => throw TimeoutException(ViewConstants.requestTimeout),
      ) as T;
      return DataSuccess<T>(response);
    } on TimeoutException catch (e, s) {
      final errorMessage = e.message!;
      _showErrorInConsole(error: errorMessage, stackTrace: s);
      return DataFailed(errorMessage);
    } on CustomException catch (e, s) {
      final errorMessage = e.message;
      final errorToLog = e.error ?? errorMessage;
      _showErrorInConsole(error: errorToLog, stackTrace: e.stackTrace ?? s);
      return DataFailed(errorMessage);
    } catch (e, s) {
      final error = e.toString();
      _showErrorInConsole(error: error, stackTrace: s);
      return DataFailed(error);
    }
  }

  static void _showErrorInConsole<T>({
    error,
    stackTrace,
  }) {
    printLog('$error\n$stackTrace');
  }
}
