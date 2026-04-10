import 'dart:convert';
import 'package:http/http.dart' as http;

class Config {
  // 1. مین کنفیگریشن
  static const String _baseUrl = "https://paxochat.com";
  static const String _apiKey = "PixoChat_Master_Secure_2026";

  // 2. آپ کی میپنگ لسٹ (جوں کی توں)
  static const String _LIST = """
    {auth > /auth}
    {otp_verification > /verify-otp}
    {profile_setup > /register-new-user}
    {security_gateway > /security_getway} 
  """;

  // 3. مرکزی فنکشن (Gateway)
  static Future<Map<String, dynamic>> send(String screenName, Map<String, dynamic> data) async {
    try {
      final RegExp regExp = RegExp('\{' + screenName + r'\s*>\s*([^}]+)\}');
      final match = regExp.firstMatch(_LIST);

      if (match != null) {
        String endpoint = match.group(1)!.trim();
        String finalUrl = _baseUrl + endpoint;

        // نیچے موجود ApiService کے فنکشن کو اسی فائل میں کال کرنا
        return await _ApiService.directPost(finalUrl, data, _apiKey);
      } else {
        return {"status": "error", "message": "Mapping missing for: $screenName"};
      }
    } catch (e) {
      return {"status": "error", "message": "Gateway Error: $e"};
    }
  }
}

// 4. اندرونی سروس (اب کسی دوسری فائل کی ضرورت نہیں)
class _ApiService {
  static Future<Map<String, dynamic>> directPost(String url, Map<String, dynamic> data, String key) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $key", // سیکیورٹی کی ہیڈر میں
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"status": "error", "message": "Server Error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"status": "error", "message": "Network Error: $e"};
    }
  }
}
