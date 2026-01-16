import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<String?>? _authStateSubscription;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _authStateSubscription = _authRepository.onAuthStateChanged.listen((userId) async {
      if (userId != null) {
        // User is signed in, check if they have a business
        final user = FirebaseAuth.instance.currentUser;
        final email = user?.email ?? '';
        
        final result = await _authRepository.checkHasBusiness(email);
        result.fold(
          (failure) => emit(AuthError(failure.message)),
          (hasBusiness) async {
            if (hasBusiness) {
              emit(Authenticated(userId, email));
            } else {
              // Get user name from Firestore users collection
              String userName = '';
              try {
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get();
                if (userDoc.exists) {
                  userName = userDoc.data()?['userName'] ?? '';
                }
              } catch (_) {}
              emit(NeedsBusiness(userId: userId, email: email, userName: userName));
            }
          },
        );
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

  Future<void> signUp({
    required String email,
    required String password,
    required String userName,
    String phone = '',
  }) async {
    emit(AuthLoading());
    final result = await _authRepository.signUp(
      email: email,
      password: password,
      userName: userName,
      phone: phone,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {}, // Success is handled by the stream listener
    );
  }

  Future<void> registerBusiness({
    required String businessName,
    required String phone,
  }) async {
    final currentState = state;
    if (currentState is! NeedsBusiness) return;

    emit(AuthLoading());
    final result = await _authRepository.registerBusiness(
      email: currentState.email,
      businessName: businessName,
      phone: phone,
      userId: currentState.userId,
      userName: currentState.userName,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Authenticated(currentState.userId, currentState.email)),
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
