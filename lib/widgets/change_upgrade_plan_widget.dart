import 'package:chopper/src/response.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/widgets/plan_info_widget.dart';
import 'package:twin_app/widgets/utils.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:nocode_api/api/nocode.swagger.dart' as nocode;
import 'dart:js' as js;


class ChangeUpgradePlanWidget extends StatefulWidget {
  final nocode.Plan plan;
  final nocode.OrgPlan orgPlan;
  final bool upgrade;
  final OnPlanChanged onPlanChanged;

  const ChangeUpgradePlanWidget({
    super.key,
    required this.plan,
    required this.orgPlan,
    required this.upgrade,
    required this.onPlanChanged,
  });

  @override
  State<ChangeUpgradePlanWidget> createState() =>
      _ChangeUpgradePlanWidgetState();
}

class _ChangeUpgradePlanWidgetState extends BaseState<ChangeUpgradePlanWidget> {
  static const TextStyle freqencyStyle = TextStyle(
      color: Colors.black38, fontSize: 14, fontWeight: FontWeight.bold);
  static const TextStyle currencyStyle = TextStyle(
      color: Colors.black45, fontSize: 14, fontWeight: FontWeight.bold);
  static const TextStyle planStyle = TextStyle(
      color: Colors.black38, fontSize: 14, fontWeight: FontWeight.bold);
  static const TextStyle buttonStyle =
      TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold);
  static const TextStyle headerStyle = TextStyle(
      color: Color(0xFF287FFF), fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle featureStyle =
      TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);
  static const TextStyle addOnStyle = TextStyle(
      color: Colors.black45, fontSize: 14, fontWeight: FontWeight.bold);

  void _close() {
    Navigator.pop(context);
  }

  Future<bool?> _changePlan(
      {required String orgId, required String planId, String? orderId}) async {
    if (loading) return false;
    loading = true;
    bool changed = false;
    await execute(() async {
      var res = await TwinnedSession.instance.nocode.createOrUpdateOrgPlan(
          token: TwinnedSession.instance.noCodeAuthToken,
          body: nocode.PlanChangeRequest(
              orgId: orgId, planId: planId, orderId: orderId));
      if (validateResponse(res)) {
        changed = true;
        _close();
        alert('Success', 'Plan changed successfully');
        widget.onPlanChanged();
      }
    });
    loading = false;
    return changed;
  }

  Future<Response<nocode.OrderEntityRes>> _createOrder() {
    return TwinnedSession.instance.nocode.createNewOrder(
        token: TwinnedSession.instance.noCodeAuthToken,
        body: nocode.OrderInfo(
          orgId: widget.orgPlan.orgId,
          planId: widget.plan.id,
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

  Future _upgradePlan() async {
    if (loading) return;
    loading = true;

    bool orderCreated = false;
    bool secretGenerated = false;
    bool paymentDone = false;
    bool paymentSet = false;
    bool planUpgraded = false;

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
        js.context.callMethod('open', [order!.paymentUrl!]);
      }
    });

    _close();

    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 700,
      //height: 500,
      child: IntrinsicHeight(
        child: Card(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  divider(height: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.plan.planType!.value!} PLAN (${widget.plan.currency})',
                        style: headerStyle,
                      ),
                      divider(height: 25),
                      Text(
                        widget.plan.planFrequency == nocode.PlanPlanFrequency.m
                            ? 'MONTHLY'
                            : 'YEARLY',
                        style: headerStyle,
                      ),
                    ],
                  ),
                  divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        spacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'PRICE',
                            style: headerStyle,
                          ),
                          Text(
                            '${currencyToSymbol(widget.plan.currency!)} ${widget.upgrade ? widget.plan.planFee : 0.0}',
                            style: headerStyle.copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  divider(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Features',
                              style: featureStyle.copyWith(
                                  fontWeight: FontWeight.normal),
                            ),
                            divider(),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${widget.plan.defaultDataPointsCount} Data Points',
                                  style: featureStyle,
                                ),
                              ],
                            ),
                            divider(height: 2),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${widget.plan.defaultUserCount} Users',
                                  style: featureStyle,
                                ),
                              ],
                            ),
                            divider(height: 2),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${widget.plan.defaultDashboardCount} Dashboards',
                                  style: featureStyle,
                                ),
                              ],
                            ),
                            divider(height: 2),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${widget.plan.defaultClientCount} Sub Accounts (Clients)',
                                  style: featureStyle,
                                ),
                              ],
                            ),
                            divider(height: 2),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${widget.plan.defaultDeviceModelCount} Device Libraries',
                                  style: featureStyle,
                                ),
                              ],
                            ),
                            divider(height: 2),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${widget.plan.defaultModelParametersCount} Device Parameters',
                                  style: featureStyle,
                                ),
                              ],
                            ),
                            divider(height: 2),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  'History data archival after ${widget.plan.defaultArchivalYears} years',
                                  style: featureStyle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Ons',
                              style: featureStyle.copyWith(
                                  fontWeight: FontWeight.normal),
                            ),
                            divider(),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${currencyToSymbol(widget.plan.currency)}${widget.plan.extraDataPointsFee}',
                                  style: featureStyle.copyWith(
                                    decoration: widget.plan.planType ==
                                            nocode.PlanPlanType.basic
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  '/ 50000 data points',
                                  style: addOnStyle.copyWith(
                                    decoration: widget.plan.planType ==
                                            nocode.PlanPlanType.basic
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  '/ month',
                                  style: planStyle.copyWith(
                                    decoration: widget.plan.planType ==
                                            nocode.PlanPlanType.basic
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${currencyToSymbol(widget.plan.currency)}${widget.plan.extraUserFee}',
                                  style: featureStyle,
                                ),
                                const Text(
                                  '/ user',
                                  style: addOnStyle,
                                ),
                                const Text(
                                  '/ month',
                                  style: planStyle,
                                ),
                              ],
                            ),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${currencyToSymbol(widget.plan.currency)}${widget.plan.extraDashboardFee}',
                                  style: featureStyle,
                                ),
                                const Text(
                                  '/ 10 dashboards',
                                  style: addOnStyle,
                                ),
                                const Text(
                                  '/ month',
                                  style: planStyle,
                                ),
                              ],
                            ),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${currencyToSymbol(widget.plan.currency)}${widget.plan.extraDeviceModelFee}',
                                  style: featureStyle,
                                ),
                                const Text(
                                  '/ 10 device libraries',
                                  style: addOnStyle,
                                ),
                                const Text(
                                  '/ month',
                                  style: planStyle,
                                ),
                              ],
                            ),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${currencyToSymbol(widget.plan.currency)}${widget.plan.extraModelParametersFee}',
                                  style: featureStyle,
                                ),
                                const Text(
                                  '/ 10 device parameters',
                                  style: addOnStyle,
                                ),
                                const Text(
                                  '/ month',
                                  style: planStyle,
                                ),
                              ],
                            ),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${currencyToSymbol(widget.plan.currency)}${widget.plan.extraClientFee}',
                                  style: featureStyle.copyWith(
                                    decoration: widget.plan.planType ==
                                            nocode.PlanPlanType.basic
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  '/ sub account (client)',
                                  style: addOnStyle.copyWith(
                                    decoration: widget.plan.planType ==
                                            nocode.PlanPlanType.basic
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  '/ month',
                                  style: planStyle.copyWith(
                                    decoration: widget.plan.planType ==
                                            nocode.PlanPlanType.basic
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Icon(
                                  Icons.add_circle,
                                  color: headerStyle.color,
                                  size: 12,
                                ),
                                Text(
                                  '${currencyToSymbol(widget.plan.currency)}${widget.plan.extraArchivalFee}',
                                  style: featureStyle.copyWith(
                                    decoration: widget.plan.planType ==
                                                nocode.PlanPlanType.basic ||
                                            widget.plan.planType ==
                                                nocode.PlanPlanType.standard
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  '/ 1 year extended data archival',
                                  style: addOnStyle.copyWith(
                                    decoration: widget.plan.planType ==
                                                nocode.PlanPlanType.basic ||
                                            widget.plan.planType ==
                                                nocode.PlanPlanType.standard
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  '/ month',
                                  style: planStyle.copyWith(
                                    decoration: widget.plan.planType ==
                                                nocode.PlanPlanType.basic ||
                                            widget.plan.planType ==
                                                nocode.PlanPlanType.standard
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const BusyIndicator(),
                      divider(horizontal: true),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'CANCEL',
                            style: buttonStyle.copyWith(color: Colors.black),
                          )),
                      divider(horizontal: true),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent),
                          onPressed: () async {
                            if (widget.upgrade) {
                              await _upgradePlan();
                            } else {
                              await _changePlan(
                                  orgId: widget.orgPlan.orgId,
                                  planId: widget.plan.id);
                            }
                          },
                          child: Text(
                            widget.upgrade ? 'UPGRADE' : 'CHANGE',
                            style: buttonStyle,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void setup() {}
}
