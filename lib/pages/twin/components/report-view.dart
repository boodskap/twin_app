import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:twin_commons/util/nocode_utils.dart';

class ReportViewGrid extends StatefulWidget {
  final Report entity;
  const ReportViewGrid({super.key, required this.entity});

  @override
  State<ReportViewGrid> createState() => _ReportViewGridState();
}

class _ReportViewGridState extends BaseState<ReportViewGrid> {
  int _currentPage = 0;
  static const int _itemsPerPage = 25;
  final TextEditingController _controller = TextEditingController();
  int totalCount = 0;
  final List<DeviceData> _twinReportsData = [];
  String _searchQuery = '*';
  List<String> dataFields = [];
  List<String> gridFieldHeader = [];
  List<String> defaultGridHeader = [];
  bool apiLoadingStatus = false;
  @override
  void initState() {
    dataFields = widget.entity.fields;
    if (widget.entity.includePremise!) {
      defaultGridHeader.add('Premise');
    }
    if (widget.entity.includeFacility!) {
      defaultGridHeader.add('Facility');
    }
    if (widget.entity.includeFloor!) {
      defaultGridHeader.add('Floor');
    }
    if (widget.entity.includeAsset!) {
      defaultGridHeader.add('Asset');
    }
    if (widget.entity.includeDevice!) {
      defaultGridHeader.add('Device');
    }
    defaultGridHeader.addAll(['Created Time', 'Updated Time']);
    super.initState();
  }

  List<DeviceData> _getFilteredData() {
    return _twinReportsData;
  }

  List<DeviceData> _getPaginatedData() {
    final filteredData = _getFilteredData();
    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;
    return filteredData.sublist(
      start,
      end > filteredData.length ? filteredData.length : end,
    );
  }

