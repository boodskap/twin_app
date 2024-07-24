import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:twin_app/core/session_variables.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintKey;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    this.controller,
    this.hintKey = 'password',
    this.onChanged,
    this.onSubmitted,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscure = true;

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
      child: TextFormField(
        onFieldSubmitted: widget.onSubmitted,
        controller: widget.controller,
        onChanged: widget.onChanged,
        obscureText: _isObscure,
        autofillHints: [AutofillHints.password],
        decoration: InputDecoration(
          hintText: widget.hintKey.tr(),
          hintStyle:
              theme.getStyle().copyWith(color: theme.getIntermediateColor()),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}
