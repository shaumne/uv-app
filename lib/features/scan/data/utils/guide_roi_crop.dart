import 'dart:io';

import 'package:image/image.dart' as img;

/// Kılavuz dairenin kapladığı alan: backend ile aynı oran (merkez kare, kenar = min(w,h)*0.45).
const double guideRoiFraction = 0.45;

/// Çekilen fotoğrafı kılavuz alanına göre kırpar; API'ye sadece bu bölge gidecek.
///
/// Merkez kare: kenar = min(genişlik, yükseklik) * [guideRoiFraction].
/// Kaydedilen dosya geçici dizinde oluşturulur; çağıran silmekle yükümlüdür.
///
/// Returns: Kırpılmış görüntünün kaydedildiği dosya yolu.
/// Throws: [Exception] decode/crop/encode veya dosya yazma hatalarında.
Future<String> cropImageToGuideRoi(String sourceImagePath) async {
  final file = File(sourceImagePath);
  if (!await file.exists()) {
    throw Exception('Guide ROI crop: source file not found: $sourceImagePath');
  }

  final bytes = await file.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception('Guide ROI crop: failed to decode image');
  }

  final w = decoded.width;
  final h = decoded.height;
  final size = (w < h ? w : h) * guideRoiFraction;
  if (size < 10) {
    throw Exception('Guide ROI crop: image too small to crop');
  }
  final side = size.toInt();
  final x = (w - side) ~/ 2;
  final y = (h - side) ~/ 2;

  final cropped = img.copyCrop(
    decoded,
    x: x.clamp(0, w - 1),
    y: y.clamp(0, h - 1),
    width: side.clamp(1, w),
    height: side.clamp(1, h),
  );

  final outBytes = img.encodeJpg(cropped, quality: 90);
  if (outBytes == null || outBytes.isEmpty) {
    throw Exception('Guide ROI crop: failed to encode cropped image');
  }

  final dir = file.parent;
  final outPath = '${dir.path}/cropped_roi_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final outFile = File(outPath);
  await outFile.writeAsBytes(outBytes);
  return outPath;
}
