import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:twin_app/core/session_variables.dart';

class CustomParametersDropDown extends StatefulWidget {
  final void Function(Parameter?) valueChanged;
  final List<Parameter> dropDownParamList;
  final String fieldValue;

  CustomParametersDropDown(
      {Key? key,
      required this.valueChanged,
      required this.dropDownParamList,
      required this.fieldValue})
      : super(key: key);

  @override
  State<CustomParametersDropDown> createState() =>
      _CustomParametersDropDownState();
}

class _CustomParametersDropDownState
    extends BaseState<CustomParametersDropDown> {
  final List<DropdownMenuItem<Parameter>> _entries = [];
  Parameter? _selected;

  @override
  void setup() async {
    _entries.clear();
    for (var element in widget.dropDownParamList) {
      if (element.parameterType == ParameterParameterType.numeric ||
          element.parameterType == ParameterParameterType.floating) {
        DropdownMenuItem<Parameter> me = DropdownMenuItem(
          value: element,
          child: Text(
            element.name,
            style:
                theme.getStyle().copyWith(color: Colors.black),
          ),
        );
        _entries.add(me);
      }
    }
    if (_entries.isNotEmpty && widget.fieldValue != "") {
      _selected = _entries.first.value;
      for (var i = 0; i < _entries.length; i++) {
        if (_entries[i].value?.name == widget.fieldValue) {
          _selected = _entries[i].value;
        }
      }
    }
    setState(() {});
    widget.valueChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField2<Parameter>(
        isExpanded: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            left: 1,
            right: 3,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0XFF79747e), width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        buttonStyleData: const ButtonStyleData(
          height: 35,
          padding: EdgeInsets.only(left: 0, right: 3),
        ),
        isDense: true,
        hint: const Text("Select Field"),
        items: _entries,
        value: _selected,
        validator: (value) {
          if (value == null) {
            return "Please select an Field";
          }
          return null;
        },
        onChanged: (Parameter? value) {
          setState(() {
            _selected = value;
          });

          widget.valueChanged(value);
        },
      ),
    );
  }
}
