import 'package:flutter/material.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class TwinTheme {
  final String name;
  final List<Color> colors;
  final String fontFamily;
  final Color menuColor;
  final Color selectedMenuColor;
  const TwinTheme(
      {required this.name,
      required this.colors,
      this.fontFamily = 'Roboto Condensed',
      this.menuColor = Colors.white,
      this.selectedMenuColor = Colors.white});

  Color getPrimaryColor() {
    return colors[colors.length - 1];
  }

  Color getIntermediateColor() {
    return TwinUtils.lighten(getPrimaryColor());
  }

  Color getSecondaryColor() {
    return colors[1];
  }

  TextStyle getStyle() {
    return GoogleFonts.getFont(fontFamily)
        .copyWith(overflow: TextOverflow.ellipsis);
  }

  Decoration getCredentialsPageDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        stops: [0.08, 0.5, 0.75, 1],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  Decoration getCredentialsContentDecoration() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(180),
          bottomRight: Radius.circular(30),
        ));
  }
}

final List<TwinTheme> themes = [
  TwinTheme(name: 'Aqua', fontFamily: 'Roboto Condensed', colors: [
    Color(0xFFFFFFFF),
    Color(0xFF90E0EF),
    Color(0xFF00B4D8),
    Color(0xFF0077B6),
  ]),
  TwinTheme(name: 'Pinky', fontFamily: 'Open Sans', colors: [
    Color(0xFFFFFFFF),
    Color(0xffF6878F),
    Color(0xffEE6E7D),
    Color(0xffE0475D),
  ]),
  TwinTheme(name: 'Ocean', fontFamily: 'Roboto', colors: [
    Color(0xFFFFFFFF),
    Color(0xffD1DA2E),
    Color(0xff9ABC38),
    Color(0xff175A50),
  ]),
];
