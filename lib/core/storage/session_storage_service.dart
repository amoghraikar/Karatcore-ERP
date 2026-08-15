import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../shared/models/user_session.dart';
import 'web_storage_stub.dart' if (dart.library.html) 'web_storage_html.dart';

class SessionStorageService {
  static const String _sessionKey = 'karatcore_user_session';
  static Map<String, dynamic>? _inMemoryStorage;

  /// Saves active user session to persistent storage
  static Future<void> saveSession(UserSession session) async {
    final jsonStr = jsonEncode(session.toJson());
    _inMemoryStorage = session.toJson();
    if (kIsWeb) {
      setWebItem(_sessionKey, jsonStr);
    }
  }

  /// Loads active user session from persistent storage
  static Future<UserSession?> loadSession() async {
    if (kIsWeb) {
      final jsonStr = getWebItem(_sessionKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final Map<String, dynamic> data = jsonDecode(jsonStr);
          _inMemoryStorage = data;
          return UserSession.fromJson(data);
        } catch (_) {}
      }
    }

    if (_inMemoryStorage != null) {
      return UserSession.fromJson(_inMemoryStorage!);
    }

    return null;
  }

  /// Clears stored session upon logout
  static Future<void> clearSession() async {
    _inMemoryStorage = null;
    if (kIsWeb) {
      removeWebItem(_sessionKey);
    }
  }
}
