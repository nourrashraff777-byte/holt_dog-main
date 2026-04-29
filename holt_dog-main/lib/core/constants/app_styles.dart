import 'package:flutter/material.dart';

class AppStyles {
  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 20.0; // For TextFields & Cards as seen in PDF
  static const double radiusXL = 30.0; // For Buttons
  static const double radiusFull = 100.0; // For Curved Headers

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> deepShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Common Paddings
  static const EdgeInsets screenPadding = EdgeInsets.all(spaceL);
  static const EdgeInsets cardPadding = EdgeInsets.all(spaceM);
}
