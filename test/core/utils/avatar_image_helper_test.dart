import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/core/utils/avatar_image_helper.dart';

void main() {
  group('AvatarImageHelper Tests', () {
    test('returns null for null or empty input', () {
      expect(AvatarImageHelper.resolve(null), isNull);
      expect(AvatarImageHelper.resolve(''), isNull);
      expect(AvatarImageHelper.resolve('   '), isNull);
    });

    test('resolves http and https network images', () {
      final resHttps = AvatarImageHelper.resolve('https://images.example.com/avatar.jpg');
      expect(resHttps, isA<NetworkImage>());
      expect((resHttps as NetworkImage).url, 'https://images.example.com/avatar.jpg');

      final resHttp = AvatarImageHelper.resolve('http://images.example.com/avatar.jpg');
      expect(resHttp, isA<NetworkImage>());
    });

    test('resolves base64 data URIs correctly', () {
      final sampleBytes = utf8.encode('foodbridge_avatar_sample_bytes');
      final b64 = base64Encode(sampleBytes);
      final dataUri = 'data:image/jpeg;base64,$b64';

      final res = AvatarImageHelper.resolve(dataUri);
      expect(res, isA<MemoryImage>());
      expect((res as MemoryImage).bytes, equals(sampleBytes));
    });

    test('resolves raw long base64 strings correctly', () {
      final sampleBytes = List<int>.generate(120, (i) => i % 256);
      final rawB64 = base64Encode(sampleBytes);

      final res = AvatarImageHelper.resolve(rawB64);
      expect(res, isA<MemoryImage>());
      expect((res as MemoryImage).bytes, equals(sampleBytes));
    });

    test('resolves existing local file path', () {
      final tempDir = Directory.systemTemp.createTempSync('fb_avatar_test');
      final testFile = File('${tempDir.path}/test_avatar.jpg');
      testFile.writeAsBytesSync([1, 2, 3, 4]);

      final res = AvatarImageHelper.resolve(testFile.path);
      expect(res, isA<FileImage>());
      expect((res as FileImage).file.path, testFile.path);

      tempDir.deleteSync(recursive: true);
    });

    test('returns null gracefully for non-existent file path', () {
      final res = AvatarImageHelper.resolve('/non/existent/path/avatar_123.jpg');
      expect(res, isNull);
    });
  });
}
