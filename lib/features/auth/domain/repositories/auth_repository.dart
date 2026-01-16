import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> signIn({required String email, required String password});
  Future<Either<Failure, void>> signUp({
    required String email,
    required String password,
    required String userName,
    String phone,
  });
  Future<Either<Failure, void>> signOut();
  Stream<String?> get onAuthStateChanged;
  Future<Either<Failure, bool>> checkHasBusiness(String email);
  Future<Either<Failure, void>> registerBusiness({
    required String email,
    required String businessName,
    required String phone,
    required String userId,
    required String userName,
  });
}
