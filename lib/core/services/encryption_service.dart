import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:injectable/injectable.dart';
import 'package:pointycastle/export.dart' as pc;

import '../utils/app_logger.dart';
import 'secure_storage_service.dart';

/// Encryption Service providing AES-256 encryption and decryption.
/// Supports two payload formats:
/// - **v1** (legacy): AES-256-CBC with PKCS7 padding, key = SHA-256(passphrase). Format: `ivBase64:cipherTextBase64`
/// - **v2**: AES-256-GCM with PBKDF2-HMAC-SHA256 key derivation. Format: JSON with version, kdf params, iv, ciphertext, tag.
@lazySingleton
class EncryptionService {
  final SecureStorageService _secureStorage;

  EncryptionService(this._secureStorage);

  static const int _pbkdf2Iterations = 120000;
  static const int _saltLength = 16;
  static const int _ivLength = 12; // GCM standard nonce length
  static const int _keyLength = 32; // 256-bit key

  // ---------------------------------------------------------------------------
  // Key generation helpers
  // ---------------------------------------------------------------------------

  /// Generates a random 256-bit (32-byte) AES key encoded as base64.
  String generateRandomKeyBase64() {
    final key = encrypt_pkg.Key.fromSecureRandom(32);
    return key.base64;
  }

  /// Retrieves existing master encryption key or generates a new key
  /// securely stored in SecureStorage.
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

  /// Derives a 32-byte AES key from passphrase using simple SHA-256 (v1 legacy).
  encrypt_pkg.Key keyFromPassphrase(String passphrase) {
    final bytes = utf8.encode(passphrase);
    final digest = sha256.convert(bytes);
    return encrypt_pkg.Key(Uint8List.fromList(digest.bytes));
  }

