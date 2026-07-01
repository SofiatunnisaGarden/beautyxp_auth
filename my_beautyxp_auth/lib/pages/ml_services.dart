import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class SkinPrediction {
  final String predictedClass;
  final double confidence;
  final Map<String, double> probabilities;

  SkinPrediction({
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
  });
}

class MLService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  static const String _modelPath = 'assets/BeautyXP_SkinConcern_Model2.tflite';
  static const String _labelsPath = 'assets/BeautyXP_labels.txt';

  Future<void> loadModel() async {
    _interpreter ??= await Interpreter.fromAsset(_modelPath);

    final labelsRaw = await rootBundle.loadString(_labelsPath);

    _labels = labelsRaw
        .split('\n')
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList();

    if (_labels.isEmpty) {
      throw Exception('Labels file is empty.');
    }
  }

  Future<SkinPrediction> predictImage(File imageFile) async {
    if (_interpreter == null || _labels.isEmpty) {
      await loadModel();
    }

    final imageBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception('Unable to decode image.');
    }

    final resizedImage = img.copyResize(
      decodedImage,
      width: 224,
      height: 224,
    );

    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resizedImage.getPixel(x, y);

            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          },
        ),
      ),
    );

    final output = List.generate(
      1,
      (_) => List<double>.filled(_labels.length, 0.0),
    );

    _interpreter!.run(input, output);

    final probabilities = output[0];

    int maxIndex = 0;
    double maxConfidence = probabilities[0];

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        maxIndex = i;
      }
    }

    final probabilityMap = <String, double>{};

    for (int i = 0; i < _labels.length; i++) {
      probabilityMap[_labels[i]] = probabilities[i];
    }

    return SkinPrediction(
      predictedClass: _labels[maxIndex],
      confidence: maxConfidence,
      probabilities: probabilityMap,
    );
  }

  void close() {
    _interpreter?.close();
  }
}