import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/email_cache_snapshot.dart';

class CacheService {
  static const String _snapshotKey = 'email_cache_snapshot_v1';
  static const int schemaVersion = 1;

  Future<EmailCacheSnapshot?> loadSnapshot() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? rawSnapshot = preferences.getString(_snapshotKey);
    if (rawSnapshot == null || rawSnapshot.isEmpty) {
      return null;
    }

    final dynamic decoded = jsonDecode(rawSnapshot);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final EmailCacheSnapshot snapshot = EmailCacheSnapshot.fromJson(decoded);
    if (snapshot.schemaVersion != schemaVersion) {
      await clear();
      return null;
    }

    return snapshot;
  }

  Future<void> saveSnapshot(EmailCacheSnapshot snapshot) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_snapshotKey, jsonEncode(snapshot.toJson()));
  }

  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_snapshotKey);
  }
}
