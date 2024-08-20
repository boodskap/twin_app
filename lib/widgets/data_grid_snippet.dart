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
import 'package:twin_app/widgets/commons/premise_search.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/default_deviceview.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;
import 'package:chopper/chopper.dart' as chopper;

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
  final OnAnalyticsTapped onAnalyticsTapped;
  final OnAnalyticsTapped onAnalyticsDoubleTapped;
  final OnDeviceAnalyticsTapped onDeviceAnalyticsTapped;
  final OnDeviceAnalyticsTapped onDeviceAnalyticsDoubleTapped;
  final OnAssetModelTapped onAssetModelTapped;
  final OnAssetTapped onAssetTapped;
  final OnDeviceTapped onDeviceTapped;
  final OnDeviceModelTapped onDeviceModelTapped;
  final OnClientTapped onClientTapped;
  final OnPremiseTapped onPremiseTapped;
  final OnFacilityTapped onFacilityTapped;
  final OnFloorTapped onFloorTapped;
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
    required this.onAnalyticsTapped,
    required this.onAnalyticsDoubleTapped,
    required this.onDeviceAnalyticsTapped,
    required this.onDeviceAnalyticsDoubleTapped,
    required this.onAssetModelTapped,
    required this.onAssetTapped,
    required this.onDeviceTapped,
    required this.onDeviceModelTapped,
    required this.onClientTapped,
    required this.onPremiseTapped,
    required this.onFacilityTapped,
    required this.onFloorTapped,
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
                          color:
                              null == _client ? null : theme.getPrimaryColor()),
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
                            body:
                                ClientSearch(onClientSelected: (entity) async {
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
                          color: null == _premise
                              ? null
                              : theme.getPrimaryColor()),
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
                          color: null == _facility
                              ? null
                              : theme.getPrimaryColor()),
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
                          color:
                              null == _floor ? null : theme.getPrimaryColor()),
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
                          color: null == _assetGroup
                              ? null
                              : theme.getPrimaryColor()),
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
                          color:
                              null == _event ? null : theme.getPrimaryColor()),
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
                          color:
                              null == _alarm ? null : theme.getPrimaryColor()),
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
            if (!loading && _children.isNotEmpty) ..._children,
          ],
        ));
  }

  void _buildChildren() {
    _children.clear();
    double colWidth = (MediaQuery.of(context).size.width / 3) / 3.5;

    _children.add(Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 1,
        decoration:
            BoxDecoration(border: Border.all(color: theme.getPrimaryColor())),
      ),
    ));

    for (tapi.DeviceData dd in _data) {
      _children.add(SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AssetActionWidget(
                models: _models,
                deviceData: dd,
                onDeviceTapped: widget.onDeviceTapped,
                onAssetModelTapped: widget.onAssetModelTapped,
                onDeviceModelTapped: widget.onDeviceModelTapped,
                onTimeSeriesDoubleTapped: widget.onAnalyticsDoubleTapped,
                onTimeSeriesTapped: widget.onAnalyticsTapped,
              ),
            ),
            SizedBox(
              width: colWidth,
              child: AssetInfoWidget(
                deviceData: dd,
                onDeviceTapped: widget.onDeviceTapped,
                onClientTapped: widget.onClientTapped,
                onAssetTapped: widget.onAssetTapped,
                onFacilityTapped: widget.onFacilityTapped,
                onPremiseTapped: widget.onPremiseTapped,
                onFloorTapped: widget.onFloorTapped,
              ),
            ),
            divider(horizontal: true),
            SizedBox(
              width: colWidth,
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
          width: MediaQuery.of(context).size.width,
          height: 1,
          decoration:
              BoxDecoration(border: Border.all(color: theme.getPrimaryColor())),
        ),
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

    _buildChildren();

    refresh();
  }
}
