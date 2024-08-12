import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';

class FontsAndColors extends StatefulWidget {
  const FontsAndColors({super.key});

  @override
  State<FontsAndColors> createState() => _FontsAndColorsState();
}

class _FontsAndColorsState extends State<FontsAndColors> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'FONTS AND COLORS',
            style: theme.getStyle().copyWith(fontSize: 20),
          ),
        )
      ],
    );
  }
}
