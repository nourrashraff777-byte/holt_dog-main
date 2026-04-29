import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand Colors ───────────────────────────────────────────────
  static const Color primaryPurple     = Color(0xFF7B2D8B);
  static const Color primaryMagenta    = Color(0xFFC62FAD);
  static const Color primaryHotPink    = Color(0xFFE040B0);

  // ─── Purple Shades ──────────────────────────────────────────────
  static const Color purpleDark        = Color(0xFF5A1FA0);
  static const Color purpleMedium      = Color(0xFF7B2D8B);
  static const Color purpleLight       = Color(0xFFA0289A);

  // ─── Pink / Magenta Shades ──────────────────────────────────────
  static const Color magentaDark       = Color(0xFFC62FAD);
  static const Color magentaLight      = Color(0xFFE040B0);
  static const Color pinkSoft          = Color(0xFFF4C0D1);
  static const Color pinkPale          = Color(0xFFFBEAF0);

  // ─── Background Colors ──────────────────────────────────────────
  static const Color backgroundWhite   = Color(0xFFFFFFFF);
  static const Color backgroundGray    = Color(0xFFF5F5F5);
  static const Color backgroundLight   = Color(0xFFF8F4FB);

  // ─── Text Colors ────────────────────────────────────────────────
  static const Color textPrimary       = Color(0xFF1A1A1A);
  static const Color textSecondary     = Color(0xFF555555);
  static const Color textHint          = Color(0xFF9E9E9E);
  static const Color textOnPurple      = Color(0xFFFFFFFF);

  // ─── Status Colors ──────────────────────────────────────────────
  static const Color statusRescued     = Color(0xFF4CAF50);  // Rescued / Available
  static const Color statusNeedsHelp   = Color(0xFFF44336);  // Needs Help / Pending / Closed
  static const Color statusUndercare   = Color(0xFFFF9800);  // Undercare

  // ─── Status Light Backgrounds ───────────────────────────────────
  static const Color statusRescuedBg   = Color(0xFFE8F5E9);
  static const Color statusNeedsHelpBg = Color(0xFFFFEBEE);
  static const Color statusUndercareB  = Color(0xFFFFF3E0);

  // ─── Border Colors ──────────────────────────────────────────────
  static const Color borderPurple      = Color(0xFFC49BD0);
  static const Color borderLight       = Color(0xFFE0E0E0);

  // ─── Social Login Colors ────────────────────────────────────────
  static const Color googleBlue        = Color(0xFF4285F4);
  static const Color facebookBlue      = Color(0xFF1877F2);
  static const Color instagramPink     = Color(0xFFE1306C);

  // ─── Gradient ───────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [
      Color(0xFF5A1FA0),
      Color(0xFF7B2D8B),
      Color(0xFFA0289A),
      Color(0xFFC62FAD),
      Color(0xFFE040B0),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [
      Color(0xFF7B2D8B),
      Color(0xFFC62FAD),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient instagramGradient = LinearGradient(
    colors: [
      Color(0xFFE040B0),
      Color(0xFFFF5722),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}