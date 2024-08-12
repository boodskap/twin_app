import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'LANDING PAGE',
            style: theme.getStyle().copyWith(fontSize: 20),
          ),
        )
      ],
    );
  }
}
