import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/view_constants.dart';
import '../../../core/resources/custom_exceptions.dart';
import '../../../core/resources/interceptors/retry_on_disconnect.dart';
import 'api_manager.dart';

class DioApiManager extends ApiManager {
  @override
  final String baseUrl;

  final Dio _dio = Dio();

  DioApiManager(this.baseUrl) {
    _dio.interceptors.add(
        RetryOnDisconnectInterceptor(dio: _dio, connectivity: Connectivity()));
  }

  @override
  Future<dynamic> get(String endpoint,
      {Map<String, String>? headers, Function(dynamic)? onCached}) async {
    final response = await _onRequest(
      endpoint,
      fetch: (url) async => await _dio.get(url,
          options: Options(headers: _mergeHeaders(headers))),
    );
    return response;
  }

  @override
  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Function(dynamic)? onCached,
  }) async {
    final response = await _onRequest(
      endpoint,
      fetch: (url) async => await _dio.post(
        url,
        data: jsonEncode(body),
        options: Options(headers: _mergeHeaders(headers)),
      ),
    );
    return response;
  }

  @override
  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Function(dynamic)? onCached,
  }) async {
    final response = await _onRequest(
      endpoint,
      fetch: (url) async => await _dio.put(
        url,
        data: jsonEncode(body),
        options: Options(headers: _mergeHeaders(headers)),
      ),
    );
    return response;
  }

  @override
  Future<dynamic> delete(String endpoint,
      {Map<String, String>? headers, Function(dynamic)? onCached}) async {
    final response = await _onRequest(
      endpoint,
      fetch: (url) async => await _dio.delete(
        url,
        options: Options(headers: _mergeHeaders(headers)),
      ),
    );
    return response;
  }

  @override
  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    Map<String, String>? headers,
    Function(int, int)? onProgress,
    String field = 'image',
    Function(dynamic)? onCached,
  }) async {
    final response = await _onRequest(
      endpoint,
      fetch: (url) async {
        final formData = FormData.fromMap({
          field: await MultipartFile.fromFile(file.path),
        });
        return await _dio.post(
          url,
          data: formData,
          options: Options(headers: _mergeHeaders(headers)),
          onSendProgress: (int sent, int total) =>
              onProgress?.call(sent, total),
        );
      },
    );
    return response;
  }

  Map<String, String> _mergeHeaders(Map<String, String>? customHeaders) {
    return {
      ...defaultHeaders,
      if (customHeaders != null) ...customHeaders,
    };
  }

  Future<dynamic> _onRequest(String endpoint,
      {required Future<Response> Function(String url) fetch}) async {
    try {
      final url = '$baseUrl$endpoint';
      final response = await fetch(url);
      return _handleResponse(response);
    } on CustomException {
      rethrow;
    } on DioException catch (e) {
      _handleError(e.response);
    } catch (e, s) {
      _handleRestfulRequestException(e, s);
    }
  }

  dynamic _handleResponse(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return response.data;
    } else {
      if (response.data is! Map) {
        _handleInvalidResponseException(
          response.statusCode,
          response.data,
          StackTrace.current,
          response.data,
          message: ViewConstants.issuePleaseTryAgain.tr(),
        );
      }
      _handleInvalidResponseException(
        response.statusCode,
        response.data['error'],
        StackTrace.current,
        response.data,
        message: response.data['message'],
      );
    }
  }

  void _handleError(
    Response? response, {
    List<String> messageKeys = const ['message', 'error'],
  }) {
    dynamic errorMessage;

    try {
      final data = response?.data;

      if (data is Map) {
        for (final key in messageKeys) {
          final value = data[key];

          if (value != null && value.toString().trim().isNotEmpty) {
            errorMessage = value;
            break;
          }
        }
      }
    } catch (e, s) {
      _handleInvalidResponseException(
        response?.statusCode,
        e,
        s,
        response?.data,
        message: ViewConstants.issuePleaseTryAgain.tr(),
      );
    }

    _handleErrorMessageFromServer(
      response?.statusCode,
      errorMessage,
    );
  }

  void _handleRestfulRequestException(Object? e, StackTrace? s) {
    throw CustomException(
      type: CustomExceptionType.restfulRequest,
      message: ViewConstants.serverError.tr(),
      error: e,
      stackTrace: s,
    );
  }

  void _handleInvalidResponseException(
      int? statusCode, Object? e, StackTrace? s, dynamic response,
      {required String message}) {
    throw CustomException(
      type: CustomExceptionType.invalidServerResponse,
      message: message,
      statusCode: statusCode,
      error: e,
      stackTrace: s,
      response: response,
    );
  }

  void _handleErrorMessageFromServer(int? statusCode, String message) {
    throw CustomException(
      type: CustomExceptionType.errorMessageFromServer,
      message: message,
      statusCode: statusCode,
    );
  }
}
