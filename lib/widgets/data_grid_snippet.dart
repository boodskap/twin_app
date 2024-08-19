import 'dart:async';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/alarm_search.dart';
import 'package:twin_app/widgets/commons/asset_group_search.dart';
import 'package:twin_app/widgets/commons/client_search.dart';
import 'package:twin_app/widgets/commons/data_search.dart';
import 'package:twin_app/widgets/commons/event_search.dart';
import 'package:twin_app/widgets/commons/facility_search.dart';
import 'package:twin_app/widgets/commons/floor_search.dart';
import 'package:twin_app/widgets/commons/premise_search.dart';
import 'package:twin_app/widgets/device_component_view.dart';
import 'package:twin_app/widgets/field_analytics_page.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:uuid/uuid.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/default_deviceview.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:twin_commons/level/widgets/cylinder_tank.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;
import 'package:timeago/timeago.dart' as timeago;
import 'package:chopper/chopper.dart' as chopper;
import 'package:twin_commons/core/sensor_widget.dart' as sensors;

enum FilterType { none, data, field, group, model }

class DataGridSnippet extends StatefulWidget {
  final bool autoRefresh;
  final int autoRefreshInterval;
  final String searchHint;
  final List<String> deviceModelIds;
  final List<String> assetModelIds;
  final List<String> assetIds;
  final List<String> premiseIds;
  final List<String> facilityIds;
  final List<String> floorIds;
  final List<String> clientIds;
  final VoidCallback? onGridViewSelected;
  final VoidCallback? onCardViewSelected;
  final OnAnalyticsTapped? onAnalyticsTapped;
  final OnAssetModelTapped? onAssetModelTapped;
  final OnAssetTapped? onAssetTapped;
  final OnDeviceTapped? onDeviceTapped;
  final OnDeviceModelTapped? onDeviceModelTapped;
  final OnClientTapped? onClientTapped;
  final OnPremiseTapped? onPremiseTapped;
  final OnFacilityTapped? onFacilityTapped;
  final OnFloorTapped? onFloorTapped;
  final bool enableClintFiler;
  final bool enablePremiseFiler;
  final bool enableFacilityFiler;
  final bool enableFloorFiler;
  final bool enableDataFiler;
  final bool enableGroupFiler;
  final bool enableAlarmFiler;
  final bool enableEventFiler;

  const DataGridSnippet({
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
    this.clientIds = const [],
    this.onGridViewSelected,
    this.onCardViewSelected,
    this.onAnalyticsTapped,
    this.onAssetModelTapped,
    this.onAssetTapped,
    this.onDeviceTapped,
    this.onDeviceModelTapped,
    this.onClientTapped,
    this.onPremiseTapped,
    this.onFacilityTapped,
    this.onFloorTapped,
    this.enableClintFiler = true,
    this.enablePremiseFiler = true,
    this.enableFacilityFiler = true,
    this.enableFloorFiler = true,
    this.enableDataFiler = true,
    this.enableGroupFiler = true,
    this.enableAlarmFiler = true,
    this.enableEventFiler = true,
  });

  @override
  State<DataGridSnippet> createState() => DataGridSnippetState();
}

class DataGridSnippetState extends BaseState<DataGridSnippet> {
  final List<tapi.DeviceData> _data = [];
  final Map<String, tapi.DeviceModel> _models = {};
  final List<String> _modelIds = [];
  Timer? timer;
  String _searchQuery = '';
  final TextEditingController _controller = TextEditingController();
  bool _cardView = true;
  tapi.Client? _client;
  tapi.Premise? _premise;
  tapi.Facility? _facility;
  tapi.Floor? _floor;
  tapi.DataFilter? _dataFilter;
  tapi.FieldFilter? _fieldFilter;
  tapi.AssetGroup? _assetGroup;
  tapi.Alarm? _alarm;
  tapi.Event? _event;

  @override
  void initState() {
    super.initState();
    _cardView = smallScreen;
  }

