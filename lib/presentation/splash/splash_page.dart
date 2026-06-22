import 'package:flutter/material.dart';

import '../../core/ui_kit/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static String tag = '/splash-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Text(
          'Usta Book',
          style: TextStyle(
            color: AppColors.secondaryBg,
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
