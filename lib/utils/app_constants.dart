import 'package:flutter/material.dart';
import 'dart:math';

// Global variable for testing audio call with Zego
final String localUserID = Random().nextInt(10000).toString();

class AppSpacing {
  // Horizontal spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // Vertical spacing
  static const SizedBox vXs = SizedBox(height: xs);
  static const SizedBox vSm = SizedBox(height: sm);
  static const SizedBox vMd = SizedBox(height: md);
  static const SizedBox vLg = SizedBox(height: lg);
  static const SizedBox vXl = SizedBox(height: xl);
  static const SizedBox vXxl = SizedBox(height: xxl);

  // Horizontal spacing
  static const SizedBox hXs = SizedBox(width: xs);
  static const SizedBox hSm = SizedBox(width: sm);
  static const SizedBox hMd = SizedBox(width: md);
  static const SizedBox hLg = SizedBox(width: lg);
  static const SizedBox hXl = SizedBox(width: xl);
  static const SizedBox hXxl = SizedBox(width: xxl);

  // Padding presets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  // Specific padding
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(
    vertical: lg,
  );
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double round = 50.0;
}

class AppColors {
  AppColors._();

  // ── Brand / Primary ────────────────────────────────────────────────────────
  /// Main brand green used for buttons, active tabs, etc.
  static const Color primary = Color(0xFF1F803A);
  static const Color primaryLight = Color(0xFFE8F5E9);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E1E2C);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);

  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const Color bgLight = Color(0xFFF4F6FB);
  static const Color bgDark = Color(0xFF101010); // More neutral black-grey
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(
    0xFF1C1C1C,
  ); // Neutral dark grey, no blue tint

  // ── Surface / UI elements ──────────────────────────────────────────────────
  static const Color surface = Color(0xFFF7F7FA);
  static const Color border = Color(0xFFEEEEEE);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1F803A);
  static const Color error = Colors.red;
  static const Color info = Colors.blue;

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const Color star = Color(0xFFFFB800);
  static const Color gold = Color(0xFFFFB800);
  static const Color disabled = Color(0xFFBDBDBD);

  // Legacy aliases kept for backward compat
  static const Color grey = Colors.grey;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // ── Helpers ────────────────────────────────────────────────────────────────
  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight;

  static Color scaffold(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bgDark : bgLight;
}
