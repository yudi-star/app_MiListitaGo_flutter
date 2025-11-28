import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

class ThemeManager {
  static const _prefKey = 'isDarkMode';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_prefKey) ?? false;
    isDarkMode.value = value;
  }

  static Future<void> save(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    isDarkMode.value = value;
  }
}
