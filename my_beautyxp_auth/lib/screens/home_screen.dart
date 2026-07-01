import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_screen.dart';
import '../pages/questionnaire.dart';
import '../pages/camera.dart';

class HomeScreen extends StatefulWidget {
  final String greet;
  final VoidCallback? onProfileTap;

  const HomeScreen({
    super.key,
    this.greet = 'Welcome to BeautyXP!',
    this.onProfileTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _skinType = "Not Set";
  String _skinStatus = "Please complete the assessment";
  String _latestSkinConcern = "Unknown";
  double _latestSkinConfidence = 0.0;

  late String _currentBeautyTip;

  final List<String> _beautyTips = [
    'Apply moisturizer on damp skin.',
    'Double cleanse to remove makeup.',
    'Drink water for deep hydration.',
    'Use chemical exfoliants, not scrubs.',
  ];

  @override
  void initState() {
    super.initState();
    _beautyTips.shuffle();
    _currentBeautyTip = _beautyTips.first;
    _loadSkinProfile();
  }

  Future<void> _loadSkinProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _skinType = prefs.getString('skin_type') ?? "Not Set";
      _skinStatus =
          prefs.getString('skin_status') ?? "Please complete the assessment";
      _latestSkinConcern = prefs.getString('latest_skin_concern') ?? "Unknown";
      _latestSkinConfidence =
          prefs.getDouble('latest_skin_confidence') ?? 0.0;
    });
  }

  String _formatClass(String value) {
    if (value == "Unknown") return "Not scanned yet";

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Future<void> _openQuestionnaire(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QuestionnaireScreen(),
      ),
    );

    _loadSkinProfile();
  }

  Future<void> _openCamera(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraScreen(),
      ),
    );

    _loadSkinProfile();
  }

  void _openProfile(BuildContext context) {
    if (widget.onProfileTap != null) {
      widget.onProfileTap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB),

      body: Stack(
        children: [
          // Soft pink/purple glow at the top left
          Positioned(
            top: -110,
            left: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x99E8A6E8),
                    Color(0x00E8A6E8),
                  ],
                ),
              ),
            ),
          ),

          // Soft glow behind profile avatar area
          Positioned(
            top: 60,
            right: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x77B85CA8),
                    Color(0x00B85CA8),
                  ],
                ),
              ),
            ),
          ),

          // Small decorative sparkle
          const Positioned(
            top: 125,
            left: 32,
            child: Icon(
              Icons.auto_awesome,
              color: Color(0x55B85CA8),
              size: 22,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.greet,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E1A2F),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () => _openProfile(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFE6A6DE),
                                Color(0xFFB85CA8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFFB85CA8).withOpacity(0.35),
                                blurRadius: 18,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFFB85CA8),
                            child: Text(
                              widget.greet[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ===== BEAUTY TIP =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFFFFECFA),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB85CA8).withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
                          right: 0,
                          top: 0,
                          child: Icon(
                            Icons.auto_awesome,
                            color: Color(0x33B85CA8),
                            size: 42,
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Color(0xFFB85CA8),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Beauty Tip of the Day',
                                  style: TextStyle(
                                    color: Color(0xFF9B6B9B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Text(
                              _currentBeautyTip,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF2E1A2F),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ===== SKIN ANALYSIS =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD94FA3),
                          Color(0xFF8E4BE8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Capture your daily selfie to track progress.',
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Start Skin Analysis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        ElevatedButton.icon(
                          onPressed: () => _openCamera(context),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Selfie'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ===== SKIN PROFILE =====
                  const Text(
                    "Your Skin Profile",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E1A2F),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== SKIN TYPE =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB85CA8).withOpacity(0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFF1D8F0),
                          child: Icon(
                            Icons.face_retouching_natural,
                            color: Color(0xFFB85CA8),
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Type: $_skinType",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E1A2F),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                _skinStatus,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFB85CA8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        TextButton(
                          onPressed: () => _openQuestionnaire(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _skinType == "Not Set" ? "Take" : "Retake",
                            style: const TextStyle(
                              color: Color(0xFFB85CA8),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ===== SKIN CONCERN =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB85CA8).withOpacity(0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFF1D8F0),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFB85CA8),
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Skin Concern: ${_formatClass(_latestSkinConcern)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E1A2F),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                _latestSkinConcern == "Unknown"
                                    ? "Take a selfie analysis to see your skin concern result."
                                    : "Confidence: ${(_latestSkinConfidence * 100).toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFB85CA8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}