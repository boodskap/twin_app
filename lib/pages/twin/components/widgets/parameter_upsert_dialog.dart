import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';

typedef AddRow = void Function();

class ParameterUpsertDialogSettings extends StatefulWidget {
  final TextEditingController paramName;
  final TextEditingController paramDesc;
  final TextEditingController paramLabel;
  final TextEditingController paramValue;
  ValueNotifier<tapi.AttributeAttributeType> paramType;
  tapi.DeviceModel? model;
  AddRow addRow;
  bool isEdit;
  final ValueNotifier<bool> paramEditable;

  ParameterUpsertDialogSettings({
    Key? key,
    this.model,
    required this.addRow,
    required this.paramName,
    required this.paramDesc,
    required this.paramLabel,
    required this.paramType,
    required this.paramValue,
    required this.isEdit,
    required this.paramEditable,
  }) : super(key: key);

  @override
  State<ParameterUpsertDialogSettings> createState() =>
      _ParameterUpsertDialogSettingsState();
}

class _ParameterUpsertDialogSettingsState
    extends State<ParameterUpsertDialogSettings> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    widget.paramName.clear();
    widget.paramDesc.clear();
    widget.paramLabel.clear();
    widget.paramValue.clear();
    widget.paramEditable.value = true;
    widget.paramType = ValueNotifier(tapi.AttributeAttributeType.numeric);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const vDivider = SizedBox(height: 8);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Parameter Info'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              vDivider,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  controller: widget.paramName,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r"\s")),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ),
              vDivider,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: LabelTextField(
                  label: 'Description',
                  controller: widget.paramDesc,
                ),
              ),
              vDivider,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: LabelTextField(
                  label: 'Label',
                  controller: widget.paramLabel,
                ),
              ),
              vDivider,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField2<tapi.AttributeAttributeType>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                        left: 1,
                        right: 3,
                      ),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0XFF79747e), width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.only(left: 0, right: 3),
                    ),
                    items: const [
                      DropdownMenuItem<tapi.AttributeAttributeType>(
                        value: tapi.AttributeAttributeType.numeric,
                        child: Text('Number'),
                      ),
                      DropdownMenuItem<tapi.AttributeAttributeType>(
                        value: tapi.AttributeAttributeType.floating,
                        child: Text('Decimal'),
                      ),
                      DropdownMenuItem<tapi.AttributeAttributeType>(
                        value: tapi.AttributeAttributeType.yesno,
                        child: Text('Boolean'),
                      ),
                      DropdownMenuItem<tapi.AttributeAttributeType>(
                        value: tapi.AttributeAttributeType.text,
                        child: Text('Text'),
                      ),
                    ],
                    value: widget.paramType.value,
                    onChanged: !widget.isEdit
                        ? (tapi.AttributeAttributeType? value) {
                            setState(() {
                              widget.paramType.value =
                                  value ?? tapi.AttributeAttributeType.numeric;
                            });
                          }
                        : null,
                  ),
                ),
              ),
              vDivider,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Value',
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                  controller: widget.paramValue,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
              ),
              vDivider,
              Wrap(
                spacing: 8,
                children: [
                  CheckboxListTile(
                    title: const Text('Editable'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    value: widget.paramEditable.value,
                    onChanged: (bool? value) {
                      setState(() {
                        widget.paramEditable.value = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              height: 1,
              indent: 10,
              endIndent: 10,
              color: Colors.grey,
              thickness: 1,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
               SecondaryButton(labelKey: 'Cancel', onPressed: () {
                    Navigator.pop(context);
                  },),
                const SizedBox(width: 10),
                PrimaryButton(labelKey: 'Add Parameter', onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.addRow();
                      Navigator.pop(context);
                    }
                  },),
              ],
            ),
          ],
        )
      ],
    );
  }
}
