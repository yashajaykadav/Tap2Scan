import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'file_service.dart';

class PdfService {
  static Future<String> createPdfFromImage(String imagePath) async {
    try {
      // Load and compress image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Decode and compress
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if too large (max 1500px width)
      if (originalImage.width > 1500) {
        originalImage = img.copyResize(
          originalImage,
          width: 1500,
        );
      }

      // Encode as JPEG with compression
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(originalImage, quality: 85),
      );

      // Create PDF
      final pdf = pw.Document();
      final image = pw.MemoryImage(compressedBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );

      // Save PDF
      final docPath = await FileService.getDocumentsPath();
      final fileName = FileService.generateFileName();
      final pdfPath = '$docPath/$fileName';

      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      // Clean old files
      await FileService.cleanOldFiles();

      return pdfPath;
    } catch (e) {
      throw Exception('Failed to create PDF: $e');
    }
  }
}