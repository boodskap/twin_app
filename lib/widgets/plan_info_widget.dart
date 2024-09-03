import 'package:flutter/material.dart';
import 'package:nocode_api/api/nocode.swagger.dart' as nocode;
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/buy_button.dart';
import 'package:twin_app/widgets/change_upgrade_plan_widget.dart';
import 'package:twin_app/widgets/choose_plans.dart';
import 'package:twin_app/widgets/utils.dart';
import 'package:twin_commons/core/base_state.dart';

typedef OnPlanChanged = void Function();

class PlanInfoWidget extends StatelessWidget {
  static TextStyle headerStyle = theme.getStyle().copyWith(
      color: Color(0xFF287FFF), fontSize: 20, fontWeight: FontWeight.bold);
  static TextStyle planStyle = theme.getStyle().copyWith(
      color: Colors.black38, fontSize: 14, fontWeight: FontWeight.bold);
  static TextStyle addOnStyle = theme.getStyle().copyWith(
      color: Colors.black45, fontSize: 14, fontWeight: FontWeight.bold);
  static TextStyle featureStyle = theme
      .getStyle()
      .copyWith(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

  final nocode.Plan plan;
  final nocode.OrgPlan orgPlan;
  final bool standalone;
  static final Map<String, int> _planWeights = {
    'BASIC': 0,
    'STANDARD': 1,
    'PROFESSIONAL': 2,
    'ENTERPRISE': 3
  };
  static final Map<String, int> _freqencyWeights = {
    'M': 0,
    'Y': 1,
  };

  final OnPlanChanged onPlanChanged;

  const PlanInfoWidget(
      {super.key,
      required this.plan,
      required this.orgPlan,
      this.standalone = false,
      required this.onPlanChanged});

  @override
  Widget build(BuildContext context) {
    bool isMyPlan = orgPlan.planId == plan.id;
    bool canChangePlan = !isMyPlan &&
        orgPlan.planType == plan.planType.value &&
        _freqencyWeights[plan.planFrequency.value]! >
            _freqencyWeights[orgPlan.planFrequency]!;
    if (!canChangePlan &&
        !isMyPlan &&
        orgPlan.planType == plan.planType.value &&
        orgPlan.currency != plan.currency) {
      canChangePlan = true;
    }
    bool canUpgradePlan = !isMyPlan &&
        !canChangePlan &&
        _planWeights[plan.planType.value]! > _planWeights[orgPlan.planType]!;

    String planName;

    switch (plan.planType) {
      case nocode.PlanPlanType.standard:
        planName = 'Standard';
        break;
      case nocode.PlanPlanType.professional:
        planName = 'Professional';
        break;
      case nocode.PlanPlanType.enterprise:
        planName = 'Enterprise';
        break;
      case nocode.PlanPlanType.basic:
        planName = 'Basic';
        break;
      case nocode.PlanPlanType.swaggerGeneratedUnknown:
      case nocode.PlanPlanType.custom:
      default:
        planName = 'Custom';
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
            color: isMyPlan
                ? Colors.green.withAlpha(100)
                : const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.black38)),
        child: SizedBox(
          width: (MediaQuery.of(context).size.width / 4) - 50,
          height: MediaQuery.of(context).size.height - 150,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                divider(height: 25),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    '${plan.name} PLAN',
                    style: headerStyle,
                  ),
                ),
                Center(
                    child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 4) - 75,
                        height: 130,
                        child: Card(
                          color: Colors.white,
                          elevation: 0,
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    direction: Axis.horizontal,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 10,
                                    children: [
                                      Text(
                                        '${currencyToSymbol(plan.currency)} ${plan.planFee}',
                                        style: headerStyle,
                                      ),
                                      Text(
                                        '/ month',
                                        style: planStyle,
                                      )
                                    ],
                                  ),
                                  divider(),
                                  Wrap(
                                    direction: Axis.horizontal,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 10,
                                    children: [
                                      Text(
                                        '${currencyToSymbol(plan.currency)} ${plan.extraDeviceFee}',
                                        style: headerStyle,
                                      ),
                                      Text(
                                        '/ device / month',
                                        style: planStyle,
                                      )
                                    ],
                                  ),
                                  divider(),
                                  Wrap(
                                    direction: Axis.horizontal,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 10,
                                    children: [
                                      Text(
                                        '${plan.defaultDevicesCount}',
                                        style: headerStyle,
                                      ),
                                      Text(
                                        'free device license included',
                                        style: planStyle,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ))),
                divider(height: 15),
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (canChangePlan)
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.withAlpha(100)),
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Align(
                                      alignment: Alignment.center,
                                      child: ChangeUpgradePlanWidget(
                                        plan: plan,
                                        orgPlan: orgPlan,
                                        upgrade: false,
                                        onPlanChanged: onPlanChanged,
                                      ),
                                    );
                                  });
                            },
                            child: Text(
                              'Change Plan',
                              style: headerStyle.copyWith(color: Colors.white),
                            )),
                      if (canUpgradePlan || standalone)
                        BuyButton(
                          onPressed: () {
                            if (standalone) {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    body: ChoosePlansPage(
                                      orgId: orgPlan.orgId,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Align(
                                      alignment: Alignment.center,
                                      child: ChangeUpgradePlanWidget(
                                        plan: plan,
                                        orgPlan: orgPlan,
                                        upgrade: true,
                                        onPlanChanged: onPlanChanged,
                                      ),
                                    );
                                  });
                            }
                          },
                          label:
                              standalone ? 'Upgrade' : 'Upgrade to $planName',
                          style: theme.getStyle().copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                          iconData: Icons.star,
                        ),
                    ],
                  ),
                ),
                divider(height: 15),
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
                            '${plan.defaultDataPointsCount} Data Points',
                            style: featureStyle,
                          ),
                          Text(
                            '/ device',
                            style: addOnStyle,
                          ),
                          Text(
                            '/ month',
                            style: planStyle,
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
                            '${plan.defaultUserCount} Users',
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
                            '${plan.defaultDashboardCount} Dashboards',
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
                            '${plan.defaultClientCount} Sub Accounts (Clients)',
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
                            '${plan.defaultDeviceModelCount} Device Libraries',
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
                            '${plan.defaultModelParametersCount} Device Parameters',
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
                            'History data archival after ${plan.defaultArchivalYears} years',
                            style: featureStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                divider(height: 25),
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
                            '${currencyToSymbol(plan.currency)} ${plan.extraDataPointsFee}',
                            style: featureStyle.copyWith(
                              decoration:
                                  plan.planType == nocode.PlanPlanType.basic
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          Text(
                            '/ 50000 data points',
                            style: addOnStyle.copyWith(
                              decoration:
                                  plan.planType == nocode.PlanPlanType.basic
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          Text(
                            '/ month',
                            style: planStyle.copyWith(
                              decoration:
                                  plan.planType == nocode.PlanPlanType.basic
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
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
                            Icons.add_circle,
                            color: headerStyle.color,
                            size: 12,
                          ),
                          Text(
                            '${currencyToSymbol(plan.currency)} ${plan.extraUserFee}',
                            style: featureStyle,
                          ),
                          Text(
                            '/ user',
                            style: addOnStyle,
                          ),
                          Text(
                            '/ month',
                            style: planStyle,
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
                            Icons.add_circle,
                            color: headerStyle.color,
                            size: 12,
                          ),
                          Text(
                            '${currencyToSymbol(plan.currency)} ${plan.extraDashboardFee}',
                            style: featureStyle,
                          ),
                          Text(
                            '/ 10 dashboards',
                            style: addOnStyle,
                          ),
                          Text(
                            '/ month',
                            style: planStyle,
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
                            Icons.add_circle,
                            color: headerStyle.color,
                            size: 12,
                          ),
                          Text(
                            '${currencyToSymbol(plan.currency)} ${plan.extraDeviceModelFee}',
                            style: featureStyle,
                          ),
                          Text(
                            '/ 10 device libraries',
                            style: addOnStyle,
                          ),
                          Text(
                            '/ month',
                            style: planStyle,
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
                            Icons.add_circle,
                            color: headerStyle.color,
                            size: 12,
                          ),
                          Text(
                            '${currencyToSymbol(plan.currency)} ${plan.extraModelParametersFee}',
                            style: featureStyle,
                          ),
                          Text(
                            '/ 10 device parameters',
                            style: addOnStyle,
                          ),
                          Text(
                            '/ month',
                            style: planStyle,
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
                            Icons.add_circle,
                            color: headerStyle.color,
                            size: 12,
                          ),
                          Text(
                            '${currencyToSymbol(plan.currency)} ${plan.extraClientFee}',
                            style: featureStyle.copyWith(
                              decoration:
                                  plan.planType == nocode.PlanPlanType.basic
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          Text(
                            '/ sub account (client)',
                            style: addOnStyle.copyWith(
                              decoration:
                                  plan.planType == nocode.PlanPlanType.basic
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          Text(
                            '/ month',
                            style: planStyle.copyWith(
                              decoration:
                                  plan.planType == nocode.PlanPlanType.basic
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
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
                            Icons.add_circle,
                            color: headerStyle.color,
                            size: 12,
                          ),
                          Text(
                            '${currencyToSymbol(plan.currency)} ${plan.extraArchivalFee}',
                            style: featureStyle.copyWith(
                              decoration:
                                  plan.planType == nocode.PlanPlanType.basic ||
                                          plan.planType ==
                                              nocode.PlanPlanType.standard
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          Text(
                            '/ 1 year extended data archival',
                            style: addOnStyle.copyWith(
                              decoration:
                                  plan.planType == nocode.PlanPlanType.basic ||
                                          plan.planType ==
                                              nocode.PlanPlanType.standard
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          Text(
                            '/ month',
                            style: planStyle.copyWith(
                              decoration:
                                  plan.planType == nocode.PlanPlanType.basic ||
                                          plan.planType ==
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
                divider(height: 25),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (plan.planType == nocode.PlanPlanType.basic ||
                          plan.planType == nocode.PlanPlanType.standard)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_rounded,
                              color: Colors.red,
                              size: 12,
                            ),
                            Text(
                              'No private cloud support',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      if (plan.planType != nocode.PlanPlanType.basic &&
                          plan.planType != nocode.PlanPlanType.standard)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              'Manage private cloud on AWS/Azure/GCP',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      if (plan.planType == nocode.PlanPlanType.basic ||
                          plan.planType == nocode.PlanPlanType.standard)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_rounded,
                              color: Colors.red,
                              size: 12,
                            ),
                            Text(
                              'Can not purchase extended archival days',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      if (plan.planType != nocode.PlanPlanType.basic &&
                          plan.planType != nocode.PlanPlanType.standard)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              'Can purchase extended archival days',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      if (plan.planType == nocode.PlanPlanType.basic)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_rounded,
                              color: Colors.red,
                              size: 12,
                            ),
                            Text(
                              'No White Labeling',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      if (plan.planType != nocode.PlanPlanType.basic)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              'White Labeling${plan.planType == nocode.PlanPlanType.standard ? '*' : ''}',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      if (plan.planType == nocode.PlanPlanType.basic)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_rounded,
                              color: Colors.red,
                              size: 12,
                            ),
                            Text(
                              'Can not purchase additional data plans',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      if (plan.planType != nocode.PlanPlanType.basic)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              'Can purchase additional data plans',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      if (plan.planType == nocode.PlanPlanType.basic)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_rounded,
                              color: Colors.red,
                              size: 12,
                            ),
                            Text(
                              'Can not purchase additional sub accounts',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      if (plan.planType != nocode.PlanPlanType.basic)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              'Can purchase additional sub accounts',
                              style: featureStyle,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                divider(height: 25),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support',
                        style: featureStyle.copyWith(
                            fontWeight: FontWeight.normal),
                      ),
                      divider(),
                      if (plan.planType == nocode.PlanPlanType.basic)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              'Self-service documentation',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      divider(height: 2),
                      if (plan.planType == nocode.PlanPlanType.standard)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              '8 X 5 support',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      divider(height: 2),
                      if (plan.planType == nocode.PlanPlanType.standard)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              '60 mins solution design call',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      divider(height: 2),
                      if (plan.planType == nocode.PlanPlanType.professional)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              '8 X 7 support',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      divider(height: 2),
                      if (plan.planType == nocode.PlanPlanType.professional)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              'Dedicated account manager',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      divider(height: 2),
                      if (plan.planType == nocode.PlanPlanType.professional)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              'Dedicated slack channel',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      divider(height: 2),
                      if (plan.planType == nocode.PlanPlanType.enterprise)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              '24 X 7 support*',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      divider(height: 2),
                      if (plan.planType == nocode.PlanPlanType.enterprise)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              'Dedicated account manager',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      divider(height: 2),
                      if (plan.planType == nocode.PlanPlanType.enterprise)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              'Dedicated slack channel',
                              style: featureStyle,
                            ),
                          ],
                        ),
                      divider(height: 2),
                      if (plan.planType == nocode.PlanPlanType.enterprise)
                        Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: headerStyle.color,
                              size: 12,
                            ),
                            Text(
                              'Dedicated phone line',
                              style: featureStyle,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                divider(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
