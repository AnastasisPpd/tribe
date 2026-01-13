import 'package:flutter/material.dart';

class TribeHeader extends StatelessWidget {
  const TribeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Icon
        Image.asset(
          'assets/app_icon.png',
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.flash_on, color: Colors.blueAccent, size: 32),
        ),
        const SizedBox(width: 8),
        // Tribe Logo Text
        Image.asset(
          'assets/tribe_logo.png',
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text(
            'TRIBE',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
