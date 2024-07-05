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
    return colors[0];
  }

  Color getIntermediateColor() {
    return TwinUtils.lighten(getPrimaryColor());
  }

  Color getSecondaryColor() {
    return colors[colors.length - 1];
  }

  TextStyle getStyle() {
    return GoogleFonts.getFont(fontFamily);
  }

  Decoration getCredentialsPageDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        stops: [0, 0.5, 0.75, 1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
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
    Color(0xff1d6095),
    Color(0xff1b8a9d),
    Color(0xff14aaa2),
    Color(0xffD0EEEC),
  ]),
  TwinTheme(name: 'Pinky', fontFamily: 'Open Sans', colors: [
    Color(0xffE0475D),
    Color(0xffEE6E7D),
    Color(0xffF6878F),
    Color(0xffF6A5A2),
  ]),
  TwinTheme(name: 'Ocean', fontFamily: 'Roboto', colors: [
    Color(0xff175A50),
    Color(0xff9ABC38),
    Color(0xffD1DA2E),
    Color(0xffD1D08B),
  ]),
];
