import 'package:flutter_test/flutter_test.dart';
import 'package:uv_dosimeter/features/home/domain/entities/daily_dose_summary.dart';
import 'package:uv_dosimeter/features/home/domain/entities/uv_index.dart';
import 'package:uv_dosimeter/features/home/presentation/providers/home_provider.dart';

void main() {
  group('HomeState', () {
    test('copyWith(pendingDoseNotification: null) clears pending notification', () {
      const state = HomeState(pendingDoseNotification: PendingDoseNotification.threshold80);
      final cleared = state.copyWith(pendingDoseNotification: null);
      expect(cleared.pendingDoseNotification, isNull);
    });

    test('copyWith(pendingDoseNotification: dailyDone) sets value', () {
      const state = HomeState();
      final updated = state.copyWith(pendingDoseNotification: PendingDoseNotification.dailyDone);
      expect(updated.pendingDoseNotification, PendingDoseNotification.dailyDone);
    });
  });
}
