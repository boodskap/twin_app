import 'package:flutter/material.dart';

class BuyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? fontColor;
  final String? tooltip;
  final IconData iconData;
  const BuyButton(
      {super.key,
      required this.label,
      this.tooltip,
      this.fontSize = 14,
      this.fontWeight = FontWeight.bold,
      this.fontColor,
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
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: fontColor),
              ),
            ],
          )),
    );
  }
}
