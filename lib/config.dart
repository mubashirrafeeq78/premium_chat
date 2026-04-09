class AppConfig {
  static const String _proxy = "https://corsproxy.io/?"; 
  static const String baseUrl = "${_proxy}https://paxochat.com"; 
  static const String apiKey = "PixoChat_Master_Secure_2026";

  // اسے اب 'register-new-user' کر دیں کیونکہ آپ کی فائل کا نام یہی ہے
  static const String profileSetup = "/register-new-user";
  
  static const String auth = "/auth";
  static const String verifyOtp = "/verify-otp";
}
