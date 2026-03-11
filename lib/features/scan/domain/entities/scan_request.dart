import 'package:equatable/equatable.dart';

/// Input payload sent to the FastAPI `/analyze` endpoint.
///
/// [imagePath] points to the captured image on local device storage.
/// [ambientLux] is the ambient light sensor reading used for white balance.
/// [fitzpatrickType] and [spf] allow the backend to run the MED calculation.
/// [cumulativeDoseJm2], [uvIndex], [hoursSinceApplication] are passed at call
/// time (from home state) so the repository stays stateless and testable.
class ScanRequest extends Equatable {
  const ScanRequest({
    required this.imagePath,
    required this.ambientLux,
    required this.fitzpatrickType,
    required this.spf,
    required this.cumulativeDoseJm2,
    required this.uvIndex,
    required this.hoursSinceApplication,
  });

  final String imagePath;
  final double ambientLux;
  final int fitzpatrickType;
  final int spf;
  final double cumulativeDoseJm2;
  final double uvIndex;
  final double hoursSinceApplication;

  @override
  List<Object> get props => [
        imagePath,
        ambientLux,
        fitzpatrickType,
        spf,
        cumulativeDoseJm2,
        uvIndex,
        hoursSinceApplication,
      ];
}
