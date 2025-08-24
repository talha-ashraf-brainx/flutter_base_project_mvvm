import 'dart:async';
import 'dart:convert';

import 'local_storage.dart';

/// Lightweight key-value cache persisted on top of LocalStorageManager.
///
/// Values are stored as strings with metadata:
/// - savedAt: persisted timestamp (milliseconds since epoch)
/// - ttl: optional time-to-live (milliseconds). If null, the entry does not
///   auto-expire.
///
/// On read, attempts jsonDecode of the stored string; if decoding fails,
/// returns the raw string.
class CustomCacheManager {
  final LocalStorageManager _localStorageManager;
  CustomCacheManager(this._localStorageManager);

  /// Persist [value] under [key].
  ///
  /// - Non-strings are jsonEncoded when possible; otherwise value.toString()
  ///   is used.
  /// - [ttl]: if null, the entry never auto-expires; if provided, the entry is
  ///   considered fresh until (now - savedAt) > ttl.
  Future<void> setCache({
    required String key,
    required dynamic value,
    Duration? ttl,
  }) async {
    final String storedValue = value is String ? value : _safeJsonEncode(value);

    final jsonString = jsonEncode({
      'value': storedValue,
      'savedAt': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds,
    });
    await _localStorageManager.setString(key: key, value: jsonString);
  }

  /// Read cached value for [key].
  ///
  /// Freshness:
  /// - If a ttl was stored and it has expired, returns null unless
  ///   [allowExpired] is true.
  /// - If ttl was null at write-time, the entry is treated as non-expiring
  ///   (always fresh).
  ///
  /// Returns the parsed JSON if possible; otherwise returns the raw string.
  dynamic getCache({
    required String key,
    bool allowExpired = false,
  }) {
    final String? jsonStr = _localStorageManager.getString(key: key);
    if (jsonStr == null) return null;

    final Map<String, dynamic> decoded = jsonDecode(jsonStr);
    final int? savedAt = decoded['savedAt'];
    final int? ttl = decoded['ttl'];

    // Respect TTL when present. If ttl is null, the entry is non-expiring.
    if (!allowExpired && savedAt != null && ttl != null) {
      final int now = DateTime.now().millisecondsSinceEpoch;
      if (now - savedAt > ttl) return null;
    }

    final dynamic raw = decoded['value'];
    if (raw is! String) return raw;

    try {
      final dynamic parsed = jsonDecode(raw);
      return parsed;
    } catch (_) {
      return raw;
    }
  }

  Future<void> deleteCache(String key) async {
    await _localStorageManager.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _localStorageManager.deleteAll();
  }

  String _safeJsonEncode(dynamic value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      try {
        return jsonEncode(value.toString());
      } catch (_) {
        return value.toString();
      }
    }
  }
}
