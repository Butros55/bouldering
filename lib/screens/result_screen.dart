import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;

  const ResultScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verarbeitetes Bild')),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
