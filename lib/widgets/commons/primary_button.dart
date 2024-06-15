import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:twin_app/core/session_variables.dart';

class PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String labelKey;
  final Size minimumSize;
  const PrimaryButton(
      {super.key,
      this.onPressed,
      required this.labelKey,
      this.minimumSize = const Size(150, 50)});

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      child: Text(
        widget.labelKey,
        style: theme.getStyle().copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
      ).tr(),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.getPrimaryColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        minimumSize: widget.minimumSize,
      ),
    );
  }
}
