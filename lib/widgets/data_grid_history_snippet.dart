import 'dart:async';
import 'package:flutter/Material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/device_component_view.dart';
import 'package:twin_app/widgets/field_analytics_page.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:data_table_2/data_table_2.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:uuid/uuid.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/default_deviceview.dart';
import 'package:twin_commons/core/sensor_widget.dart' as sensors;
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:twin_commons/level/widgets/cylinder_tank.dart';

enum FilterType { none, data, field, group, model }

class DataGridHistorySnippet extends StatefulWidget {
  final bool autoRefresh;
  final int autoRefreshInterval;
  final String searchHint;
  final List<String> deviceIds;
  final List<String> assetIds;
  final VoidCallback? onGridViewSelected;
  final VoidCallback? onCardViewSelected;
  final OnAnalyticsTapped? onAnalyticsTapped;
  final OnAssetModelTapped? onAssetModelTapped;
  final OnDeviceModelTapped? onDeviceModelTapped;
  final OnClientTapped? onClientTapped;
  final OnPremiseTapped? onPremiseTapped;
  final OnFacilityTapped? onFacilityTapped;
  final OnFloorTapped? onFloorTapped;

  const DataGridHistorySnippet({
    super.key,
    this.autoRefresh = true,
    this.autoRefreshInterval = 60,
    this.searchHint = 'Search',
    this.deviceIds = const [],
    this.assetIds = const [],
    this.onGridViewSelected,
    this.onCardViewSelected,
    this.onAnalyticsTapped,
    this.onAssetModelTapped,
    this.onDeviceModelTapped,
    this.onClientTapped,
    this.onPremiseTapped,
    this.onFacilityTapped,
    this.onFloorTapped,
  });

  @override
  State<DataGridHistorySnippet> createState() => DataGridHistorySnippetState();
}

class DataGridHistorySnippetState extends BaseState<DataGridHistorySnippet> {
  final List<DeviceData> _data = [];
  final Map<String, DeviceModel> _models = {};
  final Map<String, Device> _devices = {};
  final List<String> _modelIds = [];
  Timer? timer;
  String _searchQuery = '';
  final TextEditingController _controller = TextEditingController();
  bool _cardView = true;

  @override
  void initState() {
    super.initState();
    _cardView = smallScreen;
    if (widget.autoRefresh) {
      timer = Timer.periodic(
          Duration(seconds: widget.autoRefreshInterval), (Timer t) => _load());
    }
  }

