import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRDataSource {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );

    return recognizedText.text;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
