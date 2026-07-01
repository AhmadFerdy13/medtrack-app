import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper untuk penyimpanan token JWT secara aman.
class SecureStorage {
  static const _tokenKey = 'jwt_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Menyimpan token JWT.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Mengambil token JWT. Mengembalikan null jika tidak ada.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Menghapus token JWT (saat logout).
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Mengecek apakah token tersimpan.
  Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }
}
