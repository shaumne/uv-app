import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/skin_profile_local_datasource.dart';
import '../../data/repositories/skin_profile_repository_impl.dart';
import '../../domain/entities/skin_profile.dart';
import '../../domain/repositories/skin_profile_repository.dart';
import '../../domain/usecases/save_skin_profile.dart';

// ── Infrastructure providers ─────────────────────────────────────────────────

/// Pre-initialised in main.dart via ProviderScope.overrides — never throws.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  ),
);

final skinProfileLocalDatasourceProvider =
    Provider<SkinProfileLocalDatasource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SkinProfileLocalDatasourceImpl(prefs);
});

final skinProfileRepositoryProvider = Provider<SkinProfileRepository>((ref) {
  final ds = ref.watch(skinProfileLocalDatasourceProvider);
  return SkinProfileRepositoryImpl(ds);
});

final saveSkinProfileProvider = Provider<SaveSkinProfile>((ref) {
  return SaveSkinProfile(ref.watch(skinProfileRepositoryProvider));
});

// ── State ─────────────────────────────────────────────────────────────────────

class OnboardingState {
  const OnboardingState({
    this.selectedType = 1,
    this.selectedSpf = 30,
    this.isSaving = false,
    this.errorMessage,
  });

  final int selectedType;
  final int selectedSpf;
  final bool isSaving;
  final String? errorMessage;

  OnboardingState copyWith({
    int? selectedType,
    int? selectedSpf,
    bool? isSaving,
    String? errorMessage,
  }) =>
      OnboardingState(
        selectedType: selectedType ?? this.selectedType,
        selectedSpf: selectedSpf ?? this.selectedSpf,
        isSaving: isSaving ?? this.isSaving,
        errorMessage: errorMessage,
      );
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this._saveUseCase) : super(const OnboardingState());

  final SaveSkinProfile _saveUseCase;

  void selectSkinType(int type) =>
      state = state.copyWith(selectedType: type, errorMessage: null);

  void selectSpf(int spf) =>
      state = state.copyWith(selectedSpf: spf, errorMessage: null);

  /// Persists the skin profile and returns true on success.
  Future<bool> saveAndComplete() async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    final profile = SkinProfile(
      fitzpatrickType: state.selectedType,
      spf: state.selectedSpf,
    );

    final result = await _saveUseCase(profile);

    return result.fold(
      (failure) {
        appLogger.e('OnboardingNotifier.saveAndComplete', error: failure.message);
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isSaving: false);
        return true;
      },
    );
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref.watch(saveSkinProfileProvider));
});
