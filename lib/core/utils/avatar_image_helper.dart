import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Robust ImageProvider resolver for user profile avatars across the entire app.
/// Handles:
/// - Remote HTTPS / HTTP image URLs
/// - Base64 data URIs (`data:image/jpeg;base64,...`, `data:image/png;base64,...`)
/// - Raw Base64 string fallbacks
/// - Local file paths on Android, iOS, and Desktop (`/data/user/0/...` or `file://...`)
class AvatarImageHelper {
  AvatarImageHelper._();

  static ImageProvider? resolve(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final cleanUrl = url.trim();

    // 1. Remote HTTP / HTTPS URLs
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return NetworkImage(cleanUrl);
    }

    // 2. Base64 Data URI (e.g. data:image/jpeg;base64,...)
    if (cleanUrl.startsWith('data:image/') && cleanUrl.contains('base64,')) {
      try {
        final b64Part = cleanUrl.split('base64,').last.replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(b64Part);
        if (bytes.isNotEmpty) {
          return MemoryImage(bytes);
        }
      } catch (e) {
        debugPrint('[AvatarImageHelper] Failed to decode base64 data URI: $e');
      }
    }

    // 3. Raw Base64 string (no data:image/ prefix, long encoded string)
    if (cleanUrl.length > 80 && !cleanUrl.startsWith('/') && !cleanUrl.startsWith('file://')) {
      try {
        final sanitized = cleanUrl.replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(sanitized);
        if (bytes.isNotEmpty) {
          return MemoryImage(bytes);
        }
      } catch (_) {}
    }

    // 4. Local File path on device
    if (!kIsWeb) {
      try {
        String path = cleanUrl;
        if (path.startsWith('file://')) {
          path = Uri.parse(path).toFilePath();
        }
        final file = File(path);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (e) {
        debugPrint('[AvatarImageHelper] File system check error: $e');
      }
    }

    return null;
  }
}
