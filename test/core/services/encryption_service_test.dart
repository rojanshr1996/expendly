import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/services/encryption_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read(String key) async => _storage[key];

  @override
  Future<void> write(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async => _storage.containsKey(key);

  @override
  Future<void> clearAll() async => _storage.clear();

  @override
  Future<String?> getSecurityPin() async => read(SecureStorageService.keySecurityPin);

  @override
  Future<void> setSecurityPin(String? pin) async {
    if (pin == null || pin.isEmpty) {
      await delete(SecureStorageService.keySecurityPin);
    } else {
      await write(SecureStorageService.keySecurityPin, pin);
    }
  }

  @override
  Future<String?> getMasterEncryptionKey() async => read(SecureStorageService.keyMasterEncryptionKey);

  @override
  Future<void> setMasterEncryptionKey(String key) async => write(SecureStorageService.keyMasterEncryptionKey, key);

  @override
  Future<String?> getSecurityQuestion() async => read(SecureStorageService.keySecurityQuestion);

  @override
  Future<void> setSecurityQuestion(String question) async => write(SecureStorageService.keySecurityQuestion, question);

  @override
  Future<void> setSecurityAnswer(String answer) async {
    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final hash = sha256.convert(bytes).toString();
    await write(SecureStorageService.keySecurityAnswerHash, hash);
  }

  @override
  Future<bool> verifySecurityAnswer(String answer) async {
    final storedHash = await read(SecureStorageService.keySecurityAnswerHash);
    if (storedHash == null || storedHash.isEmpty) return false;

    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final inputHash = sha256.convert(bytes).toString();
    return storedHash == inputHash;
  }

  @override
  Future<String?> getSecurityQuestion1() async => (await read(SecureStorageService.keySecurityQuestion1)) ?? (await read(SecureStorageService.keySecurityQuestion));

  @override
  Future<void> setSecurityQuestion1(String question) => write(SecureStorageService.keySecurityQuestion1, question);

  @override
  Future<void> setSecurityAnswer1(String answer) async {
    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final hash = sha256.convert(bytes).toString();
    await write(SecureStorageService.keySecurityAnswerHash1, hash);
  }

  @override
  Future<bool> verifySecurityAnswer1(String answer) async {
    final storedHash = (await read(SecureStorageService.keySecurityAnswerHash1)) ?? (await read(SecureStorageService.keySecurityAnswerHash));
    if (storedHash == null || storedHash.isEmpty) return false;

    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final inputHash = sha256.convert(bytes).toString();
    return storedHash == inputHash;
  }

  @override
  Future<String?> getSecurityQuestion2() async => read(SecureStorageService.keySecurityQuestion2);

  @override
  Future<void> setSecurityQuestion2(String question) => write(SecureStorageService.keySecurityQuestion2, question);

  @override
  Future<void> setSecurityAnswer2(String answer) async {
    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final hash = sha256.convert(bytes).toString();
    await write(SecureStorageService.keySecurityAnswerHash2, hash);
  }

  @override
  Future<bool> verifySecurityAnswer2(String answer) async {
    final storedHash = await read(SecureStorageService.keySecurityAnswerHash2);
    if (storedHash == null || storedHash.isEmpty) return false;

    final normalized = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalized);
    final inputHash = sha256.convert(bytes).toString();
    return storedHash == inputHash;
  }

  @override
  Future<bool> hasSecurityAnswer() async {
    final hash1 = await read(SecureStorageService.keySecurityAnswerHash1);
    final hash2 = await read(SecureStorageService.keySecurityAnswerHash2);
    final legacyHash = await read(SecureStorageService.keySecurityAnswerHash);
    return (hash1 != null && hash1.isNotEmpty) ||
        (hash2 != null && hash2.isNotEmpty) ||
        (legacyHash != null && legacyHash.isNotEmpty);
  }
}

void main() {
  setUpAll(() {
    AppConfig.initialize(
      const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Expendly Dev',
      ),
    );
  });

  late FakeSecureStorageService fakeSecureStorage;
  late EncryptionService encryptionService;

  setUp(() {
    fakeSecureStorage = FakeSecureStorageService();
    encryptionService = EncryptionService(fakeSecureStorage);
  });

  group('EncryptionService AES-256 Tests', () {
    test('Should generate and store master encryption key if none exists', () async {
      final key = await encryptionService.getOrCreateMasterKey();
      expect(key, isNotEmpty);

      final storedKey = await fakeSecureStorage.getMasterEncryptionKey();
      expect(storedKey, equals(key));
    });

    test('Should encrypt and decrypt string using master key accurately', () async {
      const originalText = '{"account": "Expendly Vault Data", "balance": 15000.50}';

      final encrypted = await encryptionService.encryptString(originalText);
      expect(encrypted, contains(':'));
      expect(encrypted, isNot(equals(originalText)));

      final decrypted = await encryptionService.decryptString(encrypted);
      expect(decrypted, equals(originalText));
    });

    test('Should encrypt and decrypt string using custom passphrase', () async {
      const originalText = 'Secret user financial export payload';
      const passphrase = 'UserPassphrase#2026';

      final encrypted = await encryptionService.encryptString(originalText, customKeyOrPassphrase: passphrase);
      expect(encrypted, isNot(equals(originalText)));

      final decrypted = await encryptionService.decryptString(encrypted, customKeyOrPassphrase: passphrase);
      expect(decrypted, equals(originalText));
    });
  });
}
