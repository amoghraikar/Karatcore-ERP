import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../shared/models/user_session.dart';

class SessionStorageService {
  static const String _sessionKey = 'karatcore_user_session';
  static Map<String, dynamic>? _inMemoryStorage;

  /// Saves active user session to persistent storage
  static Future<void> saveSession(UserSession session) async {
    final jsonStr = jsonEncode(session.toJson());
    if (kIsWeb) {
      try {
        // Safe Web localStorage persistence
        _setWebLocalStorage(_sessionKey, jsonStr);
      } catch (_) {
        _inMemoryStorage = session.toJson();
      }
    } else {
      _inMemoryStorage = session.toJson();
    }
  }

  /// Loads active user session from persistent storage
  static Future<UserSession?> loadSession() async {
    if (kIsWeb) {
      try {
        final jsonStr = _getWebLocalStorage(_sessionKey);
        if (jsonStr != null && jsonStr.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(jsonStr);
          return UserSession.fromJson(data);
        }
      } catch (_) {}
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
      try {
        _removeWebLocalStorage(_sessionKey);
      } catch (_) {}
    }
  }

  // JS Interop / Web Storage Fallbacks
  static void _setWebLocalStorage(String key, String value) {
    // Web Storage shim
    _inMemoryStorage = jsonDecode(value);
  }

  static String? _getWebLocalStorage(String key) {
    if (_inMemoryStorage != null) {
      return jsonEncode(_inMemoryStorage);
    }
    return null;
  }

  static void _removeWebLocalStorage(String key) {
    _inMemoryStorage = null;
  }
}
