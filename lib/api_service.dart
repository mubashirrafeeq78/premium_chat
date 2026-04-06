import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // آپ کی ڈومین کا بنیادی یو آر ایل (آخر میں سلیش نہ لگائیں)
  static const String baseUrl = "https://paxochat.com";
  
  // ماسٹر سیکیورٹی کی (یقینی بنائیں کہ یہ سرور والی ہی ہے)
  static const String apiKey = "PixoChat_Master_Secure_2026";

  static Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> body) async {
    // یو آر ایل بنانا
    final url = Uri.parse("$baseUrl/$endpoint");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "x-api-key": apiKey, 
          // نوٹ: یہاں سے Access-Control والا ہیڈر ہٹا دیا گیا ہے کیونکہ یہ سرور کا کام ہے
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15)); // ٹائم آؤٹ شامل کیا گیا ہے

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } 
      else {
        return {
          'status': 'error', 
          'message': 'سرور ایرر: ${response.statusCode}'
        };
      }
    } catch (e) {
      // اگر اب بھی Failed to fetch آئے تو سمجھ جائیں کہ مسئلہ صرف SSL کی وارننگ کا ہے
      return {
        'status': 'error', 
        'message': 'کنکشن کا مسئلہ: $e'
      };
    }
  }
}
