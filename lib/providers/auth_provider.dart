import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/gmail_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService authService, required GmailService gmailService})
    : _authService = authService,
      _gmailService = gmailService;

  final AuthService _authService;
  final GmailService _gmailService;

  AuthStatus _status = AuthStatus.initial;
  AuthUser? _currentUser;
  GoogleSignInAccount? _googleUser;
  bool _hasGmailAccess = false;
  String? _errorMessage;
  String? _gmailAddress;

  AuthStatus get status => _status;
  AuthUser? get currentUser => _currentUser;
  bool get hasGmailAccess => _hasGmailAccess;
  String? get errorMessage => _errorMessage;
  String? get gmailAddress => _gmailAddress;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> bootstrap() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.initialize();
      final GoogleSignInAccount? account = await _authService.trySilentSignIn();
      if (account == null) {
        _clearUserState();
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      await _setAuthenticatedUser(account);
      if (!_hasGmailAccess) {
        _clearUserState();
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
    } on GoogleSignInException catch (error) {
      _applyGoogleSignInError(
        error,
        onCanceledStatus: AuthStatus.unauthenticated,
        clearSessionOnCanceled: true,
      );
    } catch (error) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to bootstrap auth state: $error';
      notifyListeners();
    }
  }

  Future<void> signIn() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.initialize();
      final GoogleSignInAccount account = await _authService.signIn();
      await _setAuthenticatedUser(account, requestScopesIfMissing: true);
      if (!_hasGmailAccess) {
        throw StateError('Gmail access is required to use this app.');
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
    } on GoogleSignInException catch (error) {
      _applyGoogleSignInError(
        error,
        onCanceledStatus: AuthStatus.unauthenticated,
        clearSessionOnCanceled: true,
      );
    } catch (error) {
      _status = AuthStatus.error;
      _errorMessage = error is StateError
          ? error.message
          : 'Sign in failed: $error';
      notifyListeners();
    }
  }

  Future<void> authorizeScopes() async {
    final GoogleSignInAccount? account = _googleUser;
    if (account == null) {
      _status = AuthStatus.error;
      _errorMessage = 'Sign in first before requesting Gmail access.';
      notifyListeners();
      return;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.requestRequiredScopes(account);
      _hasGmailAccess = true;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } on GoogleSignInException catch (error) {
      _applyGoogleSignInError(
        error,
        onCanceledStatus: AuthStatus.authenticated,
      );
    } catch (error) {
      _status = AuthStatus.error;
      _errorMessage = 'Scope authorization failed: $error';
      notifyListeners();
    }
  }

  Future<void> testGmailConnection() async {
    final GoogleSignInAccount? account = _googleUser;
    if (account == null) {
      _status = AuthStatus.error;
      _errorMessage = 'Sign in first to test Gmail connection.';
      notifyListeners();
      return;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final gmailApi = await _authService.getGmailApiClient(account);
      final String address = await _gmailService.getMyEmailAddress(gmailApi);
      _gmailAddress = address;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (error) {
      _status = AuthStatus.error;
      _errorMessage = 'Gmail connectivity test failed: $error';
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _clearUserState();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (error) {
      _status = AuthStatus.error;
      _errorMessage = 'Sign out failed: $error';
      notifyListeners();
    }
  }

  Future<GmailApi> getGmailApiClient({bool promptIfNecessary = false}) async {
    final GoogleSignInAccount? account = _googleUser;
    if (account == null) {
      throw StateError('No signed-in Google account is available.');
    }

    final GmailApi gmailApi = await _authService.getGmailApiClient(
      account,
      promptIfNecessary: promptIfNecessary,
    );

    if (!_hasGmailAccess) {
      _hasGmailAccess = true;
      notifyListeners();
    }

    return gmailApi;
  }

  Future<void> _setAuthenticatedUser(
    GoogleSignInAccount account, {
    bool requestScopesIfMissing = false,
  }) async {
    _googleUser = account;
    _currentUser = _authService.toAuthUser(account);
    _hasGmailAccess = await _authService.hasRequiredScopes(account);

    if (!_hasGmailAccess && requestScopesIfMissing) {
      await _authService.requestRequiredScopes(account);
      _hasGmailAccess = await _authService.hasRequiredScopes(account);
    }
  }

  void _clearUserState() {
    _googleUser = null;
    _currentUser = null;
    _hasGmailAccess = false;
    _gmailAddress = null;
  }

  void _applyGoogleSignInError(
    GoogleSignInException error, {
    required AuthStatus onCanceledStatus,
    bool clearSessionOnCanceled = false,
  }) {
    if (error.code == GoogleSignInExceptionCode.canceled ||
        error.code == GoogleSignInExceptionCode.interrupted ||
        error.code == GoogleSignInExceptionCode.uiUnavailable) {
      if (clearSessionOnCanceled) {
        _clearUserState();
      }
      _status = onCanceledStatus;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _status = AuthStatus.error;
    _errorMessage = 'Google Sign-In error (${error.code.name}): ${error.description}';
    notifyListeners();
  }
}
