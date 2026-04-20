import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/email_cache_snapshot.dart';
import '../models/email_model.dart';
import '../services/cache_service.dart';
import '../services/gmail_service.dart';
import 'auth_provider.dart';

enum EmailFilter { all, order, shipping, promotion, other }

extension EmailFilterX on EmailFilter {
  String get label {
    switch (this) {
      case EmailFilter.all:
        return 'All';
      case EmailFilter.order:
        return 'Orders';
      case EmailFilter.shipping:
        return 'Shipping';
      case EmailFilter.promotion:
        return 'Promotions';
      case EmailFilter.other:
        return 'Other';
    }
  }
}

class EmailProvider extends ChangeNotifier {
  EmailProvider({
    required GmailService gmailService,
    CacheService? cacheService,
  }) : _gmailService = gmailService,
       _cacheService = cacheService ?? CacheService();

  final GmailService _gmailService;
  final CacheService _cacheService;

  AuthProvider? _authProvider;
  bool _isBootstrappingCache = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  List<EmailModel> _emails = const <EmailModel>[];
  Map<String, String?> _nextPageTokensByLabel = const <String, String?>{};
  DateTime? _lastRefreshedAt;
  EmailFilter _selectedFilter = EmailFilter.all;
  bool _hasHydratedCache = false;
  bool _initialSyncTriggered = false;

  bool get isBootstrappingCache => _isBootstrappingCache;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  List<EmailModel> get emails => List<EmailModel>.unmodifiable(_emails);
  Map<String, String?> get nextPageTokensByLabel =>
      Map<String, String?>.unmodifiable(_nextPageTokensByLabel);
  DateTime? get lastRefreshedAt => _lastRefreshedAt;
  EmailFilter get selectedFilter => _selectedFilter;
  bool get hasMore => _nextPageTokensByLabel.values.any(
    (String? token) => token != null && token.isNotEmpty,
  );

  List<EmailModel> get allEcommerceEmails => _emails
      .where((EmailModel email) => email.isEcommerce)
      .toList(growable: false);

  List<EmailModel> get orderEmails => _emails
      .where((EmailModel email) => email.category == EmailCategory.order)
      .toList(growable: false);

  List<EmailModel> get shippingEmails => _emails
      .where((EmailModel email) => email.category == EmailCategory.shipping)
      .toList(growable: false);

  List<EmailModel> get promotionEmails => _emails
      .where((EmailModel email) => email.category == EmailCategory.promotion)
      .toList(growable: false);

  List<EmailModel> get otherEmails => _emails
      .where((EmailModel email) => email.category == EmailCategory.other)
      .toList(growable: false);

  List<EmailModel> get visibleEmails {
    switch (_selectedFilter) {
      case EmailFilter.all:
        return allEcommerceEmails;
      case EmailFilter.order:
        return orderEmails;
      case EmailFilter.shipping:
        return shippingEmails;
      case EmailFilter.promotion:
        return promotionEmails;
      case EmailFilter.other:
        return otherEmails;
    }
  }

  int get allCount => allEcommerceEmails.length;
  int get orderCount => orderEmails.length;
  int get shippingCount => shippingEmails.length;
  int get promotionCount => promotionEmails.length;
  int get otherCount => otherEmails.length;

  Future<void> bootstrap() async {
    if (_isBootstrappingCache || _hasHydratedCache) {
      return;
    }

    _isBootstrappingCache = true;
    notifyListeners();

    try {
      final EmailCacheSnapshot? snapshot = await _cacheService.loadSnapshot();
      if (snapshot != null) {
        _emails = snapshot.emails;
        _nextPageTokensByLabel = snapshot.nextPageTokensByLabel;
        _lastRefreshedAt = snapshot.lastSyncedAt;
      }
    } catch (error) {
      _errorMessage = 'Failed to load cached emails: $error';
    } finally {
      _isBootstrappingCache = false;
      _hasHydratedCache = true;
      notifyListeners();
      _scheduleInitialSyncIfNeeded();
    }
  }

  void bindAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;

    if (authProvider.currentUser == null) {
      if (authProvider.status == AuthStatus.initial ||
          authProvider.status == AuthStatus.loading) {
        return;
      }

      _initialSyncTriggered = false;
      clear(notify: true);
      unawaited(_cacheService.clear());
      return;
    }

