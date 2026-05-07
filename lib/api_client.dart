import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? AppConfig.baseUrl;

  Uri _url(String path, [Map<String, String>? query]) {
    final uri = Uri.parse("$baseUrl$path");
    return query == null ? uri : uri.replace(queryParameters: query);
  }

  Map<String, dynamic> _parseJson(http.Response response) {
    final ct = (response.headers["content-type"] ?? "").toLowerCase();
    if (!ct.contains("application/json")) {
      throw Exception(
        "Invalid response (${response.statusCode}), not JSON",
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;

    throw Exception("Invalid JSON structure");
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    String? token,
    Map<String, String>? headers,
  }) async {
    final h = <String, String>{
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      ...?headers,
    };

    final res = await http
        .post(
          _url(path),
          headers: h,
          body: jsonEncode(body ?? {}),
        )
        .timeout(AppConfig.timeout);

    final json = _parseJson(res);
    if (res.statusCode >= 400) {
      throw Exception(json["message"] ?? "Request failed");
    }
    return json;
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
    String? token,
    Map<String, String>? headers,
  }) async {
    final h = <String, String>{
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      ...?headers,
    };

    final res = await http
        .get(_url(path, query), headers: h)
        .timeout(AppConfig.timeout);

    final json = _parseJson(res);
    if (res.statusCode >= 400) {
      throw Exception(json["message"] ?? "Request failed");
    }
    return json;
  }
}
