import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import 'auth_service.dart';
import 'auth_state.dart';
import 'user_model.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiClientProvider));
});

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.watch(authServiceProvider));
});

final currentUserProvider = Provider<AppUser?>((ref) {
  final state = ref.watch(authStateProvider);
  if (state is AuthAuthenticated) return state.user;
  return null;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider) is AuthAuthenticated;
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AuthUnauthenticated());

  Future<void> loadStoredAuth() async {
    state = const AuthLoading();
    try {
      final result = await _authService.loadStoredAuth();
      if (result != null) {
        state = AuthAuthenticated(user: result.user, token: result.token);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      final result = await _authService.signInWithGoogle();
      state = AuthAuthenticated(
        user: result.user,
        token: result.token,
        isNewUser: result.isNewUser,
      );
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signInWithApple() async {
    state = const AuthLoading();
    try {
      final result = await _authService.signInWithApple();
      state = AuthAuthenticated(
        user: result.user,
        token: result.token,
        isNewUser: result.isNewUser,
      );
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> registerWithEmail(String email, String password, String nickname) async {
    state = const AuthLoading();
    try {
      final result = await _authService.registerWithEmail(email, password, nickname);
      state = AuthAuthenticated(
        user: result.user,
        token: result.token,
        isNewUser: result.isNewUser,
      );
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AuthLoading();
    try {
      final result = await _authService.signInWithEmail(email, password);
      state = AuthAuthenticated(
        user: result.user,
        token: result.token,
      );
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthUnauthenticated();
  }

  void updateUser(AppUser user) {
    final current = state;
    if (current is AuthAuthenticated) {
      state = AuthAuthenticated(user: user, token: current.token);
    }
  }
}
