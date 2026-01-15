import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, void>> signIn({required String email, required String password}) async {
    try {
      await _remoteDataSource.signIn(email, password);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      debugPrint('SignIn Error: $e');
      return Left(ServerFailure('SignIn Error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signUp({required String email, required String password}) async {
    try {
      await _remoteDataSource.signUp(email, password);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Sign up failed'));
    } catch (e) {
      debugPrint('SignUp Error: $e');
      return Left(ServerFailure('SignUp Error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to sign out'));
    }
  }

  @override
  Stream<String?> get onAuthStateChanged => _remoteDataSource.onAuthStateChanged;
}
