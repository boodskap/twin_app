import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:twin_app/core/session_variables.dart';

enum PickTarget { border, background }

typedef ColorCallback = void Function(int borderColor, int bgColor);

class CustomColorPalette extends StatefulWidget {
  final ColorCallback onColorChanged;

  late int currentBorderColor;
  late int currentBgColor;
  CustomColorPalette(
      {super.key,
      required this.onColorChanged,
      required this.currentBorderColor,
      required this.currentBgColor});

  @override
  State<CustomColorPalette> createState() => _CustomColorPaletteState();
}

class _CustomColorPaletteState extends State<CustomColorPalette> {
  double iconSize = 15;

  @override
  void initState() {
    super.initState();
  }

  void _pickColor(PickTarget target) {
    Color existingColor;
    switch (target) {
      case PickTarget.border:
        existingColor = Color(widget.currentBorderColor!);
        break;
      case PickTarget.background:
        existingColor = Color(widget.currentBgColor!);
        break;
    }
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Pick a Color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                hexInputBar: true,
                labelTypes: [],
                pickerColor: existingColor,
                displayThumbColor: true,
                onColorChanged: (color) {
                  switch (target) {
                    case PickTarget.border:
                      widget.currentBorderColor = color.value;
                      break;
                    case PickTarget.background:
                      widget.currentBgColor = color.value;
                      break;
                  }
                  // Invoke the callback to return the colors
                  widget.onColorChanged(
                      widget.currentBorderColor, widget.currentBgColor);
                  _refresh();
                },
              ),
            ),
          );
        });
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Border Color",
            style: theme.getStyle().copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
        Tooltip(
            message: 'Choose border color',
            child: IconButton(
                onPressed: () {
                  _pickColor(PickTarget.border);
                },
                icon: Icon(
                  Icons.border_color,
                  size: iconSize,
                  color: Color(widget.currentBorderColor),
                ))),
        const SizedBox(width: 8),
        Text("Fill Color",
            style: theme.getStyle().copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
        Tooltip(
            message: 'Choose fill color',
            child: IconButton(
                onPressed: () {
                  _pickColor(PickTarget.background);
                },
                icon: Icon(
                  Icons.format_color_fill,
                  size: iconSize,
                  color: Color(widget.currentBgColor),
                ))),
      ],
    );
  }
}
