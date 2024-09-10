import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_app/core/session_variables.dart' as session;

class AlarmsNotificationsGrid extends StatefulWidget {
  const AlarmsNotificationsGrid({super.key});

  @override
  State<AlarmsNotificationsGrid> createState() =>
      _AlarmsNotificationsGridState();
}

class _AlarmsNotificationsGridState extends BaseState<AlarmsNotificationsGrid> {
  int _currentPage = 0;
  static const int _itemsPerPage = 25;
  String _selectedFilter = 'Recent';
  DateTimeRange? _selectedDateRange;
  bool _isEmailView = true;
  bool _isSMSView = false;
  bool _isVoiceView = false;
  final TextEditingController _controller = TextEditingController();
  int totalCount = 0;
  final List<TriggeredEvent> _twinNotifications = [];
  String _searchQuery = '*';
  bool isShowAll = true;
  TwinUser? user;

  @override
  void initState() {
    super.initState();
  }

  List<TriggeredEvent> _getFilteredData() {
    // DateTime now = DateTime.now();
    // DateTime startOfToday = DateTime(now.year, now.month, now.day);
    // DateTime startOfYesterday = startOfToday.subtract(Duration(days: 1));

    // DateTime startOfWeek =
    //     startOfToday.subtract(Duration(days: now.weekday - 1));
    // DateTime startOfMonth = DateTime(now.year, now.month, 1);

    // switch (_selectedFilter) {
    //   case 'Today':
    //     return _twinNotifications
    //         .where((data) => data.createdStamp!.isAfter(startOfToday))
    //         .toList();
    //   case 'Yesterday':
    //     return _twinNotifications
    //         .where((data) =>
    //             data.triggeredTime.isAfter(startOfYesterday) &&
    //             data.triggeredTime.isBefore(startOfToday))
    //         .toList();
    //   case 'This Week':
    //     return _twinNotifications
    //         .where((data) =>
    //             data.triggeredTime.isAfter(startOfWeek) &&
    //             data.triggeredTime.isBefore(startOfToday))
    //         .toList();
    //   case 'This Month':
    //     return _twinNotifications
    //         .where((data) =>
    //             data.triggeredTime.isAfter(startOfMonth) &&
    //             data.triggeredTime.isBefore(startOfToday))
    //         .toList();
    //   case 'Date Range':
    //     if (_selectedDateRange != null) {
    //       return _twinNotifications
    //         .where((data) =>
    //               data.triggeredTime.isAfter(_selectedDateRange!.start) &&
    //               data.triggeredTime.isBefore(_selectedDateRange!.end))
    //           .toList();
    //     }
    //     return _twinNotifications;
    //   default:
    //     return _twinNotifications;
    // }
    return _twinNotifications;
  }

