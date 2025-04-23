abstract class LocalStorageManager {
  String? getString({required String key});
  Future<void> setString({required String key, required String value});

  Future<void> delete({required String key});
  Future<void> deleteAll();
}
