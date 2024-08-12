import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';

class Invoices extends StatefulWidget {
  const Invoices({super.key});

  @override
  State<Invoices> createState() => _InvoicesState();
}

class _InvoicesState extends State<Invoices> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Invoices',
        style: theme.getStyle().copyWith(
              fontSize: 20,
            ),
      ),
    );
  }
}
