import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/main_screen.dart';
import '../services/firestore_service.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  
  // Store user answers here
  List<String?> _answers = List.filled(10, null);

  // The 10-Question Skincare Deck
  final List<Map<String, dynamic>> _questions = [
    {
      "question": "How does your skin feel 30 minutes after washing your face?",
      "options": [
        {"text": "Tight, stretched, or flaky", "type": "Dry"},
        {"text": "Comfortable and balanced", "type": "Normal"},
        {"text": "Shiny and slick all over", "type": "Oily"},
        {"text": "Oily on the forehead/nose, tight on cheeks", "type": "Combination"},
      ]
    },
    {
      "question": "By midday, how does your complexion look?",
      "options": [
        {"text": "Dull or feeling dry", "type": "Dry"},
        {"text": "Fresh and mostly matte", "type": "Normal"},
        {"text": "Shiny all over, needing powder", "type": "Oily"},
        {"text": "Shiny mostly in the T-zone", "type": "Combination"},
      ]
    },
    {
      "question": "Looking closely in a mirror, how would you describe your pores?",
      "options": [
        {"text": "Practically invisible", "type": "Dry"},
        {"text": "Small and normal-looking", "type": "Normal"},
        {"text": "Large and visible everywhere", "type": "Oily"},
        {"text": "Visible only around the nose", "type": "Combination"},
      ]
    },
    {
      "question": "How often do you experience breakouts?",
      "options": [
        {"text": "Rarely, I get dry patches instead", "type": "Dry"},
        {"text": "Occasionally (hormonal/stress)", "type": "Normal"},
        {"text": "Frequently all over my face", "type": "Oily"},
        {"text": "Mostly just in the T-zone", "type": "Combination"},
      ]
    },
    {
      "question": "When you apply moisturizer, how does your skin react?",
      "options": [
        {"text": "It drinks it up instantly", "type": "Dry"},
        {"text": "It absorbs nicely and feels hydrated", "type": "Normal"},
        {"text": "It feels heavy and greasy", "type": "Oily"},
        {"text": "Good on cheeks, greasy on forehead", "type": "Combination"},
      ]
    },
    {
      "question": "How does your skin generally feel to the touch?",
      "options": [
        {"text": "Rough, thin, or slightly textured", "type": "Dry"},
        {"text": "Smooth and supple", "type": "Normal"},
        {"text": "Slightly thick and slick", "type": "Oily"},
        {"text": "Uneven depending on the area", "type": "Combination"},
      ]
    },
    {
      "question": "How does your skin react to the sun or hot weather?",
      "options": [
        {"text": "It feels easily irritated or burns", "type": "Dry"},
        {"text": "It handles it fairly well", "type": "Normal"},
        {"text": "It gets incredibly greasy quickly", "type": "Oily"},
        {"text": "My T-zone sweats and gets oily fast", "type": "Combination"},
      ]
    },
    {
      "question": "When you wear foundation or liquid sunscreen, how does it look after a few hours?",
      "options": [
        {"text": "It clings to dry patches or looks flaky", "type": "Dry"},
        {"text": "It stays put and looks mostly the same", "type": "Normal"},
        {"text": "It slides off or gets incredibly shiny", "type": "Oily"},
        {"text": "It fades on the nose, but stays on cheeks", "type": "Combination"},
      ]
    },
    {
      "question": "If you splash your face with just plain water (no cleanser), how does it feel?",
      "options": [
        {"text": "Tight, I need moisturizer immediately", "type": "Dry"},
        {"text": "Refreshed and normal", "type": "Normal"},
        {"text": "Still a bit greasy or unclean", "type": "Oily"},
        {"text": "Cheeks feel fine, forehead feels unclean", "type": "Combination"},
      ]
    },
    {
      "question": "How does your skin react in a heavily air-conditioned room?",
      "options": [
        {"text": "Extremely dry, tight, and uncomfortable", "type": "Dry"},
        {"text": "Mostly comfortable and balanced", "type": "Normal"},
        {"text": "It feels better, or stays slightly oily", "type": "Oily"},
        {"text": "Cheeks get tight, T-zone stays oily", "type": "Combination"},
      ]
    }
  ];

  void _handleAnswer(String skinType) {
    HapticFeedback.lightImpact(); // Subtle vibration
    
    setState(() {
      _answers[_currentIndex] = skinType;
    });

    // Auto-advance after a tiny delay so they can see their selection
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_currentIndex < _questions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400), 
          curve: Curves.easeInOut,
        );
      } else {
        _calculateAndSaveResult();
      }
    });
  }

  Future<void> _calculateAndSaveResult() async {
    Map<String, int> counts = {
      "Dry": 0,
      "Normal": 0,
      "Oily": 0,
      "Combination": 0,
    };

    for (var answer in _answers) {
      if (answer != null) {
        counts[answer] = counts[answer]! + 1;
      }
    }

    // 1. Determine final skin type
    String finalSkinType = counts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // 2. Determine skin status
    String inferredStatus = "";

    switch (finalSkinType) {
      case "Dry":
        inferredStatus = "Needs deep hydration & barrier repair";
        break;
      case "Normal":
        inferredStatus = "Balanced & healthy";
        break;
      case "Oily":
        inferredStatus = "Dehydrated / Overproducing";
        break;
      case "Combination":
        inferredStatus = "Balanced but requires targeted care";
        break;
    }

    final prefs = await SharedPreferences.getInstance();

    // 3. Save locally for HomeScreen display
    await prefs.setString('skin_type', finalSkinType);
    await prefs.setString('skin_status', inferredStatus);

    // 4. Save/update Firebase
    String? docId = prefs.getString('current_analysis_doc_id');

    if (docId != null && docId.isNotEmpty) {
      // If AI result was saved first, update the same Firebase document
      await FirestoreService().updateSkinTypeResult(
        docId: docId,
        skinType: finalSkinType,
        skinStatus: inferredStatus,
      );
    } else {
      // If user takes quiz only, create a new Firebase document
      docId = await FirestoreService().createSkinTypeOnlyRecord(
        skinType: finalSkinType,
        skinStatus: inferredStatus,
      );

      await prefs.setString('current_analysis_doc_id', docId);
    }

    if (mounted) {
      _showResultDialog(finalSkinType);
    }
  }

  void _showResultDialog(String skinType) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars,
                color: Color(0xFFA259B3),
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Assessment Complete!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Your baseline skin type is:",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              skinType.toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFFA259B3),
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog

                  Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 2),
                  ),
                  (route) => false,
                );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA259B3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Continue to Budget",
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
                "Return Home",
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
  Widget build(BuildContext context) {
    double progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFB657B4),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Skin Assessment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Question ${_currentIndex + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("${_currentIndex + 1}/${_questions.length}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.purple.shade50,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA259B3)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // Question Card Section
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Prevents manual swiping so they must answer
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionCard(_questions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> questionData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionData['question'],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 30),
          
          ...List.generate(questionData['options'].length, (index) {
            var option = questionData['options'][index];
            bool isSelected = _answers[_currentIndex] == option['type'];

            return GestureDetector(
              onTap: () => _handleAnswer(option['type']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFA259B3) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFA259B3) : Colors.grey.shade200,
                    width: 2,
                  ),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        option['text'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}