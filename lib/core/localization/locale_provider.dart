import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _kLocalePrefKey = 'foodbridge_language_code';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // Hindi
    Locale('mr'), // Marathi
  ];

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_kLocalePrefKey);
      if (savedCode != null && savedCode.isNotEmpty) {
        final target = supportedLocales.firstWhere(
          (l) => l.languageCode == savedCode,
          orElse: () => const Locale('en'),
        );
        _locale = target;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale newLocale) async {
    if (supportedLocales.contains(newLocale) && _locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
      try {
        if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kLocalePrefKey, newLocale.languageCode);
      } catch (_) {}
    }
  }

  Future<void> setLanguageCode(String code, {String? userEmail}) async {
    final target = supportedLocales.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => const Locale('en'),
    );
    await setLocale(target);
    if (userEmail != null && userEmail.isNotEmpty) {
      try {
        if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
        final prefs = await SharedPreferences.getInstance();
        final userKey = 'foodbridge_language_${userEmail.toLowerCase().trim()}';
        await prefs.setString(userKey, code);
      } catch (_) {}
    }
  }

  Future<void> syncUserLanguage(String? userEmail) async {
    if (userEmail == null || userEmail.isEmpty) return;
    try {
      if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
      final prefs = await SharedPreferences.getInstance();
      final userKey = 'foodbridge_language_${userEmail.toLowerCase().trim()}';
      final savedUserLang = prefs.getString(userKey);
      if (savedUserLang != null && savedUserLang.isNotEmpty) {
        await setLanguageCode(savedUserLang);
      }
    } catch (_) {}
  }

  String get languageName {
    switch (_locale.languageCode) {
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'mr':
        return 'मराठी (Marathi)';
      case 'en':
      default:
        return 'English';
    }
  }

  String get shortName {
    switch (_locale.languageCode) {
      case 'hi':
        return 'हिंदी';
      case 'mr':
        return 'मराठी';
      case 'en':
      default:
        return 'EN';
    }
  }
}
