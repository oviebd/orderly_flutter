import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<String?>? _authStateSubscription;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _authStateSubscription = _authRepository.onAuthStateChanged.listen((userId) {
      if (userId != null) {
        emit(Authenticated(userId));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    final result = await _authRepository.signIn(email: email, password: password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {}, // Success is handled by the stream listener
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(AuthLoading());
    final result = await _authRepository.signUp(email: email, password: password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {}, // Success is handled by the stream listener
    );
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