  /// Derives a 32-byte AES key from passphrase using PBKDF2-HMAC-SHA256 (v2).
  Uint8List keyFromPassphrasePbkdf2(String passphrase, Uint8List salt,
      {int iterations = _pbkdf2Iterations}) {
    final pbkdf2 = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
      ..init(pc.Pbkdf2Parameters(salt, iterations, _keyLength));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(passphrase)));
  }

  Uint8List _generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
        List<int>.generate(length, (_) => random.nextInt(256)));
  }

  // ---------------------------------------------------------------------------
  // V2: AES-256-GCM with PBKDF2 (recommended for all new backups)
  // ---------------------------------------------------------------------------

  /// Encrypts plaintext with AES-256-GCM using PBKDF2-derived key from passphrase.
  /// Returns a JSON string containing version, KDF params, IV, ciphertext, and GCM auth tag.
  String encryptStringV2(String input, {required String passphrase}) {
    try {
      final salt = _generateSecureRandomBytes(_saltLength);
      final iv = _generateSecureRandomBytes(_ivLength);
      final keyBytes = keyFromPassphrasePbkdf2(passphrase, salt);

      final cipher = pc.GCMBlockCipher(pc.AESEngine())
        ..init(
          true,
          pc.AEADParameters(
            pc.KeyParameter(keyBytes),
            128, // tag length in bits
            iv,
            Uint8List(0), // no additional authenticated data
          ),
        );

      final plainBytes = Uint8List.fromList(utf8.encode(input));
      final cipherOutput = cipher.process(plainBytes);

      // GCM appends the 16-byte auth tag to the end of cipherOutput
      final ciphertext = cipherOutput.sublist(0, cipherOutput.length - 16);
      final tag = cipherOutput.sublist(cipherOutput.length - 16);

      final payload = jsonEncode({
        'version': 2,
        'kdf': {
          'algo': 'pbkdf2-sha256',
          'iterations': _pbkdf2Iterations,
          'salt': base64.encode(salt),
        },
        'cipher': 'aes-256-gcm',
        'iv': base64.encode(iv),
        'ciphertext': base64.encode(ciphertext),
        'tag': base64.encode(tag),
      });

      AppLogger.d('EncryptionService: Data encrypted with AES-256-GCM (v2)');
      return payload;
    } catch (e, stack) {
      AppLogger.e('EncryptionService: v2 encryption failed', e, stack);
      rethrow;
    }
  }

  /// Decrypts a v2 AES-256-GCM JSON payload using PBKDF2-derived key from passphrase.
  /// Throws if auth tag verification fails (tampered data).
  String decryptStringV2(String encryptedJson, {required String passphrase}) {
    try {
      final Map<String, dynamic> payload = jsonDecode(encryptedJson);

      final kdf = payload['kdf'] as Map<String, dynamic>;
      final salt = base64.decode(kdf['salt'] as String);
      final iterations = kdf['iterations'] as int;
      final iv = base64.decode(payload['iv'] as String);
      final ciphertext = base64.decode(payload['ciphertext'] as String);
      final tag = base64.decode(payload['tag'] as String);

      final keyBytes = keyFromPassphrasePbkdf2(
        passphrase,
        Uint8List.fromList(salt),
        iterations: iterations,
      );

      final cipher = pc.GCMBlockCipher(pc.AESEngine())
        ..init(
          false,
          pc.AEADParameters(
            pc.KeyParameter(keyBytes),
            128,
            Uint8List.fromList(iv),
            Uint8List(0),
          ),
        );

      // Reconstruct input: ciphertext + tag
      final cipherInput = Uint8List(ciphertext.length + tag.length)
        ..setAll(0, ciphertext)
        ..setAll(ciphertext.length, tag);

      final decrypted = cipher.process(cipherInput);
      AppLogger.d('EncryptionService: Data decrypted with AES-256-GCM (v2)');
      return utf8.decode(decrypted);
    } catch (e, stack) {
      AppLogger.e('EncryptionService: v2 decryption failed', e, stack);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // V1: AES-256-CBC (legacy, kept for backward-compatible reads)
  // ---------------------------------------------------------------------------

  /// Encrypts raw string payload into AES-256-CBC ciphertext using master key or custom passphrase.
  /// Format of returned string: `ivBase64:cipherTextBase64`
  Future<String> encryptString(String input,
      {String? customKeyOrPassphrase}) async {
    try {
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

      final iv = encrypt_pkg.IV.fromSecureRandom(16);
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(aesKey,
            mode: encrypt_pkg.AESMode.cbc, padding: 'PKCS7'),
      );

      final encrypted = encrypter.encrypt(input, iv: iv);
      final result = '${iv.base64}:${encrypted.base64}';
      AppLogger.d(
          'EncryptionService: Data encrypted successfully using AES-256-CBC (v1)');
      return result;
    } catch (e, stack) {
      AppLogger.e('EncryptionService: v1 encryption failed', e, stack);
      rethrow;
    }
  }

  /// Decrypts `ivBase64:cipherTextBase64` payload back to raw string (v1 CBC).
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
          'EncryptionService: Data decrypted successfully using AES-256-CBC (v1)');
      return decrypted;
    } catch (e, stack) {
      AppLogger.e('EncryptionService: v1 decryption failed', e, stack);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Auto-detect version and decrypt
  // ---------------------------------------------------------------------------

  /// Detects the encryption version from the payload and decrypts accordingly.
  /// - If the payload starts with `{` and contains `"cipher"` or `"version": 2`, uses v2 GCM.
  /// - If the payload starts with `{` and contains `"app": "Expendly"` or database keys, treats as unencrypted JSON.
  /// - If payload contains `:`, treats as v1 CBC format (`ivBase64:cipherTextBase64`).
  Future<String> decryptAuto(String encryptedPayload,
      {String? passphrase}) async {
    final trimmed = encryptedPayload.trim();

    if (trimmed.startsWith('{')) {
      try {
        final parsed = jsonDecode(trimmed) as Map<String, dynamic>;
        if (parsed.containsKey('cipher') || parsed['version'] == 2) {
          if (passphrase == null || passphrase.isEmpty) {
            throw const FormatException(
                'V2 backup requires a passphrase (PIN) to decrypt.');
          }
          return decryptStringV2(trimmed, passphrase: passphrase);
        } else if (parsed['app'] == 'Expendly' ||
            parsed.containsKey('transactions') ||
            parsed.containsKey('categories')) {
          // Unencrypted raw Expendly JSON payload
          return trimmed;
        }
      } catch (e) {
        if (e is FormatException) rethrow;
        // Fall through to v1 / fallback check if JSON parse fails
      }
    }

    if (trimmed.contains(':')) {
      return decryptString(trimmed, customKeyOrPassphrase: passphrase);
    }

    throw const FormatException('Invalid or corrupted backup file format.');
  }
}
