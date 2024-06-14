import 'package:flutter/material.dart';
import 'package:twin_app/core/constants.dart';
import 'package:twin_app/pages/login/page_login.dart';
import 'package:easy_localization/easy_localization.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: theme.getSplashPageDecoration(),
        child: Center(
          child: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: Text(
              'appName',
              style: TextStyle(color: Colors.black),
            ).tr(),
          ),
        ),
      ),
    );
  }
}
