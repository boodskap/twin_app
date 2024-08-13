import 'package:flutter/material.dart';
import 'package:twin_app/pages/nocodebuilder/foldable_card.dart';
import 'package:twin_app/pages/nocodebuilder/move_lrtb.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:twinned_widgets/core/border_config.dart';
import 'package:twinned_widgets/core/padding_config.dart';
import 'package:twin_app/core/session_variables.dart';

typedef OnRowUpdate = void Function(int rowIndex, ScreenRow row);

class ConfigRowPalette extends StatefulWidget {
  final int index;
  final int totalRows;
  final ScreenRow row;
  final OnRowUpdate onRowDeleted;
  final OnRowUpdate onRowSaved;
  final OnRowUpdate onRowMovedUp;
  final OnRowUpdate onRowMovedDown;

  const ConfigRowPalette({
    super.key,
    required this.index,
    required this.totalRows,
    required this.row,
    required this.onRowDeleted,
    required this.onRowSaved,
    required this.onRowMovedUp,
    required this.onRowMovedDown,
  });

  @override
  State<ConfigRowPalette> createState() => _ConfigRowPaletteState();
}

class _ConfigRowPaletteState extends BaseState<ConfigRowPalette> {
  // static const labelStyle =
  //     TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

  static final InputDecorationTheme dropdownDecoration = InputDecorationTheme(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    constraints: BoxConstraints.tight(const Size.fromHeight(40)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static bool collapsed = false;

  late ScreenRow _row;

  @override
  void initState() {
    _row = widget.row.copyWith();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FoldableCard(
      title: 'Row Properties',
      collapsed: collapsed,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MoveLeftRightTopBottomWidget(
                currentIndex: widget.index,
                totalItems: widget.totalRows,
                direction: Axis.vertical,
                onMoveBack: () {
                  widget.onRowMovedUp(widget.index, _row);
                },
                onMoveFront: () {
                  widget.onRowMovedDown(widget.index, _row);
                }),
            divider(horizontal: true),
            IconButton(
                onPressed: () {
                  widget.onRowDeleted(widget.index, widget.row);
                },
                icon: const Icon(Icons.delete_forever)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Child Spacing',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 35,
              child: IntrinsicWidth(
                child: SpinBox(
                  min: 0.0,
                  max: 500,
                  value: _row.spacing ?? 10,
                  step: 1,
                  onSubmitted: (value) {
                    setState(() {
                      _row = _row.copyWith(spacing: value);
                    });
                    widget.onRowSaved(widget.index, _row);
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
                  color: Color((_row.bgColor ?? 0) > 0
                      ? _row.bgColor!
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
              'Row Height',
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
                  value: _row.height ?? 200,
                  step: 1,
                  onSubmitted: (value) {
                    setState(() {
                      _row = _row.copyWith(height: value);
                    });
                    widget.onRowSaved(widget.index, _row);
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
              'Main Axis Alignment',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            DropdownMenu<MainAxisAlignment>(
                initialSelection: MainAxisAlignment.values.byName(
                    _row.mainAxisAlignment ?? MainAxisAlignment.start.name),
                inputDecorationTheme: dropdownDecoration,
                onSelected: (value) {
                  setState(() {
                    _row = _row.copyWith(
                        mainAxisAlignment:
                            (value ?? MainAxisAlignment.start).name);
                  });
                  widget.onRowSaved(widget.index, _row);
                },
                dropdownMenuEntries: const [
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.start, label: 'Start'),
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.center, label: 'Center'),
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.end, label: 'End'),
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.spaceEvenly,
                      label: 'Space Evenly'),
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.spaceBetween,
                      label: 'Space Between'),
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.spaceAround,
                      label: 'Space Around'),
                ]),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cross Axis Alignment',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            DropdownMenu<CrossAxisAlignment>(
                initialSelection: CrossAxisAlignment.values.byName(
                    _row.crossAxisAlignment ?? CrossAxisAlignment.start.name),
                inputDecorationTheme: dropdownDecoration,
                onSelected: (value) {
                  setState(() {
                    _row = _row.copyWith(
                        crossAxisAlignment:
                            (value ?? CrossAxisAlignment.start).name);
                  });
                  widget.onRowSaved(widget.index, _row);
                },
                dropdownMenuEntries: const [
                  DropdownMenuEntry<CrossAxisAlignment>(
                      value: CrossAxisAlignment.start, label: 'Start'),
                  DropdownMenuEntry<CrossAxisAlignment>(
                      value: CrossAxisAlignment.center, label: 'Center'),
                  DropdownMenuEntry<CrossAxisAlignment>(
                      value: CrossAxisAlignment.end, label: 'End'),
                  DropdownMenuEntry<CrossAxisAlignment>(
                      value: CrossAxisAlignment.stretch, label: 'Stretch'),
                  // DropdownMenuEntry<CrossAxisAlignment>(
                  //     value: CrossAxisAlignment.baseline, label: 'Baseline'),
                ]),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Main Axis Size',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            DropdownMenu<MainAxisSize>(
                initialSelection: MainAxisSize.values
                    .byName(_row.mainAxisSize ?? MainAxisSize.max.name),
                inputDecorationTheme: dropdownDecoration,
                onSelected: (value) {
                  setState(() {
                    _row = _row.copyWith(
                        mainAxisSize: (value ?? MainAxisSize.max).name);
                  });
                  widget.onRowSaved(widget.index, _row);
                },
                dropdownMenuEntries: const [
                  DropdownMenuEntry<MainAxisSize>(
                      value: MainAxisSize.min, label: 'Min'),
                  DropdownMenuEntry<MainAxisSize>(
                      value: MainAxisSize.max, label: 'Max'),
                ]),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scroll Direction',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            DropdownMenu<String>(
                initialSelection: _row.scrollDirection ?? 'none',
                inputDecorationTheme: dropdownDecoration,
                onSelected: (value) {
                  setState(() {
                    _row = _row.copyWith(scrollDirection: value ?? 'none');
                  });
                  widget.onRowSaved(widget.index, _row);
                },
                dropdownMenuEntries: [
                  const DropdownMenuEntry<String>(value: 'none', label: 'None'),
                  DropdownMenuEntry<String>(
                      value: Axis.vertical.name, label: 'Vertical'),
                  DropdownMenuEntry<String>(
                      value: Axis.horizontal.name, label: 'Horizontal'),
                ]),
          ],
        ),
        divider(),
        BorderConfigWidget(
            borderConfig: _row.rowBorderConfig,
            onBorderConfigured: (border) {
              _onBorderConfigured(border);
            }),
        divider(),
        PaddingConfigWidget(
            title: 'Padding',
            paddingConfig: _row.paddingConfig,
            onPaddingConfigSaved: (paddingConfig) {
              _onPaddingConfigSaved(paddingConfig);
            }),
        divider(),
        PaddingConfigWidget(
            title: 'Margin',
            paddingConfig: _row.marginConfig,
            onPaddingConfigSaved: (paddingConfig) {
              _onMarginConfigSaved(paddingConfig);
            }),
      ],
      onCollapsed: (value) {
        setState(() {
          collapsed = value;
        });
      },
    );
  }

  void _onPaddingConfigSaved(PaddingConfig? paddingConfig) {
    final ScreenRow thisRow;

    if (null == paddingConfig) {
      thisRow = ScreenRow(
          spacing: _row.spacing,
          crossAxisAlignment: _row.crossAxisAlignment,
          mainAxisAlignment: _row.mainAxisAlignment,
          height: _row.height,
          scrollDirection: _row.scrollDirection,
          bgImageFit: _row.bgImageFit,
          mainAxisSize: _row.mainAxisSize,
          bgImage: _row.bgImage,
          bgColor: _row.bgColor,
          marginConfig: _row.marginConfig,
          rowBorderConfig: _row.rowBorderConfig,
          children: _row.children);
    } else {
      thisRow = _row.copyWith(paddingConfig: paddingConfig);
    }

    setState(() {
      _row = thisRow;
    });

    widget.onRowSaved(widget.index, _row);
  }

  void _onMarginConfigSaved(PaddingConfig? marginConfig) {
    final ScreenRow thisRow;

    if (null == marginConfig) {
      thisRow = ScreenRow(
          spacing: _row.spacing,
          crossAxisAlignment: _row.crossAxisAlignment,
          mainAxisAlignment: _row.mainAxisAlignment,
          height: _row.height,
          scrollDirection: _row.scrollDirection,
          bgImageFit: _row.bgImageFit,
          mainAxisSize: _row.mainAxisSize,
          bgImage: _row.bgImage,
          bgColor: _row.bgColor,
          paddingConfig: _row.paddingConfig,
          rowBorderConfig: _row.rowBorderConfig,
          children: _row.children);
    } else {
      thisRow = _row.copyWith(marginConfig: marginConfig);
    }

    setState(() {
      _row = thisRow;
    });

    widget.onRowSaved(widget.index, _row);
  }

  void _onBorderConfigured(BorderConfig? borderConfig) {
    final ScreenRow thisRow;

    if (null == borderConfig) {
      thisRow = ScreenRow(
          spacing: _row.spacing,
          crossAxisAlignment: _row.crossAxisAlignment,
          mainAxisAlignment: _row.mainAxisAlignment,
          height: _row.height,
          scrollDirection: _row.scrollDirection,
          bgImageFit: _row.bgImageFit,
          mainAxisSize: _row.mainAxisSize,
          bgImage: _row.bgImage,
          bgColor: _row.bgColor,
          marginConfig: _row.marginConfig,
          paddingConfig: _row.paddingConfig,
          children: _row.children);
    } else {
      thisRow = _row.copyWith(rowBorderConfig: borderConfig);
    }
    setState(() {
      _row = thisRow;
    });

    widget.onRowSaved(widget.index, _row);
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
              pickerColor: Color(_row.bgColor ?? Colors.white.value),
              onColorChanged: (color) {
                setState(() {
                  _row = _row.copyWith(bgColor: color.value);
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
                widget.onRowSaved(widget.index, _row);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}
