import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/scanned_document.dart';

class FileService {
  static Future<String> getDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final docPath = '${directory.path}/Scans';

    // Create directory if it doesn't exist
    final docDirectory = Directory(docPath);
    if (!await docDirectory.exists()) {
      await docDirectory.create(recursive: true);
    }

    return docPath;
  }

  static String generateFileName() {
    final now = DateTime.now();
    return 'Scan_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.pdf';
  }

  static Future<List<ScannedDocument>> getRecentDocuments() async {
    final path = await getDocumentsPath();
    final directory = Directory(path);

    if (!await directory.exists()) {
      return [];
    }

    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.pdf'))
        .toList();

    files.sort((a, b) =>
        b.statSync().modified.compareTo(a.statSync().modified));

    return files.take(10).map((file) {
      final fileName = file.path.split('/').last;
      return ScannedDocument(
        fileName: fileName,
        filePath: file.path,
        dateTime: file.statSync().modified,
      );
    }).toList();
  }

  static Future<void> cleanOldFiles() async {
    final documents = await getRecentDocuments();

    if (documents.length > 10) {
      for (var i = 10; i < documents.length; i++) {
        final file = File(documents[i].filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }
}