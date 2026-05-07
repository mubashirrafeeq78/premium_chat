import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppStorage {
  static const _kToken = "token";
  static const _kPhone = "phone";
  static const _kUser = "user_json";

  static Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
  }

  static Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString(_kToken);
    return (t == null || t.isEmpty) ? null : t;
  }

  static Future<void> savePhone(String phone) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kPhone, phone);
  }

  static Future<String?> getPhone() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kPhone);
  }

  static Future<void> saveUser(UserModel user) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kUser, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(j);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kPhone);
    await sp.remove(_kUser);
  }
}