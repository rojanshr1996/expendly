import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../utils/app_logger.dart';

/// Secure Storage Service wrapping FlutterSecureStorage to safely persist
/// sensitive user data such as Security PINs, secret answers, auth tokens, and encryption keys.
@lazySingleton
class SecureStorageService {
  static const String keySecurityPin = 'security_pin';
  static const String keyMasterEncryptionKey = 'master_encryption_key';
  static const String keySecurityQuestion = 'security_question';
  static const String keySecurityAnswerHash = 'security_answer_hash';

  static const String keySecurityQuestion1 = 'security_question_1';
  static const String keySecurityAnswerHash1 = 'security_answer_hash_1';
  static const String keySecurityQuestion2 = 'security_question_2';
  static const String keySecurityAnswerHash2 = 'security_answer_hash_2';

  late final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage]) {
    _storage = storage ??
        const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );
  }

  /// Reads a secure value associated with [key]
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, stack) {
      AppLogger.e('SecureStorage read error for key: $key', e, stack);
      return null;
    }
  }

  /// Writes a key-value pair to secure storage
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.d('SecureStorage write successful for key: $key');
    } catch (e, stack) {
      AppLogger.e('SecureStorage write error for key: $key', e, stack);
      rethrow;
    }
  }

  /// Deletes a key from secure storage
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.d('SecureStorage deleted key: $key');
    } catch (e, stack) {
      AppLogger.e('SecureStorage delete error for key: $key', e, stack);
    }
  }

  /// Checks if a key exists in secure storage
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e, stack) {
      AppLogger.e('SecureStorage containsKey error for key: $key', e, stack);
      return false;
    }
  }

  /// Clears all stored values in secure storage
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.i('SecureStorage cleared all entries');
    } catch (e, stack) {
      AppLogger.e('SecureStorage clearAll error', e, stack);
    }
  }

  // Helper methods for Security PIN
  Future<String?> getSecurityPin() => read(keySecurityPin);

  Future<void> setSecurityPin(String? pin) async {
    if (pin == null || pin.isEmpty) {
      await delete(keySecurityPin);
    } else {
      await write(keySecurityPin, pin);
    }
  }

  // Helper methods for Master Encryption Key
  Future<String?> getMasterEncryptionKey() => read(keyMasterEncryptionKey);

  Future<void> setMasterEncryptionKey(String key) =>
      write(keyMasterEncryptionKey, key);

  // Helper methods for Security Recovery Question & Answer (Legacy Single)
  Future<String?> getSecurityQuestion() => read(keySecurityQuestion);

  Future<void> setSecurityQuestion(String question) =>
      write(keySecurityQuestion, question);

  Future<void> setSecurityAnswer(String answer) async {
    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final hash = sha256.convert(bytes).toString();
    await write(keySecurityAnswerHash, hash);
  }

  Future<bool> verifySecurityAnswer(String answer) async {
    final storedHash = await read(keySecurityAnswerHash);
    if (storedHash == null || storedHash.isEmpty) return false;

    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final inputHash = sha256.convert(bytes).toString();
    return storedHash == inputHash;
  }

  // Helper methods for Dual Security Questions (Max 2)
  Future<String?> getSecurityQuestion1() async =>
      (await read(keySecurityQuestion1)) ?? (await read(keySecurityQuestion));
  Future<void> setSecurityQuestion1(String question) =>
      write(keySecurityQuestion1, question);

  Future<void> setSecurityAnswer1(String answer) async {
    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final hash = sha256.convert(bytes).toString();
    await write(keySecurityAnswerHash1, hash);
  }

  Future<bool> verifySecurityAnswer1(String answer) async {
    final storedHash = (await read(keySecurityAnswerHash1)) ??
        (await read(keySecurityAnswerHash));
    if (storedHash == null || storedHash.isEmpty) return false;

    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final inputHash = sha256.convert(bytes).toString();
    return storedHash == inputHash;
  }

  Future<String?> getSecurityQuestion2() => read(keySecurityQuestion2);
  Future<void> setSecurityQuestion2(String question) =>
      write(keySecurityQuestion2, question);

  Future<void> setSecurityAnswer2(String answer) async {
    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final hash = sha256.convert(bytes).toString();
    await write(keySecurityAnswerHash2, hash);
  }

  Future<bool> verifySecurityAnswer2(String answer) async {
    final storedHash = await read(keySecurityAnswerHash2);
    if (storedHash == null || storedHash.isEmpty) return false;

    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final inputHash = sha256.convert(bytes).toString();
    return storedHash == inputHash;
  }

  Future<bool> hasSecurityAnswer() async {
    final hash1 = await read(keySecurityAnswerHash1);
    final hash2 = await read(keySecurityAnswerHash2);
    final legacyHash = await read(keySecurityAnswerHash);
    return (hash1 != null && hash1.isNotEmpty) ||
        (hash2 != null && hash2.isNotEmpty) ||
        (legacyHash != null && legacyHash.isNotEmpty);
  }
}
