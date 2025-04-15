import 'dart:io';

abstract class ApiManager {
  String get baseUrl;

  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<dynamic> get(String endpoint, {Map<String, String>? headers});

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  });

  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  });

  Future<dynamic> delete(String endpoint, {Map<String, String>? headers});

  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    Map<String, String>? headers,
    Function(int, int)? onProgress,
    String field = '',
  });
}
