import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _locale = const Locale('ar');
  late SharedPreferences _prefs;

  Locale get locale => _locale;
  
  String get languageCode => _locale.languageCode;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguage = _prefs.getString(_languageKey);
    
    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    await _prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }

  void toggleLanguage() async {
    final newLanguageCode = _locale.languageCode == 'en' ? 'ar' : 'en';
    await setLanguage(newLanguageCode);
  }
}
