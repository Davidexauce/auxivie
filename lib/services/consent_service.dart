import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ConsentState {
  final bool essential;
  final bool analytics;
  final bool marketing;
  final DateTime decidedAt;
  final int schemaVersion;

  const ConsentState({
    required this.essential,
    required this.analytics,
    required this.marketing,
    required this.decidedAt,
    required this.schemaVersion,
  });

  bool get isDecided => true;

  Map<String, dynamic> toJson() => {
        'essential': essential,
        'analytics': analytics,
        'marketing': marketing,
        'decidedAt': decidedAt.toIso8601String(),
        'schemaVersion': schemaVersion,
      };

  static ConsentState? fromJson(Map<String, dynamic> json) {
    try {
      final decidedAtRaw = json['decidedAt'];
      final decidedAt = decidedAtRaw is String ? DateTime.tryParse(decidedAtRaw) : null;
      if (decidedAt == null) return null;

      final essential = json['essential'];
      final analytics = json['analytics'];
      final marketing = json['marketing'];
      final schemaVersion = json['schemaVersion'];

      if (essential is! bool || analytics is! bool || marketing is! bool) return null;
      if (schemaVersion is! int) return null;

      return ConsentState(
        essential: essential,
        analytics: analytics,
        marketing: marketing,
        decidedAt: decidedAt,
        schemaVersion: schemaVersion,
      );
    } catch (_) {
      return null;
    }
  }
}

class ConsentService {
  static const int _schemaVersion = 1;
  static const String _prefsKey = 'cmp_consent_state_v1';

  static Future<ConsentState?> getConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return ConsentState.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setConsent({
    required bool analytics,
    required bool marketing,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final state = ConsentState(
      essential: true, // Toujours actif (fonctionnement/sécurité)
      analytics: analytics,
      marketing: marketing,
      decidedAt: DateTime.now(),
      schemaVersion: _schemaVersion,
    );
    await prefs.setString(_prefsKey, jsonEncode(state.toJson()));
  }

  static Future<void> clearConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}

