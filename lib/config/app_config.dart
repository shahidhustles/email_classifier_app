import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String _defaultAppName = 'The Inbox Store';
  static const String _defaultGmailScope =
      'https://www.googleapis.com/auth/gmail.readonly';

  static String get appName {
    final value = dotenv.env['APP_NAME']?.trim();
    if (value == null || value.isEmpty) {
      return _defaultAppName;
    }
    return value;
  }

  static List<String> get gmailScopes {
    final value = dotenv.env['GMAIL_SCOPES']?.trim();
    if (value == null || value.isEmpty) {
      return const [_defaultGmailScope];
    }

    return value
        .split(',')
        .map((scope) => scope.trim())
        .where((scope) => scope.isNotEmpty)
        .toList(growable: false);
  }

  static String? get googleClientId {
    final value = dotenv.env['GOOGLE_CLIENT_ID']?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  static String? get googleServerClientId {
    final value = dotenv.env['GOOGLE_SERVER_CLIENT_ID']?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
