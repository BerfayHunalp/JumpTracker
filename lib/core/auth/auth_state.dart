import 'user_model.dart';

sealed class AuthState {
  const AuthState();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  final String token;
  final bool isNewUser;

  const AuthAuthenticated({
    required this.user,
    required this.token,
    this.isNewUser = false,
  });
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
