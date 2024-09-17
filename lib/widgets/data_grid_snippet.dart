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

import 'google_map.dart';

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
  final bool isTwin;
  final bool oldVersion;

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
    required this.isTwin,
    this.oldVersion = false,
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
  bool _isExpanded = true;
  bool _isTableView = true;
  bool _isMapView = false;

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

  void _togglePanel() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Widget _buildControls() {
    double dialogWidth = (MediaQuery.of(context).size.width / 2) + 100;
    double dialogHeight = (MediaQuery.of(context).size.height / 2) + 100;
    final ButtonStyle customButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white, // Background color
      foregroundColor: Colors.black, // Text color
      side: BorderSide(color: Colors.black, width: 1), // Border color and width
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // Border radius (optional)
      ),
    );
    final ButtonStyle customEnabledButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.blue, // Background color
      foregroundColor: Colors.white, // Text color
      side: BorderSide(color: Colors.blue, width: 1), // Border color and width
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // Border radius (optional)
      ),
    );

    return Container(
      child: Column(
        children: [
          if (widget.isTwin || smallScreen)
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
                              color:
                                  (null != _dataFilter || null != _fieldFilter)
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
                              titleStyle: theme.getStyle().copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                              width: dialogWidth,
                              height: dialogHeight,
                              body: DataSearch(
                                  clientIds:
                                      null != _client ? [_client!.id] : [],
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
                        // textStyle: theme.getStyle(),
                        child: InkWell(
                          child: Icon(Icons.perm_contact_cal_outlined,
                              color: null == _client
                                  ? null
                                  : theme.getPrimaryColor()),
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
                          onDoubleTap: () async {
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
                                titleStyle: theme.getStyle().copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                width: dialogWidth,
                                height: dialogHeight,
                                body: ClientSearch(
                                    onClientSelected: (entity) async {
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
                          onDoubleTap: () async {
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
                                titleStyle: theme.getStyle().copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                width: dialogWidth,
                                height: dialogHeight,
                                body: PremiseSearch(
                                    clientIds:
                                        null != _client ? [_client!.id] : [],
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
                          onDoubleTap: () async {
                            setState(() {
                              _facility = null;
                              _floor = null;
                            });
                            await _load(search: _searchQuery);
                          },
                          onTap: () async {
                            await super.alertDialog(
                                title: 'Filter by Facility',
                                titleStyle: theme.getStyle().copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                width: dialogWidth,
                                height: dialogHeight,
                                body: FacilitySearch(
                                    clientIds:
                                        null != _client ? [_client!.id] : [],
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
                              color: null == _floor
                                  ? null
                                  : theme.getPrimaryColor()),
                          onLongPress: () async {
                            setState(() {
                              _floor = null;
                            });
                            await _load(search: _searchQuery);
                          },
                          onDoubleTap: () async {
                            setState(() {
                              _floor = null;
                            });
                            await _load(search: _searchQuery);
                          },
                          onTap: () async {
                            await super.alertDialog(
                                title: 'Filter by Floor',
                                titleStyle: theme.getStyle().copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 20),
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
                          onDoubleTap: () async {
                            setState(() {
                              _assetGroup = null;
                            });
                            await _load(search: _searchQuery);
                          },
                          onTap: () async {
                            await super.alertDialog(
                                title: 'Filter by Group',
                                titleStyle: theme.getStyle().copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                width: dialogWidth,
                                height: dialogHeight,
                                body: AssetGroupSearch(
                                    clientIds:
                                        null != _client ? [_client!.id] : [],
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
                              color: null == _event
                                  ? null
                                  : theme.getPrimaryColor()),
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
                                titleStyle: theme.getStyle().copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                width: dialogWidth,
                                height: dialogHeight,
                                body: EventSearch(
                                    clientIds:
                                        null != _client ? [_client!.id] : [],
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
                              color: null == _alarm
                                  ? null
                                  : theme.getPrimaryColor()),
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
                                titleStyle: theme.getStyle().copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                width: dialogWidth,
                                height: dialogHeight,
                                body: AlarmSearch(
                                    clientIds:
                                        null != _client ? [_client!.id] : [],
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
                              hintStyle:
                                  WidgetStatePropertyAll(theme.getStyle()),
                              textStyle:
                                  WidgetStatePropertyAll(theme.getStyle()),
                              hintText: widget.searchHint,
                              controller: _controller,
                              trailing: [const BusyIndicator()],
                              onChanged: (val) {
                                if (loading) {
                                  // _controller.text = _searchQuery;
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
                        hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                        textStyle: WidgetStatePropertyAll(theme.getStyle()),
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
          if (!smallScreen && !widget.isTwin)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue, // Border color
                    width: 0.8, // Border width
                  ),
                  borderRadius: BorderRadius.circular(
                      8.0), // Optional: to give rounded corners
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6.0),
                          topRight: Radius.circular(6.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Filters',
                              style: theme.getStyle().copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isExpanded
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                            onPressed: _togglePanel,
                          ),
                        ],
                      ),
                    ),
                    if (_isExpanded)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Column(
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: [
                                if (widget.enableDataFiler)
                                  GestureDetector(
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
                                    child: ElevatedButton(
                                      style: (null != _dataFilter ||
                                              null != _fieldFilter)
                                          ? customEnabledButtonStyle
                                          : customButtonStyle,
                                      child: Text(
                                        'Filter by Data',
                                        style: theme.getStyle().copyWith(
                                            color: (null != _dataFilter ||
                                                    null != _fieldFilter)
                                                ? Colors.white
                                                : null),
                                      ),
                                      onPressed: () async {
                                        await super.alertDialog(
                                          title: 'Filter by Data',
                                          titleStyle: theme.getStyle().copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                          width: dialogWidth,
                                          height: dialogHeight,
                                          body: DataSearch(
                                            clientIds: null != _client
                                                ? [_client!.id]
                                                : [],
                                            onFieldFilterSelected:
                                                (entity) async {
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
                                            onDataFilterSelected:
                                                (entity) async {
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
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                if (isAdmin() && widget.enableClintFiler)
                                  GestureDetector(
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
                                    onDoubleTap: () async {
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
                                    child: ElevatedButton(
                                      style: null == _client
                                          ? customButtonStyle
                                          : customEnabledButtonStyle,
                                      child: Text('Filter by Clients',
                                          style: theme.getStyle().copyWith(
                                              color: null == _client
                                                  ? null
                                                  : Colors.white)),
                                      onPressed: () async {
                                        await super.alertDialog(
                                            title: 'Filter by Client',
                                            titleStyle: theme
                                                .getStyle()
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                            width: dialogWidth,
                                            height: dialogHeight,
                                            body: ClientSearch(onClientSelected:
                                                (entity) async {
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
                                  GestureDetector(
                                    onLongPress: () async {
                                      setState(() {
                                        _premise = null;
                                        _facility = null;
                                        _floor = null;
                                      });
                                      await _load(search: _searchQuery);
                                    },
                                    onDoubleTap: () async {
                                      setState(() {
                                        _premise = null;
                                        _facility = null;
                                        _floor = null;
                                      });
                                      await _load(search: _searchQuery);
                                    },
                                    child: ElevatedButton(
                                      style: null == _premise
                                          ? customButtonStyle
                                          : customEnabledButtonStyle,
                                      child: Text(
                                        'Filter by Premises',
                                        style: theme.getStyle().copyWith(
                                              color: null == _premise
                                                  ? null
                                                  : Colors.white,
                                            ),
                                      ),
                                      onPressed: () async {
                                        await super.alertDialog(
                                            title: 'Filter by Premise',
                                            titleStyle: theme
                                                .getStyle()
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                            width: dialogWidth,
                                            height: dialogHeight,
                                            body: PremiseSearch(
                                                clientIds: null != _client
                                                    ? [_client!.id]
                                                    : [],
                                                onPremiseSelected:
                                                    (entity) async {
                                                  setState(() {
                                                    _premise = entity;
                                                    _facility = null;
                                                    _floor = null;
                                                  });
                                                  await _load(
                                                      search: _searchQuery);
                                                }));
                                      },
                                    ),
                                  ),
                                if (widget.enableFacilityFiler)
                                  GestureDetector(
                                    onLongPress: () async {
                                      setState(() {
                                        _facility = null;
                                        _floor = null;
                                      });
                                      await _load(search: _searchQuery);
                                    },
                                    onDoubleTap: () async {
                                      setState(() {
                                        _facility = null;
                                        _floor = null;
                                      });
                                      await _load(search: _searchQuery);
                                    },
                                    child: ElevatedButton(
                                      style: null == _facility
                                          ? customButtonStyle
                                          : customEnabledButtonStyle,
                                      child: Text(
                                        'Filter by Facility',
                                        style: theme.getStyle().copyWith(
                                            color: null == _facility
                                                ? null
                                                : Colors.white),
                                      ),
                                      onPressed: () async {
                                        await super.alertDialog(
                                            title: 'Filter by Facility',
                                            titleStyle: theme
                                                .getStyle()
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                            width: dialogWidth,
                                            height: dialogHeight,
                                            body: FacilitySearch(
                                                clientIds: null != _client
                                                    ? [_client!.id]
                                                    : [],
                                                premiseId: _premise?.id,
                                                onFacilitySelected:
                                                    (entity) async {
                                                  setState(() {
                                                    _facility = entity;
                                                    _floor = null;
                                                  });
                                                  await _load(
                                                      search: _searchQuery);
                                                }));
                                      },
                                    ),
                                  ),
                                if (widget.enableFloorFiler)
                                  GestureDetector(
                                    onLongPress: () async {
                                      setState(() {
                                        _floor = null;
                                      });
                                      await _load(search: _searchQuery);
                                    },
                                    onDoubleTap: () async {
                                      setState(() {
                                        _floor = null;
                                      });
                                      await _load(search: _searchQuery);
                                    },
                                    child: ElevatedButton(
                                      style: null == _floor
                                          ? customButtonStyle
                                          : customEnabledButtonStyle,
                                      child: Text(
                                        'Filter by Floor',
                                        style: theme.getStyle().copyWith(
                                            color: null == _floor
                                                ? null
                                                : Colors.white),
                                      ),
                                      onPressed: () async {
                                        await super.alertDialog(
                                            title: 'Filter by Floor',
                                            titleStyle: theme
                                                .getStyle()
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                            width: dialogWidth,
                                            height: dialogHeight,
                                            body: FloorSearch(
                                                premiseId: _premise?.id,
                                                facilityId: _facility?.id,
                                                onFloorSelected:
                                                    (entity) async {
                                                  setState(() {
                                                    _floor = entity;
                                                  });
                                                  await _load(
                                                      search: _searchQuery);
                                                }));
                                      },
                                    ),
                                  ),
                                if (widget.enableGroupFiler)
                                  GestureDetector(
                                    onLongPress: () async {
                                      setState(() {
                                        _assetGroup = null;
                                      });
                                      await _load(search: _searchQuery);
                                    },
                                    onDoubleTap: () async {
                                      setState(() {
                                        _assetGroup = null;
                                      });
                                      await _load(search: _searchQuery);
                                    },
                                    child: ElevatedButton(
                                      style: null == _assetGroup
                                          ? customButtonStyle
                                          : customEnabledButtonStyle,
                                      child: Text(
                                        'Filter by Group',
                                        style: theme.getStyle().copyWith(
                                            color: null == _assetGroup
                                                ? null
                                                : Colors.white),
                                      ),
                                      onPressed: () async {
                                        await super.alertDialog(
                                            title: 'Filter by Group',
                                            titleStyle: theme
                                                .getStyle()
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                            width: dialogWidth,
                                            height: dialogHeight,
                                            body: AssetGroupSearch(
                                                clientIds: null != _client
                                                    ? [_client!.id]
                                                    : [],
                                                onAssetGroupSelected:
                                                    (entity) async {
                                                  setState(() {
                                                    _assetGroup = entity;
                                                  });
                                                  await _load(
                                                      search: _searchQuery);
                                                }));
                                      },
                                    ),
                                  ),
                                if (widget.enableEventFiler)
                                  GestureDetector(
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
                                    child: ElevatedButton(
                                      style: null == _event
                                          ? customButtonStyle
                                          : customEnabledButtonStyle,
                                      child: Text(
                                        'Filter by Event',
                                        style: theme.getStyle().copyWith(
                                            color: null == _event
                                                ? null
                                                : Colors.white),
                                      ),
                                      onPressed: () async {
                                        await super.alertDialog(
                                            title: 'Filter by Event',
                                            titleStyle: theme
                                                .getStyle()
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                            width: dialogWidth,
                                            height: dialogHeight,
                                            body: EventSearch(
                                                clientIds: null != _client
                                                    ? [_client!.id]
                                                    : [],
                                                onEventSelected:
                                                    (entity) async {
                                                  setState(() {
                                                    _event = entity;
                                                  });
                                                  await _load(
                                                      search: _searchQuery);
                                                }));
                                      },
                                    ),
                                  ),
                                if (widget.enableAlarmFiler)
                                  GestureDetector(
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
                                    child: ElevatedButton(
                                      style: null == _alarm
                                          ? customButtonStyle
                                          : customEnabledButtonStyle,
                                      child: Text(
                                        'Filter by Alarm',
                                        style: theme.getStyle().copyWith(
                                            color: null == _alarm
                                                ? null
                                                : Colors.white),
                                      ),
                                      onPressed: () async {
                                        await super.alertDialog(
                                            title: 'Filter by Alarm',
                                            titleStyle: theme
                                                .getStyle()
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                            width: dialogWidth,
                                            height: dialogHeight,
                                            body: AlarmSearch(
                                                clientIds: null != _client
                                                    ? [_client!.id]
                                                    : [],
                                                onAlarmSelected:
                                                    (entity) async {
                                                  setState(() {
                                                    _alarm = entity;
                                                  });
                                                  await _load(
                                                      search: _searchQuery);
                                                }));
                                      },
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: InkWell(
                                      onTap: () {
                                        _load();
                                      },
                                      child: Icon(Icons.refresh,
                                          color: loading
                                              ? theme.getPrimaryColor()
                                              : null)),
                                ),
                                if (!smallScreen)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: SizedBox(
                                        width: 250,
                                        height: 40,
                                        child: SearchBar(
                                          hintStyle: WidgetStatePropertyAll(
                                              theme.getStyle()),
                                          textStyle: WidgetStatePropertyAll(
                                              theme.getStyle()),
                                          hintText: widget.searchHint,
                                          controller: _controller,
                                          trailing: [const BusyIndicator()],
                                          onChanged: (val) {
                                            if (loading) {
                                              // _controller.text = _searchQuery;
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
                      )
                  ],
                ),
              ),
            ),
        ],
      ),
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
                      Center(
                        child: Text(
                          'No Data',
                          style: theme.getStyle().copyWith(fontSize: 20),
                        ),
                      ),
                  ],
                ),
              ),
            if (!loading && _children.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: "Grid view",
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isTableView
                            ? Colors.blue[200]
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.grid_on,
                          color: _isTableView
                              ? Colors.black
                              : theme.getPrimaryColor(),
                        ),
                        onPressed: () {
                          setState(() {
                            _isMapView = false;
                            _isTableView = true;
                          });
                          _buildChildren();
                        },
                      ),
                    ),
                  ),
                  divider(horizontal: true),
                  Tooltip(
                    message: "Map view",
                    child: Container(
                      decoration: BoxDecoration(
                        color: !_isTableView
                            ? Colors.blue[200]
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: !_isTableView
                              ? Colors.black
                              : theme.getPrimaryColor(),
                        ),
                        onPressed: () {
                          setState(() {
                            _isMapView = true;
                            _isTableView = false;
                          });
                          _buildChildren();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: _data.length == 0
                      ? WrapCrossAlignment.center
                      : WrapCrossAlignment.start,
                  direction: _isTableView ? Axis.vertical : Axis.horizontal,
                  children: _children,
                ),
              ),
            ),
          ],
        ));
  }

  void _buildChildren() {
    _children.clear();
    double colWidth = (MediaQuery.of(context).size.width / 3) / 2.87;
    _children.add(Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width - 10,
        height: 1,
        decoration:
            BoxDecoration(border: Border.all(color: theme.getPrimaryColor())),
      ),
    ));
    List<tapi.GeoLocation> geoLocationList = [];
    for (tapi.DeviceData dd in _data) {
      if (dd.geolocation != null) {
        geoLocationList.add(dd.geolocation!);
      }

      refresh(sync: () {
        if (_isTableView) {
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
                    models: _models,
                    deviceData: dd,
                    onDeviceTapped: widget.onDeviceTapped,
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
        }
      });
    }

    if (_isMapView) {
      _children.add(geoLocationList.isNotEmpty
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: widget.isTwin
                  ? MediaQuery.of(context).size.height
                  : MediaQuery.of(context).size.height / 1.6,
              child: GoogleMapMultiWidget(
                geoLocationList: geoLocationList,
                isTwin: widget.isTwin,
                deviceDataList: _data,
                onAssetTapped: widget.onAssetTapped,
                onDeviceTapped: widget.onDeviceTapped,
              ),
            )
          : Center(
              child: Text(
                'No Data',
                style: theme.getStyle().copyWith(fontSize: 20),
              ),
            ));
    }

    if ((_data.isEmpty && !loading && _isTableView)) {
      _children.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'No Data',
              style: theme.getStyle().copyWith(fontSize: 20),
            ),
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

    refresh(sync: () {
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
              "terms": {"assetModelId.keyword": widget.assetModelIds}
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

    if (mounted) {
      _buildChildren();
    }

    refresh();
  }

  Future<void> _showLocationDialog(longitude, latitude) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: theme
              .getStyle()
              .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preview Location',
                style: theme.getStyle(),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: 1000,
            child: GoogleMapWidget(
              longitude: longitude,
              latitude: latitude,
              viewMode: false,
            ),
          ),
        );
      },
    );
  }
}
