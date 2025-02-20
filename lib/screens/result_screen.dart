import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  // Erwartet ein Map, das "processed_image" und "grip_data" enthält.
  final Map<String, dynamic> processedResult;

  const ResultScreen({Key? key, required this.processedResult})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extrahiere und dekodiere das Bild
    String base64Image = processedResult["processed_image"] as String;
    Uint8List imageBytes = base64Decode(base64Image);

    // Konvertiere die Grip-Daten in einen schön formatierten JSON-String
    String jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(processedResult["grip_data"]);

    return Scaffold(
      appBar: AppBar(title: const Text('Verarbeitetes Bild')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.memory(imageBytes),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                jsonString,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
