import 'package:flutter_test/flutter_test.dart';
import 'package:uv_dosimeter/features/result/domain/entities/uv_analysis_result.dart';

/// Unit tests for [UvAnalysisResult] domain entity.
///
/// Validates risk classification helpers that drive UI colour/copy decisions
/// on the result screen.
void main() {
  UvAnalysisResult makeResult({
    required String riskLevel,
    double medUsedFraction = 0.0,
    double remainingMinutes = 60,
  }) {
    return UvAnalysisResult(
      hexColor: '#FFD700',
      uvPercent: medUsedFraction * 100,
      medUsedFraction: medUsedFraction,
      remainingMinutes: remainingMinutes.round(),
      riskLevel: riskLevel,
      spfEffectiveNow: 30.0,
      sunscreenReapplyRecommended: false,
    );
  }

  group('UvAnalysisResult.isSafe', () {
    test('returns true when riskLevel is "safe"', () {
      expect(makeResult(riskLevel: 'safe').isSafe, isTrue);
    });
    test('returns false for other levels', () {
      for (final level in ['caution', 'warning', 'danger', 'exceeded']) {
        expect(makeResult(riskLevel: level).isSafe, isFalse, reason: level);
      }
    });
  });

  group('UvAnalysisResult.isCaution', () {
    test('returns true when riskLevel is "caution"', () {
      expect(makeResult(riskLevel: 'caution').isCaution, isTrue);
    });
  });

  group('UvAnalysisResult.isWarning', () {
    test('returns true when riskLevel is "warning"', () {
      expect(makeResult(riskLevel: 'warning').isWarning, isTrue);
    });
  });

  group('UvAnalysisResult.isDanger', () {
    test('returns true when riskLevel is "danger"', () {
      expect(makeResult(riskLevel: 'danger').isDanger, isTrue);
    });
  });

  group('UvAnalysisResult.isExceeded', () {
    test('returns true when riskLevel is "exceeded"', () {
      expect(makeResult(riskLevel: 'exceeded').isExceeded, isTrue);
    });
  });

  group('UvAnalysisResult.requiresAction', () {
    test('true for danger', () {
      expect(makeResult(riskLevel: 'danger').requiresAction, isTrue);
    });
    test('true for exceeded', () {
      expect(makeResult(riskLevel: 'exceeded').requiresAction, isTrue);
    });
    test('false for safe/caution/warning', () {
      for (final level in ['safe', 'caution', 'warning']) {
        expect(makeResult(riskLevel: level).requiresAction, isFalse, reason: level);
      }
    });
  });

  group('UvAnalysisResult.medUsedPercent', () {
    test('converts fraction to percentage correctly', () {
      final result = makeResult(riskLevel: 'caution', medUsedFraction: 0.65);
      expect(result.medUsedPercent, closeTo(65.0, 0.001));
    });

    test('100% when fraction is 1.0', () {
      final result = makeResult(riskLevel: 'exceeded', medUsedFraction: 1.0);
      expect(result.medUsedPercent, closeTo(100.0, 0.001));
    });
  });
}