  @override
  void setup() {
    _load();
    if (widget.autoRefresh) {
      timer = Timer.periodic(
          Duration(seconds: widget.autoRefreshInterval), (Timer t) => _load());
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
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

  void _padding(List<Widget> children) {
    if (children.isNotEmpty) {
      if (children.last is! SizedBox) {
        children.add(divider(horizontal: true, width: 24));
      }
    }
  }

  Widget _buildControls() {
    double dialogWidth = (MediaQuery.of(context).size.width / 2) + 100;
    double dialogHeight = (MediaQuery.of(context).size.height / 2) + 100;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Wrap(
          spacing: smallScreen ? 8 : 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (widget.enableDataFiler)
              Tooltip(
                message: 'filter by data',
                child: InkWell(
                  child: Icon(Icons.filter_alt_sharp,
                      color: (null != _dataFilter || null != _fieldFilter)
                          ? theme.getPrimaryColor()
                          : null),
                  onLongPress: () async {
                    setState(() {
                      _dataFilter = null;
                      _fieldFilter = null;
                    });
                    await _load(search: _searchQuery);
                  },
                  onTap: () async {
                    await super.alertDialog(
                      title: 'Filter by Data',
                      width: dialogWidth,
                      height: dialogHeight,
                      body: DataSearch(
                          clientIds: null != _client ? [_client!.id] : [],
                          onFieldFilterSelected: (entity) async {
                            setState(() {
                              _fieldFilter = entity;
                              _client = null;
                              _premise = null;
                              _facility = null;
                              _floor = null;
                              _assetGroup = null;
                              _dataFilter = null;
                            });
                            await _load(search: _searchQuery);
                          },
                          onDataFilterSelected: (entity) async {
                            setState(() {
                              _dataFilter = entity;
                              _client = null;
                              _premise = null;
                              _facility = null;
                              _floor = null;
                              _assetGroup = null;
                              _fieldFilter = null;
                            });
                            await _load(search: _searchQuery);
                          }),
                    );
                  },
                ),
              ),
            if (isAdmin() && widget.enableClintFiler)
              Tooltip(
                message: 'filter by clients',
                child: InkWell(
                  child: Icon(Icons.perm_contact_cal_outlined,
                      color: null == _client ? null : theme.getPrimaryColor()),
                  onLongPress: () async {
                    setState(() {
                      _client = null;
                      _premise = null;
                      _facility = null;
                      _floor = null;
                      _assetGroup = null;
                      _dataFilter = null;
                      _fieldFilter = null;
                    });
                    await _load(search: _searchQuery);
                  },
                  onTap: () async {
                    await super.alertDialog(
                        title: 'Filter by Client',
                        width: dialogWidth,
                        height: dialogHeight,
                        body: ClientSearch(onClientSelected: (entity) async {
                          setState(() {
                            _client = entity;
                            _premise = null;
                            _facility = null;
                            _floor = null;
                            _assetGroup = null;
                            _dataFilter = null;
                            _fieldFilter = null;
                          });
                          await _load(search: _searchQuery);
                        }));
                  },
                ),
              ),
            if (widget.enablePremiseFiler)
              Tooltip(
                message: 'filter by premises',
                child: InkWell(
                  child: Icon(Icons.home,
                      color: null == _premise ? null : theme.getPrimaryColor()),
                  onLongPress: () async {
                    setState(() {
                      _premise = null;
                      _facility = null;
                      _floor = null;
                    });
                    await _load(search: _searchQuery);
                  },
                  onTap: () async {
                    await super.alertDialog(
                        title: 'Filter by Premise',
                        width: dialogWidth,
                        height: dialogHeight,
                        body: PremiseSearch(
                            clientIds: null != _client ? [_client!.id] : [],
                            onPremiseSelected: (entity) async {
                              setState(() {
                                _premise = entity;
                                _facility = null;
                                _floor = null;
                              });
                              await _load(search: _searchQuery);
                            }));
                  },
                ),
              ),
            if (widget.enableFacilityFiler)
              Tooltip(
                message: 'filter by facility',
                child: InkWell(
                  child: Icon(Icons.business,
                      color:
                          null == _facility ? null : theme.getPrimaryColor()),
                  onLongPress: () async {
                    setState(() {
                      _facility = null;
                      _floor = null;
                    });
                    await _load(search: _searchQuery);
                  },
                  onTap: () async {
                    await super.alertDialog(
                        title: 'Filter by Facility',
                        width: dialogWidth,
                        height: dialogHeight,
                        body: FacilitySearch(
                            clientIds: null != _client ? [_client!.id] : [],
                            premiseId: _premise?.id,
                            onFacilitySelected: (entity) async {
                              setState(() {
                                _facility = entity;
                                _floor = null;
                              });
                              await _load(search: _searchQuery);
                            }));
                  },
                ),
              ),
            if (widget.enableFloorFiler)
              Tooltip(
                message: 'filter by floor',
                child: InkWell(
                  child: Icon(Icons.cabin,
                      color: null == _floor ? null : theme.getPrimaryColor()),
                  onLongPress: () async {
                    setState(() {
                      _floor = null;
                    });
                    await _load(search: _searchQuery);
                  },
                  onTap: () async {
                    await super.alertDialog(
                        title: 'Filter by Floor',
                        width: dialogWidth,
                        height: dialogHeight,
                        body: FloorSearch(
                            premiseId: _premise?.id,
                            facilityId: _facility?.id,
                            onFloorSelected: (entity) async {
                              setState(() {
                                _floor = entity;
                              });
                              await _load(search: _searchQuery);
                            }));
                  },
                ),
              ),
            if (widget.enableGroupFiler)
              Tooltip(
                message: 'filter by group',
                child: InkWell(
                  child: Icon(Icons.group_add,
                      color:
                          null == _assetGroup ? null : theme.getPrimaryColor()),
                  onLongPress: () async {
                    setState(() {
                      _assetGroup = null;
                    });
                    await _load(search: _searchQuery);
                  },
                  onTap: () async {
                    await super.alertDialog(
                        title: 'Filter by Group',
                        width: dialogWidth,
                        height: dialogHeight,
                        body: AssetGroupSearch(
                            clientIds: null != _client ? [_client!.id] : [],
                            onAssetGroupSelected: (entity) async {
                              setState(() {
                                _assetGroup = entity;
                              });
                              await _load(search: _searchQuery);
                            }));
                  },
                ),
              ),
            if (widget.enableEventFiler)
              Tooltip(
                message: 'filter by event',
                child: InkWell(
                  child: Icon(Icons.event_rounded,
                      color: null == _event ? null : theme.getPrimaryColor()),
                  onLongPress: () async {
                    setState(() {
                      _event = null;
                    });
                    await _load(search: _searchQuery);
                  },
                  onTap: () async {
                    await super.alertDialog(
                        title: 'Filter by Event',
                        width: dialogWidth,
                        height: dialogHeight,
                        body: EventSearch(
                            clientIds: null != _client ? [_client!.id] : [],
                            onEventSelected: (entity) async {
                              setState(() {
                                _event = entity;
                              });
                              await _load(search: _searchQuery);
                            }));
                  },
                ),
              ),
            if (widget.enableAlarmFiler)
              Tooltip(
                message: 'filter by alarm',
                child: InkWell(
                  child: Icon(Icons.doorbell_outlined,
                      color: null == _alarm ? null : theme.getPrimaryColor()),
                  onLongPress: () async {
                    setState(() {
                      _alarm = null;
                    });
                    await _load(search: _searchQuery);
                  },
                  onTap: () async {
                    await super.alertDialog(
                        title: 'Filter by Alarm',
                        width: dialogWidth,
                        height: dialogHeight,
                        body: AlarmSearch(
                            clientIds: null != _client ? [_client!.id] : [],
                            onAlarmSelected: (entity) async {
                              setState(() {
                                _alarm = entity;
                              });
                              await _load(search: _searchQuery);
                            }));
                  },
                ),
              ),
            if (null != widget.onCardViewSelected)
              Tooltip(
                message: 'Card View',
                child: InkWell(
                    onTap: () {
                      setState(() {
                        _cardView = true;
                      });
                      widget.onCardViewSelected!();
                    },
                    child: Icon(Icons.grid_view,
                        color: _cardView ? theme.getPrimaryColor() : null)),
              ),
            if (null != widget.onGridViewSelected)
              Tooltip(
                message: 'Grid View',
                child: InkWell(
                    onTap: () {
                      setState(() {
                        _cardView = false;
                      });
                      widget.onGridViewSelected!();
                    },
                    child: Icon(Icons.grid_on,
                        color: !_cardView ? theme.getPrimaryColor() : null)),
              ),
            InkWell(
                onTap: () {
                  _load();
                },
                child: Icon(Icons.refresh,
                    color: loading ? theme.getPrimaryColor() : null)),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SizedBox(
                  width: 250,
                  height: 40,
                  child: SearchBar(
                    hintText: widget.searchHint,
                    controller: _controller,
                    trailing: [const BusyIndicator()],
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
        Map<String, dynamic> dynData = dd.data as Map<String, dynamic>;
        tapi.DeviceModel deviceModel = _models[dd.modelId]!;
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
        tapi.DeviceModel deviceModel = _models[dd.modelId]!;
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
                      child: InkWell(
                        onTap: (null == widget.onAssetTapped ||
                                null == dd.assetId ||
                                dd.assetId!.isEmpty)
                            ? null
                            : () async {
                                widget.onAssetTapped!(dd.assetId!, dd);
                              },
                        child: Text(
                          dd.asset ?? '-',
                          style: theme.getStyle().copyWith(
                              fontSize: 16,
                              color: theme.getPrimaryColor(),
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold),
                        ),
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
                      child: InkWell(
                        onTap: (null == widget.onDeviceTapped)
                            ? null
                            : () {
                                widget.onDeviceTapped!(dd.deviceId, dd);
                              },
                        child: Icon(
                          Icons.qr_code,
                          color: theme.getPrimaryColor(),
                        ),
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
                    dd.premise ?? ' ',
                    style: theme.getStyle().copyWith(
                        color: theme.getPrimaryColor(),
                        fontSize: 14,
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
                    dd.facility ?? '-',
                    style: theme.getStyle().copyWith(
                          color: theme.getPrimaryColor(),
                          fontSize: 12,
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
                          fontSize: 12,
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
    return smallScreen ? _buildSmallTable() : _buildTable();
  }

  Future _load({String search = '*', int page = 0, int size = 1000}) async {
    if (loading) return;
    loading = true;

    if (search.trim().isEmpty) {
      search = '*';
    }

    _data.clear();
    _models.clear();
    _modelIds.clear();

    late final chopper.Response<tapi.DeviceDataArrayRes> dRes;

    if (null != _dataFilter) {
      await execute(() async {
        dRes = await TwinnedSession.instance.twin.filterRecentDeviceData(
            apikey: TwinnedSession.instance.authToken,
            filterId: _dataFilter!.id,
            page: page,
            size: size);
      });
    }

    if (null != _fieldFilter) {
      await execute(() async {
        dRes = await TwinnedSession.instance.twin.fieldFilterRecentDeviceData(
            apikey: TwinnedSession.instance.authToken,
            fieldFilterId: _fieldFilter!.id,
            page: page,
            size: size);
      });
    }

    if (null == _dataFilter && null == _fieldFilter) {
      await execute(() async {
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
                "client",
                "description",
                "tags"
              ]
            }
          }
        ];

        mustConditions.addAll([
          if (widget.deviceModelIds.isNotEmpty)
            {
              "terms": {'modelId': widget.deviceModelIds}
            },
          if (widget.assetModelIds.isNotEmpty)
            {
              "terms": {"assetModelId": widget.assetModelIds}
            },
          if (widget.assetIds.isNotEmpty ||
              null != _assetGroup && _assetGroup!.assetIds.isNotEmpty)
            {
              "terms": {
                "assetId": null != _assetGroup
                    ? _assetGroup!.assetIds
                    : widget.assetIds
              }
            },
          if (widget.premiseIds.isNotEmpty || null != _premise)
            {
              "terms": {
                "premiseId":
                    null != _premise ? [_premise!.id] : widget.premiseIds
              }
            },
          if (widget.facilityIds.isNotEmpty || null != _facility)
            {
              "terms": {
                "facilityId":
                    null != _facility ? [_facility!.id] : widget.facilityIds
              }
            },
          if (widget.floorIds.isNotEmpty || null != _floor)
            {
              "terms": {
                "floorId": null != _floor ? [_floor!.id] : widget.floorIds
              }
            },
          if (widget.clientIds.isNotEmpty || null != _client)
            {
              "terms": {
                "clientIds.keyword":
                    null != _client ? [_client!.id] : widget.clientIds
              }
            },
          if (null != _alarm)
            {
              "match_phrase": {"alarms.alarmId": _alarm!.id}
            },
          if (null != _event)
            {
              "match_phrase": {"events.eventId": _event!.id}
            },
        ]);

        dRes = await TwinnedSession.instance.twin.queryEqlDeviceData(
            apikey: TwinnedSession.instance.authToken,
            body: tapi.EqlSearch(
                source: [],
                mustConditions: mustConditions,
                page: 0,
                size: 25,
                sort: {'updatedStamp': 'desc'}));
      });
    }

    if (validateResponse(dRes)) {
      _data.addAll(dRes.body!.values!);

      for (tapi.DeviceData dd in _data) {
        if (_modelIds.contains(dd.modelId)) continue;
        _modelIds.add(dd.modelId);
      }

      var mRes = await TwinnedSession.instance.twin.getDeviceModels(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.GetReq(ids: _modelIds));

      if (validateResponse(mRes)) {
        for (var deviceModel in mRes.body!.values!) {
          _models[deviceModel.id] = deviceModel;
        }
      }
    }

    loading = false;
    // _controller.text = _searchQuery;
    refresh();
  }
}
