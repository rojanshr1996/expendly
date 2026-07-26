import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:injectable/injectable.dart';

import '../utils/app_logger.dart';
import 'secure_storage_service.dart';

/// Encryption Service providing AES-256 encryption and decryption functionality
/// for exporting and importing sensitive user data.
@lazySingleton
class EncryptionService {
  final SecureStorageService _secureStorage;

  EncryptionService(this._secureStorage);

  /// Generates a random 256-bit (32-byte) AES key encoded as base64
  String generateRandomKeyBase64() {
    final key = encrypt_pkg.Key.fromSecureRandom(32);
    return key.base64;
  }

  /// Retrieves existing master encryption key or generates a new key securely stored in SecureStorage
  Future<String> getOrCreateMasterKey() async {
    final existingKey = await _secureStorage.getMasterEncryptionKey();
    if (existingKey != null && existingKey.isNotEmpty) {
      return existingKey;
    }

    final newKey = generateRandomKeyBase64();
    await _secureStorage.setMasterEncryptionKey(newKey);
    AppLogger.i(
        'EncryptionService: New AES-256 master key generated and stored in SecureStorage');
    return newKey;
  }

  /// Derives a 32-byte (256-bit) AES key from a text passphrase using SHA-256
  encrypt_pkg.Key keyFromPassphrase(String passphrase) {
    final bytes = utf8.encode(passphrase);
    final digest = sha256.convert(bytes);
    return encrypt_pkg.Key(Uint8List.fromList(digest.bytes));
  }

  /// Encrypts raw string payload into AES-256 ciphertext using master key or custom base64 key/passphrase.
  /// Format of returned string: `ivBase64:cipherTextBase64`
  Future<String> encryptString(String input,
      {String? customKeyOrPassphrase}) async {
    try {
      encrypt_pkg.Key aesKey;
      if (customKeyOrPassphrase != null && customKeyOrPassphrase.isNotEmpty) {
        // Try parsing base64 key, fallback to SHA-256 key derivation from passphrase
        try {
          final decoded = base64.decode(customKeyOrPassphrase);
          if (decoded.length == 32) {
            aesKey = encrypt_pkg.Key(decoded);
          } else {
            aesKey = keyFromPassphrase(customKeyOrPassphrase);
          }
        } catch (_) {
          aesKey = keyFromPassphrase(customKeyOrPassphrase);
        }
      } else {
        final masterKeyBase64 = await getOrCreateMasterKey();
        aesKey = encrypt_pkg.Key.fromBase64(masterKeyBase64);
      }

      final iv = encrypt_pkg.IV.fromSecureRandom(16);
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(aesKey,
            mode: encrypt_pkg.AESMode.cbc, padding: 'PKCS7'),
      );

      final encrypted = encrypter.encrypt(input, iv: iv);
      final result = '${iv.base64}:${encrypted.base64}';
      AppLogger.d(
          'EncryptionService: Data encrypted successfully using AES-256');
      return result;
    } catch (e, stack) {
      AppLogger.e('EncryptionService: Failed to encrypt string', e, stack);
      rethrow;
    }
  }

  /// Decrypts `ivBase64:cipherTextBase64` payload back to raw string using master key or custom passphrase.
  Future<String> decryptString(String encryptedPayload,
      {String? customKeyOrPassphrase}) async {
    try {
      final parts = encryptedPayload.split(':');
      if (parts.length != 2) {
        throw const FormatException(
            'Invalid AES payload format. Expected iv:ciphertext');
      }

      final iv = encrypt_pkg.IV.fromBase64(parts[0]);
      final cipherTextBase64 = parts[1];

      encrypt_pkg.Key aesKey;
      if (customKeyOrPassphrase != null && customKeyOrPassphrase.isNotEmpty) {
        try {
          final decoded = base64.decode(customKeyOrPassphrase);
          if (decoded.length == 32) {
            aesKey = encrypt_pkg.Key(decoded);
          } else {
            aesKey = keyFromPassphrase(customKeyOrPassphrase);
          }
        } catch (_) {
          aesKey = keyFromPassphrase(customKeyOrPassphrase);
        }
      } else {
        final masterKeyBase64 = await getOrCreateMasterKey();
        aesKey = encrypt_pkg.Key.fromBase64(masterKeyBase64);
      }

      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(aesKey,
            mode: encrypt_pkg.AESMode.cbc, padding: 'PKCS7'),
      );

      final decrypted = encrypter.decrypt(
        encrypt_pkg.Encrypted.fromBase64(cipherTextBase64),
        iv: iv,
      );
      AppLogger.d(
          'EncryptionService: Data decrypted successfully using AES-256');
      return decrypted;
    } catch (e, stack) {
      AppLogger.e('EncryptionService: Failed to decrypt string', e, stack);
      rethrow;
    }
  }
}
