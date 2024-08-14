import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/dashboard.dart';
import 'package:twin_app/pages/wrapper_page.dart';
import 'package:twin_app/widgets/data_grid_history_snippet.dart';
import 'package:twin_app/widgets/data_grid_snippet.dart';
import 'package:twin_app/widgets/data_card_snippet.dart';
import 'package:twin_commons/core/base_state.dart';

class DashboardHistory extends StatefulWidget {
  final List<String> deviceIds;
  final List<String> assetIds;

  const DashboardHistory({
    super.key,
    this.deviceIds = const [],
    this.assetIds = const [],
  });

  @override
  State<DashboardHistory> createState() => _DashboardHistoryState();
}

class _DashboardHistoryState extends BaseState<DashboardHistory> {
  bool _cardView = true;

  @override
  void initState() {
    super.initState();
    _cardView = smallScreen;
  }

  Widget _buildSmall(BuildContext context) {
    return DataCardSnippet(
      assetIds: widget.assetIds,
      onGridViewSelected: () {
        setState(() {
          _cardView = false;
        });
      },
      onAssetTapped: (id, dd) {
        _showDashboard(dd.asset ?? '', assetIds: [id]);
      },
    );
  }

  void _showDashboard(
    String title, {
    List<String> deviceModelIds = const [],
    List<String> assetModelIds = const [],
    List<String> assetIds = const [],
    List<String> premiseIds = const [],
    List<String> facilityIds = const [],
    List<String> floorIds = const [],
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
    if (smallScreen || _cardView) {
      return _buildSmall(context);
    }

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
                assetIds: widget.assetIds,
                deviceIds: widget.deviceIds,
                onCardViewSelected: () {
                  setState(() {
                    _cardView = true;
                  });
                },
                onGridViewSelected: () {
                  setState(() {
                    _cardView = false;
                  });
                },
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
