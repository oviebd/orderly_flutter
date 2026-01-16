import 'package:dartz/dartz.dart';
import 'package:orderly/core/error/failures.dart';
import 'package:orderly/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:orderly/features/profile/data/models/business_profile_model.dart';
import 'package:orderly/features/profile/domain/repositories/profile_repository.dart';
import 'package:orderly/features/profile/domain/entities/business_profile.dart';
import 'package:orderly/features/profile/domain/entities/plan.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, BusinessProfile>> getProfile(String email) async {
    try {
      final profile = await _remoteDataSource.getProfile(email);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(String email, BusinessProfile profile) async {
    try {
      await _remoteDataSource.updateProfile(
        email,
        profile as BusinessProfileModel,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Plan>>> getPlans() async {
    try {
      final plans = await _remoteDataSource.getPlans();
      return Right(plans);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePlan(String email, String planId) async {
    try {
      await _remoteDataSource.updatePlan(email, planId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
