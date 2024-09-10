import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/widgets/default_deviceview.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;

class AssetActionWidget extends StatefulWidget {
  final Map<String, tapi.DeviceModel> models;
  final tapi.DeviceData deviceData;

  final OnDeviceTapped? onDeviceTapped;
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
    required this.onDeviceModelTapped,
    required this.onAssetModelTapped,
    required this.onTimeSeriesTapped,
    required this.onTimeSeriesDoubleTapped,
    this.onDeviceTapped,
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
        if (null != widget.onDeviceTapped)
          InkWell(
            onTap: () {
              widget.onDeviceTapped!(dd.deviceId, dd);
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
            showDeviceDataJson(context, widget.deviceData);
          },
          child: Tooltip(
              message: 'View Device Data', child: Icon(Icons.remove_red_eye)),
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

  void showDeviceDataJson(BuildContext context, tapi.DeviceData jsonData) {
    String prettyJson = const JsonEncoder.withIndent('  ').convert(jsonData);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titleTextStyle: theme
              .getStyle()
              .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          // title: const Text('Device Data'),
          title:ModelHeaderSection(copyText: prettyJson, title: 'Device Data'),
          content: SingleChildScrollView(
            child: Text(
              prettyJson,
              style: theme.getStyle(),
            ),
          ),
          actions: [
            SecondaryButton(
              labelKey: 'Close',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


class ModelHeaderSection extends StatefulWidget {
  final String copyText;
  final String title;
  const ModelHeaderSection({super.key, required this.copyText, required this.title});

  @override
  State<ModelHeaderSection> createState() => _ModelHeaderSectionState();
}

class _ModelHeaderSectionState extends State<ModelHeaderSection> {
  bool _showCopiedText = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         Text(widget.title),
        Column(
          children: [
            Tooltip(
              message: 'Copy',
              child: IconButton(
                icon: Icon(Icons.copy, color: Colors.black),
                onPressed: () {
                  copyToClipboard(widget.copyText);
                },
              ),
            ),
             if (_showCopiedText)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              'Copied',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
          ),
          ],
        ),
       
      ],
    );
  }

  copyToClipboard(jsonData) {
    Clipboard.setData(ClipboardData(text: jsonData));
    setState(() {
      _showCopiedText = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showCopiedText = false;
      });
    });
  }
}