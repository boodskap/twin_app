import 'dart:async';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/alarm_search.dart';
import 'package:twin_app/widgets/commons/asset_action_widget.dart';
import 'package:twin_app/widgets/commons/asset_group_search.dart';
import 'package:twin_app/widgets/commons/asset_info_widget.dart';
import 'package:twin_app/widgets/commons/client_search.dart';
import 'package:twin_app/widgets/commons/data_search.dart';
import 'package:twin_app/widgets/commons/device_field_widget.dart';
import 'package:twin_app/widgets/commons/event_search.dart';
import 'package:twin_app/widgets/commons/facility_search.dart';
import 'package:twin_app/widgets/commons/floor_search.dart';
import 'package:twin_app/widgets/commons/location_info_widget.dart';
import 'package:twin_app/widgets/commons/premise_search.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/default_deviceview.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;
import 'package:chopper/chopper.dart' as chopper;

class DataGridHistorySnippet extends StatefulWidget {
  final bool autoRefresh;
  final int autoRefreshInterval;
  final String searchHint;
  final List<String> deviceModelIds;
  final List<String> deviceIds;
  final List<String> assetIds;
  final OnAnalyticsTapped onAnalyticsTapped;
  final OnAnalyticsTapped onAnalyticsDoubleTapped;
  final OnDeviceAnalyticsTapped onDeviceAnalyticsTapped;
  final OnDeviceAnalyticsTapped onDeviceAnalyticsDoubleTapped;
  final OnAssetModelTapped onAssetModelTapped;
  final OnAssetTapped onAssetTapped;
  final OnDeviceModelTapped onDeviceModelTapped;
  final OnClientTapped onClientTapped;
  final OnPremiseTapped onPremiseTapped;
  final OnFacilityTapped onFacilityTapped;
  final OnFloorTapped onFloorTapped;
  final bool enableDataFiler;
  final bool enableAlarmFiler;
  final bool enableEventFiler;
  final bool oldVersion;

  const DataGridHistorySnippet({
    super.key,
    this.autoRefresh = true,
    this.autoRefreshInterval = 60,
    this.searchHint = 'Search',
    this.deviceModelIds = const [],
    this.deviceIds = const [],
    this.assetIds = const [],
    required this.onAnalyticsTapped,
    required this.onAnalyticsDoubleTapped,
    required this.onDeviceAnalyticsTapped,
    required this.onDeviceAnalyticsDoubleTapped,
    required this.onAssetModelTapped,
    required this.onAssetTapped,
    required this.onDeviceModelTapped,
    required this.onClientTapped,
    required this.onPremiseTapped,
    required this.onFacilityTapped,
    required this.onFloorTapped,
    this.enableDataFiler = true,
    this.enableAlarmFiler = true,
    this.enableEventFiler = true,
    this.oldVersion = false,
  });

  @override
  State<DataGridHistorySnippet> createState() => DataGridHistorySnippetState();
}

class DataGridHistorySnippetState extends BaseState<DataGridHistorySnippet> {
  final List<tapi.DeviceData> _data = [];
  final List<Widget> _children = [];
  final Map<String, tapi.DeviceModel> _models = {};
  final List<String> _modelIds = [];
  Timer? timer;
  String _searchQuery = '';
  final TextEditingController _controller = TextEditingController();
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

