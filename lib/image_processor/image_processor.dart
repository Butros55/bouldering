import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImageProcessor {
  static final String _serverUrl = 'http://127.0.0.1:5000/process';

  /// Erwartet:
  /// - Auf Mobile: [image] als File
  /// - Auf Web: [image] als Uint8List
  /// Rückgabe:
  /// - Auf Mobile: File (Pfad als String)
  /// - Auf Web: Uint8List (verarbeitete Bildbytes)
  static Future<dynamic> processImage(dynamic image) async {
    http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse(_serverUrl),
    );
    if (kIsWeb) {
      if (image is! Uint8List) {
        throw Exception('Auf Web muss image vom Typ Uint8List sein.');
      }
      request.files.add(
        http.MultipartFile.fromBytes('image', image, filename: 'image.jpg'),
      );
    } else {
      if (image is! File) {
        throw Exception(
          'Auf mobilen Plattformen muss image vom Typ File sein.',
        );
      }
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
      if (kIsWeb) {
        return bytes; // Rückgabe als Uint8List
      } else {
        final processedImage = File('${image.path}_processed.jpg');
        await processedImage.writeAsBytes(bytes);
        return processedImage; // Rückgabe als File
      }
    } else {
      throw Exception(
        'Bildverarbeitung fehlgeschlagen: ${response.statusCode}',
      );
    }
  }
}
