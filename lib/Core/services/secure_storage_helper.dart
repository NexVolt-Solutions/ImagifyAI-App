import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared encrypted store for tokens, cached user data, and other sensitive prefs.
class SecureStorageHelper {
  SecureStorageHelper._();

  static const FlutterSecureStorage store = FlutterSecureStorage();

  static Future<String?> read(String key) => store.read(key: key);

  static Future<void> write(String key, String value) =>
      store.write(key: key, value: value);

  static Future<void> delete(String key) => store.delete(key: key);

  static Future<bool?> readBool(String key) async {
    final s = await read(key);
    if (s == null) return null;
    if (s == 'true') return true;
    if (s == 'false') return false;
    return null;
  }

  static Future<void> writeBool(String key, bool value) =>
      write(key, value ? 'true' : 'false');

  static Future<int?> readInt(String key) async {
    final s = await read(key);
    if (s == null || s.isEmpty) return null;
    return int.tryParse(s);
  }

  static Future<void> writeInt(String key, int value) =>
      write(key, value.toString());
}
