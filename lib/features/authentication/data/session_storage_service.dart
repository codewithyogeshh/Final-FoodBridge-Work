import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/models/app_user.dart';

class SessionStorageService {
  static const String _userSessionKey = 'foodbridge_user_session';
  final FlutterSecureStorage _storage;

  SessionStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveUserSession(AppUser user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await _storage.write(key: _userSessionKey, value: jsonString);
    } catch (_) {
      // Secure storage fallback if unavailable in environment
    }
  }

  Future<AppUser?> getUserSession() async {
    try {
      final jsonString = await _storage.read(key: _userSessionKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        return AppUser.fromJson(map);
      }
    } catch (_) {
      // Handle read error gracefully
    }
    return null;
  }

  Future<void> clearUserSession() async {
    try {
      await _storage.delete(key: _userSessionKey);
    } catch (_) {
      // Fallback
    }
  }
}