  Future _getDeviceModelData() async {
    if (widget.entity.fields.isNotEmpty) {
      await execute(() async {
        DeviceModel? deviceModel =
            await TwinUtils.getDeviceModel(modelId: widget.entity.modelId);

        if (null == deviceModel) return;
        List<String> deviceFields = TwinUtils.getSortedFields(deviceModel);
        gridFieldHeader = [];
        for (String field in dataFields) {
          String label = TwinUtils.getParameterLabel(field, deviceModel);
          if (deviceFields.contains(field)) {
            if (label.isNotEmpty) {
              String capitalizedField =
                  label[0].toUpperCase() + label.substring(1).toLowerCase();
              gridFieldHeader.add(capitalizedField);
            }
          } else {
            if (field.isNotEmpty) {
              String capitalizedField =
                  field[0].toUpperCase() + field.substring(1).toLowerCase();
              gridFieldHeader.add(capitalizedField);
            }
          }
        }
        gridFieldHeader.addAll(defaultGridHeader);
      });
    } else {
      gridFieldHeader.addAll(defaultGridHeader);
    }
    apiLoadingStatus = true;
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TopBar(
              title: 'Custom Report View',
              style: theme.getStyle().copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.05,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildFilterDropdown(),
                      _buildTableHeader(),
                      loading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      right: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: _buildTableRows(),
                                ),
                              ),
                            ),
                      divider(),
                      _buildPaginationControls(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total Reports  :  $totalCount",
            overflow: TextOverflow.ellipsis,
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF000000),
                ),
          ),
          Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                    onTap: () {
                      _load();
                    },
                    child: Icon(Icons.refresh,
                        color: loading ? theme.getPrimaryColor() : null)),
              ),
              if (!smallScreen)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: SizedBox(
                      width: 250,
                      height: 40,
                      child: SearchBar(
                        hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                        textStyle: WidgetStatePropertyAll(theme.getStyle()),
                        hintText: 'Search',
                        controller: _controller,
                        trailing: [const BusyIndicator()],
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = '*${value.trim()}*';
                          });
                          Future.delayed(Duration(milliseconds: 500), () {
                            _load();
                          });
                        },
                      )),
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
                        hintText: "Search",
                        hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                        textStyle: WidgetStatePropertyAll(theme.getStyle()),
                        controller: _controller,
                        trailing: [const BusyIndicator()],
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = '*${value.trim()}*';
                          });
                          _load();
                        },
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Table(
      border: TableBorder.all(color: Colors.grey, width: 1),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.blue[200]),
          children: buildTableCells(),
        ),
      ],
    );
  }

  List<Widget> buildTableCells() {
    return gridFieldHeader
        .map((name) => _buildTableCell(name, true, false, ""))
        .toList();
  }

  Widget _buildTableRows() {
    final paginatedData = _getPaginatedData();
    if (paginatedData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No data found',
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    return !loading
        ? Column(
            children: _getPaginatedData()
                .asMap()
                .map((index, report) {
                  Object deviceData = report.data;
                  Map<String, dynamic> map = deviceData as Map<String, dynamic>;
                  return MapEntry(
                    index,
                    Table(
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                          ),
                          children: [
                            ...dataFields.map((field) {
                              return _buildTableCell(
                                map[field]?.toString() ?? '-',
                                false,
                                false,
                                "",
                              );
                            }).toList(),
                            if (widget.entity.includePremise!)
                              _buildTableCell(
                                  report.premise ?? '-', false, false, ""),
                            if (widget.entity.includeFacility!)
                              _buildTableCell(
                                  report.facility ?? '-', false, false, ""),
                            if (widget.entity.includeFloor!)
                              _buildTableCell(
                                  report.floor ?? '-', false, false, ""),
                            if (widget.entity.includeAsset!)
                              _buildTableCell(
                                  report.asset ?? '-', false, false, ""),
                            if (widget.entity.includeDevice!)
                              _buildTableCell(
                                  report.deviceName ?? '-', false, false, ""),
                            _buildTableCell(
                                timeAgoCustomize(report.createdStamp!),
                                false,
                                true,
                                timeFormatText(report.createdStamp!)),
                            _buildTableCell(
                                timeAgoCustomize(report.updatedStamp!),
                                false,
                                true,
                                timeFormatText(report.createdStamp!)),
                          ],
                        ),
                      ],
                    ),
                  );
                })
                .values
                .toList(),
          )
        : CircularProgressIndicator();
  }

  Widget _buildTableCell(
      String text, bool isHeading, bool isTooltip, String tooltipMessage) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isTooltip
          ? Tooltip(
              message: tooltipMessage,
              child: Center(
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  text != "" ? text : '-',
                  style: TextStyle(
                    fontSize: isHeading ? 16 : 14,
                    fontWeight: isHeading ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                overflow: TextOverflow.ellipsis,
                text != "" ? text : '-',
                style: TextStyle(
                  fontSize: isHeading ? 16 : 14,
                  fontWeight: isHeading ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (_getFilteredData().length / _itemsPerPage).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: 'Previous',
            child: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: _currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null,
            ),
          ),
          divider(horizontal: true),
          Text('Page ${_currentPage + 1} of $totalPages'),
          divider(horizontal: true),
          Tooltip(
            message: 'Next',
            child: IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: _currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  : null,
            ),
          ),
          divider(horizontal: true),
        ],
      ),
    );
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    _twinReportsData.clear();
   
    await execute(() async {
      var qres = await TwinnedSession.instance.twin.queryEqlDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          source: [],
          page: 0,
          size: 9999,
          sort: {"updatedStamp": "desc"},
          mustConditions: [
            {
              "query_string": {
                "query": _searchQuery,
                "fields": [
                  "premise",
                  "facility",
                  "floor",
                  "asset",
                  "deviceName",
                ]
              }
            },
            {
              "match_phrase": {"modelId": widget.entity.modelId},
            },
          ],
        ),
      );
      if (validateResponse(qres)) {
        totalCount = qres.body!.total;
        refresh(
          sync: () {
            _twinReportsData.addAll(qres.body!.values!);
          },
        );
      }
    });

    loading = false;
    refresh();
  }

  String timeAgoCustomize(int stamp) {
    var timeAgoVal = DateTime.fromMillisecondsSinceEpoch(stamp);
    return timeago.format(timeAgoVal, locale: 'en');
  }

  String timeFormatText(int stamp) {
    var timeFormat = DateTime.fromMillisecondsSinceEpoch(stamp);
    return timeFormat.toString();
  }

  @override
  void setup() {
    _load();
    _getDeviceModelData();
  }
}
