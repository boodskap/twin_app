import 'package:flutter/material.dart';
import 'package:twin_app/widgets/buy_button.dart';
import 'package:twin_app/widgets/choose_plans.dart';
import 'package:twin_app/widgets/purchase_change_addon_widget.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_commons/core/base_state.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';

class CurrentPlan extends StatefulWidget {
  const CurrentPlan({super.key});

  @override
  State<CurrentPlan> createState() => _CurrentPlanState();
}

class _CurrentPlanState extends BaseState<CurrentPlan> {
  tapi.Usage? usage;
  tapi.OrgPlan? orgPlan;

  Widget _buildPlan() {
    if (null == orgPlan) {
      return const SizedBox.shrink();
    }

    tapi.OrgPlan p = orgPlan!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${p.planType} Plan',
                style: BaseState.labelTextStyle.copyWith(
                    color: Colors.teal,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              BuyButton(
                label: 'Upgrade Plan',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontColor: Colors.blue,
                iconData: Icons.star,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        body: ChoosePlansPage(
                          orgId: p.id,
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
          divider(),
          Expanded(
            child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                columns: [
                  DataColumn2(
                    label: Text(
                      'Component',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 16),
                    ),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text(
                      'Count',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 16),
                    ),
                  ),
                  DataColumn2(
                    label: Text(
                      'Add On (Qty)',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 16),
                    ),
                  ),
                  DataColumn2(
                    label: Text(
                      'Total',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 16),
                    ),
                  ),
                  DataColumn2(
                    label: Text(
                      '',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 16),
                    ),
                  ),
                ],
                rows: [
                  DataRow2(cells: [
                    DataCell(Text(
                      'Data Points',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 14),
                    )),
                    DataCell(Text(
                      '${p.dataPointsCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.purchasedDataPoints}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${(p.dataPointsCount * p.totalDevicesCount) + (p.purchasedDataPoints * 50000)}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(BuyButton(
                      label: 'Buy',
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      onPressed: p.canBuyDataPlan!
                          ? () {
                              _buyAddon(dataPoints: 1);
                            }
                          : null,
                    )),
                  ]),
                  DataRow2(cells: [
                    DataCell(Text(
                      'Devices',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 14),
                    )),
                    DataCell(Text(
                      '${p.devicesCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.purchasedDevices}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.totalDevicesCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(BuyButton(
                      label: 'Buy',
                      onPressed: () {
                        _buyAddon(devices: 1);
                      },
                    )),
                  ]),
                  DataRow2(cells: [
                    DataCell(Text(
                      'Users',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 14),
                    )),
                    DataCell(Text(
                      '${p.userCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.purchasedUsers}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.totalUserCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(BuyButton(
                      label: 'Buy',
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      onPressed: () {
                        _buyAddon(users: 1);
                      },
                    )),
                  ]),
                  DataRow2(cells: [
                    DataCell(Text(
                      'Dashboards',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 14),
                    )),
                    DataCell(Text(
                      '${p.dashboardCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.purchasedDashboards}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.totalDashboardCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(BuyButton(
                      label: 'Buy',
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      onPressed: () {
                        _buyAddon(dashboards: 1);
                      },
                    )),
                  ]),
                  DataRow2(cells: [
                    DataCell(Text(
                      'Clients',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 14),
                    )),
                    DataCell(Text(
                      '${p.clientCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.purchasedClients}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.totalClientCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(BuyButton(
                      label: 'Buy',
                      onPressed: p.canBuyClientPlan!
                          ? () {
                              _buyAddon(clients: 1);
                            }
                          : null,
                    )),
                  ]),
                  DataRow2(cells: [
                    DataCell(Text(
                      'Device Libraries',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 14),
                    )),
                    DataCell(Text(
                      '${p.deviceModelCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.purchasedModels}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.totalDeviceModelCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(BuyButton(
                      label: 'Buy',
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      onPressed: () {
                        _buyAddon(models: 1);
                      },
                    )),
                  ]),
                  DataRow2(cells: [
                    DataCell(Text(
                      'Device Parameters',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 14),
                    )),
                    DataCell(Text(
                      '${p.modelParametersCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.purchasedParameters}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.totalModelParametersCount}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(BuyButton(
                      label: 'Buy',
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      onPressed: () {
                        _buyAddon(parameters: 1);
                      },
                    )),
                  ]),
                  DataRow2(cells: [
                    DataCell(Text(
                      'Archival',
                      style: BaseState.labelTextStyle.copyWith(fontSize: 14),
                    )),
                    DataCell(Text(
                      '${p.archivalYearsCount} year(s)',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.purchasedArchivals}',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(Text(
                      '${p.totalArchivalYearsCount} year(s)',
                      style: BaseState.labelTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    )),
                    DataCell(BuyButton(
                      label: 'Buy',
                      onPressed: p.canBuyArchivalPlan!
                          ? () {
                              _buyAddon(archivals: 1);
                            }
                          : null,
                    )),
                  ]),
                ]),
          ),
        ],
      ),
    );
  }

  void _buyAddon(
      {int dataPoints = 0,
      int devices = 0,
      int users = 0,
      int dashboards = 0,
      int clients = 0,
      int models = 0,
      int parameters = 0,
      int archivals = 0}) async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            content: PurchaseChangeAddonWidget(
                orgId: TwinnedSession.instance.noCodeAuthToken,
                purchase: true,
                archivals: archivals,
                clients: clients,
                devices: devices,
                dashboards: dashboards,
                dataPoints: dataPoints,
                deviceModels: models,
                parameters: parameters,
                users: users),
          );
        });
    _load();
  }

  Widget _buildUsage() {
    if (null == usage) {
      return const SizedBox.shrink();
    }

    tapi.Usage u = usage!;

    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Utilization',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Data Points',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    divider(),
                    Tooltip(
                      message: '${u.usedDataPoints} / ${u.availableDataPoints}',
                      child: SfLinearGauge(
                        orientation: LinearGaugeOrientation.vertical,
                        maximum: u.availableDataPoints.toDouble(),
                        ranges: [
                          LinearGaugeRange(
                            startValue: 0,
                            endValue: u.usedDataPoints.toDouble(),
                          ),
                        ],
                        markerPointers: [
                          LinearShapePointer(
                            value: u.usedDataPoints.toDouble(),
                          ),
                        ],
                        barPointers: [
                          LinearBarPointer(
                              value: u.availableDataPoints.toDouble())
                        ],
                      ),
                    ),
                  ],
                ),
                if (u.availablePooledDataPoints > 0)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pooled Data Points',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      divider(),
                      Tooltip(
                        message:
                            '${u.usedPooledDataPoints} / ${u.availablePooledDataPoints}',
                        child: SfLinearGauge(
                          maximum: u.availablePooledDataPoints.toDouble(),
                          ranges: [
                            LinearGaugeRange(
                              startValue: 0,
                              endValue: u.usedPooledDataPoints.toDouble(),
                            ),
                          ],
                          markerPointers: [
                            LinearShapePointer(
                              value: u.usedPooledDataPoints.toDouble(),
                            ),
                          ],
                          barPointers: [
                            LinearBarPointer(
                                value: u.availablePooledDataPoints.toDouble())
                          ],
                        ),
                      ),
                    ],
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Devices',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    divider(),
                    Tooltip(
                      message: '${u.usedDevices} / ${u.availableDevices}',
                      child: SfLinearGauge(
                        maximum: u.availableDevices.toDouble(),
                        orientation: LinearGaugeOrientation.vertical,
                        ranges: [
                          LinearGaugeRange(
                            startValue: 0,
                            endValue: u.usedDevices.toDouble(),
                          ),
                        ],
                        markerPointers: [
                          LinearShapePointer(
                            value: u.usedDevices.toDouble(),
                          ),
                        ],
                        barPointers: [
                          LinearBarPointer(value: u.availableDevices.toDouble())
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Users',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    divider(),
                    Tooltip(
                      message: '${u.usedUsers} / ${u.availableUsers}',
                      child: SfLinearGauge(
                        maximum: u.availableUsers.toDouble(),
                        orientation: LinearGaugeOrientation.vertical,
                        ranges: [
                          LinearGaugeRange(
                            startValue: 0,
                            endValue: u.usedUsers.toDouble(),
                          ),
                        ],
                        markerPointers: [
                          LinearShapePointer(
                            value: u.usedUsers.toDouble(),
                          ),
                        ],
                        barPointers: [
                          LinearBarPointer(value: u.availableUsers.toDouble())
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Clients',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    divider(),
                    Tooltip(
                      message: '${u.usedClients} / ${u.availableClients}',
                      child: SfLinearGauge(
                        maximum: u.availableClients.toDouble(),
                        orientation: LinearGaugeOrientation.vertical,
                        ranges: [
                          LinearGaugeRange(
                            startValue: 0,
                            endValue: u.usedClients.toDouble(),
                          ),
                        ],
                        markerPointers: [
                          LinearShapePointer(
                            value: u.usedClients.toDouble(),
                          ),
                        ],
                        barPointers: [
                          LinearBarPointer(value: u.availableClients.toDouble())
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Dashboards',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    divider(),
                    Tooltip(
                      message: '${u.usedDashboards} / ${u.availableDashboards}',
                      child: SfLinearGauge(
                        maximum: u.availableDashboards.toDouble(),
                        orientation: LinearGaugeOrientation.vertical,
                        ranges: [
                          LinearGaugeRange(
                            startValue: 0,
                            endValue: u.usedDashboards.toDouble(),
                          ),
                        ],
                        markerPointers: [
                          LinearShapePointer(
                            value: u.usedDashboards.toDouble(),
                          ),
                        ],
                        barPointers: [
                          LinearBarPointer(
                              value: u.availableDashboards.toDouble())
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Device Libraries',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    divider(),
                    Tooltip(
                      message:
                          '${u.usedDeviceModels} / ${u.availableDeviceModels}',
                      child: SfLinearGauge(
                        maximum: u.availableDeviceModels!.toDouble(),
                        orientation: LinearGaugeOrientation.vertical,
                        ranges: [
                          LinearGaugeRange(
                            startValue: 0,
                            endValue: u.usedDeviceModels.toDouble(),
                          ),
                        ],
                        markerPointers: [
                          LinearShapePointer(
                            value: u.usedDeviceModels.toDouble(),
                          ),
                        ],
                        barPointers: [
                          LinearBarPointer(
                              value: u.availableDeviceModels!.toDouble())
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const BusyIndicator(),
                divider(horizontal: true),
                IconButton(
                    onPressed: () {
                      _load();
                    },
                    icon: const Icon(Icons.refresh)),
                divider(horizontal: true),
              ],
            ),
            divider(),
            Expanded(
                child: Row(
              children: [
                Expanded(flex: 60, child: _buildUsage()),
                divider(horizontal: true),
                Expanded(flex: 40, child: _buildPlan()),
              ],
            )),
          ],
        ));
  }

  void _load() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var res = await TwinnedSession.instance.twin
          .getPlan(apikey: TwinnedSession.instance.authToken);
      if (validateResponse(res)) {
        refresh(sync: () {
          orgPlan = res.body!.entity!;
        });
      }
    });

    await execute(() async {
      var res = await TwinnedSession.instance.twin
          .getUsage(apikey: TwinnedSession.instance.authToken);
      if (validateResponse(res)) {
        refresh(sync: () {
          usage = res.body!.entity!;
        });
      }
    });

    loading = false;
  }

  @override
  void setup() {
    _load();
  }
}
