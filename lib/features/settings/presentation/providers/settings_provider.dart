import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/utils/logger.dart';
import '../../../onboarding/domain/entities/skin_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../onboarding/presentation/providers/skin_profile_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class SettingsState {
  const SettingsState({
    this.selectedType = 2,
    this.selectedSpf = 30,
    this.isSaving = false,
    this.isSaved = false,
    this.errorMessage,
    this.appVersion = '',
  });

  final int selectedType;
  final int selectedSpf;
  final bool isSaving;

  /// Transient flag — true for ~2 s after a successful save.
  final bool isSaved;
  final String? errorMessage;
  final String appVersion;

  SettingsState copyWith({
    int? selectedType,
    int? selectedSpf,
    bool? isSaving,
    bool? isSaved,
    String? errorMessage,
    String? appVersion,
  }) =>
      SettingsState(
        selectedType: selectedType ?? this.selectedType,
        selectedSpf: selectedSpf ?? this.selectedSpf,
        isSaving: isSaving ?? this.isSaving,
        isSaved: isSaved ?? this.isSaved,
        errorMessage: errorMessage,
        appVersion: appVersion ?? this.appVersion,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._ref) : super(const SettingsState()) {
    _loadCurrentProfile();
  }

  final Ref _ref;

  Future<void> _loadCurrentProfile() async {
    // Load stored skin profile to pre-populate the form.
    final profileAsync = _ref.read(storedSkinProfileProvider);
    final profile = profileAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );

    // Load app version.
    String version = '';
    try {
      final info = await PackageInfo.fromPlatform();
      version = '${info.version} (${info.buildNumber})';
    } catch (e) {
      appLogger.w('[Settings] Could not read package info: $e');
    }

    if (mounted) {
      state = state.copyWith(
        selectedType: profile?.fitzpatrickType ?? 2,
        selectedSpf: profile?.spf ?? 30,
        appVersion: version,
      );
    }
  }

  void selectSkinType(int type) =>
      state = state.copyWith(selectedType: type, errorMessage: null, isSaved: false);

  void selectSpf(int spf) =>
      state = state.copyWith(selectedSpf: spf, errorMessage: null, isSaved: false);

  /// Persists the updated profile.
  Future<void> saveChanges() async {
    state = state.copyWith(isSaving: true, isSaved: false, errorMessage: null);

    final saveUseCase = _ref.read(saveSkinProfileProvider);
    final profile = SkinProfile(
      fitzpatrickType: state.selectedType,
      spf: state.selectedSpf,
    );

    final result = await saveUseCase(profile);
    result.fold(
      (failure) {
        appLogger.e('[Settings] Save failed: ${failure.message}');
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
      },
      (_) {
        appLogger.i('[Settings] Profile saved.');
        state = state.copyWith(isSaving: false, isSaved: true);
        // Reset isSaved flag after 2 s so the banner auto-hides.
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) state = state.copyWith(isSaved: false);
        });
        // Invalidate downstream providers to reflect the change.
        _ref.invalidate(storedSkinProfileProvider);
      },
    );
  }

  /// Clears the skin profile and onboarding flag — resets to first-launch state.
  Future<void> resetProfile() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.remove('skin_profile');
    await prefs.remove('onboarding_complete');
    _ref.invalidate(storedSkinProfileProvider);
    appLogger.i('[Settings] Profile reset.');
  }
}

final settingsNotifierProvider =
    StateNotifierProvider.autoDispose<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(ref),
);