  @override
  void setup() async {
    _load();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void showAnalytics(
      {required bool asPopup,
      required List<String> fields,
      required DeviceModel deviceModel,
      required DeviceData dd}) {
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

  void _padding(List<Widget> children) {
    if (children.isNotEmpty) {
      if (children.last is! SizedBox) {
        children.add(divider(horizontal: true, width: 24));
      }
    }
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const BusyIndicator(),
        divider(horizontal: true),
        if (null != widget.onCardViewSelected) divider(horizontal: true),
        if (null != widget.onCardViewSelected)
          Tooltip(
            message: 'Card View',
            child: IconButton(
                onPressed: () {
                  setState(() {
                    _cardView = true;
                  });
                  widget.onCardViewSelected!();
                },
                icon: Icon(Icons.grid_view,
                    color: _cardView ? theme.getPrimaryColor() : null)),
          ),
        if (null != widget.onCardViewSelected) divider(horizontal: true),
        if (null != widget.onGridViewSelected)
          Tooltip(
            message: 'Grid View',
            child: IconButton(
                onPressed: () {
                  setState(() {
                    _cardView = false;
                  });
                  widget.onGridViewSelected!();
                },
                icon: Icon(Icons.grid_on,
                    color: !_cardView ? theme.getPrimaryColor() : null)),
          ),
        IconButton(
            onPressed: () {
              _load();
            },
            icon: const Icon(Icons.refresh)),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: SizedBox(
              width: 250,
              height: 40,
              child: SearchBar(
                hintText: widget.searchHint,
                controller: _controller,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                  _load();
                },
              )),
        ),
      ],
    );
  }

  Widget _buildSmallTable() {
    List<DataColumn2> columns = [];
    List<DataRow2> rows = [];

    columns.addAll([
      DataColumn2(
        size: ColumnSize.L,
        fixedWidth: MediaQuery.of(context).size.width / 4,
        tooltip: 'Tank Details',
        label: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.locationPin,
              color: Colors.black38,
            ),
          ],
        ),
      ),
      const DataColumn2(
        size: ColumnSize.L,
        tooltip: 'Tank Level',
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.water,
              color: Colors.black38,
            ),
          ],
        ),
      ),
      const DataColumn2(
        size: ColumnSize.L,
        tooltip: 'Tank Volume',
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.chartPie,
              color: Colors.black38,
            ),
          ],
        ),
      ),
      const DataColumn2(
        size: ColumnSize.L,
        tooltip: 'Tank Temperature',
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.temperatureFull,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    ]);

    if (_models.isNotEmpty) {
      for (var dd in _data) {
        var dT = DateTime.fromMillisecondsSinceEpoch(dd.updatedStamp);
        List<Widget> children = [];
        Map<String, dynamic> dynData = dd.data as Map<String, dynamic>;
        DeviceModel deviceModel = _models[dd.modelId]!;
        List<String> timeSeriesFields =
            TwinUtils.getTimeSeriesFields(deviceModel);
        List<DataCell> cells = [];

        cells.add(DataCell(Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (null != dd.asset && dd.asset!.isNotEmpty)
              Text(
                maxLines: 2,
                dd.asset ?? '-',
                style: theme
                    .getStyle()
                    .copyWith(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            Text(
              timeago.format(dT),
              style: theme
                  .getStyle()
                  .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            divider(),
            if (null != dd.premise && dd.premise!.isNotEmpty)
              Text(
                dd.premise ?? '-',
                style: theme
                    .getStyle()
                    .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            if (null != dd.modelName && dd.modelName!.isNotEmpty)
              Text(
                dd.modelName ?? '-',
                style: theme
                    .getStyle()
                    .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            if (null != dd.deviceName && dd.deviceName!.isNotEmpty)
              Text(
                dd.deviceName ?? '-',
                style: theme
                    .getStyle()
                    .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
              ),
          ],
        )));
        if (timeSeriesFields.isNotEmpty) {
          cells.add(DataCell(InkWell(
            onTap: () {
              showAnalytics(
                  asPopup: true,
                  fields: timeSeriesFields,
                  deviceModel: deviceModel,
                  dd: dd);
            },
            onDoubleTap: () {
              showAnalytics(
                  asPopup: false,
                  fields: timeSeriesFields,
                  deviceModel: deviceModel,
                  dd: dd);
            },
            child: CylinderTank(
              label: '',
              width: 80,
              height: 90,
              liquidLevel: (dynData['level'] ?? 0 as num).toDouble(),
            ),
          )));
        }
        cells.add(DataCell(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.vertical,
              children: [
                Text(
                  '${dynData['volume'] ?? '-'} gals',
                  style: theme
                      .getStyle()
                      .copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                divider(),
                Text(
                  'Total ${dynData['totalVolume'] ?? '-'} gals',
                  style: theme
                      .getStyle()
                      .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        )));
        cells.add(DataCell(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${dynData['temperature_f'] ?? '-'} ${String.fromCharCode(0xB0)}F',
              style: theme
                  .getStyle()
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        )));

        rows.add(DataRow2(cells: cells));
      }
    }

    return Column(
      children: [
        _buildControls(),
        Flexible(
          child: DataTable2(
              key: Key(const Uuid().v4()),
              empty: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (loading)
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: const CircularProgressIndicator(
                        color: Colors.red,
                      ),
                    ),
                  if (!loading)
                    Text(
                      'No data',
                      style: theme.getStyle(),
                    ),
                ],
              ),
              dataRowHeight: 120,
              columnSpacing: 12,
              horizontalMargin: 12,
              columns: columns,
              rows: rows),
        ),
      ],
    );
  }

  Widget _buildTable() {
    if (smallScreen) return _buildSmallTable();

    List<DataColumn2> columns = [];
    List<DataRow2> rows = [];

    columns.addAll([
      DataColumn2(
        fixedWidth: 200,
        label: Wrap(
          spacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.castle),
            Text(
              'Asset',
              style: theme
                  .getStyle()
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      DataColumn2(
        fixedWidth: 200,
        label: Wrap(
          spacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.access_time),
            Text(
              'Last Reported',
              style: theme
                  .getStyle()
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      DataColumn2(
        fixedWidth: 200,
        label: Wrap(
          spacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.location_pin),
            Text(
              'Location',
              style: theme
                  .getStyle()
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      DataColumn2(
        //fixedWidth: 400,
        label: Wrap(
          spacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.menu),
            Text(
              'Sensor Data',
              style: theme
                  .getStyle()
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      DataColumn2(
        fixedWidth: 300,
        label: Wrap(
          spacing: 4.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.add_alert),
            Text(
              'Alarms',
              style: theme
                  .getStyle()
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    ]);

    if (_models.isNotEmpty) {
      for (var dd in _data) {
        var dT = DateTime.fromMillisecondsSinceEpoch(dd.updatedStamp);
        List<Widget> children = [];
        Map<String, dynamic> dynData = dd.data as Map<String, dynamic>;
        DeviceModel deviceModel = _models[dd.modelId]!;
        List<String> fields = TwinUtils.getSortedFields(deviceModel);
        List<String> timeSeriesFields =
            TwinUtils.getTimeSeriesFields(deviceModel);

        for (String field in fields) {
          sensors.SensorWidgetType type =
              TwinUtils.getSensorWidgetType(field, _models[dd.modelId]!);
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
                        showAnalytics(
                            asPopup: true,
                            fields: [field],
                            deviceModel: deviceModel,
                            dd: dd);
                      },
                onDoubleTap: !hasSeries
                    ? null
                    : () {
                        showAnalytics(
                            asPopup: false,
                            fields: [field],
                            deviceModel: deviceModel,
                            dd: dd);
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
                    if (iconId.isNotEmpty) divider(),
                    if (iconId.isNotEmpty)
                      SizedBox(
                          width: 28,
                          height: 28,
                          child: TwinImageHelper.getDomainImage(iconId)),
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
            Parameter? parameter =
                TwinUtils.getParameter(field, _models[dd.modelId]!);
            children.add(Tooltip(
              message: hasSeries ? "View TimeSeries" : "",
              child: InkWell(
                onTap: !hasSeries
                    ? null
                    : () {
                        showAnalytics(
                            asPopup: true,
                            fields: [field],
                            deviceModel: deviceModel,
                            dd: dd);
                      },
                onDoubleTap: !hasSeries
                    ? null
                    : () {
                        showAnalytics(
                            asPopup: false,
                            fields: [field],
                            deviceModel: deviceModel,
                            dd: dd);
                      },
                child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        minWidth: 80,
                        minHeight: 160,
                        maxWidth: 80,
                        maxHeight: 160),
                    child: sensors.SensorWidget(
                      parameter: parameter!,
                      deviceData: dd,
                      deviceModel: deviceModel,
                      tiny: true,
                    )),
              ),
            ));
          }
        }

        rows.add(DataRow2(cells: [
          DataCell(Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Tooltip(
                      message: 'Asset',
                      child: Text(
                        dd.asset ?? '-',
                        style: theme.getStyle().copyWith(
                            fontSize: 16,
                            color: theme.getPrimaryColor(),
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (timeSeriesFields.isNotEmpty)
                      Tooltip(
                        message: "View TimeSeries",
                        child: InkWell(
                            onTap: () {
                              showAnalytics(
                                  asPopup: true,
                                  fields: timeSeriesFields,
                                  deviceModel: deviceModel,
                                  dd: dd);
                            },
                            onDoubleTap: () {
                              showAnalytics(
                                  asPopup: false,
                                  fields: timeSeriesFields,
                                  deviceModel: deviceModel,
                                  dd: dd);
                            },
                            child: const Icon(Icons.bar_chart)),
                      )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 4.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (dd.hardwareDeviceId != dd.deviceName)
                      Tooltip(
                        message: 'Device Name',
                        child: Text(
                          dd.deviceName ?? '-',
                          style: theme.getStyle().copyWith(
                              color: theme.getPrimaryColor(),
                              overflow: TextOverflow.ellipsis,
                              fontSize: 12),
                        ),
                      ),
                    Tooltip(
                      message: 'Device Model',
                      child: InkWell(
                        onTap: (null == widget.onDeviceModelTapped)
                            ? null
                            : () {
                                widget.onDeviceModelTapped!(deviceModel.id, dd);
                              },
                        child: Text(
                          dd.modelName ?? '-',
                          style: theme.getStyle().copyWith(
                              color: theme.getPrimaryColor(),
                              overflow: TextOverflow.ellipsis,
                              fontSize: 12),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Asset Model',
                      child: InkWell(
                        onTap: (null == widget.onAssetModelTapped)
                            ? null
                            : () {
                                widget.onAssetModelTapped!(
                                    dd.assetModelId!, dd);
                              },
                        child: Icon(
                          Icons.memory_rounded,
                          color: theme.getPrimaryColor(),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Device Serial#',
                      child: Icon(
                        Icons.qr_code,
                        color: theme.getPrimaryColor(),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
          DataCell(Wrap(
            direction: Axis.vertical,
            children: [
              Text(
                timeago.format(dT, locale: 'en'),
                style: theme.getStyle().copyWith(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 16),
              ),
              Text(
                dT.toString(),
              ),
            ],
          )),
          DataCell(Wrap(
            direction: Axis.vertical,
            children: [
              Tooltip(
                message: 'Client / Organization',
                child: InkWell(
                  onTap: (null == widget.onClientTapped ||
                          (dd.clientIds?.isEmpty ?? true))
                      ? null
                      : () {
                          widget.onClientTapped!(dd.clientIds!.first, dd);
                        },
                  child: Text(
                    dd.$client ?? '',
                    style: theme.getStyle().copyWith(
                        color: theme.getPrimaryColor(),
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Tooltip(
                message: 'Premise',
                child: InkWell(
                  onTap: (null == widget.onPremiseTapped ||
                          (dd.premiseId?.isEmpty ?? true))
                      ? null
                      : () {
                          widget.onPremiseTapped!(dd.premiseId!, dd);
                        },
                  child: Text(
                    dd.premise ?? '',
                    style: theme.getStyle().copyWith(
                        color: theme.getPrimaryColor(),
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Tooltip(
                message: 'Facility',
                child: InkWell(
                  onTap: (null == widget.onFacilityTapped ||
                          (dd.facilityId?.isEmpty ?? true))
                      ? null
                      : () {
                          widget.onFacilityTapped!(dd.facilityId!, dd);
                        },
                  child: Text(
                    dd.facility ?? '',
                    style: theme.getStyle().copyWith(
                          color: theme.getPrimaryColor(),
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ),
              ),
              Tooltip(
                message: 'Floor',
                child: InkWell(
                  onTap: (null == widget.onFloorTapped ||
                          (dd.floorId?.isEmpty ?? true))
                      ? null
                      : () {
                          widget.onFloorTapped!(dd.floorId!, dd);
                        },
                  child: Text(
                    dd.floor ?? '',
                    style: theme.getStyle().copyWith(
                          color: theme.getPrimaryColor(),
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ),
              ),
            ],
          )),
          DataCell(Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: children,
              ),
            ),
          )),
          if (dd.alarms.isNotEmpty ||
              dd.displays.isNotEmpty ||
              dd.controls!.isNotEmpty)
            DataCell(
              DeviceComponentView(
                  twinned: TwinnedSession.instance.twin,
                  authToken: TwinnedSession.instance.authToken,
                  deviceData: dd),
            ),
          if (dd.alarms.isEmpty && dd.displays.isEmpty && dd.controls!.isEmpty)
            const DataCell(
              Text(''),
            ),
        ]));
      }
    }

    return Column(
      children: [
        _buildControls(),
        Flexible(
          child: DataTable2(
              key: Key(const Uuid().v4()),
              dataRowHeight: 100,
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              columns: columns,
              empty: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'No data',
                    style: theme.getStyle(),
                  ),
                ],
              ),
              rows: rows),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTable();
  }

  Future _load({String search = '*', int page = 0, int size = 1000}) async {
    if (loading) return;
    loading = true;

    if (search.trim().isEmpty) {
      search = '*';
    }

    await execute(() async {
      _data.clear();
      _models.clear();
      _modelIds.clear();

      late final chopper.Response<DeviceDataArrayRes> dRes;

      final List<Object> mustConditions = [
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
              "client"
                  "description",
              "tags"
            ]
          }
        }
      ];

      mustConditions.addAll([
        if (widget.deviceIds.isNotEmpty)
          {
            "terms": {'deviceId': widget.deviceIds}
          },
        if (widget.assetIds.isNotEmpty)
          {
            "terms": {"assetId": widget.assetIds}
          },
      ]);

      dRes = await TwinnedSession.instance.twin.queryEqlDeviceHistoryData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(
              source: [],
              mustConditions: mustConditions,
              page: 0,
              size: 100,
              sort: {'updatedStamp': 'desc'}));

      if (validateResponse(dRes)) {
        _data.addAll(dRes.body!.values!);

        for (DeviceData dd in _data) {
          if (_modelIds.contains(dd.modelId)) continue;
          _modelIds.add(dd.modelId);
        }

        refresh();

        var mRes = await TwinnedSession.instance.twin.getDeviceModels(
            apikey: TwinnedSession.instance.authToken,
            body: GetReq(ids: _modelIds));

        if (validateResponse(mRes)) {
          for (var deviceModel in mRes.body!.values!) {
            _models[deviceModel.id] = deviceModel;
          }
        }
      }
    });

    loading = false;
    // _controller.text = _searchQuery;
    refresh();
  }
}
