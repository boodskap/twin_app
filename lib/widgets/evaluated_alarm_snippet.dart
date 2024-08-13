import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:twin_commons/core/twin_image_helper.dart';

class EvaluatedAlarmsSnippet extends StatefulWidget {
  final twin.Twinned twinned;
  final String authToken;
  final twin.DeviceData deviceData;
  final Axis orientation;
  final double spacing;
  final double alarmHeight;
  final double alarmWidth;

  const EvaluatedAlarmsSnippet(
      {super.key,
      required this.twinned,
      required this.authToken,
      required this.deviceData,
      this.orientation = Axis.horizontal,
      this.alarmHeight = 40,
      this.alarmWidth = 40,
      this.spacing = 8});

  @override
  State<EvaluatedAlarmsSnippet> createState() => _EvaluatedAlarmsSnippetState();
}

class _EvaluatedAlarmsSnippetState extends BaseState<EvaluatedAlarmsSnippet> {
  final List<Widget> icons = [];

  @override
  void initState() {
    for (int i = 0; i < widget.deviceData.alarms.length; i++) {
      icons.add(const Icon(Icons.hourglass_empty));
    }
    super.initState();
  }

  @override
  void setup() async {
    icons.clear();
    for (var alarm in widget.deviceData.alarms) {
      if (alarm.state >= 0 && alarm.stateIcon.isNotEmpty) {
        var res = await widget.twinned
            .getAlarm(apikey: widget.authToken, alarmId: alarm.alarmId);

        if (validateResponse(res, shouldAlert: false)) {
          var parent = res.body!.entity!;
          var icon = TwinImageHelper.getDomainImage(
            alarm.stateIcon,
            fit: BoxFit.contain,
          );

          icons.add(Tooltip(
            message: parent.conditions[alarm.state].tooltip ?? parent.name,
            child: SizedBox(
                width: widget.alarmWidth,
                height: widget.alarmHeight,
                child: icon),
          ));
        }
      }
    }
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: widget.orientation,
      spacing: widget.spacing,
      children: icons,
    );
  }
}
