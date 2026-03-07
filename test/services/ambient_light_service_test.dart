import 'package:flutter_test/flutter_test.dart';
import 'package:uv_dosimeter/core/services/ambient_light_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AmbientLightService', () {
    late AmbientLightService service;

    setUp(() {
      service = AmbientLightService();
    });

    test('getCurrentLux returns a non-negative double', () async {
      final lux = await service.getCurrentLux();
      expect(lux, isA<double>());
      expect(lux, greaterThanOrEqualTo(0));
      // Sensor or fallback; fallback is 500
      expect(lux, lessThanOrEqualTo(200000));
    });
  });
}
