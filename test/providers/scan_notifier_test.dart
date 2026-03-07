import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uv_dosimeter/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:uv_dosimeter/features/scan/presentation/providers/scan_provider.dart';

void main() {
  group('ScanNotifier', () {
    test('releaseCamera does not throw and leaves isCameraReady false', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(scanNotifierProvider.notifier);
      expect(() => notifier.releaseCamera(), returnsNormally);
      expect(container.read(scanNotifierProvider).isCameraReady, isFalse);
    });
  });
}
