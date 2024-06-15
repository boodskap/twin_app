import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:twin_app/core/session_variables.dart';

class EmailField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  const EmailField({super.key, this.controller, this.onChanged});

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
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
        autofillHints: [AutofillHints.username],
        decoration: InputDecoration(
          hintText: "email".tr(),
          hintStyle:
              theme.getStyle().copyWith(color: theme.getIntermediateColor()),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
