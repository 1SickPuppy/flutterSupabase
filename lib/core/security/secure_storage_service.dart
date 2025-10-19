import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

// Interface for secure storage service (følger Interface Segregation Principle)
abstract class SecureStorageService {
  Future<void> init();
  Future<void> saveSecureData(String key, String value);
  Future<String?> getSecureData(String key);
  Future<void> deleteSecureData(String key);
}

// Implementation af secure storage service (følger Single Responsibility Principle)
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  SecureStorageServiceImpl(this._secureStorage);

  @override
  Future<void> init() async {
    // Generer eller hent krypteringsnøgle
    final keyString = await _getOrCreateEncryptionKey();
    final key = encrypt.Key.fromUtf8(keyString);
    _iv = encrypt.IV.fromLength(16); // 16 bytes IV for AES
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  Future<String> _getOrCreateEncryptionKey() async {
    // Tjek om vi allerede har en nøgle
    String? existingKey = await _secureStorage.read(key: 'encryption_key');
    
    if (existingKey != null) {
      return existingKey;
    }

    // Generer en ny tilfældig 32-byte nøgle, hvis ingen findes
    final key = encrypt.Key.fromSecureRandom(32);
    final keyString = key.base64;
    await _secureStorage.write(key: 'encryption_key', value: keyString);
    return keyString;
  }

  @override
  Future<void> saveSecureData(String key, String value) async {
    final encrypted = _encrypter.encrypt(value, iv: _iv);
    await _secureStorage.write(key: key, value: encrypted.base64);
  }

  @override
  Future<String?> getSecureData(String key) async {
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
  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }
}