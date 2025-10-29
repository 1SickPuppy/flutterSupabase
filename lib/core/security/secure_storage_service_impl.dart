// lib/core/security/secure_storage_service_impl.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'secure_storage_service.dart'; // ⭐️ VIGTIGT: Tilføjet for at kende interfacet ⭐️

class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  static const String _encryptionKeyName = 'app_encryption_key';

  SecureStorageServiceImpl(this._secureStorage);

  @override
  Future<void> init() async {
    final keyString = await _getOrCreateEncryptionKey();
    final key = encrypt.Key.fromUtf8(keyString.padRight(32));
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  // ⭐️ RETTELSE 1: Sikrer at den altid returnerer en String (hvis null, returneres tom streng) ⭐️
  // Denne metode lover Future<String> (ikke nullable)
  Future<String> _getOrCreateEncryptionKey() async {
    String? existingKey = await _secureStorage.read(key: _encryptionKeyName);
    // Hvis nøglen ikke findes (null), returneres en tom streng, som derefter bruges til at oprette en ny nøgle.
    return existingKey ?? '';
  }

  @override
  Future<void> write({required String key, required String value}) async {
    final encrypted = _encrypter.encrypt(value, iv: _iv);
    await _secureStorage.write(key: key, value: encrypted.base64);
  }

  // ⭐️ RETTELSE 2: Tilføjer ? til returtypen for at matche interfacet ⭐️
  // Denne metode returnerer Future<String?> (nullable)
  @override
  Future<String?> read({required String key}) async {
    final encryptedValue = await _secureStorage.read(key: key);
    if (encryptedValue == null) return null;

    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedValue);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }
}