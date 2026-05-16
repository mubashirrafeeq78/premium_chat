class AppConfig {
  // 🔹 صرف یہی URL بدلیں گے جب بھی سرور چینج ہو
  static const String baseUrl =
      "https://paxochat.com";

  // 🔹 API timeout (slow internet کیلئے مناسب)
  static const Duration timeout = Duration(seconds: 20);
}
