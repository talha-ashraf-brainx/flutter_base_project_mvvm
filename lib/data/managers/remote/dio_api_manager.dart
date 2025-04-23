import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/view_constants.dart';
import '../../../core/resources/custom_exceptions.dart';
import '../../../core/resources/interceptors/retry_on_disconnect.dart';
import '../local/custom_cache_manager.dart';
import 'api_manager.dart';

class DioApiManager extends ApiManager {
  @override
  final String baseUrl;

  @override
  final CustomCacheManager cacheManager;

  final Dio _dio = Dio();

  DioApiManager(this.baseUrl, this.cacheManager) {
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
      onCached: onCached,
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
      onCached: onCached,
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
      onCached: onCached,
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
      onCached: onCached,
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
      onCached: onCached,
    );
    return response;
  }

  Map<String, String> _mergeHeaders(Map<String, String>? customHeaders) {
    return {
      ...defaultHeaders,
      if (customHeaders != null) ...customHeaders,
    };
  }

  dynamic _handleResponse(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return response.data;
    } else {
      dynamic errorMessage;
      try {
        final decoded = response.data;
        // TODO: Add error message key from server here
        errorMessage = decoded['msg'] ?? decoded['error'];
      } catch (e, s) {
        _handleInvalidResponseException(
            response.statusCode ?? 0, e, s, response.data);
      }

      _handleErrorMessageFromServer(response.statusCode ?? 0, errorMessage);
    }
  }

  void _handleRestfulRequestException(Object error, StackTrace stackTrace) {
    throw RestfulRequestException(
        message: ViewConstants.serverError.tr(),
        error: error,
        stackTrace: stackTrace);
  }

  void _handleInvalidResponseException(
      int statusCode, Object error, StackTrace stackTrace, dynamic response) {
    throw InvalidServerResponseException(
        statusCode: statusCode,
        message: ViewConstants.invalidResponse.tr(),
        error: error,
        stackTrace: stackTrace,
        response: response);
  }

  void _handleErrorMessageFromServer(int statusCode, String message) {
    throw ErrorMessageFromServer(statusCode: statusCode, message: message);
  }

  Future<dynamic> _onRequest(String endpoint,
      {required Future<Response> Function(String url) fetch,
      required Function(dynamic)? onCached}) async {
    try {
      final url = '$baseUrl$endpoint';
      final cachedData = cacheManager.getCache<dynamic>(key: url);
      if (cachedData != null) onCached?.call(cachedData);
      final response = await fetch(url);
      final data = _handleResponse(response);
      cacheManager.setCache(key: url, value: data);
      return data;
    } on InvalidServerResponseException {
      rethrow;
    } on ErrorMessageFromServer {
      rethrow;
    } catch (e, s) {
      _handleRestfulRequestException(e, s);
    }
  }
}
