import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends BaseState<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Center(
                child: Text(
                  'Heading',
                  style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.bold),
                ),
              ),
              Text('Body'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}
