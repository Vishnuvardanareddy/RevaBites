import 'package:flutter/material.dart';

class AppColors {
  static const primary = Colors.deepOrange;
  static const background = Colors.white;
  static const text = Color(0xFF1A1A1A);
  static const textLight = Color(0xFF757575);
  static const matteBlack = Color(0xFF1A1A1A);
  static const cardBorder = Color(0xFFEEEEEE);
  static const cardShadow = Color(0x1A000000);
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 16.0;
  static const double cardElevation = 4.0;
}

class AppDecorations {
  static BoxDecoration modernCard = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
    boxShadow: const [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 20,
        offset: Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: AppColors.cardBorder,
      width: 1,
    ),
  );

  static BoxDecoration searchBar = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
    boxShadow: const [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
}
