part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String userId;
  final String email;

  const Authenticated(this.userId, this.email);

  @override
  List<Object> get props => [userId, email];
}

class NeedsBusiness extends AuthState {
  final String userId;
  final String email;
  final String userName;

  const NeedsBusiness({
    required this.userId,
    required this.email,
    required this.userName,
  });

  @override
  List<Object> get props => [userId, email, userName];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
