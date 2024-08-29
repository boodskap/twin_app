// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:twin_commons/level/widgets/settings/conicaltank_settings.dart';
import 'package:twin_commons/level/widgets/settings/corkedbottle_settings.dart';
import 'package:twin_commons/level/widgets/settings/cylindricaltank_settings.dart';
import 'package:twin_commons/level/widgets/settings/pressuregauge_settings.dart';
import 'package:twin_commons/level/widgets/settings/rectangulartank_settings.dart';
import 'package:twin_commons/level/widgets/settings/speedometer_settings.dart';
import 'package:twin_commons/level/widgets/settings/sphericaltank_settings.dart';
import 'package:twin_commons/level/widgets/settings/batterygauge_settings.dart';
import 'package:twin_commons/level/widgets/settings/cylindertank_settings.dart';
import 'package:twin_commons/level/widgets/settings/prismtank_settings.dart';
import 'package:twin_commons/level/widgets/settings/bladdertank_settings.dart';
import 'package:twin_commons/level/widgets/settings/semicircle_settings.dart';
import 'package:twin_commons/level/widgets/settings/triangle_settings.dart';
import 'package:twin_commons/level/widgets/settings/trapezoid_settings.dart';
import 'package:twin_commons/level/widgets/settings/hexagon_settings.dart';
import 'package:twin_commons/level/widgets/settings/roof_top_settings.dart';
import 'package:twin_commons/core/sensor_widget.dart';

import 'package:twin_commons/widgets/common/parameter_units_dropdown.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';

typedef AddRow = void Function();
typedef OnSensorWidgetUpdated = Function(twinned.SensorWidget sensorWidget);

class ParameterUpsertDialog extends StatefulWidget {
  final TextEditingController paramName;
  final TextEditingController paramUnit;
  final TextEditingController paramDesc;
  final TextEditingController paramLabel;
  final TextEditingController paramValue;
  final ValueNotifier<bool> paramRequired;
  final ValueNotifier<bool> enableTrend;
  final ValueNotifier<bool> enableTimeSeries;
  // final VoidCallback onUpload;
  final Function(String) onUpload;
  final String paramIcon;
  ValueNotifier<twinned.ParameterParameterType> paramType;
  twinned.DeviceModel? model;
  AddRow addRow;
  bool isEdit;
  twinned.SensorWidget sensorWidget;
  final OnSensorWidgetUpdated onSensorWidgetUpdated;

  ParameterUpsertDialog({
    super.key,
    this.model,
    required this.addRow,
    required this.paramName,
    required this.paramDesc,
    required this.paramLabel,
    required this.paramType,
    required this.paramValue,
    required this.paramRequired,
    required this.enableTrend,
    required this.enableTimeSeries,
    required this.isEdit,
    required this.paramUnit,
    required this.onUpload,
    required this.paramIcon,
    required this.sensorWidget,
    required this.onSensorWidgetUpdated,
  });

  @override
  State<ParameterUpsertDialog> createState() => _ParameterUpsertDialogState();
}

class _ParameterUpsertDialogState extends BaseState<ParameterUpsertDialog> {
  String iconParamId = "";
  SensorWidgetType? selectedWidgetType = SensorWidgetType.none;

  @override
  void initState() {
    iconParamId = widget.paramIcon;
    if (SensorWidgetType.values
        .asNameMap()
        .containsKey(widget.sensorWidget.widgetId)) {
      selectedWidgetType =
          SensorWidgetType.values.byName(widget.sensorWidget.widgetId);
    }
    super.initState();
  }

  @override
  void setup() {}

