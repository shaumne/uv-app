import 'package:dio/dio.dart';
import '../../domain/entities/scan_request.dart';

/// Converts [ScanRequest] to a Dio [FormData] for multipart/form-data POST.
class ScanRequestModel {
  static Future<FormData> toFormData(
    ScanRequest request,
    double cumulativeDoseJm2,
    double uvIndex,
    double hoursSinceApplication,
  ) async {
    return FormData.fromMap({
      'image': await MultipartFile.fromFile(
        request.imagePath,
        filename: 'sticker.jpg',
      ),
      'ambient_lux': request.ambientLux,
      'skin_type': request.fitzpatrickType,
      'spf': request.spf,
      'cumulative_dose_jm2': cumulativeDoseJm2,
      'uv_index': uvIndex,
      'hours_since_application': hoursSinceApplication,
    });
  }
}
