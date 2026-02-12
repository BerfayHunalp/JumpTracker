import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../network/api_client.dart';
import '../network/api_exceptions.dart';
import 'user_model.dart';

class AuthResult {
  final AppUser user;
  final String token;
  final bool isNewUser;

  AuthResult({required this.user, required this.token, required this.isNewUser});
}

class AuthService {
  final ApiClient _api;
  final FlutterSecureStorage _storage;

  AuthService(this._api, [FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  /// Try to load an existing session from secure storage.
  Future<AuthResult?> loadStoredAuth() async {
    final token = await _api.token;
    if (token == null) return null;

    try {
      final data = await _api.get('/users/me');
      final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      return AuthResult(user: user, token: token, isNewUser: false);
    } on UnauthorizedException {
      // Token expired - try refresh
      try {
        final refreshData = await _api.post('/auth/refresh');
        final newToken = refreshData['token'] as String;
        await _api.setToken(newToken);
        final user =
            AppUser.fromJson(refreshData['user'] as Map<String, dynamic>);
        return AuthResult(user: user, token: newToken, isNewUser: false);
      } catch (_) {
        await _api.clearToken();
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// Sign in with Google.
  Future<AuthResult> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email'],
      serverClientId: '350271156284-cc9t9s71dbod6meu4asi9pst0dg4qj2o.apps.googleusercontent.com',
    );
    final account = await googleSignIn.signIn();
    if (account == null) throw Exception('Google sign-in cancelled');

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('No ID token from Google');

    final data = await _api.post('/auth/google', body: {'idToken': idToken});
    final token = data['token'] as String;
    await _api.setToken(token);

    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    final isNewUser = data['isNewUser'] as bool? ?? false;
    return AuthResult(user: user, token: token, isNewUser: isNewUser);
  }

  /// Sign in with Apple.
  Future<AuthResult> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final idToken = credential.identityToken;
    if (idToken == null) throw Exception('No ID token from Apple');

    final data = await _api.post('/auth/apple', body: {
      'idToken': idToken,
      'firstName': credential.givenName,
      'lastName': credential.familyName,
    });

    final token = data['token'] as String;
    await _api.setToken(token);

    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    final isNewUser = data['isNewUser'] as bool? ?? false;
    return AuthResult(user: user, token: token, isNewUser: isNewUser);
  }

  /// Register with email and password.
  Future<AuthResult> registerWithEmail(String email, String password, String nickname) async {
    final data = await _api.post('/auth/register', body: {
      'email': email,
      'password': password,
      'nickname': nickname,
    });
    final token = data['token'] as String;
    await _api.setToken(token);
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    final isNewUser = data['isNewUser'] as bool? ?? true;
    return AuthResult(user: user, token: token, isNewUser: isNewUser);
  }

  /// Sign in with email and password.
  Future<AuthResult> signInWithEmail(String email, String password) async {
    final data = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    final token = data['token'] as String;
    await _api.setToken(token);
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    return AuthResult(user: user, token: token, isNewUser: false);
  }

  /// Sign out.
  Future<void> signOut() async {
    await _api.clearToken();
    await _storage.delete(key: 'user_json');
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {
      // Google sign-out may fail if not signed in with Google
    }
  }
}
