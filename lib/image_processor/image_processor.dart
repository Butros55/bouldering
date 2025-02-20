import 'dart:io';
import 'package:http/http.dart' as http;

class ImageProcessor {
  static Future<File> processImage(File image) async {
    // Ersetze '<deine-ip-adresse>' durch die IP deines Computers (im selben Netzwerk)
    var uri = Uri.parse('http://192.168.188.27:5000/process');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    
    var response = await request.send();
    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
      final processed = File('${image.path}_processed.jpg');
      await processed.writeAsBytes(bytes);
      return processed;
    } else {
      throw Exception('Fehler bei der Bildverarbeitung: ${response.statusCode}');
    }
  }
}
