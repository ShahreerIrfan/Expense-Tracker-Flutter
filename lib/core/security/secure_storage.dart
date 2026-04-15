import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  static Future<void> savePin(int userId, String pin) async {
    final hashedPin = hashPin(pin);
    await write('pin_$userId', hashedPin);
  }

  static Future<bool> verifyPin(int userId, String pin) async {
    final storedHash = await read('pin_$userId');
    if (storedHash == null) return false;
    return storedHash == hashPin(pin);
  }

  static Future<void> saveLastActiveTime() async {
    await write('last_active', DateTime.now().toIso8601String());
  }

  static Future<DateTime?> getLastActiveTime() async {
    final value = await read('last_active');
    return value != null ? DateTime.parse(value) : null;
  }

  static Future<void> saveCurrentUserId(int userId) async {
    await write('current_user_id', userId.toString());
  }

  static Future<int?> getCurrentUserId() async {
    final value = await read('current_user_id');
    return value != null ? int.tryParse(value) : null;
  }
}
