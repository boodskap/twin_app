import 'package:flutter/material.dart';
import 'package:twin_app/core/constants.dart';
import 'package:twin_app/pages/login/page_login.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });

    return Scaffold(
      body: Container(
        decoration: purpleGradientBoxDecoration,
        child: Center(
          child: Text(
            'Twin App',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
