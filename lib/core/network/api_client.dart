import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_config.dart';

class ApiException implements Exception {
  ApiException({required this.statusCode, required this.code, required this.message, this.details});

  final int statusCode;
  final String code;
  final String message;
  final dynamic details;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String path) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.get(url, headers: _headers());
    return _parseResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.post(
      url,
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _parseResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.put(
      url,
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _parseResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await _client.delete(url, headers: _headers());
    return _parseResponse(response);
  }

  dynamic _parseResponse(http.Response response) {
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }
      throw ApiException(
        statusCode: response.statusCode,
        code: 'HTTP_ERROR',
        message: 'Server returned HTTP ${response.statusCode}',
      );
    }

    final dynamic body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    }

    if (body is Map<String, dynamic> && body.containsKey('error')) {
      final err = body['error'];
      throw ApiException(
        statusCode: response.statusCode,
        code: err['code'] ?? 'UNKNOWN_ERROR',
        message: err['message'] ?? 'An API error occurred',
        details: err['details'],
      );
    }

    if (body is Map<String, dynamic> && body.containsKey('detail')) {
      throw ApiException(
        statusCode: response.statusCode,
        code: 'HTTP_ERROR',
        message: body['detail'].toString(),
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      code: 'HTTP_ERROR',
      message: 'Server returned HTTP ${response.statusCode}',
    );
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
