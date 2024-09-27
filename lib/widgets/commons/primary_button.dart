import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:twin_app/core/session_variables.dart';

class PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String labelKey;
  final Size minimumSize;
  final Widget? leading;
  final Widget? trailing;
  const PrimaryButton(
      {super.key,
      this.onPressed,
      required this.labelKey,
      this.leading,
      this.trailing,
      this.minimumSize = const Size(150, 50)});

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        children: [
          if (null != widget.leading) widget.leading!,
          Text(
            widget.labelKey,
            style: theme.getStyle().copyWith(
                  color: Colors.white,
                  fontSize: smallScreen ? 14 : 18,
                ),
          ).tr(),
          if (null != widget.trailing) widget.trailing!,
        ],
      ),
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
