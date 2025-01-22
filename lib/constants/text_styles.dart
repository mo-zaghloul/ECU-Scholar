import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Headings
  static final TextStyle headline1 = GoogleFonts.almarai(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle headline2 = GoogleFonts.almarai(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle headline3 = GoogleFonts.almarai(
    fontSize: 24.0,
    fontWeight: FontWeight.normal,
  );

  // Body text
  static final TextStyle bodyText1 = GoogleFonts.almarai(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );
  static final TextStyle bodyText2 = GoogleFonts.almarai(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
  );

  // Subtitles & Captions
  static final TextStyle subtitle1 = GoogleFonts.almarai(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle subtitle1bold = GoogleFonts.almarai(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle subtitle2 = GoogleFonts.almarai(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );
}
