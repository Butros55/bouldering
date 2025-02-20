import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImageProcessor {
  static final String _serverUrl = 'http://127.0.0.1:5000/process';

  /// Diese Methode sendet das Bild an den Server und parst den JSON-Response.
  /// Auf allen Plattformen wird ein Map<String, dynamic> zurückgegeben,
  /// das mindestens die Schlüssel "processed_image" (base64-codierter Bildstring)
  /// und "grip_data" enthält.
  static Future<Map<String, dynamic>> processImage(dynamic image) async {
    http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse(_serverUrl),
    );

    if (kIsWeb) {
      // Auf Web erwarten wir, dass image vom Typ Uint8List ist.
      if (image is! Uint8List) {
        throw Exception('Auf Web muss image vom Typ Uint8List sein.');
      }
      request.files.add(
        http.MultipartFile.fromBytes('image', image, filename: 'image.jpg'),
      );
    } else {
      // Auf mobilen Plattformen erwarten wir ein File
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
      final responseString = utf8.decode(bytes);
      // Hier parsen wir den JSON-Response
      final Map<String, dynamic> result = json.decode(responseString);
      return result;
    } else {
      throw Exception(
        'Bildverarbeitung fehlgeschlagen: ${response.statusCode}',
      );
    }
  }
}
