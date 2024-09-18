import 'package:flutter/material.dart';


class CustomBadge extends StatelessWidget {
  final String hintText;
  final String text;
  final Color badgeColor;
  const CustomBadge(
      {super.key,
      required this.hintText,
      required this.text,
      required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: badgeColor,
            radius: 10.0,
            child: Text(
              hintText,
              style: TextStyle(color: Colors.white, fontSize: 12.0),
            ),
          ),
          SizedBox(width: 8.0),
          Text(
            text,
            style: TextStyle(color: badgeColor),
          ),
          SizedBox(width: 8.0),
        ],
      ),
    );
  }
}