import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const TextStyle kbodytext = TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal);

TextStyle kFont(double fontsize) {
  return GoogleFonts.adventPro(
    textStyle: kbodytext.copyWith(fontSize: fontsize),
  );
}

TextStyle kFontText(double fontsize) {
  return GoogleFonts.sansita(
      textStyle: TextStyle(fontSize: fontsize, color: kGreen, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal));
}

TextStyle kFontTextwithColor(double fontsize, Color color) {
  return GoogleFonts.adventPro(
      textStyle: TextStyle(fontSize: fontsize, color: color, fontWeight: FontWeight.w600, fontStyle: FontStyle.normal));
}

const Color kBlack = Colors.black54;
const Color kPink = Color(0xffff8364);
const Color kBrown = Color(0xff433520);
const Color kYellow = Color(0xffffd98e);
const Color kBgPink = Color(0xffAC718D);
const Color kGreen = Color(0xff004a2f);
Color kRed = Colors.red[900];

Map<int, Color> color = {
  50: kGreen.withOpacity(0.05),
  100: kGreen.withOpacity(0.1),
  200: kGreen.withOpacity(0.2),
  300: kGreen.withOpacity(0.3),
  400: kGreen.withOpacity(0.4),
  500: kGreen.withOpacity(0.5),
  600: kGreen.withOpacity(0.6),
  700: kGreen.withOpacity(0.7),
  800: kGreen.withOpacity(0.8),
  900: kGreen.withOpacity(0.9),
};

MaterialColor appBarColor = MaterialColor(0xff004a2f, color);
