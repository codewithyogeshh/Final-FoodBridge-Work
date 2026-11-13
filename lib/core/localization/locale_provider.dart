import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // Hindi
    Locale('mr'), // Marathi
  ];

  void setLocale(Locale newLocale) {
    if (supportedLocales.contains(newLocale) && _locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  void setLanguageCode(String code) {
    final target = supportedLocales.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => const Locale('en'),
    );
    setLocale(target);
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
