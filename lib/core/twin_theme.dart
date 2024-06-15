import 'package:flutter/material.dart';

abstract class TwinTheme {
  const TwinTheme();

  Color getPrimaryColor() {
    return Color(0xFF4A0072);
  }

  Color getSecondaryColor() {
    return Color(0xFFFFFFFF);
  }

  Decoration getCredentialsPageDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xff1d6095), Color(0xff1b8a9d), Color(0xff14aaa2)],
        stops: [0, 0.5, 1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  Decoration getSplashPageDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x09203F72),
          Color(0x537895C8),
        ],
      ),
    );
  }
}

class PurpleTheme extends TwinTheme {
  const PurpleTheme();
}
