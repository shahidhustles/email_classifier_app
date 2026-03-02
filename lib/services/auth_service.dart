import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';

import '../config/app_config.dart';
import '../models/auth_user.dart';

class AuthService {
  AuthService({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;
  bool _isInitialized = false;

  List<String> get _scopes => AppConfig.gmailScopes;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await _googleSignIn.initialize(
      clientId: AppConfig.googleClientId,
      serverClientId: AppConfig.googleServerClientId,
    );
    _isInitialized = true;
  }

  Future<GoogleSignInAccount?> trySilentSignIn() async {
    final Future<GoogleSignInAccount?>? signInAttempt =
        _googleSignIn.attemptLightweightAuthentication();

    if (signInAttempt == null) {
      return null;
    }

    return signInAttempt;
  }

  Future<GoogleSignInAccount> signIn() {
    return _googleSignIn.authenticate(scopeHint: _scopes);
  }

  Future<void> signOut() {
    return _googleSignIn.disconnect();
  }

  AuthUser toAuthUser(GoogleSignInAccount account) {
    return AuthUser(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
    );
  }

  Future<bool> hasRequiredScopes(GoogleSignInAccount account) async {
    final GoogleSignInClientAuthorization? authorization = await account
        .authorizationClient
        .authorizationForScopes(_scopes);
    return authorization != null;
  }

  Future<GoogleSignInClientAuthorization> requestRequiredScopes(
    GoogleSignInAccount account,
  ) {
    return account.authorizationClient.authorizeScopes(_scopes);
  }

  Future<GmailApi> getGmailApiClient(
    GoogleSignInAccount account, {
    bool promptIfNecessary = false,
  }) async {
    GoogleSignInClientAuthorization? authorization = await account
        .authorizationClient
        .authorizationForScopes(_scopes);

    if (authorization == null && promptIfNecessary) {
      authorization = await account.authorizationClient.authorizeScopes(_scopes);
    }

    if (authorization == null) {
      throw StateError(
        'Missing Gmail authorization. Call requestRequiredScopes first.',
      );
    }

    return GmailApi(authorization.authClient(scopes: _scopes));
  }
}
