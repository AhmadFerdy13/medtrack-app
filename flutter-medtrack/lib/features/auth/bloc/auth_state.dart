import 'package:equatable/equatable.dart';
import '../data/models/user_model.dart';

/// State untuk AuthBloc.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// State awal.
class AuthInitial extends AuthState {}

/// Sedang memproses (loading).
class AuthLoading extends AuthState {}

/// User berhasil login/register.
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User belum login.
class AuthUnauthenticated extends AuthState {}

/// Registrasi berhasil (redirect ke login).
class AuthRegistered extends AuthState {
  final String message;

  const AuthRegistered(this.message);

  @override
  List<Object?> get props => [message];
}

/// Terjadi error.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
