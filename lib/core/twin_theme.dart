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
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF4A0072),
          Color(0xFF7B1FA2),
          Color(0xFFBA68C8),
        ],
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
