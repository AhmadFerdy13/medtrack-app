import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';

/// Service HTTP wrapper yang menambahkan JWT token ke setiap request.
class ApiService {
  final SecureStorage _storage = SecureStorage();

  /// Membuat headers dengan token JWT.
  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// HTTP GET request.
  Future<Map<String, dynamic>> get(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  /// HTTP POST request.
  Future<Map<String, dynamic>> post(String url, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse(url),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// HTTP PUT request.
  Future<Map<String, dynamic>> put(String url, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      Uri.parse(url),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  /// HTTP DELETE request.
  Future<Map<String, dynamic>> delete(String url) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  /// Memproses response dan mengembalikan Map.
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: body['message'] ?? 'Terjadi kesalahan',
        errors: body['data'],
      );
    }
  }
}

/// Exception khusus untuk error API.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic errors;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() => message;
}
