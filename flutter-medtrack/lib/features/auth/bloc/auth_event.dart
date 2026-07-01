import 'package:equatable/equatable.dart';

/// Event untuk AuthBloc.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Cek status login saat aplikasi dibuka.
class AuthCheckStatus extends AuthEvent {}

/// Event login.
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event register.
class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation];
}

/// Event logout.
class AuthLogoutRequested extends AuthEvent {}

/// Event ambil profil.
class AuthGetProfile extends AuthEvent {}
