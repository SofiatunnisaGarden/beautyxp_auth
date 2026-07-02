import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ml_services.dart';
import 'questionnaire.dart';
import '../screens/main_screen.dart';
import '../services/firestore_service.dart';

class SkinResultPage extends StatefulWidget {
  final File imageFile;
  const SkinResultPage({super.key, required this.imageFile});

  @override
  State<SkinResultPage> createState() => _SkinResultPageState();
}

class _SkinResultPageState extends State<SkinResultPage> {
  final MLService _mlService = MLService();
  bool _isLoading = true;
  bool _isSaving = false;
  SkinPrediction? _prediction;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _runPrediction();
  }

  Future<void> _runPrediction() async {
    try {
      final result = await _mlService.predictImage(widget.imageFile);
      setState(() {
        _prediction = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSkinResult() async {
    if (_prediction == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Create Firebase record for this AI analysis
      final docId = await FirestoreService().createSkinAnalysisRecord(
        skinConcern: _prediction!.predictedClass,
        confidence: _prediction!.confidence,
        imagePath: widget.imageFile.path,
      );

      // Save latest AI result locally for HomeScreen display
      await Future.wait([
        prefs.setString('latest_skin_concern', _prediction!.predictedClass),
        prefs.setDouble('latest_skin_confidence', _prediction!.confidence),
        prefs.setString(
          'latest_skin_analysis_date',
          DateTime.now().toIso8601String(),
        ),
        prefs.setString('latest_skin_image_path', widget.imageFile.path),

        // Important: save Firestore document ID for questionnaire/recommendation later
        prefs.setString('current_analysis_doc_id', docId),
      ]);

      if (!mounted) return;

  _showQuizPromptDialog();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save result: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showQuizPromptDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFFA259B3),
                  size: 50,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Result Saved!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Let's answer some quiz to know your skin type.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close popup

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuestionnaireScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA259B3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Take the Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 0),
                  ),
                  (route) => false,
                );
                },
                child: const Text(
                  'Return Home',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mlService.close();
    super.dispose();
  }

  // Condensed Helper Method
  String _formatClass(String className) => className.replaceAll('_', ' ').toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FF),
      appBar: AppBar(
        title: const Text('Skin Analysis Result'),
        backgroundColor: const Color(0xFFEDE2F2),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _buildBody(), // Moved logic to a cleaner helper method
    );
  }

  Widget _buildBody() {
    // Handle Loading State
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFA259B3)));
    }
    
    // Handle Error State
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Prediction failed:\n$_errorMessage', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        ),
      );
    }

    // Sort probabilities cleanly in one line
    final sortedProbs = _prediction!.probabilities.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // 3. Handle Success State
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 280,
              color: Colors.black,
              child: Image.file(widget.imageFile, fit: BoxFit.contain, width: double.infinity),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Detected Skin Result', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(_formatClass(_prediction!.predictedClass), textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8),
          Text('Confidence: ${(_prediction!.confidence * 100).toStringAsFixed(2)}%', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 28),
          const Text('All Class Probabilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          // Generate the probability cards
          ...sortedProbs.map((entry) => Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  title: Text(_formatClass(entry.key), style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Text('${(entry.value * 100).toStringAsFixed(2)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              )),
              
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // close SkinResultPage
                    Navigator.pop(context); // close CameraPreviewScreen, return to CameraScreen
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSkinResult,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Result'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA259B3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}