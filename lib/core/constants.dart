import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF4A0072);
const Color secondaryColor = Color(0xFFFFFFFF);

const BoxDecoration purpleGradientBoxDecoration = BoxDecoration(
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
