import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> signIn({required String email, required String password});
  Future<Either<Failure, void>> signUp({required String email, required String password});
  Future<Either<Failure, void>> signOut();
  Stream<String?> get onAuthStateChanged;
}
