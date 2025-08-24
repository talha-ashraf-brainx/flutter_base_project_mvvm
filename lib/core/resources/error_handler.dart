import 'dart:async';

import 'package:flutter_base_project_mvvm/core/utils/helpers.dart';

import 'custom_exceptions.dart';
import 'data_state.dart';

class ErrorHandler {
  /// Handles network requests and catches common API-related exceptions gracefully.
  ///
  /// This method wraps your API calls in a consistent error-handling flow that:
  /// - Catches and classifies known exception types.
  /// - Returns a [DataState] to indicate success or failure.
  /// - Logs errors to the console for debugging.
  ///
  /// ---
  ///
  /// Parameters:
  ///
  /// [caller]
  /// - *(Optional)* A string representing the function or location that initiated the request.
  /// - Used for logging and debugging context.
  ///
  /// [fetch]
  /// - *(Required)* A function that returns a `Future` of the desired data.
  /// - Should represent the actual network/API call.
  ///
  /// ---
  ///
  /// Handles the following exceptions:
  ///
  /// - [RestfulRequestException]:
  ///   Thrown when a network request fails unexpectedly—e.g., no internet,
  ///   timeout, or non-200 HTTP status code with no valid error body.
  ///
  /// - [InvalidServerResponseException]:
  ///   Triggered when the server responds with a format that cannot be parsed correctly
  ///   (e.g., HTML page instead of JSON).
  ///
  /// - [ErrorMessageFromServer]:
  ///   A custom error thrown when the server intentionally returns a known failure
  ///   along with an informative error message (e.g., validation error).
  ///
  /// - [catch-all Exception]:
  ///   Catches any unanticipated exceptions and converts them into a generic failure message.
  ///
  /// ---
  ///
  /// Returns:
  /// - A [DataSuccess<T>] containing the parsed result on success.
  /// - A [DataFailed] with an error message on failure.
  static Future<DataState<T>> onNetworkRequest<T>({
    required Future<dynamic> Function() fetch,
  }) async {
    try {
      final response = await fetch() as T;
      return DataSuccess<T>(response);
    } on RestfulRequestException catch (e, s) {
      final errorMessage = e.message;
      _showErrorInConsole(error: e.error, stackTrace: s);
      return DataFailed(errorMessage);
    } on InvalidServerResponseException catch (e, s) {
      final errorMessage = e.message;
      _showErrorInConsole(error: e.error, stackTrace: s);
      return DataFailed(errorMessage);
    } on ErrorMessageFromServer catch (e, s) {
      final errorMessage = e.message;
      _showErrorInConsole(error: errorMessage, stackTrace: s);
      return DataFailed(errorMessage);
    } catch (e, s) {
      final error = e.toString();
      _showErrorInConsole(error: error, stackTrace: s);
      return DataFailed(error);
    }
  }

  /// Logs errors to the console with function context, error message, and stack trace.
  static void _showErrorInConsole<T>({
    error,
    stackTrace,
  }) {
    printLog('$error\n$stackTrace');
  }
}
