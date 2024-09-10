import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/wrapper_page.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;

class SmsPage extends StatefulWidget {
  final String? to;
  final String? pulseStatus;
  final String? gatewayStatus;
  final String? search;

  const SmsPage({
    super.key,
    this.to,
    this.pulseStatus,
    this.gatewayStatus,
    this.search,
  });

  @override
  State<SmsPage> createState() => _SmsPageState();
}

class _SmsPageState extends BaseState<SmsPage> {
  final List<pulse.Sms> _data = [];
  String _search = '*';

  @override
  void initState() {
    super.initState();
    _search = widget.search ?? '*';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            divider(),
            Tooltip(
              message: "Refresh",
              child: IconButton(
                onPressed: () async {
                  await _load();
                },
                icon: const Icon(Icons.refresh),
              ),
            ),
            SizedBox(
              width: 250,
              height: 40,
              child: SearchBar(
                leading: const Icon(Icons.search),
                textStyle: WidgetStatePropertyAll(theme.getStyle()),
                hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                hintText: "Search Emails",
                onChanged: (value) async {
                  _search = value.trim().isNotEmpty ? value.trim() : '*';
                  await _load();
                },
              ),
            ),
          ],
        ),
        divider(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            child: _buildTable(),
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    List<DataColumn2> columns = [
      DataColumn2(
        size: ColumnSize.M,
        label: Text(
          'To',
          style: theme.getStyle().copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: Text(
          'Queued At',
          style: theme.getStyle().copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: Text(
          'Sent At',
          style: theme.getStyle().copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: Text(
          'Updated At',
          style: theme.getStyle().copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: Text(
          'Pulse Status',
          style: theme.getStyle().copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: Text(
          'Gateway Status',
          style: theme.getStyle().copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      DataColumn2(
        size: ColumnSize.L,
        label: Text(
          'Content',
          style: theme.getStyle().copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    ];

    List<DataRow2> rows = _data.map((e) {
      DateTime uT = DateTime.fromMillisecondsSinceEpoch(e.updatedStamp);
      String uTs = timeago.format(uT, locale: 'en');

      DateTime qT = DateTime.fromMillisecondsSinceEpoch(e.queuedStamp!);
      String qTs = timeago.format(qT, locale: 'en');

      DateTime? sT = null != e.sentStamp
          ? DateTime.fromMillisecondsSinceEpoch(e.sentStamp!)
          : null;
      String? sTs = null != sT ? timeago.format(sT, locale: 'en') : null;

      return DataRow2(
        specificRowHeight: 60,
        cells: [
          DataCell(Wrap(
            children: [
              const SizedBox(width: 3),
              InkWell(
                onTap: () {
                  _showFilterPage(
                    title: 'Filter By - ${e.to}',
                    to: e.to,
                    gatewayStatus: widget.gatewayStatus,
                    pulseStatus: widget.pulseStatus,
                    search: widget.search,
                  );
                },
                child: Text(
                  '${e.countryCode} ${e.to}',
                  style:
                      theme.getStyle().copyWith(color: theme.getPrimaryColor()),
                ),
              ),
              const SizedBox(width: 3),
              InkWell(
                onTap: () {
                  showSMSLogs(context, e);
                },
                child: const Tooltip(
                    message: 'View SMS Logs Data',
                    child: Icon(Icons.remove_red_eye, size: 20)),
              ),
            ],
          )),
          DataCell(Tooltip(
            message: qT.toString(),
            child: Text(
              qTs,
              style: theme.getStyle(),
            ),
          )),
          DataCell(Tooltip(
            message: sT?.toString() ?? '',
            child: Text(
              sTs ?? '-',
              style: theme.getStyle(),
            ),
          )),
          DataCell(Tooltip(
            message: qT.toString(),
            child: Text(
              uTs,
              style: theme.getStyle(),
            ),
          )),
          DataCell(InkWell(
            onTap: () {
              _showFilterPage(
                title: 'Filter By - ${e.status}',
                to: widget.to,
                gatewayStatus: widget.gatewayStatus,
                pulseStatus: e.status,
                search: widget.search,
              );
            },
            child: Text(
              e.status,
              style: theme.getStyle().copyWith(color: theme.getPrimaryColor()),
            ),
          )),
          DataCell(InkWell(
            onTap: (null == e.providerStatus || e.providerStatus!.isEmpty)
                ? null
                : () {
                    _showFilterPage(
                      title: 'Filter By - ${e.providerStatus}',
                      to: widget.to,
                      gatewayStatus: e.providerStatus,
                      pulseStatus: widget.pulseStatus,
                      search: widget.search,
                    );
                  },
            child: Text(
              e.providerStatus ?? '-',
              style: theme.getStyle().copyWith(color: theme.getPrimaryColor()),
            ),
          )),
          DataCell(Text(
            e.content ?? '-',
            style: theme.getStyle(),
          )),
        ],
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.getPrimaryColor(),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Flexible(
            child: DataTable2(
              // key: Key(const Uuid().v4()),
              empty: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (loading)
                    const SizedBox(
                        width: 100, height: 100, child: BusyIndicator()),
                  if (!loading)
                    Text(
                      'No data',
                      style: theme.getStyle(),
                    ),
                ],
              ),
              dataRowHeight: 100,
              columnSpacing: 5,
              horizontalMargin: 5,
              columns: columns,
              rows: rows,
            ),
          ),
        ],
      ),
    );
  }

  Future _showFilterPage({
    required String title,
    String? to,
    String? pulseStatus,
    String? gatewayStatus,
    String? search,
  }) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: WrapperPage(
                    title: title,
                    child: SmsPage(
                      to: to,
                      pulseStatus: pulseStatus,
                      gatewayStatus: gatewayStatus,
                      search: search,
                    ),
                  ),
                )));
    _load();
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    _data.clear();
    refresh();

    if (null != widget.to ||
        null != widget.pulseStatus ||
        null != widget.gatewayStatus) {
      await execute(() async {
        var res = await TwinnedSession.instance.pulseAdmin.querySms(
            apikey: TwinnedSession.instance.authToken,
            body: pulse.EqlSearch(source: [], sort: {
              'queuedStamp': 'desc'
            }, mustConditions: [
              if (null != widget.to)
                {
                  'match_phrase': {"to": widget.to}
                },
              if (null != widget.gatewayStatus)
                {
                  'match_phrase': {"providerStatus": widget.gatewayStatus}
                },
              if (null != widget.pulseStatus)
                {
                  'match_phrase': {"status": widget.pulseStatus}
                },
              if (_search != '*')
                {
                  'query_string': {
                    "query": '*$_search*',
                    "fields": ["to", "subject", "content", "htmlContent"]
                  }
                },
            ]));
        if (validateResponse(res)) {
          _data.addAll(res.body?.values ?? []);
        }
      });
    } else {
      await execute(() async {
        var res = await TwinnedSession.instance.pulseAdmin.searchSms(
            apikey: TwinnedSession.instance.authToken,
            body: pulse.SearchReq(search: _search, page: 0, size: 25));
        if (validateResponse(res)) {
          _data.addAll(res.body?.values ?? []);
        }
      });
    }
    loading = false;
    refresh();
  }

  void showSMSLogs(BuildContext context, pulse.Sms smsData) {
    String prettyJson = const JsonEncoder.withIndent('  ').convert(smsData);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titleTextStyle: theme
              .getStyle()
              .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          title: const Text('SMS Logs Data'),
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

  @override
  void setup() {
    _load();
  }
}
