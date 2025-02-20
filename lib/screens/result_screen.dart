import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic>? processedResult;

  const ResultScreen({super.key, required this.processedResult});

  @override
  Widget build(BuildContext context) {
    if (processedResult == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verarbeitetes Bild')),
        body: const Center(child: Text('Keine Daten erhalten.')),
      );
    }

    Uint8List origBytes;
    Uint8List procBytes;
    try {
      final String origBase64 = processedResult!["original_image"] as String;
      final String procBase64 = processedResult!["processed_image"] as String;
      origBytes = base64Decode(origBase64);
      procBytes = base64Decode(procBase64);
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verarbeitetes Bild')),
        body: const Center(child: Text('Fehler beim Dekodieren der Bilder.')),
      );
    }

    String jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(processedResult!["grip_data"]);

    return Scaffold(
      appBar: AppBar(title: const Text('Verarbeitetes Bild')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 650,
                    height: 650,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.memory(origBytes, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 650,
                    height: 650,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.memory(procBytes, fit: BoxFit.contain),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Erkannte Griff-Daten:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  jsonString,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
