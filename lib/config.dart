class AppConfig {
  // یہ لائن براؤزر کی سیکیورٹی (CORS) کو بائی پاس کرنے کے لیے ہے
  static const String _proxy = "https://corsproxy.io/?"; 

  // آپ کا اصل سرور یو آر ایل (پروکسی کے ساتھ جوڑ دیا گیا ہے)
  static const String baseUrl = "${_proxy}https://paxochat.com"; 

  // آپ کی مخصوص سیکیورٹی کی
  static const String apiKey = "PixoChat_Master_Secure_2026";

  // اینڈ پوائنٹس (بیک اینڈ کی فائلوں کے نام)
  static const String auth = "/auth";
  static const String verifyOtp = "/verify-otp";
  static const String profile_setup = "/register-new-user";
}