  @override
  void dispose() {
    widget.paramName.clear();
    widget.paramUnit.clear();
    widget.paramDesc.clear();
    widget.paramLabel.clear();
    widget.paramValue.clear();
    widget.paramRequired.value = true;
    widget.enableTrend.value = false;
    widget.enableTimeSeries.value = false;
    widget.paramType = ValueNotifier(twinned.ParameterParameterType.numeric);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const vDivider = SizedBox(height: 8);

    return AlertDialog(
      title: const Text('Parameter Info'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.35,
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                Column(
                  children: [
                    vDivider,
                    Row(
                      children: [
                        Expanded(
                          flex: 70,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: LabelTextField(
                              label: 'Name',
                              controller: widget.paramName,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r"\s")),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 30,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ParameterUnitsDropdown(
                              label: 'Unit',
                              text: widget.paramUnit.text,
                              onChanged: (val) {
                                setState(() {
                                  widget.paramUnit.text = val;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
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
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Label',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        controller: widget.paramLabel,
                        validator: (widget.enableTrend.value ||
                                widget.enableTimeSeries.value)
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Label is required';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                    vDivider,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DropdownButton<twinned.ParameterParameterType>(
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem<twinned.ParameterParameterType>(
                            value: twinned.ParameterParameterType.numeric,
                            child: Text('Number'),
                          ),
                          DropdownMenuItem<twinned.ParameterParameterType>(
                            value: twinned.ParameterParameterType.floating,
                            child: Text('Decimal'),
                          ),
                          DropdownMenuItem<twinned.ParameterParameterType>(
                            value: twinned.ParameterParameterType.yesno,
                            child: Text('Boolean'),
                          ),
                          DropdownMenuItem<twinned.ParameterParameterType>(
                            value: twinned.ParameterParameterType.text,
                            child: Text('Text'),
                          ),
                        ],
                        value: widget.paramType.value,
                        onChanged: !widget.isEdit
                            ? (twinned.ParameterParameterType? value) {
                                setState(() {
                                  widget.paramType.value = value ??
                                      twinned.ParameterParameterType.numeric;
                                });
                              }
                            : null,
                      ),
                    ),
                    vDivider,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: LabelTextField(
                        label: 'Default Value',
                        controller: widget.paramValue,
                      ),
                    ),
                    vDivider,
                    Wrap(
                      spacing: 8,
                      children: [
                        CheckboxListTile(
                          title: const Text('Required'),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          value: widget.paramRequired.value,
                          onChanged: (bool? value) {
                            setState(() {
                              widget.paramRequired.value = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Enable Trend'),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          value: widget.enableTrend.value,
                          onChanged: (bool? value) {
                            setState(() {
                              widget.enableTrend.value = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Enable Time Series'),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          value: widget.enableTimeSeries.value,
                          onChanged: (bool? value) {
                            setState(() {
                              widget.enableTimeSeries.value = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    if (widget.paramType.value ==
                            twinned.ParameterParameterType.numeric ||
                        widget.paramType.value ==
                            twinned.ParameterParameterType.floating)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Text('Widget'),
                            divider(horizontal: true),
                            SensorTypesDropdown(
                                selected: selectedWidgetType,
                                onSensorSelected: (selected) {
                                  SensorWidgetType type =
                                      selected ?? SensorWidgetType.none;
                                  widget.sensorWidget = widget.sensorWidget
                                      .copyWith(widgetId: type.name);
                                  setState(() {
                                    selectedWidgetType = type;
                                  });
                                  widget.onSensorWidgetUpdated(
                                      widget.sensorWidget);
                                }),
                            divider(horizontal: true),
                            IconButton(
                                onPressed: () async {
                                  await _editWidget();
                                },
                                icon: const Icon(Icons.edit)),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          PrimaryButton(
                            labelKey: "Upload Icon",
                            onPressed: () async {
                              await _upload();
                            },
                          ),
                          SizedBox(width: 5),
                          if (iconParamId != "")
                            SizedBox(
                              height: 30,
                              width: 30,
                              child: TwinImageHelper.getCachedImage(
                                TwinnedSession.instance.domainKey,
                                iconParamId,
                                fit: BoxFit.contain,
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Column(
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
                SecondaryButton(
                  labelKey: "Close",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                PrimaryButton(
                  labelKey:
                      widget.isEdit ? 'Update Parameter' : 'Add Parameter',
                  onPressed: () {
                    widget.addRow();
                    setState(() {
                      if (widget.isEdit) {
                        if (SensorWidgetType.values
                            .asNameMap()
                            .containsKey(widget.sensorWidget.widgetId)) {
                          selectedWidgetType = SensorWidgetType.values
                              .byName(widget.sensorWidget.widgetId);
                        }
                      } else {
                        selectedWidgetType = SensorWidgetType.none;
                        widget.sensorWidget = twinned.SensorWidget(
                          widgetId: SensorWidgetType.none.name,
                          attributes: {},
                        );
                      }
                      widget.paramType.value =
                          twinned.ParameterParameterType.numeric;
                      selectedWidgetType = SensorWidgetType.none;
                      widget.sensorWidget = twinned.SensorWidget(
                        widgetId: SensorWidgetType.none.name,
                        attributes: {},
                      );
                      widget.onSensorWidgetUpdated(widget.sensorWidget);
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Future _upload() async {
    await execute(() async {
      var res = await TwinImageHelper.uploadDomainImage();
      if (null != res) {
        setState(() {
          iconParamId = res.entity!.id;
        });
        widget.onUpload(iconParamId);
      }
    });
  }

  void _onSettingsSaved(Map<String, dynamic> settings) {
    widget.sensorWidget = widget.sensorWidget.copyWith(attributes: settings);
    setState(() {});
    widget.onSensorWidgetUpdated(widget.sensorWidget);
  }

  Future _editWidget() async {
    Map<String, dynamic> settings = {};

    try {
      settings = widget.sensorWidget.attributes as Map<String, dynamic>;
    } catch (e, s) {
      settings = jsonDecode(widget.sensorWidget.attributes.toString());
    }

    String label = TwinUtils.getStrippedLabel(widget.paramLabel.text);
    String unit = widget.paramUnit.text;
    String title = '$label Widget';

    switch (selectedWidgetType ?? SensorWidgetType.none) {
      case SensorWidgetType.none:
      case SensorWidgetType.blank:
        return;
      case SensorWidgetType.speedometer:
        await alertDialog(
            title: title,
            body: SpeedometerSettings(
                label: label,
                unit: unit,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.pressureGauge:
        await alertDialog(
            title: title,
            body: PressureGaugeSettings(
                label: label,
                unit: unit,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.conicalTank:
        await alertDialog(
            title: title,
            body: ConicalTankSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.corkedBottle:
        await alertDialog(
            title: title,
            body: CorkedBottleSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.cylindricalTank:
        await alertDialog(
            title: title,
            body: CylindricalTankSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.rectangularTank:
        await alertDialog(
            title: title,
            body: RectangularTankSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.sphericalTank:
        await alertDialog(
            title: title,
            body: SphericalTankSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
      case SensorWidgetType.batteryGauge:
        await alertDialog(
            title: title,
            body: BatteryGaugeSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.cylinderTank:
        await alertDialog(
            title: title,
            body: CylinderTankSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.prismTank:
        await alertDialog(
            title: title,
            body: PrismTankSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.triangleTank:
        await alertDialog(
            title: title,
            body: TriangleTankSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.semiCircleTank:
        await alertDialog(
            title: title,
            body: SemiCircleSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.trapezoidTank:
        await alertDialog(
            title: title,
            body: TrapezoidTankSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.hexagonTank:
        await alertDialog(
            title: title,
            body: HexagonTankSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.roofTopTank:
        await alertDialog(
            title: title,
            body: RoofTopTankSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
      case SensorWidgetType.bladderTank:
        await alertDialog(
            title: title,
            body: BladderTankSettings(
                label: label,
                settings: settings,
                onSettingsSaved: _onSettingsSaved));
        break;
    }
  }
}
