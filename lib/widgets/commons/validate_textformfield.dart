import 'package:flutter/material.dart';

class ValidatedTextFormField extends StatefulWidget {
  const ValidatedTextFormField(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.minLength});

  final String hintText;
  final TextEditingController controller;
  final int minLength;

  @override
  State<ValidatedTextFormField> createState() => _ValidatedTextFormFieldState();
}

class _ValidatedTextFormFieldState extends State<ValidatedTextFormField> {
  final textFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      controller: widget.controller,
      focusNode: textFieldFocusNode,
      validator: (value) {
        if (value!.length < widget.minLength) {
          return "minimum ${widget.minLength} characters required";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: widget.hintText,
        filled: false,
        isDense: true,
        prefixIcon: const Icon(Icons.abc, size: 24),
      ),
    );
  }
}
