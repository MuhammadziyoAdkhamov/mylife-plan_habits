import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _appDataKey = 'mylife_plan_app_data_v1';

  Future<Map<String, dynamic>?> loadAppData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_appDataKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveAppData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appDataKey, jsonEncode(data));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appDataKey);
  }
}
