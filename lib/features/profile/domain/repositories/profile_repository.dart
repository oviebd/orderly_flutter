import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/business_profile.dart';
import '../entities/plan.dart';

abstract class ProfileRepository {
  Future<Either<Failure, BusinessProfile>> getProfile(String email);
  Future<Either<Failure, void>> updateProfile(String email, BusinessProfile profile);
  Future<Either<Failure, List<Plan>>> getPlans();
  Future<Either<Failure, void>> updatePlan(String email, String planId);
}
