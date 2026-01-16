import 'package:equatable/equatable.dart';
import '../../domain/entities/business_profile.dart';
import '../../domain/entities/plan.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final BusinessProfile? profile;
  final List<Plan>? plans;
  final String? error;
  final bool isUpdateSuccess;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.plans,
    this.error,
    this.isUpdateSuccess = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    BusinessProfile? profile,
    List<Plan>? plans,
    String? error,
    bool? isUpdateSuccess,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      plans: plans ?? this.plans,
      error: error,
      isUpdateSuccess: isUpdateSuccess ?? this.isUpdateSuccess,
    );
  }

  @override
  List<Object?> get props => [isLoading, profile, plans, error, isUpdateSuccess];
}
