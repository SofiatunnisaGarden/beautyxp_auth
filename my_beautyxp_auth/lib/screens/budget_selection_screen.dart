import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/budget_card.dart';
import 'recommendation_screen.dart';

class BudgetSelectionScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const BudgetSelectionScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<BudgetSelectionScreen> createState() =>
      _BudgetSelectionScreenState();
}

class _BudgetSelectionScreenState extends State<BudgetSelectionScreen> {
  int selectedBudget = -1;

  String skinType = "Loading...";

  @override
  void initState() {
    super.initState();
    loadSkinType();
  }

  Future<void> loadSkinType() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedType = prefs.getString('skin_type');

    print("Loaded skin type: $savedType");

    setState(() {
      skinType = savedType ?? "Unknown";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFFB657B4),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Products Budget',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1D8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.face_retouching_natural,
                      color: Color(0xFFB85CA8),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Skin Type: $skinType',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B2CBF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Select Your Budget",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2E8FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [

                    const Icon(Icons.wallet),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Text(
                        "We'll recommend the best products for your $skinType Skin within your budget.",
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 10),

              BudgetCard(
                selected: selectedBudget == 0,
                icon: "💚",
                title: "RM20 - RM50",
                badge: "Affordable",
                subtitle:
                    "Budget-friendly picks that still work great",
                onTap: () {
                  setState(() {
                    selectedBudget = 0;
                  });
                },
              ),

              const SizedBox(height: 15),

              BudgetCard(
                selected: selectedBudget == 1,
                icon: "💛",
                title: "RM50 - RM100",
                badge: "Popular",
                subtitle:
                    "Mid-range products with proven ingredients",
                onTap: () {
                  setState(() {
                    selectedBudget = 1;
                  });
                },
              ),

              const SizedBox(height: 15),

              BudgetCard(
                selected: selectedBudget == 2,
                icon: "💎",
                title: "RM100+",
                badge: "Premium",
                subtitle:
                    "Premium & luxury skincare formulas",
                onTap: () {
                  setState(() {
                    selectedBudget = 2;
                  });
                },
              ),

            ],
          ),
        ),
      ),

      /// CONTINUE BUTTON
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 24,
          top: 14,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B21A8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: selectedBudget == -1
              ? null
              : () {

                  String budget = "";

                  switch (selectedBudget) {
                    case 0:
                      budget = "Budget";
                      break;

                    case 1:
                      budget = "Mid";
                      break;

                    case 2:
                      budget = "Premium";
                      break;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecommendationScreen(
                        skinType: skinType,
                        budget: budget,
                      ),
                    ),
                  );
                },
          child: const Text(
            "Continue",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}