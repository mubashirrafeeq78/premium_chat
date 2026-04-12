import 'dart:convert';
import 'package:http/http.dart' as http;

class Config {
  static const String _baseUrl = "https://paxochat.com"; 

  // آپ کے سرور پر موجود فائلوں کے اصل نام (اسپیلنگ چیک کر لی گئی ہے)
  static const String _LIST = """
    {save_msg > /save_massege}
    {load_msg > /load_massege}
    {delete_msg > /delete_massege}
  """;

  static Future<Map<String, dynamic>> send(String screenName, Map<String, dynamic> data) async {
    try {
      final RegExp regExp = RegExp('\{' + screenName + r'\s*>\s*([^}]+)\}');
      final match = regExp.firstMatch(_LIST);

      if (match != null) {
        String endpoint = match.group(1)!.trim();
        String finalUrl = _baseUrl + endpoint;
        return await _ApiService.directPost(finalUrl, data);
      } else {
        return {"status": "error", "message": "Mapping missing"};
      }
    } catch (e) {
      return {"status": "error", "message": "Gateway Error: $e"};
    }
  }
}

class _ApiService {
  static Future<Map<String, dynamic>> directPost(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Connection Failed"};
    }
  }
}
