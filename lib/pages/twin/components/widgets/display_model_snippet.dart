import 'package:flutter/material.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;

class SimpleDisplaySnippet extends StatelessWidget {
  final twinned.Display display;
  const SimpleDisplaySnippet({super.key, required this.display});

  @override
  Widget build(BuildContext context) {
    if (display.conditions.isEmpty) {
      return const SizedBox.shrink();
    }

    var cond = display.conditions[0];
    List<String> values = [];

    values.add(cond.prefixText ?? '');
    values.add(cond.$value ?? '{{#}}');
    values.add(cond.suffixText ?? '');

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

    return SizedBox(
      width: cond.width,
      height: cond.height,
      child: Container(
        decoration: decoration,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Tooltip(
                  message: cond.tooltip ?? display.name, child: displayText),
            ],
          ),
        ),
      ),
    );
  }
}
