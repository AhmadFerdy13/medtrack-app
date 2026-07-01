import '../models/user_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/secure_storage.dart';

/// Repository untuk mengelola autentikasi.
class AuthRepository {
  final ApiService _apiService = ApiService();
  final SecureStorage _storage = SecureStorage();

  /// Registrasi user baru.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiService.post(
      ApiConstants.register,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return UserModel.fromJson(response['data']);
  }

  /// Login dan simpan token.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
    );
    // Simpan token JWT
    await _storage.saveToken(response['data']['token']);
    return UserModel.fromJson(response['data']['user']);
  }

  /// Mengambil profil user yang sedang login.
  Future<UserModel> getProfile() async {
    final response = await _apiService.get(ApiConstants.me);
    return UserModel.fromJson(response['data']);
  }

  /// Logout dan hapus token.
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logout);
    } catch (_) {
      // Tetap hapus token meskipun request gagal
    }
    await _storage.deleteToken();
  }

  /// Refresh token JWT.
  Future<UserModel> refreshToken() async {
    final response = await _apiService.get(ApiConstants.refresh);
    await _storage.saveToken(response['data']['token']);
    return UserModel.fromJson(response['data']['user']);
  }

  /// Cek apakah user sudah login (ada token).
  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }
}
