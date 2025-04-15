import 'dart:async';

import '../../main.dart';
import 'custom_exceptions.dart';
import 'data_state.dart';

class ErrorHandler {
  static Future<DataState<T>> onNetworkRequest<T>({
    String? referrence,
    required Future<dynamic> Function() fetch,
  }) async {
    try {
      final response = await fetch() as T;
      return DataSuccess<T>(response);
    } on RestfulRequestException catch (e, s) {
      final errorMessage = e.message;
      _showErrorInConsole(
          referrence: referrence, error: e.error, stackTrace: s);
      return DataFailed(errorMessage);
    } on InvalidServerResponseException catch (e, s) {
      final errorMessage = e.message;
      _showErrorInConsole(
          referrence: referrence, error: e.error, stackTrace: s);
      return DataFailed(errorMessage);
    } on ErrorMessageFromServer catch (e, s) {
      final errorMessage = e.message;
      _showErrorInConsole(
          referrence: referrence, error: errorMessage, stackTrace: s);
      return DataFailed(errorMessage);
    } catch (e, s) {
      final error = e.toString();
      _showErrorInConsole(referrence: referrence, error: error, stackTrace: s);
      return DataFailed(error);
    }
  }

  static void _showErrorInConsole<T>({
    referrence,
    error,
    stackTrace,
  }) {
    logger.e(referrence, error: error, stackTrace: stackTrace);
  }
}
