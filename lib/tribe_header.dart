import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

class TribeHeader extends StatelessWidget {
  const TribeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final nav = context.findAncestorStateOfType<MainNavigationState>();
        if (nav != null) {
          nav.goToDiscover();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // decoration: BoxDecoration(
        //   color: kBlue.withValues(alpha: 0.2),
        //   borderRadius: BorderRadius.circular(8),
        //   border: Border.all(color: kBlue),
        // ),
        child: Image.asset(
          'assets/images/tribe_logo.png',
          height: 40, // Adjust height as necessary
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
