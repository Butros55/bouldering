import 'dart:io';
import 'package:boulder_ai/image_processor/image_processor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  // Option 1: Foto aufnehmen (Kamera)
  Future<void> _takePicture() async {
    try {
      final XFile? picture = await _picker.pickImage(
        source: ImageSource.camera,
      );
      if (picture != null) {
        if (kIsWeb) {
          // Auf Web: Nutze Bildbytes
          Uint8List imageBytes = await picture.readAsBytes();
          final processed = await ImageProcessor.processImage(imageBytes);
          if (!mounted) return;
          Navigator.pushNamed(context, '/result', arguments: processed);
        } else {
          // Auf Mobile: Nutze File
          File imageFile = File(picture.path);
          final processed = await ImageProcessor.processImage(imageFile);
          if (!mounted) return;
          Navigator.pushNamed(context, '/result', arguments: processed);
        }
      }
    } catch (e) {
      debugPrint('Fehler beim Aufnehmen des Fotos: $e');
    }
  }

  // Option 2: Bild aus der Galerie auswählen
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        if (kIsWeb) {
          Uint8List imageBytes = await pickedFile.readAsBytes();
          final processed = await ImageProcessor.processImage(imageBytes);
          if (!mounted) return;
          Navigator.pushNamed(context, '/result', arguments: processed);
        } else {
          File imageFile = File(pickedFile.path);
          final processed = await ImageProcessor.processImage(imageFile);
          if (!mounted) return;
          Navigator.pushNamed(context, '/result', arguments: processed);
        }
      }
    } catch (e) {
      debugPrint('Fehler beim Auswählen eines Bildes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boulder AI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _takePicture,
              child: const Text('Foto aufnehmen'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Bild hochladen'),
            ),
          ],
        ),
      ),
    );
  }
}
