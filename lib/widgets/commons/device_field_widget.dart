import 'dart:async';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/device_component_view.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/widgets/default_deviceview.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;
import 'package:twin_commons/core/sensor_widget.dart' as sensors;

class DeviceFieldWidget extends StatefulWidget {
  final tapi.DeviceData deviceData;
  final Map<String, tapi.DeviceModel> models;
  final OnDeviceAnalyticsTapped onDeviceAnalyticsTapped;
  final OnDeviceAnalyticsTapped onDeviceAnalyticsDoubleTapped;

  const DeviceFieldWidget({
    super.key,
    required this.deviceData,
    required this.models,
    required this.onDeviceAnalyticsTapped,
    required this.onDeviceAnalyticsDoubleTapped,
  });

  @override
  State<DeviceFieldWidget> createState() => _DeviceFieldWidgetState();
}

class _DeviceFieldWidgetState extends BaseState<DeviceFieldWidget> {
  @override
  Widget build(BuildContext context) {
    tapi.DeviceData dd = widget.deviceData;
    var dT = DateTime.fromMillisecondsSinceEpoch(dd.updatedStamp);
    List<Widget> children = [];
    Map<String, dynamic> dynData = dd.data as Map<String, dynamic>;
    tapi.DeviceModel deviceModel = widget.models[dd.modelId]!;
    List<String> fields = TwinUtils.getSortedFields(deviceModel);
    List<String> timeSeriesFields = TwinUtils.getTimeSeriesFields(deviceModel);

    for (String field in fields) {
      sensors.SensorWidgetType type =
          TwinUtils.getSensorWidgetType(field, widget.models[dd.modelId]!);
      bool hasSeries = timeSeriesFields.contains(field);
      if (type == sensors.SensorWidgetType.none) {
        String iconId = TwinUtils.getParameterIcon(field, deviceModel);
        _padding(children);
        children.add(Tooltip(
          message: hasSeries ? "View TimeSeries" : "",
          child: InkWell(
            onTap: !hasSeries
                ? null
                : () {
                    widget.onDeviceAnalyticsTapped(field, deviceModel, dd);
                  },
            onDoubleTap: !hasSeries
                ? null
                : () {
                    widget.onDeviceAnalyticsDoubleTapped(
                        field, deviceModel, dd);
                  },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  TwinUtils.getParameterLabel(field, deviceModel),
                  style: theme.getStyle().copyWith(
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold),
                ),
                divider(),
                if (iconId.isEmpty) SizedBox(width: 28, height: 28),
                if (iconId.isNotEmpty)
                  SizedBox(
                      width: 28,
                      height: 28,
                      child: TwinImageHelper.getCachedDomainImage(iconId)),
                divider(),
                Text(
                  '${dynData[field] ?? '-'} ${TwinUtils.getParameterUnit(field, deviceModel)}',
                  style: theme.getStyle().copyWith(
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ));
        children.add(divider(horizontal: true, width: 24));
      } else {
        tapi.Parameter? parameter =
            TwinUtils.getParameter(field, widget.models[dd.modelId]!);
        children.add(Tooltip(
          message: hasSeries ? "View TimeSeries" : "",
          child: InkWell(
            onTap: !hasSeries
                ? null
                : () {
                    widget.onDeviceAnalyticsTapped(field, deviceModel, dd);
                  },
            onDoubleTap: !hasSeries
                ? null
                : () {
                    widget.onDeviceAnalyticsDoubleTapped(
                        field, deviceModel, dd);
                  },
            child: SizedBox(
              width: 100,
              height: 80,
              child: sensors.SensorWidget(
                parameter: parameter!,
                deviceData: dd,
                deviceModel: deviceModel,
                tiny: true,
              ),
            ),
          ),
        ));
      }
    }

    return Wrap(
      //mainAxisSize: MainAxisSize.min,
      spacing: 5.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...children,
        if (dd.alarms.isNotEmpty ||
            dd.displays.isNotEmpty ||
            dd.controls!.isNotEmpty)
          DeviceComponentView(
              twinned: TwinnedSession.instance.twin,
              authToken: TwinnedSession.instance.authToken,
              deviceData: dd),
      ],
    );
  }

  void _padding(List<Widget> children) {
    if (children.isNotEmpty) {
      if (children.last is! SizedBox) {
        children.add(divider(horizontal: true, width: 24));
      }
    }
  }

  @override
  void setup() {}
}
