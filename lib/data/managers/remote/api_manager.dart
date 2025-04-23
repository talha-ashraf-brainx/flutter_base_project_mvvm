import 'dart:io';

import '../local/custom_cache_manager.dart';

abstract class ApiManager {
  String get baseUrl;
  CustomCacheManager get cacheManager;

  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<dynamic> get(String endpoint,
      {Map<String, String>? headers, Function(dynamic)? onCached});

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Function(dynamic)? onCached,
  });

  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Function(dynamic)? onCached,
  });

  Future<dynamic> delete(String endpoint,
      {Map<String, String>? headers, Function(dynamic)? onCached});

  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    Map<String, String>? headers,
    Function(int, int)? onProgress,
    String field = '',
    Function(dynamic)? onCached,
  });
}
