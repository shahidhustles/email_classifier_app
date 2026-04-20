import 'email_model.dart';

class EmailCacheSnapshot {
  const EmailCacheSnapshot({
    required this.emails,
    required this.nextPageTokensByLabel,
    required this.lastSyncedAt,
    required this.schemaVersion,
  });

  final List<EmailModel> emails;
  final Map<String, String?> nextPageTokensByLabel;
  final DateTime lastSyncedAt;
  final int schemaVersion;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'lastSyncedAt': lastSyncedAt.millisecondsSinceEpoch,
      'emails': emails.map((EmailModel email) => email.toJson()).toList(),
      'nextPageTokensByLabel': nextPageTokensByLabel,
    };
  }

  factory EmailCacheSnapshot.fromJson(Map<String, dynamic> json) {
    final List<dynamic> emailsJson =
        (json['emails'] as List<dynamic>?) ?? const <dynamic>[];
    final Map<String, dynamic> tokensJson =
        (json['nextPageTokensByLabel'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};

    return EmailCacheSnapshot(
      emails: List<EmailModel>.unmodifiable(
        emailsJson.map(
          (dynamic item) => EmailModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        ),
      ),
      nextPageTokensByLabel: Map<String, String?>.unmodifiable(
        tokensJson.map(
          (String key, dynamic value) => MapEntry(key, value as String?),
        ),
      ),
      lastSyncedAt: DateTime.fromMillisecondsSinceEpoch(
        json['lastSyncedAt'] as int,
      ),
      schemaVersion: json['schemaVersion'] as int? ?? 1,
    );
  }
}
