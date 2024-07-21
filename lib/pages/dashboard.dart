import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'DASHBOARD',
            style: theme.getStyle().copyWith(fontSize: 20),
          ),
        )
      ],
    );
  }
}