  Widget _buildControls() {
    double dialogWidth = (MediaQuery.of(context).size.width / 2) + 100;
    double dialogHeight = (MediaQuery.of(context).size.height / 2) + 100;

    return Column(
      children: [
        Row(
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
                      onDoubleTap: () async {
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
                if (widget.enableEventFiler)
                  Tooltip(
                    message: 'filter by event',
                    child: InkWell(
                      child: Icon(Icons.event_rounded,
                          color:
                              null == _event ? null : theme.getPrimaryColor()),
                      onLongPress: () async {
                        setState(() {
                          _event = null;
                        });
                        await _load(search: _searchQuery);
                      },
                      onDoubleTap: () async {
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
                          color:
                              null == _alarm ? null : theme.getPrimaryColor()),
                      onLongPress: () async {
                        setState(() {
                          _alarm = null;
                        });
                        await _load(search: _searchQuery);
                      },
                      onDoubleTap: () async {
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
                InkWell(
                    onTap: () {
                      _load();
                    },
                    child: Icon(Icons.refresh,
                        color: loading ? theme.getPrimaryColor() : null)),
                if (!smallScreen)
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
                            if (loading) {
                              _controller.text = _searchQuery;
                              return;
                            }
                            setState(() {
                              _searchQuery = val.trim();
                            });
                            _load(search: _searchQuery);
                          },
                        )),
                  ),
              ],
            ),
          ],
        ),
        if (smallScreen)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
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
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width - 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildControls(),
            divider(),
            if (loading || _children.isEmpty)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (loading)
                      SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator()),
                    if (!loading)
                      Text(
                        'No Data',
                        style: theme.getStyle().copyWith(fontSize: 20),
                      ),
                  ],
                ),
              ),
            if (!loading && _children.isNotEmpty)
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    direction: Axis.vertical,
                    children: _children,
                  ),
                ),
              ),
          ],
        ));
  }

  void _buildChildren() {
    _children.clear();
    double colWidth = (MediaQuery.of(context).size.width / 3) / 3.5;

    _children.add(Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width - 10,
        height: 1,
        decoration:
            BoxDecoration(border: Border.all(color: theme.getPrimaryColor())),
      ),
    ));

    for (tapi.DeviceData dd in _data) {
      refresh(sync: () {
        _children.add(SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (smallScreen)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AssetActionWidget(
                    direction: Axis.vertical,
                    models: _models,
                    deviceData: dd,
                    onAssetModelTapped: widget.onAssetModelTapped,
                    onDeviceModelTapped: widget.onDeviceModelTapped,
                    onTimeSeriesDoubleTapped: widget.onAnalyticsDoubleTapped,
                    onTimeSeriesTapped: widget.onAnalyticsTapped,
                  ),
                ),
              SizedBox(
                width: colWidth,
                child: AssetInfoWidget(
                  models: _models,
                  deviceData: dd,
                  onClientTapped: widget.onClientTapped,
                  onAssetTapped: widget.onAssetTapped,
                  onFacilityTapped: widget.onFacilityTapped,
                  onPremiseTapped: widget.onPremiseTapped,
                  onFloorTapped: widget.onFloorTapped,
                  onAssetModelTapped: widget.onAssetModelTapped,
                  onDeviceModelTapped: widget.onDeviceModelTapped,
                  onTimeSeriesDoubleTapped: widget.onAnalyticsDoubleTapped,
                  onTimeSeriesTapped: widget.onAnalyticsTapped,
                ),
              ),
              divider(horizontal: true),
              SizedBox(
                width: colWidth,
                child: LocationInfoWidget(
                  deviceData: dd,
                  onClientTapped: widget.onClientTapped,
                  onFacilityTapped: widget.onFacilityTapped,
                  onPremiseTapped: widget.onPremiseTapped,
                  onFloorTapped: widget.onFloorTapped,
                ),
              ),
              divider(horizontal: true),
              DeviceFieldWidget(
                deviceData: dd,
                models: _models,
                onDeviceAnalyticsTapped: widget.onDeviceAnalyticsTapped,
                onDeviceAnalyticsDoubleTapped:
                    widget.onDeviceAnalyticsDoubleTapped,
              ),
            ],
          ),
        ));

        _children.add(Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Container(
            width: MediaQuery.of(context).size.width - 10,
            height: 1,
            decoration: BoxDecoration(
                border: Border.all(color: theme.getPrimaryColor())),
          ),
        ));
      });
    }

    if (_data.isEmpty) {
      _children.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No Data',
            style: theme.getStyle().copyWith(fontSize: 20),
          ),
        ],
      ));
    }
  }

  Future _load({String search = '*', int page = 0, int size = 1000}) async {
    if (loading) return;
    loading = true;

    if (search.trim().isEmpty) {
      search = '*';
    }

    _data.clear();
    _children.clear();
    _models.clear();
    _modelIds.clear();

    setState(() {
      _buildChildren();
    });

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
          if ('*' != search)
            {
              "query_string": {
                "query": '*$search*',
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
              "terms": {"modelId": widget.deviceModelIds}
            },
          if (widget.deviceIds.isNotEmpty)
            {
              "terms": {
                widget.oldVersion ? 'deviceId' : 'deviceId.keyword':
                    widget.deviceIds
              }
            },
          if (widget.assetIds.isNotEmpty ||
              null != _assetGroup && _assetGroup!.assetIds.isNotEmpty)
            {
              "terms": {
                widget.oldVersion ? 'assetId' : 'assetId.keyword':
                    null != _assetGroup
                        ? _assetGroup!.assetIds
                        : widget.assetIds
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

        dRes = await TwinnedSession.instance.twin.queryEqlDeviceHistoryData(
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

    _buildChildren();

    refresh();
  }
}
