import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/widgets/default_deviceview.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;

class AssetActionWidget extends StatefulWidget {
  final Map<String, tapi.DeviceModel> models;
  final tapi.DeviceData deviceData;

  final OnDeviceTapped onDeviceTapped;
  final OnDeviceModelTapped onDeviceModelTapped;
  final OnAssetModelTapped onAssetModelTapped;
  final OnAnalyticsTapped onTimeSeriesTapped;
  final OnAnalyticsTapped onTimeSeriesDoubleTapped;
  final Axis direction;

  const AssetActionWidget({
    super.key,
    this.direction = Axis.vertical,
    required this.models,
    required this.deviceData,
    required this.onDeviceTapped,
    required this.onDeviceModelTapped,
    required this.onAssetModelTapped,
    required this.onTimeSeriesTapped,
    required this.onTimeSeriesDoubleTapped,
  });

  @override
  State<AssetActionWidget> createState() => _AssetActionWidgetState();
}

class _AssetActionWidgetState extends State<AssetActionWidget> {
  @override
  Widget build(BuildContext context) {
    final tapi.DeviceData dd = widget.deviceData;

    return Wrap(
      direction: widget.direction,
      alignment: WrapAlignment.spaceEvenly,
      runAlignment: WrapAlignment.spaceEvenly,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: smallScreen ? 2 : 8,
      children: [
        InkWell(
          onTap: () {
            widget.onDeviceTapped(dd.deviceId, dd);
          },
          child: Tooltip(
              message: '${dd.hardwareDeviceId} History Data',
              child: Icon(Icons.history)),
        ),
        SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () {
            widget.onDeviceModelTapped(dd.modelId, dd);
          },
          child: Tooltip(
              message: 'Filter ${dd.modelName} assets',
              child: Icon(Icons.memory_rounded)),
        ),
        if (dd.assetModelId?.isNotEmpty ?? false)
          SizedBox(
            height: 8,
          ),
        if (dd.assetModelId?.isNotEmpty ?? false)
          InkWell(
            onTap: () {
              widget.onAssetModelTapped(dd.assetModelId!, dd);
            },
            child: Tooltip(
                message: 'Filter ${dd.assetModel} assets',
                child: Icon(Icons.departure_board_rounded)),
          ),
        if (dd.series?.isNotEmpty ?? false)
          SizedBox(
            height: 8,
          ),
        if (dd.series?.isNotEmpty ?? false)
          InkWell(
            onTap: () {
              widget.onTimeSeriesTapped(widget.models[dd.modelId]!, dd);
            },
            onDoubleTap: () {
              widget.onTimeSeriesDoubleTapped(widget.models[dd.modelId]!, dd);
            },
            child: Tooltip(
                message: 'View time series graphs (double tap to fullscreen)',
                child: Icon(Icons.bar_chart)),
          ),
      ],
    );
  }
}
