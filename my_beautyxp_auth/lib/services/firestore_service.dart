import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _historyCollection =
      FirebaseFirestore.instance.collection('analysis_history');

  // Create record after AI skin concern analysis
  Future<String> createSkinAnalysisRecord({
    required String skinConcern,
    required double confidence,
    required String imagePath,
  }) async {
    try {
      final docRef = await _historyCollection.add({
        'skinConcern': skinConcern,
        'confidence': confidence,
        'imagePath': imagePath,

        'skinType': 'Unknown',
        'skinStatus': '',
        'budget': '',
        'products': <String>[],

        'timestamp': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print("Error creating skin analysis record: $e");
      rethrow;
    }
  }

  // Create record if user only answers quiz without AI scan
  Future<String> createSkinTypeOnlyRecord({
    required String skinType,
    required String skinStatus,
  }) async {
    try {
      final docRef = await _historyCollection.add({
        'skinConcern': 'Unknown',
        'confidence': 0.0,
        'imagePath': '',

        'skinType': skinType,
        'skinStatus': skinStatus,
        'budget': '',
        'products': <String>[],

        'timestamp': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print("Error creating skin type record: $e");
      rethrow;
    }
  }

  // Update same record with questionnaire result
  Future<void> updateSkinTypeResult({
    required String docId,
    required String skinType,
    required String skinStatus,
  }) async {
    try {
      await _historyCollection.doc(docId).update({
        'skinType': skinType,
        'skinStatus': skinStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating skin type result: $e");
      rethrow;
    }
  }

  // Update same record with recommendation result
  Future<void> updateRecommendationResult({
    required String docId,
    required String skinType,
    required String budget,
    required List<String> products,
  }) async {
    try {
      await _historyCollection.doc(docId).update({
        'skinType': skinType,
        'budget': budget,
        'products': products,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating recommendation result: $e");
      rethrow;
    }
  }

  // Backup method: create full recommendation record if no docId exists
  Future<String> saveAnalysis({
    required String skinType,
    required String budget,
    required List<String> products,
    String skinConcern = 'Unknown',
    double confidence = 0.0,
    String imagePath = '',
    String skinStatus = '',
  }) async {
    try {
      final docRef = await _historyCollection.add({
        'skinConcern': skinConcern,
        'confidence': confidence,
        'imagePath': imagePath,
        'skinType': skinType,
        'skinStatus': skinStatus,
        'budget': budget,
        'products': products,
        'timestamp': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print("Error saving analysis: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getAnalysisHistory() {
    return _historyCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteAnalysis(String docId) async {
    try {
      await _historyCollection.doc(docId).delete();
    } catch (e) {
      print("Error deleting analysis: $e");
      rethrow;
    }
  }
}