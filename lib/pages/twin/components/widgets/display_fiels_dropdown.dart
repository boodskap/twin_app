import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';

class DisplayFieldDropdown extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final List<DropdownMenuItem<String>> fieldList;

  const DisplayFieldDropdown({
    Key? key,
    this.selectedValue,
    required this.onChanged,
    required this.fieldList,
  }) : super(key: key);

  @override
  State<DisplayFieldDropdown> createState() => _DisplayFieldDropdownState();
}

class _DisplayFieldDropdownState extends State<DisplayFieldDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton<String>(
        value: widget.selectedValue,
        onChanged: widget.onChanged,
        items: widget.fieldList,
        underline: Container(),
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        dropdownColor: Colors.white,
        isDense: true,
        hint: const Text("Select Field"),
        style: theme.getStyle().copyWith(color: Colors.black),
      ),
    );
  }
}
