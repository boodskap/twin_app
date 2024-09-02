import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:twin_app/core/session_variables.dart';

class BuyButton extends StatelessWidget {
  final String label;
  final TextStyle style;
  final VoidCallback? onPressed;
  final String? tooltip;
  final IconData iconData;
  const BuyButton(
      {super.key,
      required this.label,
      required this.style,
      this.tooltip = 'Exhausted',
      this.iconData = Icons.shopping_cart,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: ElevatedButton(
          onPressed: onPressed,
          child: Row(
            children: [
              Icon(
                iconData,
                color: Colors.blue,
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                label,
                style: style,
              ),
            ],
          )),
    );
  }
}
