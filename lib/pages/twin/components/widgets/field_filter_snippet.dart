import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter/material.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:twin_app/core/session_variables.dart';

class FieldFilterSnippet extends StatefulWidget {
  final twinned.FieldFilter? fieldFilter;
  const FieldFilterSnippet({
    super.key,
    this.fieldFilter,
  });

  @override
  State<FieldFilterSnippet> createState() => _FieldFilterSnippetState();
}

class _FieldFilterSnippetState extends BaseState<FieldFilterSnippet> {
  final List<twinned.Parameter> _parameters = [];
  final List<twinned.FieldFilterInfoCondition> _conditions = [];
  final Map<twinned.FieldFilterInfoCondition, String> _labels = {
    twinned.FieldFilterInfoCondition.eq: 'Equals',
    twinned.FieldFilterInfoCondition.neq: 'Not Equals',
    twinned.FieldFilterInfoCondition.lt: 'Less Than',
    twinned.FieldFilterInfoCondition.lte: 'Less Than & Equals',
    twinned.FieldFilterInfoCondition.gt: 'Greater Than',
    twinned.FieldFilterInfoCondition.gte: 'Greater Than & Equals',
    twinned.FieldFilterInfoCondition.between: 'Between',
    twinned.FieldFilterInfoCondition.nbetween: 'Not Between',
    twinned.FieldFilterInfoCondition.contains: 'Contains',
    twinned.FieldFilterInfoCondition.ncontains: 'Not Contains',
  };
  final TextEditingController _name = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _tags = TextEditingController();
  final TextEditingController _value = TextEditingController();
  final TextEditingController _leftValue = TextEditingController();
  final TextEditingController _rightValue = TextEditingController();
  final TextEditingController _values = TextEditingController();
  twinned.Parameter? selectedField;
  bool? selectedValue = true;
  twinned.FieldFilterInfoCondition? selectedCondition;
  int valueType = -1; //1-> Value, 2-> Left & Right, 3-> Values

  @override
  void setup() {
    _load();
  }

  void setSelectedField(twinned.Parameter? field) {
    _conditions.clear();

    selectedField = field;

    if (null != selectedField) {
      switch (selectedField!.parameterType) {
        case twinned.ParameterParameterType.yesno:
          _conditions.add(twinned.FieldFilterInfoCondition.eq);
          _conditions.add(twinned.FieldFilterInfoCondition.neq);
          break;
        case twinned.ParameterParameterType.numeric:
        case twinned.ParameterParameterType.floating:
          _conditions.addAll(twinned.FieldFilterInfoCondition.values);
          _conditions
              .remove(twinned.FieldFilterInfoCondition.swaggerGeneratedUnknown);
          break;
        case twinned.ParameterParameterType.text:
          _conditions.add(twinned.FieldFilterInfoCondition.eq);
          _conditions.add(twinned.FieldFilterInfoCondition.neq);
          _conditions.add(twinned.FieldFilterInfoCondition.contains);
          _conditions.add(twinned.FieldFilterInfoCondition.ncontains);
          break;
        case twinned.ParameterParameterType.swaggerGeneratedUnknown:
        default:
          break;
      }
    }

    if (null != selectedCondition) {
      if (!_conditions.contains(selectedCondition)) {
        selectedCondition = null;
      }
    }

    refresh();
  }

