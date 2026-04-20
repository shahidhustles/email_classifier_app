import 'package:email_classifier_app/models/auth_user.dart';
import 'package:email_classifier_app/models/email_cache_snapshot.dart';
import 'package:email_classifier_app/models/email_model.dart';
import 'package:email_classifier_app/models/latest_email_batch.dart';
import 'package:email_classifier_app/providers/auth_provider.dart';
import 'package:email_classifier_app/services/auth_service.dart';
import 'package:email_classifier_app/services/cache_service.dart';
import 'package:email_classifier_app/services/gmail_service.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:http/http.dart' as http;

EmailModel buildEmail({
  required String id,
  required String subject,
  required EmailCategory category,
  DateTime? internalDate,
  String from = 'Amazon <order-update@amazon.in>',
  String snippet = 'Snippet',
  List<String> labelIds = const <String>['INBOX'],
}) {
  return EmailModel(
    id: id,
    threadId: 'thread-$id',
    internalDate: internalDate ?? DateTime(2026, 4, 20),
    from: from,
    subject: subject,
    snippet: snippet,
    dateHeader: 'Mon, 20 Apr 2026 10:00:00 +0000',
    plainTextBody: '$subject $snippet',
    labelIds: labelIds,
    category: category,
  );
}

class FakeCacheService extends CacheService {
  EmailCacheSnapshot? storedSnapshot;
  bool cleared = false;

  @override
  Future<EmailCacheSnapshot?> loadSnapshot() async => storedSnapshot;

  @override
  Future<void> saveSnapshot(EmailCacheSnapshot snapshot) async {
    storedSnapshot = snapshot;
  }

  @override
  Future<void> clear() async {
    cleared = true;
    storedSnapshot = null;
  }
}

class FakeGmailService extends GmailService {
  FakeGmailService({required this.responses});

  final List<LatestEmailBatch> responses;
  int callCount = 0;
  Map<String, String?>? lastPageTokens;

  @override
  Future<LatestEmailBatch> fetchLatestEmails(
    GmailApi gmailApi, {
    int limitPerLabel = 15,
    Map<String, String?>? pageTokensByLabel,
  }) async {
    lastPageTokens = pageTokensByLabel == null
        ? null
        : Map<String, String?>.from(pageTokensByLabel);

    final int index = callCount < responses.length ? callCount : responses.length - 1;
    callCount += 1;
    return responses[index];
  }
}

class FakeAuthProvider extends AuthProvider {
  FakeAuthProvider({
    this.fakeCurrentUser,
    this.fakeHasGmailAccess = true,
    this.fakeStatus = AuthStatus.authenticated,
  }) : super(authService: AuthService(), gmailService: GmailService());

  AuthUser? fakeCurrentUser;
  bool fakeHasGmailAccess;
  AuthStatus fakeStatus;

  @override
  AuthUser? get currentUser => fakeCurrentUser;

  @override
  bool get hasGmailAccess => fakeHasGmailAccess;

  @override
  AuthStatus get status => fakeStatus;

  @override
  Future<GmailApi> getGmailApiClient({bool promptIfNecessary = false}) async {
    return GmailApi(_FakeHttpClient());
  }
}

class _FakeHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }
}
