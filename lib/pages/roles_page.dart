import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'ROLES',
            style: theme.getStyle().copyWith(fontSize: 20),
          ),
        )
      ],
    );
  }
}
