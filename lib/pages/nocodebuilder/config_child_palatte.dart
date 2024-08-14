import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:twin_app/core/constants.dart';
import 'package:twin_app/pages/nocodebuilder/foldable_card.dart';
import 'package:twin_app/pages/nocodebuilder/move_lrtb.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:highlight/languages/json.dart';
import 'package:twinned_widgets/core/border_config.dart';
import 'package:twinned_widgets/core/padding_config.dart';
import 'package:twinned_widgets/twinned_widgets.dart';
import 'package:twinned_models/twinned_models.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:twin_app/core/session_variables.dart';

typedef OnChildUpdate = void Function(
    int rowIndex, int columnIndex, ScreenChild child);

class ConfigChildPalette extends StatefulWidget {
  final int rowIndex;
  final int columnIndex;
  final int totalColumns;
  final ScreenChild child;
  final OnChildUpdate onChildDeleted;
  final OnChildUpdate onChildSaved;
  final OnChildUpdate onMovedLeft;
  final OnChildUpdate onMovedRight;
  const ConfigChildPalette({
    super.key,
    required this.rowIndex,
    required this.columnIndex,
    required this.totalColumns,
    required this.child,
    required this.onChildDeleted,
    required this.onChildSaved,
    required this.onMovedLeft,
    required this.onMovedRight,
  });

  @override
  State<ConfigChildPalette> createState() => _ConfigChildPaletteState();
}

class _ConfigChildPaletteState extends BaseState<ConfigChildPalette> {
  late ScreenChild _child;

