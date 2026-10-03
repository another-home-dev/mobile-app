import 'package:flutter/material.dart';

/// Another Home palette.
///
/// Built around the logo (azure house, sunshine-yellow doorway) on the
/// Oxford Blue / Orange-Yellow pairing (coolors.co #14213D / #FCA311), with
/// warm off-white neutrals instead of pure grey so the app feels homely rather
/// than clinical. The web dashboard (another-home-frontend/src/index.css) uses
/// the same primary scale, so both surfaces share one brand blue.
class AppColors {
  AppColors._();

  // Neutrals
  static const Color bg = Color(0xFFF7F6F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0EEE8);
  static const Color border = Color(0xFFE6E3DB);
  static const Color ink = Color(0xFF14213D);
  static const Color text = Color(0xFF1B2233);
  static const Color muted = Color(0xFF646B7A);
  static const Color faint = Color(0xFF9AA0AC);

  // Brand
  static const Color primary = Color(0xFF0A6CB8);
  static const Color primaryBright = Color(0xFF1F8BDC);
  static const Color primaryDark = Color(0xFF0D4B80);
  static const Color primarySoft = Color(0xFFE3F0FB);
  static const Color accent = Color(0xFFF9B826);
  static const Color accentSoft = Color(0xFFFEF3D6);
  static const Color accentInk = Color(0xFF8A5A00);

  // Status — each has a soft tint for chip/icon backgrounds.
  static const Color success = Color(0xFF1F8A5B);
  static const Color successSoft = Color(0xFFE2F4EA);
  static const Color warning = Color(0xFFB45309);
  static const Color warningSoft = Color(0xFFFDF0D5);
  static const Color danger = Color(0xFFC62828);
  static const Color dangerSoft = Color(0xFFFCE7E6);
  static const Color info = Color(0xFF5B4FCF);
  static const Color infoSoft = Color(0xFFECEAFB);

  static const Color white = Color(0xFFFFFFFF);

  /// Soft background for a given status colour, falling back to a 12% tint.
  static Color softOf(Color c) {
    if (c == primary) return primarySoft;
    if (c == success) return successSoft;
    if (c == warning) return warningSoft;
    if (c == danger) return dangerSoft;
    if (c == info) return infoSoft;
    if (c == accent || c == accentInk) return accentSoft;
    if (c == muted) return surfaceAlt;
    return c.withValues(alpha: 0.12);
  }
}
