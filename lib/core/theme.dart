import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kViolet = Color(0xFF7C5CFF);
const Color kCyan = Color(0xFF22D3EE);
const Color kPink = Color(0xFFFF6BCB);

/// Returns [c] with the given opacity (0..1) without deprecated APIs.
Color withA(Color c, double opacity) =>
    c.withAlpha((opacity * 255).round().clamp(0, 255));

ThemeData buildTheme(Brightness brightness, String lang) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: kViolet,
    brightness: brightness,
  );
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final textColor = dark ? Colors.white : const Color(0xFF14142B);

  final TextTheme text = lang == 'ar'
      ? GoogleFonts.cairoTextTheme(base.textTheme)
      : GoogleFonts.interTextTheme(base.textTheme);

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: Colors.transparent,
    textTheme: text.apply(bodyColor: textColor, displayColor: textColor),
    iconTheme: IconThemeData(color: textColor),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? const Color(0xFF2A2550) : const Color(0xFF14142B),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
