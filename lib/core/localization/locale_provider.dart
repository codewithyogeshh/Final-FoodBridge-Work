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

  String get languageName {
    switch (_locale.languageCode) {
      case 'hi':
        return 'हिंदी';
      case 'mr':
        return 'मराठी';
      case 'en':
      default:
        return 'English';
    }
  }
}
