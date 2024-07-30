import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twin_app/pages/twin/components/widgets/condition_model.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'dart:convert';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/asset_groups.dart';
import 'package:twin_app/pages/twin/components/widgets/event_content_page.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/core/device_model_dropdown.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twinned_widgets/core/top_bar.dart';
import'package:uuid/uuid.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:dropdown_search/dropdown_search.dart';



typedef OnMatchGroupSave = void Function(twin.MatchGroup group, int index);
typedef OnMatchGroupDelete = void Function(int index);

final TextStyle _style = GoogleFonts.acme(
    color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);

class MatchGroupWidget extends StatefulWidget {
  final int index;
  final twin.Event event;
  final twin.DeviceModel deviceModel;
  final OnMatchGroupSave onSave;
  final OnMatchGroupDelete onDelete;
  final String title;
  MatchGroupWidget({
    super.key,
    this.title = 'Conditions',
    required this.event,
    required this.deviceModel,
    required this.index,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<MatchGroupWidget> createState() => _MatchGroupWidgetState();
}

class _MatchGroupWidgetState extends BaseState<MatchGroupWidget> {
 ConditionModel? _selectedModel;
  final List<twin.Condition> _conditions = [];
  final List<DropdownMenuItem<twin.MatchGroupMatchType>> _matchTypeItems = [];
  twin.MatchGroupMatchType? _selectedMatchType = twin.MatchGroupMatchType.any;

  @override
  void initState() {
    super.initState();
    _matchTypeItems.add(const DropdownMenuItem<twin.MatchGroupMatchType>(
      value: twin.MatchGroupMatchType.any,
      child: Text('Match Any'),
    ));
    _matchTypeItems.add(const DropdownMenuItem<twin.MatchGroupMatchType>(
      value: twin.MatchGroupMatchType.all,
      child: Text('Match All'),
    ));
  }

  @override
  void setup() async {
    var g = widget.event.conditions[widget.index];
    _selectedMatchType = g.matchType;

    if (g.conditions.isNotEmpty) {
      var res = await TwinnedSession.instance.twin.getConditions(
          apikey: TwinnedSession.instance.authToken,
          body: twin.GetReq(ids: g.conditions));

      if (validateResponse(res)) {
        _conditions.addAll(res.body!.values!);
      }
    }
    refresh();
  }

  void _save() {
    List<String> conditions = [];
    for (var cond in _conditions) {
      conditions.add(cond.id);
    }
    twin.MatchGroup group =
        twin.MatchGroup(matchType: _selectedMatchType!, conditions: conditions);

    widget.onSave(group, widget.index);
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    const SizedBox vdivider = SizedBox(
      height: 8,
    );

    return Card(
      color: Colors.transparent,
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(15))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: _style,
            ),
            vdivider,
            Row(
              children: [
                DropdownButton<twin.MatchGroupMatchType>(
                    value: _selectedMatchType,
                    items: _matchTypeItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedMatchType = value;
                      });
                    }),
                Expanded(
                  child: DropdownSearch<ConditionModel>(
                    onChanged: (selected) {
                      setState(() {
                        _selectedModel = selected;
                      });
                    },
                    asyncItems: (String filter) async {
                      List<ConditionModel> list = [];
                      var res = await TwinnedSession.instance.twin.searchConditions(
                          apikey: TwinnedSession.instance.authToken,
                          modelId: widget.deviceModel.id,
                          body: twin.SearchReq(
                              search: filter, page: 0, size: 10000));
                      if (res.body!.ok) {
                        for (var condition in res.body!.values!) {
                          list.add(ConditionModel(condition: condition));
                        }
                      }
                      return list;
                    },
                  ),
                ),
                if (null != _selectedModel)
                  IconButton(
                    onPressed: () {
                      if (_conditions.contains(_selectedModel!.condition)) {
                        return;
                      }
                      _conditions.add(_selectedModel!.condition);
                      _save();
                    },
                    icon: Icon(Icons.add),
                  ),
              ],
            ),
            vdivider,
            SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 150,
                child: ListView.builder(
                    itemCount: _conditions.length,
                    itemBuilder: (ctx, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Chip(
                          onDeleted: () {
                            setState(() {
                              _conditions.removeAt(index);
                            });
                            _save();
                          },
                          label: Text(
                            ConditionModel.explain(_conditions[index]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
