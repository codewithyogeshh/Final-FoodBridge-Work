import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/app_user.dart';

bool get _isTestEnv => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

class SessionStorageService {
  static const String _userSessionKey = 'foodbridge_user_session';
  final FlutterSecureStorage? _storage;
  final Map<String, String> _inMemoryFallback = {};

  SessionStorageService({FlutterSecureStorage? storage, bool useInMemoryOnly = false})
      : _storage = useInMemoryOnly ? null : (storage ?? const FlutterSecureStorage());

  Future<void> saveUserSession(AppUser user) async {
    final jsonString = jsonEncode(user.toJson());
    _inMemoryFallback[_userSessionKey] = jsonString;

    if (_isTestEnv) return;

    // 1. SharedPreferences (instant, ultra-reliable & persistent across device reboots)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userSessionKey, jsonString);
    } catch (_) {}

    // 2. FlutterSecureStorage (hardware encrypted)
    try {
      await _storage?.write(key: _userSessionKey, value: jsonString);
    } catch (_) {}
  }

  Future<AppUser?> getUserSession() async {
    // 1. In-memory check first (fastest)
    if (_inMemoryFallback.containsKey(_userSessionKey)) {
      try {
        final map = jsonDecode(_inMemoryFallback[_userSessionKey]!) as Map<String, dynamic>;
        return AppUser.fromJson(map);
      } catch (_) {}
    }

    if (_isTestEnv) return null;

    // 2. SharedPreferences check (instant & guaranteed across app restarts)
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userSessionKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        _inMemoryFallback[_userSessionKey] = jsonString;
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        return AppUser.fromJson(map);
      }
    } catch (_) {}

    // 3. FlutterSecureStorage fallback
    try {
      final jsonString = await _storage?.read(key: _userSessionKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        _inMemoryFallback[_userSessionKey] = jsonString;
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        return AppUser.fromJson(map);
      }
    } catch (_) {}

    return null;
  }

  Future<void> clearUserSession() async {
    _inMemoryFallback.remove(_userSessionKey);
    if (_isTestEnv) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userSessionKey);
    } catch (_) {}
    try {
      await _storage?.delete(key: _userSessionKey);
    } catch (_) {}
  }
}