  void setSelectedCondition(twinned.FieldFilterInfoCondition condition) {
    selectedCondition = condition;

    switch (condition) {
      case twinned.FieldFilterInfoCondition.swaggerGeneratedUnknown:
      case twinned.FieldFilterInfoCondition.eq:
      case twinned.FieldFilterInfoCondition.neq:
      case twinned.FieldFilterInfoCondition.lt:
      case twinned.FieldFilterInfoCondition.lte:
      case twinned.FieldFilterInfoCondition.gt:
      case twinned.FieldFilterInfoCondition.gte:
        valueType = 1;
        break;
      case twinned.FieldFilterInfoCondition.between:
      case twinned.FieldFilterInfoCondition.nbetween:
        valueType = 2;
        break;
      case twinned.FieldFilterInfoCondition.contains:
      case twinned.FieldFilterInfoCondition.ncontains:
        valueType = 3;
        break;
    }

    refresh();
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _parameters.clear();

    await execute(() async {
      var pRes = await TwinnedSession.instance.twin
          .listAllParameters(apikey: TwinnedSession.instance.authToken);
      if (validateResponse(pRes)) {
        _parameters.addAll(pRes.body?.values ?? []);
      }
    });

    refresh();

    if (null != widget.fieldFilter) {
      for (var param in _parameters) {
        if (param.name == widget.fieldFilter!.field) {
          setSelectedField(param);
          break;
        }
      }

      setSelectedCondition(twinned.FieldFilterInfoCondition.values
          .byName(widget.fieldFilter!.condition.name));

      _name.text = widget.fieldFilter!.name;
      _desc.text = widget.fieldFilter!.description ?? '';
      _tags.text = (widget.fieldFilter!.tags ?? []).join(' ');
      _value.text = widget.fieldFilter!.$value ?? '';
      _leftValue.text = widget.fieldFilter!.leftValue ?? '';
      _rightValue.text = widget.fieldFilter!.rightValue ?? '';
      _values.text = (widget.fieldFilter!.values ?? []).join(',');
    }

    loading = false;
  }

  Future _save() async {
    if (loading) return;
    loading = true;

    String name = _name.text.trim();

    if (name.isEmpty) {
      alert('Missing Name', 'Please enter a name');
      return;
    }

    if (null == selectedField) {
      alert('Missing Field', 'Please select a field');
      return;
    }

    twinned.FieldFilterInfoFieldType fieldType = twinned
        .FieldFilterInfoFieldType.values
        .byName(selectedField!.parameterType.name);

    twinned.FieldFilterInfoCondition condition =
        twinned.FieldFilterInfoCondition.values.byName(selectedCondition!.name);

    String? icon = widget.fieldFilter?.icon ?? '';

    String value = _value.text.trim();

    if (selectedField!.parameterType == twinned.ParameterParameterType.yesno) {
      value = '$selectedValue ?? false';
    }

    twinned.FieldFilterInfo body = twinned.FieldFilterInfo(
      name: name,
      description: _desc.text.trim(),
      tags: _tags.text.trim().split(' '),
      condition: condition,
      field: selectedField!.name,
      fieldType: fieldType,
      icon: icon,
      $value: value,
      leftValue: _leftValue.text.trim(),
      rightValue: _rightValue.text.trim(),
      values: _values.text.trim().split(','),
    );

    await execute(() async {
      late final chopper.Response<twinned.FieldFilterEntityRes> eRes;

      if (null != widget.fieldFilter) {
        eRes = await TwinnedSession.instance.twin.updateFieldFilter(
            apikey: TwinnedSession.instance.authToken,
            fieldFilterId: widget.fieldFilter!.id,
            body: body);
      } else {
        eRes = await TwinnedSession.instance.twin.createFieldFilter(
            apikey: TwinnedSession.instance.authToken, body: body);
      }

      if (validateResponse(eRes)) {
        _close();
        alert('Filter ${eRes.body!.entity!.name} ', 'Saved successfully!');
      }
    });

    loading = false;
    refresh();
  }

