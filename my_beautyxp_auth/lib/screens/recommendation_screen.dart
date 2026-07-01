import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/products.dart';
import '../models/product.dart';
import '../services/firestore_service.dart'; 

class RecommendationScreen extends StatelessWidget {
  final String skinType;
  final String budget;

  const RecommendationScreen({
    super.key,
    required this.skinType,
    required this.budget,
  });

  String budgetText(String budget) {
    switch (budget) {
      case "Budget":
        return "RM20 - RM50";
      case "Mid":
        return "RM50 - RM100";
      case "Premium":
        return "RM100+";
      default:
        return budget;
    }
  }

  String categoryIcon(String category) {
    switch (category) {
      case "Cleanser":
        return "🫧";
      case "Moisturizer":
        return "💧";
      case "Sunscreen":
        return "☀️";
      default:
        return "✨";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> recommendations = allProducts.where((product) {
      return product.skinType == skinType && product.budget == budget;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "Recommended For You",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// SUMMARY CHIPS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSummaryChip(
                      icon: Icons.face, 
                      label: skinType, 
                      backgroundColor: const Color(0xFFE0F2FE),
                      textColor: const Color(0xFF0369A1),
                    ),
                    const SizedBox(width: 8),
                    _buildSummaryChip(
                      icon: Icons.payments_outlined, 
                      label: budgetText(budget), 
                      backgroundColor: const Color(0xFFF0FDF4),
                      textColor: const Color(0xFF15803D),
                    ),
                    const SizedBox(width: 8),
                    _buildSummaryChip(
                      icon: Icons.auto_awesome, 
                      label: "${recommendations.length} Found", 
                      backgroundColor: const Color(0xFFF3E8FF),
                      textColor: const Color(0xFF6B21A8),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// PRODUCT LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final product = recommendations[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "${categoryIcon(product.category)} ${product.category}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B21A8),
                                ),
                              ),
                            ),
                            Text(
                              "RM ${product.price}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Image.asset(
                            product.image,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product.description,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// PINNED BOTTOM SAVE BUTTON
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 14),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final String? docId = prefs.getString('current_analysis_doc_id');

            final List<String> productNames =
                recommendations.map((e) => e.name).toList();

            if (docId != null && docId.isNotEmpty) {
              // Update the same Firebase record from AI/quiz result
              await FirestoreService().updateRecommendationResult(
                docId: docId,
                skinType: skinType,
                budget: budget,
                products: productNames,
              );
            } else {
              // Backup: create a new record if no previous analysis document exists
              final newDocId = await FirestoreService().saveAnalysis(
                skinType: skinType,
                budget: budget,
                products: productNames,
              );

              await prefs.setString('current_analysis_doc_id', newDocId);
            }

            // Clear current doc ID after recommendation is fully saved
            await prefs.remove('current_analysis_doc_id');

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).clearSnackBars();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      "Routine saved! Your skin will thank you later.",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF27272A),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          
          child: const Text(
            "Save Recommendation",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryChip({
    required IconData icon, 
    required String label, 
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}