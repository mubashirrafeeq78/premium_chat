import 'api_service.dart';

class ApiGateway {
  // 1. مین کنفیگریشن (ڈومین اور سیکیورٹی کی)
  static const String _baseUrl = "https://paxochat.com";
  static const String _apiKey = "PixoChat_Master_Secure_2026";

  // 2. آپ کی پسندیدہ میپنگ لسٹ (بریکٹس کے ساتھ)
  static const String _LIST = """
    {auth_screen > /auth}
    {otp_verification > /verify-otp}
    {profile_setup > /register-new-user}
    {security_gateway > /security_getway}
    {provider_dashboard > /provider_dashboard}
  """;

  // 3. مرکزی فنکشن جو ڈیٹا بھیجے گا
  static Future<Map<String, dynamic>> send(String screenName, Map<String, dynamic> data) async {
    try {
      // لسٹ میں سے اینڈ پوائنٹ نکالنا
      final RegExp regExp = RegExp('\{' + screenName + r'\s*>\s*([^}]+)\}');
      final match = regExp.firstMatch(_LIST);

      if (match != null) {
        String endpoint = match.group(1)!.trim();
        
        // مکمل URL بنانا
        String finalUrl = _baseUrl + endpoint;

        // ApiService کو ڈیٹا، یو آر ایل اور کی بھیجنا
        return await ApiService.directPost(finalUrl, data, _apiKey);
      } else {
        return {"status": "error", "message": "Mapping missing for: $screenName"};
      }
    } catch (e) {
      return {"status": "error", "message": "Gateway Error: $e"};
    }
  }
}
