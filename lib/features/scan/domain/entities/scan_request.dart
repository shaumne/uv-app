import 'package:equatable/equatable.dart';

/// Input payload sent to the FastAPI `/analyze` endpoint.
///
/// [imagePath] points to the captured image on local device storage.
/// [ambientLux] is the ambient light sensor reading used for white balance.
/// [fitzpatrickType] and [spf] allow the backend to run the MED calculation.
class ScanRequest extends Equatable {
  const ScanRequest({
    required this.imagePath,
    required this.ambientLux,
    required this.fitzpatrickType,
    required this.spf,
  });

  final String imagePath;
  final double ambientLux;
  final int fitzpatrickType;
  final int spf;

  @override
  List<Object> get props => [imagePath, ambientLux, fitzpatrickType, spf];
}
