import 'package:flutter/foundation.dart';

import '../models/email_model.dart';
import '../services/gmail_service.dart';
import 'auth_provider.dart';

class EmailProvider extends ChangeNotifier {
  EmailProvider({required GmailService gmailService})
    : _gmailService = gmailService;

  final GmailService _gmailService;

  AuthProvider? _authProvider;
  bool _isLoading = false;
  String? _errorMessage;
  List<EmailModel> _emails = const <EmailModel>[];
  String? _nextPageToken;
  DateTime? _lastRefreshedAt;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EmailModel> get emails => _emails;
  String? get nextPageToken => _nextPageToken;
  DateTime? get lastRefreshedAt => _lastRefreshedAt;

  void bindAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;

    if (authProvider.currentUser == null) {
      clear(notify: true);
    }
  }

  Future<void> loadLatestEmails({int limit = 10}) async {
    if (_isLoading) {
      return;
    }

    final AuthProvider? authProvider = _authProvider;
    if (authProvider == null || authProvider.currentUser == null) {
      _errorMessage = 'Sign in first to load emails.';
      notifyListeners();
      return;
    }

    if (!authProvider.hasGmailAccess) {
      _errorMessage = 'Authorize Gmail access first.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gmailApi = await authProvider.getGmailApiClient();
      final batch = await _gmailService.fetchLatestInboxEmails(
        gmailApi,
        limit: limit,
      );

      _emails = batch.emails;
      _nextPageToken = batch.nextPageToken;
      _lastRefreshedAt = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to load latest emails: $error';
      notifyListeners();
    }
  }

  Future<void> refreshLatestEmails() async {
    await loadLatestEmails(limit: 10);
  }

  void clear({bool notify = false}) {
    final bool hadState =
        _emails.isNotEmpty ||
        _errorMessage != null ||
        _nextPageToken != null ||
        _lastRefreshedAt != null ||
        _isLoading;

    _isLoading = false;
    _errorMessage = null;
    _emails = const <EmailModel>[];
    _nextPageToken = null;
    _lastRefreshedAt = null;

    if (notify && hadState) {
      notifyListeners();
    }
  }
}
