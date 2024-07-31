import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';

class NocodeBuilder extends StatefulWidget {
  const NocodeBuilder({super.key});

  @override
  State<NocodeBuilder> createState() => _NocodeBuilderState();
}

class _NocodeBuilderState extends State<NocodeBuilder> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'NOCODE BUILDER',
            style: theme.getStyle().copyWith(fontSize: 20),
          ),
        )
      ],
    );
  }
}
