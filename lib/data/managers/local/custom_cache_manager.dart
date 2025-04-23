import 'dart:async';
import 'dart:convert';

import 'local_storage.dart';

// Custom models must have a toJson method
class CustomCacheManager {
  final LocalStorageManager _localStorageManager;
  CustomCacheManager(this._localStorageManager);

  Future<void> setCache({
    required String key,
    required dynamic value,
  }) async {
    String type;
    dynamic storeValue;

    if (value is String) {
      type = 'String';
      storeValue = value;
    } else if (value is int) {
      type = 'int';
      storeValue = value.toString();
    } else if (value is double) {
      type = 'double';
      storeValue = value.toString();
    } else if (value is bool) {
      type = 'bool';
      storeValue = value.toString();
    } else if (value is BigInt) {
      type = 'BigInt';
      storeValue = value.toString();
    } else if (value is Map<String, dynamic>) {
      type = 'Map';
      storeValue = jsonEncode(value);
    } else if (value is Set) {
      if (value.isEmpty) {
        type = 'Set:dynamic';
        storeValue = jsonEncode([]);
      } else {
        final itemType = value.first.runtimeType.toString();
        type = 'Set:$itemType';
        storeValue = jsonEncode(value.map((e) {
          try {
            return e.toJson();
          } catch (_) {
            try {
              return jsonDecode(jsonEncode(e));
            } catch (_) {
              return e.toString();
            }
          }
        }).toList());
      }
    } else if (value is List) {
      if (value.isEmpty) {
        type = 'List:dynamic';
        storeValue = jsonEncode([]);
      } else {
        final itemType = value.first.runtimeType.toString();
        type = 'List:$itemType';
        storeValue = jsonEncode(value.map((e) {
          if (_isPrimitive(e)) {
            return e.toString();
          } else {
            try {
              return e.toJson();
            } catch (_) {
              try {
                return jsonDecode(jsonEncode(e));
              } catch (_) {
                return e.toString();
              }
            }
          }
        }).toList());
      }
    } else {
      final itemType = value.runtimeType.toString();
      type = itemType;
      try {
        storeValue = jsonEncode(value.toJson());
      } catch (e) {
        try {
          storeValue = jsonEncode(value);
        } catch (_) {
          storeValue = value.toString();
        }
      }
    }

    final jsonString = jsonEncode({'type': type, 'value': storeValue});
    await _localStorageManager.setString(key: key, value: jsonString);
  }

  T? getCache<T>({
    required String key,
    T Function(dynamic)? serialize,
  }) {
    String? jsonStr = _localStorageManager.getString(key: key);

    if (jsonStr == null) return null;

    final decoded = jsonDecode(jsonStr);
    final String type = decoded['type'];
    final dynamic value = decoded['value'];

    if (type == 'String') return value as T?;
    if (type == 'int') return int.tryParse(value) as T?;
    if (type == 'double') return double.tryParse(value) as T?;
    if (type == 'bool') return (value.toLowerCase() == 'true') as T?;
    if (type == 'BigInt') return BigInt.tryParse(value) as T?;
    if (type == 'Map') return jsonDecode(value) as T;

    if (type.startsWith('List:')) {
      final itemType = type.split(':')[1];
      final List list = jsonDecode(value);
      if (_isPrimitiveType(itemType)) {
        return list.map((e) => _parsePrimitive(itemType, e)).toList() as T;
      } else {
        return serialize?.call(list);
      }
    }

    if (type.startsWith('Set:')) {
      final itemType = type.split(':')[1];
      final List list = jsonDecode(value);
      if (_isPrimitiveType(itemType)) {
        return list.map((e) => _parsePrimitive(itemType, e)).toSet() as T;
      } else {
        final deserialized = serialize?.call(list);
        return deserialized is Set
            ? deserialized
            : (deserialized as List?)?.toSet() as T?;
      }
    }

    return serialize?.call(jsonDecode(value));
  }

  bool _isPrimitiveType(String type) =>
      type == 'int' ||
      type == 'double' ||
      type == 'bool' ||
      type == 'String' ||
      type == 'BigInt';

  dynamic _parsePrimitive(String type, dynamic value) {
    switch (type) {
      case 'int':
        return int.tryParse(value.toString());
      case 'double':
        return double.tryParse(value.toString());
      case 'bool':
        return value.toString().toLowerCase() == 'true';
      case 'String':
        return value.toString();
      case 'BigInt':
        return BigInt.tryParse(value.toString());
      default:
        return value;
    }
  }

  bool _isPrimitive(dynamic val) =>
      val is int ||
      val is double ||
      val is bool ||
      val is String ||
      val is BigInt;

  Future<void> deleteCache(String key) async {
    await _localStorageManager.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _localStorageManager.deleteAll();
  }
}
