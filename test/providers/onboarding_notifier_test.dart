import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uv_dosimeter/core/error/exceptions.dart';
import 'package:uv_dosimeter/features/onboarding/data/datasources/skin_profile_local_datasource.dart';
import 'package:uv_dosimeter/features/onboarding/data/models/skin_profile_model.dart';
import 'package:uv_dosimeter/features/onboarding/presentation/providers/onboarding_provider.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class _MockSharedPreferences extends Mock implements SharedPreferences {}

class _MockSkinProfileLocalDatasource extends Mock
    implements SkinProfileLocalDatasource {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SkinProfileModel(fitzpatrickType: 1, spf: 30));
  });

  group('OnboardingNotifier', () {
    late SharedPreferences mockPrefs;
    late _MockSkinProfileLocalDatasource mockDatasource;
    late ProviderContainer container;

    setUp(() {
      mockPrefs = _MockSharedPreferences();
      mockDatasource = _MockSkinProfileLocalDatasource();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          skinProfileLocalDatasourceProvider.overrideWithValue(mockDatasource),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('initial state has selection defaults', () {
      final state = container.read(onboardingNotifierProvider);
      expect(state.selectedType, 1);
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

    test('saveAndComplete fails when save fails', () async {
      when(() => mockDatasource.save(any()))
          .thenAnswer((_) async => throw CacheException(message: 'fail'));

      final notifier = container.read(onboardingNotifierProvider.notifier);
      notifier.selectSkinType(2);
      notifier.selectSpf(30);
      final ok = await notifier.saveAndComplete();

      expect(ok, isFalse);
      final state = container.read(onboardingNotifierProvider);
      expect(state.errorMessage, isNotNull);
      expect(state.isSaving, isFalse);
    });

    test('saveAndComplete succeeds and persists to secure storage', () async {
      when(() => mockDatasource.save(any())).thenAnswer((_) async {});

      final notifier = container.read(onboardingNotifierProvider.notifier);
      notifier.selectSkinType(2);
      notifier.selectSpf(30);
      final ok = await notifier.saveAndComplete();

      expect(ok, isTrue);
      final state = container.read(onboardingNotifierProvider);
      expect(state.errorMessage, isNull);
      verify(() => mockDatasource.save(any())).called(1);
    });
  });
}
