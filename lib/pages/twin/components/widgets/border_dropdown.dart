import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';

class BorderDropdown extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const BorderDropdown({
    Key? key,
    this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<BorderDropdown> createState() => _BorderDropdownState();
}

class _BorderDropdownState extends State<BorderDropdown> {
  List<String> dropdownValues = ['NONE', 'BOX', 'ROUNDED', 'CIRCLE'];
  List<String> dropdownTexts = [
    'No Border',
    'Box Border',
    'Rounded Border',
    'Circle Border'
  ];
  List<DropdownMenuItem<String>> dropdownMenuItems = [];

  @override
  void initState() {
    super.initState();
    dropdownMenuItems = dropdownValues.map((value) {
      int index = dropdownValues.indexOf(value);
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          dropdownTexts[index],
          style: theme.getStyle().copyWith(color: Colors.black),
        ),
      );
    }).toList();
  }

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
        items: dropdownMenuItems,
        underline: Container(),
        padding: const EdgeInsets.fromLTRB(10, 5, 2, 5),
        dropdownColor: Colors.white,
        isDense: true,
        hint: const Text("Select Border Type"),
        style: theme.getStyle().copyWith(color: Colors.black),
      ),
    );
  }
}
