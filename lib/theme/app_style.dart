import 'package:flutter/material.dart';

// Light Theme Colors
class AppColors {
  static const Color primary = Color(0xFF5B8DEF);
  static const Color background = Color(0xFFF8F9FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color progressCardStart = Color(0xFFEAF1FF);
  static const Color progressCardEnd = Color(0xFFF3F7FF);
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
      color: Color(0x0D0F172A),
      blurRadius: 14,
      offset: Offset(0, 6),
    ),
  ];
}
