import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/buy_button.dart';
import 'package:twin_app/widgets/utils.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:chopper/src/response.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nocode_api/api/nocode.swagger.dart' as nocode;

class PurchaseChangeAddonWidget extends StatefulWidget {
  final String orgId;
  final bool purchase;
  final int devices;
  final int dataPoints;
  final int users;
  final int dashboards;
  final int clients;
  final int deviceModels;
  final int parameters;
  final int archivals;

  const PurchaseChangeAddonWidget(
      {super.key,
      required this.orgId,
      this.purchase = true,
      this.devices = 0,
      this.dataPoints = 0,
      this.users = 0,
      this.dashboards = 0,
      this.clients = 0,
      this.deviceModels = 0,
      this.parameters = 0,
      this.archivals = 0});

  @override
  State<PurchaseChangeAddonWidget> createState() =>
      _PurchaseChangeAddonWidgetState();
}

class _PurchaseChangeAddonWidgetState
    extends BaseState<PurchaseChangeAddonWidget> {
  static TextStyle headerStyle =
      theme.getStyle().copyWith(fontSize: 22, fontWeight: FontWeight.bold);
  static TextStyle tableHeaderStyle =
      theme.getStyle().copyWith(fontSize: 16, fontWeight: FontWeight.bold);
  static TextStyle tableRowStyle =
      theme.getStyle().copyWith(fontSize: 16, fontWeight: FontWeight.normal);
  static TextStyle priceRowStyle =
      theme.getStyle().copyWith(fontSize: 16, fontWeight: FontWeight.bold);
  static TextStyle totalPriceStyle =
      theme.getStyle().copyWith(fontSize: 20, fontWeight: FontWeight.bold);

  nocode.OrgPlan? _orgPlan;
  nocode.Plan? _plan;
  late nocode.OrderInfo _order;
  int deviceCount = 0;
  int userCount = 0;
  int dashboardCount = 0;
  int modelCount = 0;
  int parameterCount = 0;
  int dataPointsCount = 0;
  int clientCount = 0;
  int archivalCount = 0;
  double deviceTotal = 0;
  double userTotal = 0;
  double dashboardTotal = 0;
  double modelTotal = 0;
  double parameterTotal = 0;
  double dataPointsTotal = 0;
  double clientTotal = 0;
  double archivalTotal = 0;
  double total = 0;

  @override
  void initState() {
    super.initState();

    _order = nocode.OrderInfo(orgId: widget.orgId);

    deviceCount = widget.devices;
    userCount = widget.users;
    dashboardCount = widget.dashboards;
    modelCount = widget.deviceModels;
    parameterCount = widget.parameters;
    dataPointsCount = widget.dataPoints;
    clientCount = widget.clients;
    archivalCount = widget.archivals;
  }

  void _computeTotal() {
    refresh(sync: () {
      deviceTotal = deviceCount.toDouble() * _plan!.extraDeviceFee;
      userTotal = userCount.toDouble() * _plan!.extraUserFee;
      dashboardTotal = dashboardCount.toDouble() * _plan!.extraDashboardFee;
      modelTotal = modelCount.toDouble() * _plan!.extraDeviceModelFee;
      parameterTotal =
          parameterCount.toDouble() * _plan!.extraModelParametersFee;
      dataPointsTotal = dataPointsCount.toDouble() * _plan!.extraDataPointsFee;
      clientTotal = clientCount.toDouble() * _plan!.extraClientFee;
      archivalTotal = archivalCount.toDouble() * _plan!.extraArchivalFee;

      total = deviceTotal +
          userTotal +
          dashboardTotal +
          modelTotal +
          parameterTotal +
          dataPointsTotal +
          clientTotal +
          archivalTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: 600,
        height: 650,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Purchase AddOns',
                  style: headerStyle,
                ),
              ],
            ),
            divider(height: 25),
            if (null == _orgPlan || null == _plan)
              const Center(child: Icon(Icons.hourglass_bottom)),
            if (null != _orgPlan && null != _plan)
              SizedBox(
                height: 500,
                child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 600,
                    columns: [
                      DataColumn2(
                        label: Text(
                          'Add On',
                          style: tableHeaderStyle,
                        ),
                      ),
                      DataColumn2(
                        label: Text(
                          'Quantity',
                          style: tableHeaderStyle,
                        ),
                      ),
                      DataColumn2(
                        fixedWidth: 75,
                        label: Text(
                          'Price',
                          style: tableHeaderStyle,
                        ),
                      ),
                      DataColumn2(
                        numeric: true,
                        label: Text(
                          'Units',
                          style: tableHeaderStyle,
                        ),
                      ),
                      DataColumn2(
                        //fixedWidth: 75,
                        numeric: true,
                        label: Text(
                          'Amount',
                          style: tableHeaderStyle,
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text(
                          'Devices',
                          style: tableRowStyle,
                        )),
                        DataCell(InputQty(
                          maxVal: 1000000,
                          initVal: deviceCount,
                          minVal: 0,
                          steps: 1,
                          onQtyChanged: (val) {
                            deviceCount = val;
                            _computeTotal();
                          },
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} ${_plan!.extraDeviceFee}',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '1',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} $deviceTotal',
                          style: priceRowStyle,
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Users',
                          style: tableRowStyle,
                        )),
                        DataCell(InputQty(
                          maxVal: 1000000,
                          initVal: widget.users,
                          minVal: 0,
                          steps: 1,
                          onQtyChanged: (val) {
                            userCount = val;
                            _computeTotal();
                          },
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} ${_plan!.extraUserFee}',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '1',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} $userTotal',
                          style: priceRowStyle,
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Dashboards',
                          style: tableRowStyle,
                        )),
                        DataCell(InputQty(
                          maxVal: 1000000,
                          initVal: widget.dashboards,
                          minVal: 0,
                          steps: 1,
                          onQtyChanged: (val) {
                            dashboardCount = val;
                            _computeTotal();
                          },
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} ${_plan!.extraDashboardFee}',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '10',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} $dashboardTotal',
                          style: priceRowStyle,
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Device Libraries',
                          style: tableRowStyle,
                        )),
                        DataCell(InputQty(
                          maxVal: 1000000,
                          initVal: widget.deviceModels,
                          minVal: 0,
                          steps: 1,
                          onQtyChanged: (val) {
                            modelCount = val;
                            _computeTotal();
                          },
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} ${_plan!.extraDeviceModelFee}',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '10',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} $modelTotal',
                          style: priceRowStyle,
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Device Parameters',
                          style: tableRowStyle,
                        )),
                        DataCell(InputQty(
                          maxVal: 1000000,
                          initVal: widget.parameters,
                          minVal: 0,
                          steps: 1,
                          onQtyChanged: (val) {
                            parameterCount = val;
                            _computeTotal();
                          },
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} ${_plan!.extraModelParametersFee}',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '10',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} $parameterTotal',
                          style: priceRowStyle,
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Data Points)',
                            style: tableRowStyle.copyWith(
                              decoration: !_orgPlan!.canBuyDataPlan!
                                  ? TextDecoration.lineThrough
                                  : null,
                            ))),
                        if (!(_orgPlan?.canBuyDataPlan ?? false))
                          DataCell(Text(
                            '-',
                            style: tableRowStyle,
                          )),
                        if ((_orgPlan?.canBuyDataPlan ?? true))
                          DataCell(InputQty(
                            maxVal: 1000000,
                            initVal: widget.dataPoints,
                            minVal: 0,
                            steps: 1,
                            onQtyChanged: (val) {
                              dataPointsCount = val;
                              _computeTotal();
                            },
                          )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} ${_plan!.extraDataPointsFee}',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '50,000',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} $dataPointsTotal',
                          style: priceRowStyle,
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Sub Account (Clients)',
                            style: tableRowStyle.copyWith(
                              decoration: !_orgPlan!.canBuyClientPlan!
                                  ? TextDecoration.lineThrough
                                  : null,
                            ))),
                        if (!(_orgPlan?.canBuyClientPlan ?? false))
                          DataCell(Text(
                            '-',
                            style: tableRowStyle,
                          )),
                        if ((_orgPlan?.canBuyClientPlan ?? true))
                          DataCell(InputQty(
                            maxVal: 1000000,
                            initVal: widget.clients,
                            minVal: 0,
                            steps: 1,
                            onQtyChanged: (val) {
                              clientCount = val;
                              _computeTotal();
                            },
                          )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} ${_plan!.extraClientFee}',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '1',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} $clientTotal',
                          style: priceRowStyle,
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Extended Archival',
                            style: tableRowStyle.copyWith(
                              decoration: !_orgPlan!.canBuyArchivalPlan!
                                  ? TextDecoration.lineThrough
                                  : null,
                            ))),
                        if (!(_orgPlan?.canBuyArchivalPlan ?? false))
                          DataCell(Text(
                            '-',
                            style: tableRowStyle,
                          )),
                        if ((_orgPlan?.canBuyArchivalPlan ?? true))
                          DataCell(InputQty(
                            maxVal: 99,
                            initVal: widget.archivals,
                            minVal: 0,
                            steps: 1,
                            onQtyChanged: (val) {
                              archivalCount = val;
                              _computeTotal();
                            },
                          )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} ${_plan!.extraArchivalFee}',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '1 Year',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} $archivalTotal',
                          style: priceRowStyle,
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          '',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          'Total / Month',
                          style: tableRowStyle,
                        )),
                        DataCell(Text(
                          '${currencyToSymbol(_plan!.currency)} $total',
                          style: priceRowStyle,
                        )),
                      ]),
                    ]),
              ),
            divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const BusyIndicator(),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'CANCEL',
                      style: theme.getStyle().copyWith(fontSize: 16),
                    )),
                divider(horizontal: true),
                if (null != _plan)
                  BuyButton(
                    label: 'BUY',
                    style: theme.getStyle().copyWith(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                    onPressed: total <= 0
                        ? null
                        : () async {
                            await _buy();
                          },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Response<nocode.OrderEntityRes>> _createOrder() {
    return TwinnedSession.instance.nocode.createNewOrder(
        token: TwinnedSession.instance.noCodeAuthToken,
        body: nocode.OrderInfo(
          orgId: widget.orgId,
          archivalCount: archivalCount,
          clientCount: clientCount,
          dashboardCount: dashboardCount,
          dataCount: dataPointsCount,
          deviceCount: deviceCount,
          modelCount: modelCount,
          parameterCount: parameterCount,
          userCount: userCount,
        ));
  }

  Future<Response<nocode.OrderEntityRes>> _createSecret(nocode.Order order) {
    return TwinnedSession.instance.nocode.createStripePaymentSecret(
        token: TwinnedSession.instance.noCodeAuthToken,
        body: nocode.StripePaymentSecretArgs(
          orgId: order.orgId,
          orderId: order.id,
        ));
  }

  Future _buy() async {
    if (loading) return;
    loading = true;

    bool orderCreated = false;
    bool secretGenerated = false;

    await execute(() async {
      // 1) CREATE ORDER
      var oRes = await _createOrder();
      nocode.Order? order;

      if (validateResponse(oRes)) {
        orderCreated = true;
        order = oRes.body!.entity!;
      }

      // 2) CREATE SECRET
      if (orderCreated) {
        oRes = await _createSecret(order!);
        if (validateResponse(oRes)) {
          secretGenerated = true;
          order = oRes.body!.entity!;
        }
      }

      if (secretGenerated) {
        await launchUrl(Uri.parse(order!.paymentUrl!));
      }
    });

    _close();

    loading = false;
  }

  void _close() {
    Navigator.pop(context);
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    bool orgPlanLoaded = false;
    bool planLoaded = false;

    await execute(() async {
      var oRes =
          await TwinnedSession.instance.nocode.getOrgPlan(orgId: widget.orgId);
      if (validateResponse(oRes)) {
        _orgPlan = oRes.body!.entity;
        orgPlanLoaded = true;
      }

      if (!orgPlanLoaded) return;

      var pRes = await TwinnedSession.instance.nocode
          .getPlanById(planId: _orgPlan!.planId);
      if (validateResponse(pRes)) {
        _plan = pRes.body!.entity;
        planLoaded = true;
      }

      if (!planLoaded) return;

      _computeTotal();
    });

    loading = false;

    refresh();
  }

  @override
  void setup() {
    _load();
  }
}
