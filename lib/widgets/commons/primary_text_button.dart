import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:twin_app/core/session_variables.dart';

class PrimaryTextButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String labelKey;
  final Size minimumSize;
  const PrimaryTextButton(
      {super.key,
      this.onPressed,
      required this.labelKey,
      this.minimumSize = const Size(150, 50)});

  @override
  State<PrimaryTextButton> createState() => _PrimaryTextButtonState();
}

class _PrimaryTextButtonState extends State<PrimaryTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      child: Text(
        widget.labelKey,
        style: theme.getStyle().copyWith(
              fontSize: 16,
              color: theme.getPrimaryColor(),
            ),
      ).tr(),
    );
  }
}
