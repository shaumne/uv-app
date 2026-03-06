import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uv_dosimeter/features/onboarding/presentation/providers/onboarding_provider.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class _MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('OnboardingNotifier', () {
    late SharedPreferences mockPrefs;
    late ProviderContainer container;

    setUp(() {
      mockPrefs = _MockSharedPreferences();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('initial state has no selection', () {
      final state = container.read(onboardingNotifierProvider);
      expect(state.selectedType, isNull);
      expect(state.selectedSpf, 30);
      expect(state.isSaving, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('selectSkinType updates selectedType', () {
      final notifier = container.read(onboardingNotifierProvider.notifier);
      notifier.selectSkinType(3);
      final state = container.read(onboardingNotifierProvider);
      expect(state.selectedType, 3);
    });

    test('selectSpf updates selectedSpf', () {
      final notifier = container.read(onboardingNotifierProvider.notifier);
      notifier.selectSpf(50);
      final state = container.read(onboardingNotifierProvider);
      expect(state.selectedSpf, 50);
    });

    test('saveProfile fails gracefully when skin type not selected', () async {
      final notifier = container.read(onboardingNotifierProvider.notifier);
      // No skin type selected — save should set errorMessage
      await notifier.saveProfile();
      final state = container.read(onboardingNotifierProvider);
      expect(state.errorMessage, isNotNull);
      expect(state.isSaving, isFalse);
    });

    test('saveProfile succeeds and persists to SharedPreferences', () async {
      when(() => mockPrefs.setString(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockPrefs.setBool(any(), any()))
          .thenAnswer((_) async => true);

      final notifier = container.read(onboardingNotifierProvider.notifier);
      notifier.selectSkinType(2);
      notifier.selectSpf(30);
      await notifier.saveProfile();

      final state = container.read(onboardingNotifierProvider);
      expect(state.errorMessage, isNull);
      verify(() => mockPrefs.setString(any(), any())).called(1);
      verify(() => mockPrefs.setBool('onboarding_complete', true)).called(1);
    });
  });
}
