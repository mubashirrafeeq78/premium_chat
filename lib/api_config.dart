class ApiConfig {
  // 1. سرور کا مین ایڈریس (کل کو بدلنا ہو تو صرف یہاں بدلیں)
  static const String baseUrl = "https://paxochat.com";

  // 2. سیکیورٹی کی (جو Node.js بیک اینڈ میں ہے)
  static const String apiSecretKey = "PixoChat_Master_Secure_2026";

  // 3. ہیڈرز (جو ہر ریکویسٹ کے ساتھ خود بخود جائیں گے)
  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'x-api-key': apiSecretKey,
    };
  }
}
