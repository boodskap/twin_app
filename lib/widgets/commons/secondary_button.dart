import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:twin_app/core/session_variables.dart';

class SecondaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String labelKey;
  final Size minimumSize;
  const SecondaryButton(
      {super.key,
      this.onPressed,
      required this.labelKey,
      this.minimumSize = const Size(150, 50)});

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      child: Text(
        widget.labelKey,
        style: theme.getStyle().copyWith(
            color: theme.getPrimaryColor(),
            fontSize: 14,
            fontWeight: FontWeight.bold),
      ).tr(),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.getSecondaryColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: theme.getPrimaryColor()),
        ),
        minimumSize: widget.minimumSize,
      ),
    );
  }
}
