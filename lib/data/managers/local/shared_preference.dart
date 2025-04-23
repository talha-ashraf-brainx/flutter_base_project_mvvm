import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage.dart';

class SharedPreferenceManager implements LocalStorageManager {
  final SharedPreferences _preferences;
  const SharedPreferenceManager(this._preferences);

  @override
  String? getString({required String key}) {
    return _preferences.getString(key);
  }

  @override
  Future<void> setString({required String key, required String value}) async {
    await _preferences.setString(key, value);
  }

  @override
  Future<void> delete({required String key}) async {
    await _preferences.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    await _preferences.clear();
  }
}
