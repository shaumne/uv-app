import 'package:flutter_test/flutter_test.dart';
import 'package:uv_dosimeter/core/constants/uv_constants.dart';

/// Unit tests for [UvConstants] — validates MED baseline values against
/// ICNIRP/CIE photobiology standards as specified in the
/// Dermatology_Math_Engine skill.
void main() {
  group('UvConstants', () {
    group('medBaselineJoules', () {
      test('contains all 6 Fitzpatrick types', () {
        expect(UvConstants.medBaselineJoules.length, 6);
        for (var i = 1; i <= 6; i++) {
          expect(
            UvConstants.medBaselineJoules.containsKey(i),
            isTrue,
            reason: 'Type $i should be in MED table',
          );
        }
      });

      test('values match ICNIRP/skill spec exactly', () {
        const expected = {
          1: 200.0,
          2: 250.0,
          3: 350.0,
          4: 500.0,
          5: 700.0,
          6: 1000.0,
        };
        for (final entry in expected.entries) {
          expect(
            UvConstants.medBaselineJoules[entry.key],
            equals(entry.value),
            reason:
                'Type ${entry.key}: expected ${entry.value} J/m², '
                'got ${UvConstants.medBaselineJoules[entry.key]}',
          );
        }
      });

      test('values are ascending with Fitzpatrick type', () {
        final values = [for (var i = 1; i <= 6; i++) UvConstants.medBaselineJoules[i]!];
        for (var i = 0; i < values.length - 1; i++) {
          expect(
            values[i + 1] > values[i],
            isTrue,
            reason: 'MED must increase with skin type',
          );
        }
      });
    });

    test('uvIrradiancePerIndex matches WHO standard (0.025 W/m²)', () {
      expect(UvConstants.uvIrradiancePerIndex, closeTo(0.025, 1e-10));
    });

    test('warnThreshold is below dangerThreshold', () {
      expect(UvConstants.warnThreshold, lessThan(UvConstants.dangerThreshold));
    });

    test('defaultSpf is 1 (no sunscreen)', () {
      expect(UvConstants.defaultSpf, equals(1));
    });
  });
}
