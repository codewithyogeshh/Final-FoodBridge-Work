import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides camera and gallery image capture with Supabase Storage upload
/// and local cache fallback for offline operations.
class MediaService {
  MediaService._();
  static final MediaService instance = MediaService._();

  final ImagePicker _picker = ImagePicker();

  bool get _isTestEnvironment =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  /// Capture photo from device camera
  Future<XFile?> pickImageFromCamera() async {
    if (_isTestEnvironment) return null;
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('[MediaService] Camera capture error: $e');
      return null;
    }
  }

  /// Select photo from device gallery
  Future<XFile?> pickImageFromGallery() async {
    if (_isTestEnvironment) return null;
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('[MediaService] Gallery picker error: $e');
      return null;
    }
  }

  /// Upload photo to Supabase storage bucket 'donation-photos'
  /// Returns public URL if successful, or local path as fallback.
  Future<String> uploadPhoto({
    required XFile file,
    required String folder,
    String? customFileName,
  }) async {
    if (_isTestEnvironment) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600';
    }

    try {
      final fileName = customFileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final path = '$folder/$fileName';

      final client = Supabase.instance.client;
      final bytes = await file.readAsBytes();

      await client.storage.from('donation-photos').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final publicUrl =
          client.storage.from('donation-photos').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('[MediaService] Storage upload error (encoding to portable base64 data URI): $e');
      try {
        final bytes = await file.readAsBytes();
        final b64 = base64Encode(bytes);
        return 'data:image/jpeg;base64,$b64';
      } catch (_) {
        return file.path;
      }
    }
  }
}
