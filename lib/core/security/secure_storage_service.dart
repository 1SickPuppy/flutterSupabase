// lib/core/security/secure_storage_service.dart

// Dette løser typefejlen:
abstract class SecureStorageService {
  Future<void> init();
  Future<String?> read({required String key}); // VIGTIGT: String?
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
}