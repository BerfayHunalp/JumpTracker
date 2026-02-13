import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'api_exceptions.dart';

class ApiClient {
  static const _baseUrl = 'https://ski-tracker-api.apexdiligence.workers.dev';

  final FlutterSecureStorage _storage;
  final http.Client _httpClient;

  ApiClient({
    FlutterSecureStorage? storage,
    http.Client? httpClient,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _httpClient = httpClient ?? http.Client();

  Future<String?> get token => _storage.read(key: 'jwt_token');

  Future<void> setToken(String token) =>
      _storage.write(key: 'jwt_token', value: token);

  Future<void> clearToken() => _storage.delete(key: 'jwt_token');

  Future<Map<String, String>> _headers() async {
    final t = await token;
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _httpClient.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _httpClient.patch(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Server error (${response.statusCode})',
        response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final message = data['error'] as String? ?? 'Unknown error';

    if (response.statusCode == 401) {
      throw UnauthorizedException(message);
    }
    if (response.statusCode == 404) {
      throw NotFoundException(message);
    }

    throw ApiException(message, response.statusCode);
  }
}
