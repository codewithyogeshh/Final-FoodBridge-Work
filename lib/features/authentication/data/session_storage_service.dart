import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/models/app_user.dart';

class SessionStorageService {
  static const String _userSessionKey = 'foodbridge_user_session';
  final FlutterSecureStorage? _storage;
  final Map<String, String> _inMemoryFallback = {};

  SessionStorageService({FlutterSecureStorage? storage, bool useInMemoryOnly = false})
      : _storage = useInMemoryOnly ? null : (storage ?? const FlutterSecureStorage());

  Future<void> saveUserSession(AppUser user) async {
    final jsonString = jsonEncode(user.toJson());
    _inMemoryFallback[_userSessionKey] = jsonString;
    try {
      await _storage?.write(key: _userSessionKey, value: jsonString);
    } catch (_) {
      // Secure storage fallback if unavailable in platform harness
    }
  }

  Future<AppUser?> getUserSession() async {
    try {
      final jsonString = (await _storage?.read(key: _userSessionKey)) ??
          _inMemoryFallback[_userSessionKey];
      if (jsonString != null && jsonString.isNotEmpty) {
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        return AppUser.fromJson(map);
      }
    } catch (_) {
      if (_inMemoryFallback.containsKey(_userSessionKey)) {
        final map = jsonDecode(_inMemoryFallback[_userSessionKey]!) as Map<String, dynamic>;
        return AppUser.fromJson(map);
      }
    }
    return null;
  }

  Future<void> clearUserSession() async {
    _inMemoryFallback.remove(_userSessionKey);
    try {
      await _storage?.delete(key: _userSessionKey);
    } catch (_) {
      // Fallback
    }
  }
}
