import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const OCRApp());
}

class OCRApp extends StatelessWidget {
  const OCRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Font Classifier',
      theme: ThemeData.dark(),
      home: const OCRHomePage(),
    );
  }
}

class OCRHomePage extends StatefulWidget {
  const OCRHomePage({super.key});

  @override
  State<OCRHomePage> createState() => _OCRHomePageState();
}

class _OCRHomePageState extends State<OCRHomePage> {
  File? _image;
  List<Map<String, dynamic>> _classifiedText = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _classifiedText = [];
    });

    await _processImage(File(picked.path));
  }

  Future<void> _processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    List<double> heights = [];

    List<Map<String, dynamic>> results = [];
    for (TextBlock block in recognizedText.blocks) {
      var linehightmean = 0;
      for (TextLine line in block.lines) {
        final h = line.boundingBox.height ?? 0;
        linehightmean += h.toInt();
      }
      heights.add(linehightmean / block.lines.length);
      results.add({
        'height': linehightmean / block.lines.length,
        'text': block.lines.map((line) => line.text).join(' '),
      });
    }

    setState(() {
      _classifiedText = results;
    });

    await textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('OCR Font Classifier'),
        actions: [
          IconButton(icon: const Icon(Icons.image), onPressed: _pickImage),
        ],
      ),
      body: _image == null
          ? const Center(child: Text('Pick an image to begin.'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Image.file(_image!, height: 200, fit: BoxFit.cover),
                  const Divider(),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(16),

                    child: Text.rich(
                      TextSpan(
                        children: _classifiedText
                            .map(
                              (item) => TextSpan(
                                text: item['text'] + '\n',
                                style: TextStyle(fontSize: item['height']),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
