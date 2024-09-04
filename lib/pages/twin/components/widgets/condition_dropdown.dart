import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class ConditonDropdown extends StatefulWidget {
  final List<String> conditionList;
  final List<String> selectedValue;
  final Function(List<String>) onConfirm;

  ConditonDropdown({
    Key? key,
    required this.selectedValue,
    required this.conditionList,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<ConditonDropdown> createState() => _ConditonDropdownState();
}

class _ConditonDropdownState extends BaseState<ConditonDropdown> {
  @override
  void setup() async {}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.conditionList.isNotEmpty ? 240 : 100,
      child: widget.conditionList.isNotEmpty
          ? MultiSelectDialogField(
              closeSearchIcon: Icon(Icons.close),
              searchHint: 'conditions',
              cancelText: Text('Cancel',
                  style: theme.getStyle().copyWith(color: Colors.red)),
              confirmText: Text('Ok',
                  style: theme
                      .getStyle()
                      .copyWith(color: theme.getPrimaryColor())),
              title: Text('Select Condition', style: theme.getStyle()),
              selectedItemsTextStyle: theme.getStyle(),
              searchTextStyle: theme.getStyle(),
              searchHintStyle: theme.getStyle(),
              itemsTextStyle: theme.getStyle(),
              backgroundColor: Colors.white,
              searchable: true,
              buttonText: Text("Select Condition",
                  style: theme.getStyle().copyWith(color: Colors.black)),
              buttonIcon: const Icon(Icons.arrow_drop_down),
              dialogWidth: 300,
              dialogHeight: 200,
              items: widget.conditionList
                  .map((condition) =>
                      MultiSelectItem<String>(condition, condition))
                  .toList(),
              initialValue: widget.selectedValue,
              onConfirm: (List<String> values) {
                widget.onConfirm(values);
              },
            )
          : Text("Condition is Empty",
              style: theme.getStyle().copyWith(color: Colors.black)),
    );
  }
}
