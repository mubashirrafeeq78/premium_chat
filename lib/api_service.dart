import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  // یہ فنکشن کسی بھی فائل (جیسے auth.dart) سے ڈیٹا لے کر بیک اینڈ کو بھیجے گا
  static Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/$endpoint");

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(), // یہاں خودکار طریقے سے آپ کی خفیہ کی (Key) لگ جائے گی
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'سرور سے رابطہ نہیں ہو سکا: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'انٹرنیٹ کا مسئلہ: $e'};
    }
  }
}
