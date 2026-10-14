import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Arabic typefaces for the reader. Amiri ships with the app; the others
/// download once and are cached by google_fonts.
class ArabicFontOption {
  final String name;
  final double scale;
  final double height;
  final TextStyle Function(TextStyle base) _apply;

  const ArabicFontOption(this.name, this._apply, {this.scale = 1, this.height = 1.9});

  TextStyle style({required double size, required Color color, FontWeight weight = FontWeight.normal}) {
    return _apply(TextStyle(fontSize: size * scale, color: color, height: height, fontWeight: weight));
  }

  static TextStyle _amiri(TextStyle s) => s.copyWith(fontFamily: 'Amiri');

  static final List<ArabicFontOption> all = [
    const ArabicFontOption('Amiri', _amiri),
    ArabicFontOption('Amiri Quran', (s) => GoogleFonts.amiriQuran(textStyle: s), height: 2.1),
    ArabicFontOption('Noto Naskh', (s) => GoogleFonts.notoNaskhArabic(textStyle: s), scale: 0.95),
    ArabicFontOption('Scheherazade', (s) => GoogleFonts.scheherazadeNew(textStyle: s), scale: 1.1),
    ArabicFontOption('Lateef', (s) => GoogleFonts.lateef(textStyle: s), scale: 1.25, height: 1.7),
  ];

  static ArabicFontOption at(int index) => all[index.clamp(0, all.length - 1)];
}
