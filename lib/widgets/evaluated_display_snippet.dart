import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;

class EvaluatedDisplaysSnippet extends StatefulWidget {
  final twinned.Twinned twin;
  final String authToken;
  final twinned.DeviceData deviceData;
  final Axis orientation;
  final double spacing;

  const EvaluatedDisplaysSnippet(
      {super.key,
      required this.twin,
      required this.authToken,
      required this.deviceData,
      this.orientation = Axis.horizontal,
      this.spacing = 8});

  @override
  State<EvaluatedDisplaysSnippet> createState() =>
      _EvaluatedDisplaysSnippetState();
}

class _EvaluatedDisplaysSnippetState
    extends BaseState<EvaluatedDisplaysSnippet> {
  final List<Widget> displays = [];

  @override
  void initState() {
    for (int i = 0; i < widget.deviceData.alarms.length; i++) {
      displays.add(const Icon(Icons.hourglass_empty));
    }
    super.initState();
  }

  @override
  void setup() async {
    displays.clear();
    for (var display in widget.deviceData.displays) {
      displays.add(EvaluatedDisplaySnippet(
        twin: widget.twin,
        authToken: widget.authToken,
        evaluatedDisplay: display,
      ));
    }
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: widget.orientation,
      spacing: widget.spacing,
      children: displays,
    );
  }
}

class EvaluatedDisplaySnippet extends StatefulWidget {
  final twinned.Twinned twin;
  final String authToken;
  final twinned.EvaluatedDisplay evaluatedDisplay;
  const EvaluatedDisplaySnippet(
      {super.key,
      required this.twin,
      required this.authToken,
      required this.evaluatedDisplay});

  @override
  State<EvaluatedDisplaySnippet> createState() =>
      _EvaluatedDisplaySnippetState();
}

class _EvaluatedDisplaySnippetState extends BaseState<EvaluatedDisplaySnippet> {
  late twinned.Display? display;
  Widget? builtDisplay;

  @override
  void setup() async {
    var res = await widget.twin.getDisplay(
        apikey: widget.authToken, displayId: widget.evaluatedDisplay.displayId);

    if (!validateResponse(res, shouldAlert: false)) return;

    display = res.body!.entity;

    var cond = display!.conditions[widget.evaluatedDisplay.conditionIndex];
    List<String> values = [];

    values.add(widget.evaluatedDisplay.prefix);
    values.add(widget.evaluatedDisplay.$value);
    values.add(widget.evaluatedDisplay.suffix);

    BoxDecoration? decoration;

    switch (cond.borderType) {
      case twinned.DisplayMatchGroupBorderType.box:
        decoration = BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.zero),
            color: Color(cond.bgColor!),
            border: Border.all(
                style: BorderStyle.solid, color: Color(cond.bordorColor!)));
        break;
      case twinned.DisplayMatchGroupBorderType.rounded:
        decoration = BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.elliptical(cond.width, cond.height)),
            color: Color(cond.bgColor!),
            border: Border.all(
                style: BorderStyle.solid, color: Color(cond.bordorColor!)));
        break;
      case twinned.DisplayMatchGroupBorderType.circle:
        decoration = BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(cond.width)),
            color: Color(cond.bgColor!),
            border: Border.all(
                style: BorderStyle.solid, color: Color(cond.bordorColor!)));
        break;
      default:
        decoration = BoxDecoration(color: Color(cond.bgColor!));
    }

    var displayText = RichText(
      text: TextSpan(children: [
        TextSpan(
          text: values[0],
          style: TextStyle(
              fontFamily: cond.prefixFont!,
              fontSize: cond.prefixFontSize!,
              color: Color(cond.prefixFontColor!)),
        ),
        WidgetSpan(
            child: SizedBox(
          width: cond.prefixPadding,
        )),
        TextSpan(
          text: values[1],
          style: TextStyle(
              fontFamily: cond.font,
              fontSize: cond.fontSize,
              color: Color(cond.fontColor)),
        ),
        WidgetSpan(
            child: SizedBox(
          width: cond.suffixPadding,
        )),
        TextSpan(
          text: values[2],
          style: TextStyle(
              fontFamily: cond.suffixFont!,
              fontSize: cond.suffixFontSize!,
              color: Color(cond.suffixFontColor!)),
        ),
      ]),
    );

    builtDisplay = SizedBox(
        width: cond.width,
        height: cond.height,
        child: Container(
            decoration: decoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Tooltip(
                    message: cond.tooltip ?? display!.name, child: displayText),
              ],
            )));
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return null != builtDisplay
        ? builtDisplay!
        : const Icon(Icons.hourglass_empty);
  }
}
