import 'package:flutter/material.dart';

// App Colors (configured for permanent dark mode)
class AppColors {
  static const Color primary = Color(0xFF7AA2FF);
  static const Color background = Color(0xFF0F1115);
  static const Color surface = Color(0xFF171A21);
  static const Color accentGreen = Color(0xFF55D187);
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFF2A3140);
  static const Color progressCardStart = Color(0xFF1B2334);
  static const Color progressCardEnd = Color(0xFF151B28);
  static const Color progressTrack = Color(0xFF2B3448);
  static const Color navIndicator = Color(0xFF263149);
  static const Color successSurface = Color(0xFF173227);
  static const Color successBorder = Color(0xFF2D5D48);
  static const Color successText = Color(0xFF8AE8B4);
  static const Color mutedChip = Color(0xFF7E8BA6);
  static const Color danger = Color(0xFFE06666);
  static const Color buttonSecondary = Color(0xFF303C59);
}

// Category Colors
class CategoryColors {
  static const Color studyLight = Color(0xFF5B8DEF);
  static const Color assignmentLight = Color(0xFFFFA726);
  static const Color revisionLight = Color(0xFF4CAF50);
}

class AppSpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
}

class AppRadius {
  static const BorderRadius card = BorderRadius.all(Radius.circular(16));
  static const BorderRadius button = BorderRadius.all(Radius.circular(12));
  static const BorderRadius input = BorderRadius.all(Radius.circular(12));
  static const BorderRadius small = BorderRadius.all(Radius.circular(8));
}

class AppShadows {
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x52000000),
      blurRadius: 14,
      offset: Offset(0, 6),
    ),
  ];
}
