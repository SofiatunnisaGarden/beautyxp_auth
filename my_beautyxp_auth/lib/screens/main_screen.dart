import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'history_screen.dart';
import 'budget_selection_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _goToHome() {
    _changeTab(0);
  }

  void _goToProfile() {
    _changeTab(3);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onProfileTap: _goToProfile,
      ),

      HistoryScreen(
        onBackToHome: _goToHome,
      ),

      BudgetSelectionScreen(
        onBackToHome: _goToHome,
      ),

      ProfileScreen(
        onBackToHome: _goToHome,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BeautyBottomNav(
        currentIndex: currentIndex,
        onTap: _changeTab,
      ),
    );
  }
}