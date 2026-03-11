import 'package:dio/dio.dart';
import '../../domain/entities/scan_request.dart';

/// Converts [ScanRequest] to a Dio [FormData] for multipart/form-data POST.
class ScanRequestModel {
  static Future<FormData> toFormData(ScanRequest request) async {
    return FormData.fromMap({
      'image': await MultipartFile.fromFile(
        request.imagePath,
        filename: 'sticker.jpg',
      ),
      'pre_cropped': 'true', // Client sends only the guide ROI
      'ambient_lux': request.ambientLux,
      'skin_type': request.fitzpatrickType,
      'spf': request.spf,
      'cumulative_dose_jm2': request.cumulativeDoseJm2,
      'uv_index': request.uvIndex,
      'hours_since_application': request.hoursSinceApplication,
    });
  }
}
