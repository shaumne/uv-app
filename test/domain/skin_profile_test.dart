import 'package:flutter_test/flutter_test.dart';
import 'package:uv_dosimeter/features/onboarding/domain/entities/skin_profile.dart';

/// Unit tests for [SkinProfile] domain entity.
///
/// Validates immutability, equality semantics, and valid range of values.
void main() {
  group('SkinProfile entity', () {
    test('two identical instances are equal', () {
      const a = SkinProfile(fitzpatrickType: 2, spf: 50);
      const b = SkinProfile(fitzpatrickType: 2, spf: 50);
      expect(a, equals(b));
    });

    test('instances with different types are not equal', () {
      const a = SkinProfile(fitzpatrickType: 1, spf: 30);
      const b = SkinProfile(fitzpatrickType: 2, spf: 30);
      expect(a, isNot(equals(b)));
    });

    test('instances with different SPF are not equal', () {
      const a = SkinProfile(fitzpatrickType: 3, spf: 30);
      const b = SkinProfile(fitzpatrickType: 3, spf: 50);
      expect(a, isNot(equals(b)));
    });

    test('all valid Fitzpatrick types 1–6 can be created', () {
      for (var type = 1; type <= 6; type++) {
        expect(
          () => SkinProfile(fitzpatrickType: type, spf: 30),
          returnsNormally,
        );
      }
    });

    test('spf value is stored correctly', () {
      const profile = SkinProfile(fitzpatrickType: 4, spf: 50);
      expect(profile.spf, equals(50));
    });

    test('fitzpatrickType value is stored correctly', () {
      const profile = SkinProfile(fitzpatrickType: 5, spf: 15);
      expect(profile.fitzpatrickType, equals(5));
    });
  });
}
