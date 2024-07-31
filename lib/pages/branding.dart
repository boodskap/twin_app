import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';

class Branding extends StatefulWidget {
  const Branding({super.key});

  @override
  State<Branding> createState() => _BrandingState();
}

class _BrandingState extends State<Branding> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'BRANDING',
            style: theme.getStyle().copyWith(fontSize: 20),
          ),
        )
      ],
    );
  }
}
