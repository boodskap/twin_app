import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/analytics/field_analytics.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;

class FieldAnalyticsPage extends StatefulWidget {
  final List<String> fields;
  final tapi.DeviceData deviceData;
  final tapi.DeviceModel deviceModel;
  final bool asPopup;
  final bool canDeleteRecord;
  const FieldAnalyticsPage({
    super.key,
    required this.fields,
    required this.deviceData,
    required this.deviceModel,
    required this.canDeleteRecord,
    this.asPopup = false,
  });

  @override
  State<FieldAnalyticsPage> createState() => _FieldAnalyticsPageState();
}

class _FieldAnalyticsPageState extends BaseState<FieldAnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    final String title;
    if (widget.fields.length > 1) {
      title = '${widget.deviceData.asset} - Time Series';
    } else {
      title =
          '${widget.deviceData.asset} - ${TwinUtils.getParameterLabel(widget.fields[0], widget.deviceModel)} (${TwinUtils.getParameterUnit(widget.fields[0], widget.deviceModel)}) - Time Series';
    }
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: theme
            .getStyle()
            .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        backgroundColor: theme.getPrimaryColor(),
        centerTitle: true,
        leading: const BackButton(
          color: Color(0XFFFFFFFF),
        ),
        title: Text(
          title,
          style: theme.getStyle().copyWith(
                color: Color(0XFFFFFFFF),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0XFFFFFFFF)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: DeviceFieldAnalytics(
              twinned: TwinnedSession.instance.twin,
              apiKey: TwinnedSession.instance.authToken,
              canDeleteRecord: widget.canDeleteRecord,
              deviceModel: widget.deviceModel,
              deviceData: widget.deviceData,
              fields: widget.fields,
            ),
          ),
        ],
      ),
    );
  }

  Future load() async {}

  @override
  void setup() {
    load();
  }
}
