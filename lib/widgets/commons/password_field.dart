import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:twin_app/core/session_variables.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintKey;
  const PasswordField(
      {super.key, this.controller, this.hintKey = 'password', this.onChanged});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.getSecondaryColor(),
          ),
        ),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        obscureText: true,
        autofillHints: [AutofillHints.password],
        decoration: InputDecoration(
          hintText: widget.hintKey.tr(),
          hintStyle:
              theme.getStyle().copyWith(color: theme.getIntermediateColor()),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
