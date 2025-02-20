import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  // processedImage kann entweder ein String (Pfad) oder Uint8List sein.
  final dynamic processedImage;

  const ResultScreen({Key? key, required this.processedImage})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (processedImage == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verarbeitetes Bild')),
        body: const Center(child: Text('Kein Bild wurde verarbeitet.')),
      );
    }

    Widget imageWidget;
    if (kIsWeb) {
      try {
        imageWidget = Image.memory(processedImage as Uint8List);
      } catch (e) {
        imageWidget = const Text('Fehler beim Anzeigen des Bildes.');
      }
    } else {
      try {
        imageWidget = Image.file(File(processedImage as String));
      } catch (e) {
        imageWidget = const Text('Fehler beim Anzeigen des Bildes.');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verarbeitetes Bild')),
      body: Center(child: imageWidget),
    );
  }
}