  @override
  void initState() {
    _child = widget.child.copyWith();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CodeController controller = CodeController(
        language: json,
        text: const JsonEncoder.withIndent('  ').convert(widget.child.config));
    Map<String, dynamic> config = widget.child.config as Map<String, dynamic>;
    BaseConfig widgetConfig = TwinnedWidgets.getConfig(
        widgetId: widget.child.widgetId, config: config);

    TwinnedWidgetBuilder builder =
        TwinnedWidgets.builder(widget.child.widgetId)!;

    return FoldableCard(
      title: '${builder.getPaletteName()} - Properties',
      headerStyle:
          theme.getStyle().copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      labelStyle:
          theme.getStyle().copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      icon: builder.getPaletteIcon(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MoveLeftRightTopBottomWidget(
                currentIndex: widget.columnIndex,
                totalItems: widget.totalColumns,
                direction: Axis.horizontal,
                onMoveBack: () {
                  widget.onMovedLeft(
                      widget.rowIndex, widget.columnIndex, _child);
                },
                onMoveFront: () {
                  widget.onMovedRight(
                      widget.rowIndex, widget.columnIndex, _child);
                }),
            IconButton(
                onPressed: () {
                  alertDialog(
                      title: '${builder.getPaletteName()} - Parameters',
                      width: MediaQuery.of(context).size.width - 200,
                      height: MediaQuery.of(context).size.height - 150,
                      body: TwinnedConfigBuilder(
                          verbose: debug,
                          config: widgetConfig,
                          parameters: config,
                          defaultParameters: TwinnedWidgets.getConfig(
                                  widgetId: widget.child.widgetId)
                              .toJson(),
                          onConfigSaved: (config) {
                            var child = widget.child.copyWith(config: config);
                            debugPrint('SAVING CHILD: $child');
                            widget.onChildSaved(
                                widget.rowIndex, widget.columnIndex, child);
                          }));
                },
                icon: const Icon(Icons.menu)),
            IconButton(
                onPressed: () async {
                  await alertDialog(
                      title: 'Configuration',
                      width: MediaQuery.of(context).size.width / 2 + 100,
                      height: MediaQuery.of(context).size.height - 250,
                      body: Column(
                        children: [
                          Expanded(
                              child: SingleChildScrollView(
                                  child: CodeField(controller: controller))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.cancel)),
                              IconButton(
                                  onPressed: () {
                                    Map<String, dynamic> config =
                                        jsonDecode(controller.text);
                                    var child =
                                        widget.child.copyWith(config: config);
                                    widget.onChildSaved(widget.rowIndex,
                                        widget.columnIndex, child);
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.save)),
                            ],
                          ),
                        ],
                      ));
                },
                icon: const Icon(Icons.code)),
            IconButton(
                onPressed: () {
                  widget.onChildDeleted(
                      widget.rowIndex, widget.columnIndex, widget.child);
                },
                icon: const Icon(Icons.delete_forever)),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Background Color',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () {
                  _showColorPickerDialog();
                },
                icon: Icon(
                  Icons.palette,
                  color: Color((_child.bgColor ?? 0) > 0
                      ? _child.bgColor!
                      : Colors.white.value),
                )),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Widget Width',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 45,
              child: IntrinsicWidth(
                child: SpinBox(
                  min: 1,
                  max: 4096,
                  value: _child.width ?? 200,
                  step: 1,
                  onSubmitted: (value) {
                    setState(() {
                      _child = _child.copyWith(width: value);
                    });
                    widget.onChildSaved(
                        widget.rowIndex, widget.columnIndex, _child);
                  },
                ),
              ),
            ),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Widget Height',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 45,
              child: IntrinsicWidth(
                child: SpinBox(
                  min: 1,
                  max: 4096,
                  value: _child.height ?? 200,
                  step: 1,
                  onSubmitted: (value) {
                    setState(() {
                      _child = _child.copyWith(height: value);
                    });
                    widget.onChildSaved(
                        widget.rowIndex, widget.columnIndex, _child);
                  },
                ),
              ),
            ),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Expanded',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            Checkbox(
              value: _child.expanded ?? false,
              onChanged: (newValue) {
                setState(() {
                  _child = _child.copyWith(expanded: newValue);
                });
                widget.onChildSaved(
                    widget.rowIndex, widget.columnIndex, _child);
              },
            ),
          ],
        ),
        divider(),
        if (_child.expanded ?? false)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flex',
                style: theme.getStyle().copyWith(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 45,
                child: IntrinsicWidth(
                  child: SpinBox(
                    min: 1,
                    max: 100,
                    value: (_child.flex ?? 1).toDouble(),
                    step: 1,
                    onSubmitted: (value) {
                      setState(() {
                        _child = _child.copyWith(flex: value.toInt());
                      });
                      widget.onChildSaved(
                          widget.rowIndex, widget.columnIndex, _child);
                    },
                  ),
                ),
              ),
            ],
          ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alignment',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            DropdownButton<AlignmentConfig>(
                value: _child.alignment ??
                    const AlignmentConfig(
                        alignment:
                            AlignmentConfigAlignment.swaggerGeneratedUnknown),
                items: const [
                  DropdownMenuItem<AlignmentConfig>(
                      value: AlignmentConfig(
                          alignment:
                              AlignmentConfigAlignment.swaggerGeneratedUnknown),
                      child: Text('None')),
                  DropdownMenuItem<AlignmentConfig>(
                      value: AlignmentConfig(
                          alignment: AlignmentConfigAlignment.bottomRight),
                      child: Text('Bottom Right')),
                  DropdownMenuItem<AlignmentConfig>(
                      value: AlignmentConfig(
                          alignment: AlignmentConfigAlignment.bottomLeft),
                      child: Text('Bottom Left')),
                  DropdownMenuItem<AlignmentConfig>(
                      value: AlignmentConfig(
                          alignment: AlignmentConfigAlignment.center),
                      child: Text('Center')),
                  DropdownMenuItem<AlignmentConfig>(
                      value: AlignmentConfig(
                          alignment: AlignmentConfigAlignment.centerLeft),
                      child: Text('Center Left')),
                  DropdownMenuItem<AlignmentConfig>(
                      value: AlignmentConfig(
                          alignment: AlignmentConfigAlignment.centerRight),
                      child: Text('Center Right')),
                  DropdownMenuItem<AlignmentConfig>(
                      value: AlignmentConfig(
                          alignment: AlignmentConfigAlignment.topRight),
                      child: Text('Top Right')),
                  DropdownMenuItem<AlignmentConfig>(
                      value: AlignmentConfig(
                          alignment: AlignmentConfigAlignment.topLeft),
                      child: Text('Top Left')),
                  DropdownMenuItem<AlignmentConfig>(
                      value: AlignmentConfig(
                          alignment: AlignmentConfigAlignment.topCenter),
                      child: Text('Top Center')),
                  DropdownMenuItem<AlignmentConfig>(
                      value: AlignmentConfig(
                          alignment: AlignmentConfigAlignment.bottomCenter),
                      child: Text('Bottom Center')),
                ],
                onChanged: (value) {
                  setState(() {
                    _child = _child.copyWith(alignment: value);
                  });
                  widget.onChildSaved(
                      widget.rowIndex, widget.columnIndex, _child);
                })
          ],
        ),
        divider(),
        BorderConfigWidget(
            borderConfig: _child.childBorderConfig,
            onBorderConfigured: (border) {
              _onBorderConfigured(border);
            }),
        divider(),
        PaddingConfigWidget(
            title: 'Padding',
            paddingConfig: _child.paddingConfig,
            onPaddingConfigSaved: (paddingConfig) {
              _onPaddingConfigSaved(paddingConfig);
            }),
        divider(),
        PaddingConfigWidget(
            title: 'Margin',
            paddingConfig: _child.marginConfig,
            onPaddingConfigSaved: (paddingConfig) {
              _onMarginConfigSaved(paddingConfig);
            }),
      ],
      onCollapsed: (collapsed) {},
    );
  }

  void _onPaddingConfigSaved(PaddingConfig? paddingConfig) {
    final ScreenChild thisChild;

    if (null == paddingConfig) {
      thisChild = ScreenChild(
        widgetId: _child.widgetId,
        config: _child.config,
        bgImageFit: _child.bgImageFit,
        bgImage: _child.bgImage,
        bgColor: _child.bgColor,
        width: _child.width,
        height: _child.height,
        expanded: _child.expanded,
        alignment: _child.alignment,
        flex: _child.flex,
        childBorderConfig: _child.childBorderConfig,
        marginConfig: _child.marginConfig,
      );
    } else {
      thisChild = _child.copyWith(paddingConfig: paddingConfig);
    }
    setState(() {
      _child = thisChild;
    });

    widget.onChildSaved(widget.rowIndex, widget.columnIndex, _child);
  }

  void _onMarginConfigSaved(PaddingConfig? marginConfig) {
    final ScreenChild thisChild;

    if (null == marginConfig) {
      thisChild = ScreenChild(
        widgetId: _child.widgetId,
        config: _child.config,
        paddingConfig: _child.paddingConfig,
        bgImageFit: _child.bgImageFit,
        bgImage: _child.bgImage,
        bgColor: _child.bgColor,
        width: _child.width,
        height: _child.height,
        expanded: _child.expanded,
        alignment: _child.alignment,
        flex: _child.flex,
        childBorderConfig: _child.childBorderConfig,
      );
    } else {
      thisChild = _child.copyWith(marginConfig: marginConfig);
    }
    setState(() {
      _child = thisChild;
    });

    widget.onChildSaved(widget.rowIndex, widget.columnIndex, _child);
  }

  void _onBorderConfigured(BorderConfig? borderConfig) {
    final ScreenChild thisChild;

    if (null == borderConfig) {
      thisChild = ScreenChild(
        widgetId: _child.widgetId,
        config: _child.config,
        paddingConfig: _child.paddingConfig,
        bgImageFit: _child.bgImageFit,
        bgImage: _child.bgImage,
        bgColor: _child.bgColor,
        width: _child.width,
        height: _child.height,
        expanded: _child.expanded,
        alignment: _child.alignment,
        flex: _child.flex,
        marginConfig: _child.marginConfig,
      );
    } else {
      thisChild = _child.copyWith(childBorderConfig: borderConfig);
    }
    setState(() {
      _child = thisChild;
    });

    widget.onChildSaved(widget.rowIndex, widget.columnIndex, _child);
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              hexInputBar: true,
              labelTypes: [],
              pickerColor: Color(_child.bgColor ?? Colors.white.value),
              onColorChanged: (color) {
                setState(() {
                  _child = _child.copyWith(bgColor: color.value);
                });
              },
              enableAlpha: true,
              displayThumbColor: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                widget.onChildSaved(
                    widget.rowIndex, widget.columnIndex, _child);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void setup() {}
}
