import 'package:flutter/material.dart';

class UseridTextField extends StatefulWidget {
  const UseridTextField(
      {super.key, required this.hintText, required this.controller});

  final String hintText;
  final TextEditingController controller;

  @override
  State<UseridTextField> createState() => _UseridTextFieldState();
}

class _UseridTextFieldState extends State<UseridTextField> {
  final textFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      controller: widget.controller,
      focusNode: textFieldFocusNode,
            validator: (value) {
        if (!RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(value ?? '')) {
          return "Enter a valid email";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: widget.hintText,
        filled: false,
        isDense: true,
        prefixIcon: const Icon(Icons.email_rounded, size: 24),
      ),
    );
  }
}
