import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Orders',
        style: theme.getStyle().copyWith(
              fontSize: 20,
            ),
      ),
    );
  }
}
