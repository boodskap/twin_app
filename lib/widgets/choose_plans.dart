import 'package:flutter/material.dart';
import 'package:nocode_api/api/nocode.swagger.dart' as nocode;
import 'package:toggle_switch/toggle_switch.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/plan_info_widget.dart';
import 'package:twin_app/widgets/utils.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';

class ChoosePlansPage extends StatefulWidget {
  final String orgId;
  const ChoosePlansPage({super.key, required this.orgId});

  @override
  State<ChoosePlansPage> createState() => _ChoosePlansPageState();
}

class _ChoosePlansPageState extends BaseState<ChoosePlansPage> {
  static TextStyle toggleStyle =
      theme.getStyle().copyWith(fontSize: 14, fontWeight: FontWeight.bold);

  nocode.OrgPlan? _orgPlan;
  final List<nocode.Plan> _plans = [];
  final List<nocode.PlanCurrency> _currencies = [];

  int _currencyIndex = 0;
  int _frequencyIndex = 0;
  String _currency = 'USD';
  String _frequency = 'Y';

  @override
  void initState() {
    super.initState();
  }

  Future _switchCurrency(int index) async {
    setState(() {
      _currencyIndex = index;
      _currency = _currencies[index].currency;
    });
    _load();
  }

  Future _switchFrequency(int index) async {
    setState(() {
      _frequencyIndex = index;
      _frequency = index == 0 ? 'Y' : 'M';
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_circle_left)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const BusyIndicator(),
                  divider(horizontal: true),
                  if (_currencies.isNotEmpty)
                    ToggleSwitch(
                      initialLabelIndex: _currencyIndex,
                      totalSwitches: _currencies.length,
                      activeBgColor: const [Colors.blueAccent],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.black12,
                      inactiveFgColor: Colors.grey[900],
                      customTextStyles: List.generate(
                          _currencies.length, (idx) => toggleStyle),
                      labels: List.generate(
                          _currencies.length,
                          (idx) =>
                              '${currencyToSymbol(_currencies[idx].currency!)} ${_currencies[idx].currency == currencyToSymbol(_currencies[idx].currency!) ? '' : _currencies[idx].currency}'),
                      onToggle: (index) {
                        _switchCurrency(index!);
                      },
                    ),
                  divider(horizontal: true),
                  ToggleSwitch(
                    initialLabelIndex: _frequencyIndex,
                    totalSwitches: 2,
                    activeBgColor: const [Colors.blueAccent],
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.black12,
                    inactiveFgColor: Colors.grey[900],
                    customTextStyles: [toggleStyle, toggleStyle],
                    labels: const ['Yearly', 'Monthly'],
                    onToggle: (index) {
                      _switchFrequency(index!);
                    },
                  ),
                ],
              ),
            ],
          ),
          if (_plans.isEmpty) const Icon(Icons.hourglass_bottom),
          if (_plans.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _plans
                  .map((p) => PlanInfoWidget(
                        plan: p,
                        orgPlan: _orgPlan!,
                        onPlanChanged: () {
                          _orgPlan = null;
                          _load();
                        },
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _plans.clear();

    await execute(() async {
      if (null == _orgPlan) {
        var pRes = await TwinnedSession.instance.nocode
            .getOrgPlan(orgId: widget.orgId);
        if (validateResponse(pRes)) {
          _orgPlan = pRes.body!.entity!;
          _currency = _orgPlan!.currency;
          _frequency = _orgPlan!.planFrequency ?? 'Y';
          _frequencyIndex = ('Y' == _frequency) ? 0 : 1;
          _currencyIndex = 'INR' == _currency ? 0 : 1;
        }
      }

      if (_currencies.isEmpty) {
        var res = await TwinnedSession.instance.nocode.listCurrencies();
        if (validateResponse(res)) {
          int idx = 0;
          for (nocode.PlanCurrency pc in res.body!.currencies!) {
            _currencies.add(pc);
            //_symbols.add(currencySymbolToString(pc.symbol!));
            ++idx;
          }
        }
      }

      for (String id in ['BASIC', 'STANDARD', 'PROFESSIONAL', 'ENTERPRISE']) {
        var res = await TwinnedSession.instance.nocode.getPlan(
            planId: id, planFrequency: _frequency, currency: _currency);
        if (validateResponse(res)) {
          _plans.add(res.body!.entity!);
        }
      }
    });

    loading = false;

    refresh();
  }

  @override
  void setup() {
    _load();
  }
}
