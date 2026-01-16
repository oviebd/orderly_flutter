import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderly/features/profile/domain/repositories/profile_repository.dart';
import 'package:orderly/features/profile/domain/entities/business_profile.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final FirebaseAuth _auth;

  ProfileCubit({
    required ProfileRepository profileRepository,
    required FirebaseAuth auth,
  })  : _profileRepository = profileRepository,
        _auth = auth,
        super(const ProfileState());

  String? get _userEmail => _auth.currentUser?.email;

  Future<void> loadProfile() async {
    final email = _userEmail;
    if (email == null) {
      emit(state.copyWith(error: 'User not authenticated'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    final result = await _profileRepository.getProfile(email);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (profile) => emit(state.copyWith(isLoading: false, profile: profile)),
    );
  }

  Future<void> loadPlans() async {
    final result = await _profileRepository.getPlans();
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (plans) => emit(state.copyWith(plans: plans)),
    );
  }

  Future<void> updateProfile(BusinessProfile updatedProfile) async {
    final email = _userEmail;
    if (email == null) return;

    emit(state.copyWith(isLoading: true, isUpdateSuccess: false));

    final result = await _profileRepository.updateProfile(email, updatedProfile);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) {
        emit(state.copyWith(isLoading: false, profile: updatedProfile, isUpdateSuccess: true));
        // Reset success state after a delay or another action
      },
    );
  }

  Future<void> updatePlan(String planId) async {
    final email = _userEmail;
    if (email == null) return;

    emit(state.copyWith(isLoading: true));

    final result = await _profileRepository.updatePlan(email, planId);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) {
        // Reload profile to see new plan
        loadProfile();
      },
    );
  }

  void clearError() => emit(state.copyWith(error: null));
  void resetUpdateSuccess() => emit(state.copyWith(isUpdateSuccess: false));
}