  void _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: LabelTextField(
              label: 'Name',
              labelTextStyle: theme.getStyle(),
              controller: _name,
              style: theme.getStyle(),
            ),
          ),
          divider(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: [
                Expanded(
                    child: LabelTextField(
                  labelTextStyle: theme.getStyle(),
                  label: 'Description',
                  controller: _desc,
                  style: theme.getStyle(),
                )),
                divider(horizontal: true),
                Expanded(
                    child: LabelTextField(
                  label: 'Tags',
                  labelTextStyle: theme.getStyle(),
                  controller: _tags,
                  style: theme.getStyle(),
                )),
              ],
            ),
          ),
          divider(),
          Expanded(
            child: Column(
              children: [
                if (_parameters.isEmpty)
                  Text('No fields found',
                      style: theme
                          .getStyle()
                          .copyWith(fontWeight: FontWeight.bold)),
                if (_parameters.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'IF',
                          style: theme.getStyle().copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        divider(horizontal: true),
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueGrey),
                              borderRadius: BorderRadius.circular(5)),
                          child: DropdownButton<twinned.Parameter>(style: theme.getStyle(),
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            dropdownColor: Colors.white,
                            isDense: true,
                            underline: Container(),
                            hint: Row(
                              children: [
                                const Icon(Icons.menu),
                                divider(horizontal: true, width: 4),
                                Text("Fields", style: theme.getStyle()),
                              ],
                            ),
                            items: _parameters
                                .map((e) => DropdownMenuItem<twinned.Parameter>(
                                    value: e,
                                    child: Text(
                                      e.name,
                                      style: theme.getStyle(),
                                    )))
                                .toList(),
                            value: selectedField,
                            onChanged: (twinned.Parameter? value) async {
                              setState(() {
                                setSelectedField(value);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                divider(),
                if (_conditions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(5)),
                      child: DropdownButton<twinned.FieldFilterInfoCondition>(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        dropdownColor: Colors.white,
                        isDense: true,
                        underline: Container(),
                        hint: Row(
                          children: [
                            const Icon(Icons.code),
                            divider(horizontal: true, width: 4),
                            Text(
                              "Conditions",
                              style: theme.getStyle(),
                            ),
                          ],
                        ),
                        items: _conditions
                            .map((e) => DropdownMenuItem<
                                    twinned.FieldFilterInfoCondition>(
                                value: e,
                                child: Text(
                                  _labels[e] ?? '?',
                                  style: theme.getStyle(),
                                )))
                            .toList(),
                        value: selectedCondition,
                        onChanged: (twinned.FieldFilterInfoCondition? value) {
                          setSelectedCondition(
                              value ?? twinned.FieldFilterInfoCondition.eq);
                        },
                      ),
                    ),
                  ),
                divider(),
                if (null != selectedCondition &&
                    valueType == 1 &&
                    selectedField!.parameterType !=
                        twinned.ParameterParameterType.yesno)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: LabelTextField(
                        label: 'Value',
                        labelTextStyle: theme.getStyle(),
                        style: theme.getStyle(),
                        controller: _value),
                  ),
                if (null != selectedCondition &&
                    valueType == 1 &&
                    selectedField!.parameterType ==
                        twinned.ParameterParameterType.yesno)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(5)),
                      child: DropdownButton<bool>(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        dropdownColor: Colors.white,
                        isDense: true,
                        underline: Container(),
                        items: [true, false]
                            .map((e) => DropdownMenuItem<bool>(
                                value: e,
                                child: Text(
                                  '$e',
                                  style: theme.getStyle(),
                                )))
                            .toList(),
                        value: selectedValue,
                        onChanged: (bool? value) {
                          selectedValue = value;
                        },
                      ),
                    ),
                  ),
                if (null != selectedCondition && valueType == 2)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: LabelTextField(
                              label: 'Left Value',
                              labelTextStyle: theme.getStyle(),
                              style: theme.getStyle(),
                              controller: _leftValue),
                        ),
                        divider(horizontal: true),
                        Expanded(
                          child: LabelTextField(
                              label: 'Right Value',
                              labelTextStyle: theme.getStyle(),
                              style: theme.getStyle(),
                              controller: _rightValue),
                        ),
                      ],
                    ),
                  ),
                if (null != selectedCondition && valueType == 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: LabelTextField(
                      label: 'Values (comma separated)',
                      labelTextStyle: theme.getStyle(),
                      style: theme.getStyle(),
                      controller: _values,
                      maxLines: 4,
                    ),
                  ),
              ],
            ),
          ),
          divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const BusyIndicator(),
              divider(horizontal: true),
              SecondaryButton(
                labelKey: "Cancel",
                onPressed: () {
                  _close();
                },
              ),
              divider(horizontal: true),
              if (selectedCondition != null)
                PrimaryButton(
                  labelKey: "Save",
                  leading: Icon(
                    Icons.save,
                    color: Color(0xFFFFFFFF),
                  ),
                  onPressed: () async {
                    await _save();
                  },
                ),
              divider(horizontal: true),
            ],
          ),
          divider(),
        ],
      ),
    ));
  }
}