  List<TriggeredEvent> _getPaginatedData() {
    final filteredData = _getFilteredData();
    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;
    return filteredData.sublist(
      start,
      end > filteredData.length ? filteredData.length : end,
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _selectedFilter = 'Date Range';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildFilterDropdown(),
              _buildTableHeader(),
              Expanded(
                child: loading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
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
                            child: _buildTableRows()),
                      ),
              ),
              divider(),
              _buildPaginationControls(),
            ],
          ),
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
            "Total Notifications  :  $totalCount",
            overflow: TextOverflow.ellipsis,
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF000000),
                ),
          ),
          Wrap(
            children: [
              Tooltip(
                message: "Email",
                child: Container(
                  decoration: BoxDecoration(
                    color: _isEmailView ? Colors.blue[200] : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.email,
                      color:
                          _isEmailView ? Colors.black : theme.getPrimaryColor(),
                    ),
                    onPressed: () {
                      setState(() {
                        _isEmailView = true;
                        _isSMSView = false;
                        _isVoiceView = false;
                      });
                      _load();
                    },
                  ),
                ),
              ),
              divider(horizontal: true),
              Tooltip(
                message: "SMS",
                child: Container(
                  decoration: BoxDecoration(
                    color: _isSMSView ? Colors.blue[200] : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.sms,
                      color:
                          _isSMSView ? Colors.black : theme.getPrimaryColor(),
                    ),
                    onPressed: () {
                      setState(() {
                        _isEmailView = false;
                        _isSMSView = true;
                        _isVoiceView = false;
                      });
                      _load();
                    },
                  ),
                ),
              ),
              divider(horizontal: true),
              Tooltip(
                message: "Voice",
                child: Container(
                  decoration: BoxDecoration(
                    color: _isVoiceView ? Colors.blue[200] : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.voicemail,
                      color:
                          _isVoiceView ? Colors.black : theme.getPrimaryColor(),
                    ),
                    onPressed: () {
                      setState(() {
                        _isEmailView = false;
                        _isSMSView = false;
                        _isVoiceView = true;
                      });
                      _load();
                    },
                  ),
                ),
              ),
              if ((TwinnedSession.instance.isClientAdmin() ||
                  TwinnedSession.instance.isAdmin())) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Checkbox(
                    activeColor: theme.getPrimaryColor(),
                    value: isShowAll,
                    onChanged: (bool? value) {
                      setState(() {
                        isShowAll = value!;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 9, right: 2),
                  child: Text("Show All"),
                ),
              ],
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

          // DropdownButton<String>(
          //   value: _selectedFilter,
          //   items: <String>[
          //     'Recent',
          //     'Today',
          //     'Yesterday',
          //     'This Week',
          //     'This Month',
          //     'Date Range'
          //   ].map((String value) {
          //     return DropdownMenuItem<String>(
          //       value: value,
          //       child: Text(value),
          //     );
          //   }).toList(),
          //   onChanged: (String? newValue) {
          //     setState(() {
          //       _selectedFilter = newValue!;
          //       if (_selectedFilter != 'Date Range') {
          //         _selectedDateRange = null;
          //       }
          //     });
          //   },
          // ),
          // if (_selectedFilter == 'Date Range')
          //   TextButton(
          //     onPressed: () => _selectDateRange(context),
          //     child: Text('Select Date Range'),
          //   ),
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
          children: [
            // if ((TwinnedSession.instance.isClientAdmin() ||
            //         TwinnedSession.instance.isAdmin()) &&
            //     isShowAll)
            //   _buildTableCell('To', true, false, ""),
            _buildTableCell(
                _isEmailView
                    ? 'Email Subject'
                    : (_isVoiceView
                        ? 'Voice Message'
                        : (_isSMSView ? 'SMS Message' : '')),
                true,
                false,
                ""),
            _buildTableCell('Triggered By', true, false, ""),
            _buildTableCell('Delivery Status', true, false, ""),
            _buildTableCell('Created Time', true, false, ""),
            _buildTableCell('Updated Time', true, false, ""),
          ],
        ),
      ],
    );
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
    return Column(
      children: _getPaginatedData()
          .asMap()
          .map((index, event) {
            return MapEntry(
              index,
              ExpansionTile(
                title: Table(
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
                        // if ((TwinnedSession.instance.isClientAdmin() ||
                        //         TwinnedSession.instance.isAdmin()) &&
                        //     isShowAll)
                        //   _buildTableCell(
                        //       event.userId!, false, true, event.userId!),
                        Wrap(children: [
                          if (event.icon != null && event.icon != "")
                            SizedBox(
                              height: 28,
                              width: 28,
                              child: TwinImageHelper.getCachedDomainImage(
                                event.icon!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          if (_isEmailView)
                            _buildDataTableCell(event.emailSubject!, event),
                          if (_isSMSView)
                            _buildDataTableCell(event.smsMessage!, event),
                          if (_isVoiceView)
                            _buildDataTableCell(event.voiceMessage!, event),
                        ]),
                        getSourceType(event.sourceType!, event),
                        _buildTableCell(
                            getDeliveryStatusName(event.deliveryStatus!),
                            false,
                            false,
                            ""),
                        _buildTableCell(timeAgoCustomize(event.createdStamp!),
                            false, true, timeFormatText(event.createdStamp!)),
                        _buildTableCell(timeAgoCustomize(event.updatedStamp!),
                            false, true, timeFormatText(event.createdStamp!)),
                      ],
                    ),
                  ],
                ),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: EdgeInsets.zero,
                children: [
                  if (_isEmailView)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HtmlWidget(event.emailContent!),
                    ),
                  if (_isSMSView)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HtmlWidget(event.smsMessage!),
                    ),
                  if (_isVoiceView)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HtmlWidget(event.voiceMessage!),
                    ),
                ],
              ),
            );
          })
          .values
          .toList(),
    );
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
                  text,
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
                text,
                style: TextStyle(
                  fontSize: isHeading ? 16 : 14,
                  fontWeight: isHeading ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
    );
  }

  Widget _buildDataTableCell(String text, TriggeredEvent eventData) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                showEventLogs(context, eventData);
              },
              child: const Tooltip(
                  message: 'View Email Logs Data',
                  child: Icon(
                    Icons.remove_red_eye,
                    size: 20,
                  )),
            ),
            SizedBox(width: 3),
            Flexible(
              child: Tooltip(
                message: text,
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ));
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
    _twinNotifications.clear();
    await execute(() async {
      user = await TwinnedSession.instance.getUser();
    });
    await execute(() async {
      var qres = await TwinnedSession.instance.twin.queryTriggeredEqlEvent(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          source: [],
          page: 0,
          size: 25,
          sort: {"updatedStamp": "desc"},
          mustConditions: [
            {
              "query_string": {
                "query": _searchQuery,
                "fields": [
                  "emailSubject",
                  "deliveryStatus",
                  "emailContent",
                  "smsMessage",
                  "voiceMessage",
                  "modelName",
                  "deviceName",
                  "assetName",
                  "premiseName",
                  "facilityName",
                  "floorName",
                  "userId"
                ]
              }
            },
            {
              "match_phrase": {
                "eventType": _isEmailView
                    ? 'EMAIL'
                    : (_isVoiceView ? 'VOICE' : (_isSMSView ? 'SMS' : ''))
              },
            },
            if (!isShowAll && user != null)
              {
                "match_phrase": {"userId": user!.email},
              },
          ],
        ),
      );
      if (validateResponse(qres)) {
        totalCount = qres.body!.total;
        refresh(
          sync: () {
            _twinNotifications.addAll(qres.body!.values!);
          },
        );
      }
    });

    loading = false;
    refresh();
  }

  Widget getSourceType(
      TriggeredEventSourceType type, TriggeredEvent eventData) {
    switch (type) {
      case TriggeredEventSourceType.device:
        return _buildTriggeredCell(
            eventData.deviceName!, "Triggered by Device", Icons.memory_rounded);
      case TriggeredEventSourceType.asset:
        return _buildTriggeredCell(
            eventData.assetName!, "Triggered by Asset", Icons.view_comfy);
      case TriggeredEventSourceType.premise:
        return _buildTriggeredCell(
            eventData.premiseName!, "Triggered by Premise", Icons.home);
      case TriggeredEventSourceType.facility:
        return _buildTriggeredCell(
            eventData.facilityName!, "Triggered by Facility", Icons.business);
      case TriggeredEventSourceType.floor:
        return _buildTriggeredCell(
            eventData.floorName!, "Triggered by Floor", Icons.cabin);
      default:
        return _buildTriggeredCell(eventData.modelName!,
            "Triggered by Device Model", Icons.developer_board_rounded);
    }
  }

  Widget _buildTriggeredCell(
      String text, String tooltipMessage, IconData icon) {
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: tooltipMessage,
            child: Wrap(
              children: [
                Icon(icon),
                SizedBox(width: 5),
                Text(
                  overflow: TextOverflow.ellipsis,
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                )
              ],
            ),
          )),
    );
  }

  String getDeliveryStatusName(TriggeredEventDeliveryStatus type) {
    switch (type) {
      case TriggeredEventDeliveryStatus.sent:
        return 'SENT';
      case TriggeredEventDeliveryStatus.delivered:
        return 'DELIVERED';
      case TriggeredEventDeliveryStatus.failed:
        return 'FAILED';

      default:
        return 'QUEUED';
    }
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
  }

  void showEventLogs(BuildContext context, TriggeredEvent emailData) {
    Map<String, dynamic> emailDataMap;

    if (emailData is Map<String, dynamic>) {
      emailDataMap = emailData as Map<String, dynamic>;
    } else
      emailDataMap = emailData.toJson();

    emailDataMap.remove('emailContent');

    String prettyJson =
        const JsonEncoder.withIndent('  ').convert(emailDataMap);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titleTextStyle: theme
              .getStyle()
              .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          title: ModelHeaderSection(copyText: prettyJson, title: 'Event Logs Data'),
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
