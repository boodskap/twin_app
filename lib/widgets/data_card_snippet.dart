import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/data_grid_snippet.dart';
import 'package:twin_app/widgets/field_analytics_page.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/default_deviceview.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

class DataCardSnippet extends StatefulWidget {
  final bool autoRefresh;
  final int autoRefreshInterval;
  final String searchHint;
  final List<String> deviceModelIds;
  final List<String> assetModelIds;
  final List<String> assetIds;
  final List<String> premiseIds;
  final List<String> facilityIds;
  final List<String> floorIds;
  final VoidCallback? onGridViewSelected;
  final OnAnalyticsTapped? onAnalyticsTapped;
  final OnAssetTapped? onAssetTapped;
  final OnDeviceTapped? onDeviceTapped;
  final OnDeviceModelTapped? onDeviceModelTapped;
  final OnPremiseTapped? onPremiseTapped;
  final OnFacilityTapped? onFacilityTapped;
  final OnFloorTapped? onFloorTapped;

  const DataCardSnippet({
    super.key,
    this.autoRefresh = true,
    this.autoRefreshInterval = 60,
    this.searchHint = 'Search',
    this.deviceModelIds = const [],
    this.assetModelIds = const [],
    this.assetIds = const [],
    this.premiseIds = const [],
    this.facilityIds = const [],
    this.floorIds = const [],
    this.onGridViewSelected,
    this.onAnalyticsTapped,
    this.onAssetTapped,
    this.onDeviceTapped,
    this.onDeviceModelTapped,
    this.onPremiseTapped,
    this.onFacilityTapped,
    this.onFloorTapped,
  });

  @override
  State<DataCardSnippet> createState() => _DataCardSnippetState();
}

class _DataCardSnippetState extends BaseState<DataCardSnippet> {
  final List<String> _deviceIds = [];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        divider(),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BusyIndicator(),
              if (!smallScreen && null != widget.onGridViewSelected)
                divider(horizontal: true),
              if (!smallScreen && null != widget.onGridViewSelected)
                Tooltip(
                  message: 'Grid View',
                  child: IconButton(
                      onPressed: () {
                        widget.onGridViewSelected!();
                      },
                      icon: Icon(
                        Icons.grid_on,
                      )),
                ),
              divider(horizontal: true),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: SizedBox(
                    width: 250,
                    height: 40,
                    child: SearchBar(
                      hintText: 'Search',
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                        _load();
                      },
                    )),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              border: Border.all(color: theme.getPrimaryColor())),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: _deviceIds.map((e) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        height: MediaQuery.of(context).size.height - 150,
                        child: DefaultDeviceView(
                          deviceId: e,
                          authToken: TwinnedSession.instance.authToken,
                          twinned: TwinnedSession.instance.twin,
                          titleTextStyle: theme.getStyle().copyWith(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          infoTextStyle: theme.getStyle().copyWith(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          widgetTextStyle: theme.getStyle().copyWith(
                              fontSize: 12, fontWeight: FontWeight.bold),
                          onDeviceAnalyticsTapped: (f, m, d) async {
                            showAnalytics(
                                asPopup: true,
                                fields: [f],
                                deviceModel: m,
                                dd: d);
                          },
                          onAnalyticsTapped: widget.onAnalyticsTapped,
                          onDeviceDoubleTapped: (d) async {},
                          onAssetTapped: widget.onAssetTapped,
                          onDeviceModelTapped: widget.onDeviceModelTapped,
                          onDeviceTapped: widget.onDeviceTapped,
                          onFacilityTapped: widget.onFacilityTapped,
                          onFloorTapped: widget.onFloorTapped,
                          onPremiseTapped: widget.onPremiseTapped,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void showAnalytics(
      {required bool asPopup,
      required List<String> fields,
      required tapi.DeviceModel deviceModel,
      required tapi.DeviceData dd}) {
    if (asPopup) {
      alertDialog(
          title: '',
          width: MediaQuery.of(context).size.width - 100,
          body: FieldAnalyticsPage(
            fields: fields,
            deviceModel: deviceModel,
            deviceData: dd,
            asPopup: asPopup,
            canDeleteRecord: false,
          ));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FieldAnalyticsPage(
                    fields: fields,
                    deviceModel: deviceModel,
                    deviceData: dd,
                    canDeleteRecord: false,
                  )));
    }
  }

  Future _load() async {
    if (loading) return;

    loading = true;
    _deviceIds.clear();

    await execute(() async {
      List<Object> must = [
        if (widget.deviceModelIds.isNotEmpty)
          {
            "terms": {"modelId": widget.deviceModelIds}
          },
        if (widget.assetModelIds.isNotEmpty)
          {
            "terms": {"assetModelId": widget.assetModelIds}
          },
        if (widget.assetIds.isNotEmpty)
          {
            "terms": {"assetId": widget.assetIds}
          },
        if (widget.premiseIds.isNotEmpty)
          {
            "terms": {"premiseId": widget.premiseIds}
          },
        if (widget.facilityIds.isNotEmpty)
          {
            "terms": {"facilityId": widget.facilityIds}
          },
        if (widget.floorIds.isNotEmpty)
          {
            "terms": {"floorId": widget.floorIds}
          },
        if (_searchQuery.trim().isNotEmpty)
          {
            "query_string": {
              "query": '*$_searchQuery*',
              "fields": [
                "name",
                "asset",
                "deviceName",
                "modelName",
                "premise",
                "facility",
                "floor",
                "client",
                "description",
                "tags"
              ]
            }
          }
      ];

      var res = await TwinnedSession.instance.twin.queryEqlDeviceData(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.EqlSearch(source: [], mustConditions: must, size: 5));
      if (validateResponse(res)) {
        List<tapi.DeviceData> list = res.body!.values!;
        for (tapi.DeviceData dd in list) {
          _deviceIds.add(dd.deviceId);
        }
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}
