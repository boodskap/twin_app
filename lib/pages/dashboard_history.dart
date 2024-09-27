import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/dashboard.dart';
import 'package:twin_app/pages/wrapper_page.dart';
import 'package:twin_app/widgets/data_grid_history_snippet.dart';
import 'package:twin_app/widgets/field_analytics_page.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;

class DashboardHistory extends StatefulWidget {
  final List<String> deviceIds;
  final List<String> assetIds;
  final bool oldVersion;

  const DashboardHistory({
    super.key,
    this.deviceIds = const [],
    this.assetIds = const [],
    this.oldVersion = false,
  });

  @override
  State<DashboardHistory> createState() => _DashboardHistoryState();
}

class _DashboardHistoryState extends BaseState<DashboardHistory> {
  @override
  void initState() {
    super.initState();
  }

  void _showAnalytics(
      {required bool asPopup,
      required List<String> fields,
      required tapi.DeviceModel deviceModel,
      required tapi.DeviceData dd}) {
    if (asPopup) {
      alertDialog(
          title: '',
          titleStyle: theme
              .getStyle()
              .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
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

  void _showDashboard(
    String title, {
    List<String> deviceModelIds = const [],
    List<String> assetModelIds = const [],
    List<String> assetIds = const [],
    List<String> premiseIds = const [],
    List<String> facilityIds = const [],
    List<String> floorIds = const [],
    List<String> clientIds = const [],
  }) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: WrapperPage(
                    title: '$title - Dashboard',
                    child: Dashboard(
                      premiseIds: premiseIds,
                      assetIds: assetIds,
                      assetModelIds: assetModelIds,
                      deviceModelIds: deviceModelIds,
                      facilityIds: facilityIds,
                      floorIds: floorIds,
                    ),
                  ),
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                border: Border.all(color: theme.getPrimaryColor())),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DataGridHistorySnippet(
                oldVersion: widget.oldVersion,
                assetIds: widget.assetIds,
                deviceIds: widget.deviceIds,
                onPremiseTapped: (id, dd) {
                  _showDashboard(dd.premise ?? '', premiseIds: [id]);
                },
                onFloorTapped: (id, dd) {
                  _showDashboard(dd.floor ?? '', floorIds: [id]);
                },
                onFacilityTapped: (id, dd) {
                  _showDashboard(dd.facility ?? '', facilityIds: [id]);
                },
                onDeviceModelTapped: (id, dd) {
                  _showDashboard(dd.modelName ?? '', deviceModelIds: [id]);
                },
                onAssetModelTapped: (id, dd) {
                  _showDashboard(dd.assetModel ?? '', assetModelIds: [id]);
                },
                onClientTapped: (id, dd) {
                  _showDashboard(dd.$client ?? '', clientIds: [id]);
                },
                onAssetTapped: (id, dd) {
                  _showDashboard(dd.asset ?? '', assetIds: [id]);
                },
                onAnalyticsTapped: (m, dd) async {
                  _showAnalytics(
                      asPopup: true,
                      fields: dd.series!,
                      deviceModel: m,
                      dd: dd);
                },
                onAnalyticsDoubleTapped: (m, dd) async {
                  _showAnalytics(
                      asPopup: false,
                      fields: dd.series!,
                      deviceModel: m,
                      dd: dd);
                },
                onDeviceAnalyticsTapped: (f, m, dd) async {
                  _showAnalytics(
                      asPopup: true, fields: [f], deviceModel: m, dd: dd);
                },
                onDeviceAnalyticsDoubleTapped: (f, m, dd) async {
                  _showAnalytics(
                      asPopup: false, fields: [f], deviceModel: m, dd: dd);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void setup() {}
}