    _scheduleInitialSyncIfNeeded();
  }

  Future<void> loadLatestEmails({int limitPerLabel = 15}) async {
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
      final batch = await _gmailService.fetchLatestEmails(
        gmailApi,
        limitPerLabel: limitPerLabel,
      );

      _emails = batch.emails;
      _nextPageTokensByLabel = batch.nextPageTokensByLabel;
      _lastRefreshedAt = DateTime.now();
      _initialSyncTriggered = true;
      await _persistSnapshot();
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to load latest emails: $error';
      notifyListeners();
    }
  }

  Future<void> refreshLatestEmails() async {
    await loadLatestEmails(limitPerLabel: 15);
  }

  Future<void> loadMoreEmails({int limitPerLabel = 15}) async {
    if (_isLoading || _isLoadingMore || !hasMore) {
      return;
    }

    final AuthProvider? authProvider = _authProvider;
    if (authProvider == null || authProvider.currentUser == null) {
      _errorMessage = 'Sign in first to load more emails.';
      notifyListeners();
      return;
    }

    if (!authProvider.hasGmailAccess) {
      _errorMessage = 'Authorize Gmail access first.';
      notifyListeners();
      return;
    }

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gmailApi = await authProvider.getGmailApiClient();
      final batch = await _gmailService.fetchLatestEmails(
        gmailApi,
        limitPerLabel: limitPerLabel,
        pageTokensByLabel: _nextPageTokensByLabel,
      );

      _emails = _mergeDedupedEmails(_emails, batch.emails);
      _nextPageTokensByLabel = batch.nextPageTokensByLabel;
      _lastRefreshedAt = DateTime.now();
      await _persistSnapshot();
      _isLoadingMore = false;
      notifyListeners();
    } catch (error) {
      _isLoadingMore = false;
      _errorMessage = 'Failed to load more emails: $error';
      notifyListeners();
    }
  }

  void setSelectedFilter(EmailFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }

    _selectedFilter = filter;
    notifyListeners();
  }

  void clear({bool notify = false}) {
    final bool hadState =
        _emails.isNotEmpty ||
        _errorMessage != null ||
        _nextPageTokensByLabel.isNotEmpty ||
        _lastRefreshedAt != null ||
        _isLoading ||
        _isLoadingMore;

    _isLoading = false;
    _isLoadingMore = false;
    _errorMessage = null;
    _emails = const <EmailModel>[];
    _nextPageTokensByLabel = const <String, String?>{};
    _lastRefreshedAt = null;
    _selectedFilter = EmailFilter.all;

    if (notify && hadState) {
      notifyListeners();
    }
  }

  Future<void> _persistSnapshot() async {
    if (_lastRefreshedAt == null) {
      return;
    }

    await _cacheService.saveSnapshot(
      EmailCacheSnapshot(
        emails: _emails,
        nextPageTokensByLabel: _nextPageTokensByLabel,
        lastSyncedAt: _lastRefreshedAt!,
        schemaVersion: CacheService.schemaVersion,
      ),
    );
  }

  void _scheduleInitialSyncIfNeeded() {
    final AuthProvider? authProvider = _authProvider;
    if (!_hasHydratedCache ||
        authProvider == null ||
        authProvider.currentUser == null ||
        !authProvider.hasGmailAccess ||
        _emails.isNotEmpty ||
        _isLoading ||
        _initialSyncTriggered) {
      return;
    }

    _initialSyncTriggered = true;
    unawaited(loadLatestEmails());
  }

  List<EmailModel> _mergeDedupedEmails(
    List<EmailModel> existing,
    List<EmailModel> incoming,
  ) {
    final Map<String, EmailModel> byId = <String, EmailModel>{
      for (final EmailModel email in existing) email.id: email,
    };

    for (final EmailModel email in incoming) {
      byId[email.id] = email;
    }

    final List<EmailModel> merged = byId.values.toList(growable: false)
      ..sort((EmailModel a, EmailModel b) {
        final int aMs = a.internalDate?.millisecondsSinceEpoch ?? 0;
        final int bMs = b.internalDate?.millisecondsSinceEpoch ?? 0;
        return bMs.compareTo(aMs);
      });

    return List<EmailModel>.unmodifiable(merged);
  }
}
