import 'package:flutter/material.dart';
import 'package:twin_app/widgets/evaluated_alarm_snippet.dart';
import 'package:twin_app/widgets/evaluated_display_snippet.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;

class DeviceComponentView extends StatefulWidget {
  final twin.Twinned twinned;
  final String authToken;
  final twin.DeviceData deviceData;
  final Axis orientation;
  final double spacing;
  const DeviceComponentView(
      {super.key,
      required this.twinned,
      required this.authToken,
      required this.deviceData,
      this.orientation = Axis.horizontal,
      this.spacing = 8});

  @override
  State<DeviceComponentView> createState() => _DeviceComponentViewState();
}

class _DeviceComponentViewState extends State<DeviceComponentView> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: widget.orientation,
      spacing: widget.spacing,
      children: [
        EvaluatedAlarmsSnippet(
          twinned: widget.twinned,
          authToken: widget.authToken,
          deviceData: widget.deviceData,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, right: 3),
          child: EvaluatedDisplaysSnippet(
            twin: widget.twinned,
            authToken: widget.authToken,
            deviceData: widget.deviceData,
            orientation: widget.orientation,
          ),
        ),
      ],
    );
  }
}
