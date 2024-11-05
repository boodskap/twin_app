import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_app/widgets/create_edit_condition_snippet.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/core/device_model_dropdown.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_commons/widgets/common/label_text_field.dart';

class ConditionRules extends StatefulWidget {
  const ConditionRules({super.key});

  @override
  State<ConditionRules> createState() => _ConditionRulesState();
}

class _ConditionRulesState extends BaseState<ConditionRules> {
  final List<tapi.Condition> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';
  tapi.DeviceModel? _selectedDeviceModel;
  Set<String> _selectedModel = {};
  Map<String, String> _modelNames = {};
  Map<String, bool> _editable = Map<String, bool>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BusyIndicator(),
            IconButton(
                onPressed: () {
                  _load();
                },
                icon: Icon(Icons.refresh)),
            divider(horizontal: true),
            SizedBox(
              width: 250,
              child: DeviceModelDropdown(
                  hint: 'Select Device Library',
                  searchHint: 'Select Device Library',
                  style: theme.getStyle(),
                  selectedItem: _selectedDeviceModel?.id,
                  onDeviceModelSelected: (e) {
                    setState(() {
                      _selectedDeviceModel = e;
                    });
                    _load();
                  }),
            ),
            divider(horizontal: true),
            PrimaryButton(
              labelKey: 'Create New',
              leading: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: (canCreate() && _selectedDeviceModel != null)
                  ? _create
                  : null,
            ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  leading: Icon(Icons.search),
                  hintText: 'Search Conditions',
                  onChanged: (val) {
                    _search = val.trim();
                    _load();
                  },
                )),
          ],
        ),
        divider(),
        if (loading)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Loading...',
                style: theme.getStyle(),
              ),
            ],
          ),
        if (!loading && _cards.isEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No conditions found',
                style: theme.getStyle(),
              ),
            ],
          ),
        if (!loading && _cards.isNotEmpty)
          Column(
            children: [
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _cards,
              ),
            ],
          ),
      ],
    );
  }

  String getConditionDisplayText(tapi.ConditionCondition condition) {
    switch (condition) {
      case tapi.ConditionCondition.lt:
        return '<';
      case tapi.ConditionCondition.lte:
        return '<=';
      case tapi.ConditionCondition.gt:
        return '>';
      case tapi.ConditionCondition.gte:
        return '>=';
      case tapi.ConditionCondition.eq:
        return '=';
      case tapi.ConditionCondition.neq:
        return '!=';
      case tapi.ConditionCondition.between:
        return 'BETWEEN';
      case tapi.ConditionCondition.nbetween:
        return 'NOT BETWEEN';
      case tapi.ConditionCondition.contains:
        return 'CONTAINS';
      case tapi.ConditionCondition.ncontains:
        return 'NOT CONTAINS';
      default:
        return '';
    }
  }

  Widget _buildCard(tapi.Condition e) {
    TextEditingController leftValueController =
        TextEditingController(text: e.leftValue);
    TextEditingController rightValueController =
        TextEditingController(text: e.rightValue);
    TextEditingController valueController =
        TextEditingController(text: e.$value);
    TextEditingController valuesController = TextEditingController(
      text: e.values?.join('\n') ?? '',
    );

    bool editable = _editable[e.id] ?? false;
    double width = MediaQuery.of(context).size.width / 8;

    return InkWell(
      onDoubleTap: () {
        if (editable) {
          _edit(e);
        }
      },
      child: SizedBox(
        width: width,
        height: width,
        child: Card(
          elevation: 8,
          color: Colors.white,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    e.name,
                    style: theme.getStyle().copyWith(
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ),
              ),
              Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message:
                                editable ? "Update" : "No Permission to Edit",
                            child: InkWell(
                              onTap: editable
                                  ? () {
                                      _edit(e);
                                    }
                                  : null,
                              child: Icon(
                                Icons.edit,
                                color: editable
                                    ? theme.getPrimaryColor()
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Tooltip(
                            message:
                                editable ? "Delete" : "No Permission to Delete",
                            child: InkWell(
                              onTap: editable
                                  ? () {
                                      _confirmDeletionDialog(context, e);
                                    }
                                  : null,
                              child: Icon(
                                Icons.delete_forever_rounded,
                                color: editable
                                    ? theme.getPrimaryColor()
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'IN',
                            style: theme.getStyle().copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          divider(
                            horizontal: true,
                            height: 2,
                          ),
                          Text(
                            _modelNames[e.modelId] ?? '--',
                            style: theme.getStyle().copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      divider(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'IF',
                            style: theme.getStyle().copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                          ),
                          divider(
                            horizontal: true,
                            height: 4,
                          ),
                          Text(
                            e.field,
                            style: theme.getStyle().copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Text(
                        getConditionDisplayText(e.condition),
                        style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                      ),
                      divider(
                        height: 2,
                      ),
                      if (e.condition == tapi.ConditionCondition.lt ||
                          e.condition == tapi.ConditionCondition.lte ||
                          e.condition == tapi.ConditionCondition.gt ||
                          e.condition == tapi.ConditionCondition.gte ||
                          e.condition == tapi.ConditionCondition.eq ||
                          e.condition == tapi.ConditionCondition.neq)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: LabelTextField(
                            style: theme.getStyle(),
                            label: 'Value',
                            controller: valueController,
                            readOnlyVal: true,
                            textAlign: TextAlign.center,
                            labelTextStyle: theme.getStyle().copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      if (e.condition == tapi.ConditionCondition.between ||
                          e.condition == tapi.ConditionCondition.nbetween)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 80,
                              child: LabelTextField(
                                label: 'Left Value',
                                controller: leftValueController,
                                readOnlyVal: true,
                                textAlign: TextAlign.center,
                                labelTextStyle: theme.getStyle().copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: LabelTextField(
                                label: 'Right Value',
                                controller: rightValueController,
                                readOnlyVal: true,
                                textAlign: TextAlign.center,
                                labelTextStyle: theme.getStyle().copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (e.condition == tapi.ConditionCondition.contains ||
                          e.condition == tapi.ConditionCondition.ncontains)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Expanded(
                            child: SizedBox(
                              height: 65,
                              child: LabelTextField(
                                controller: valuesController,
                                readOnlyVal: true,
                                textAlign: TextAlign.center,
                                style: theme.getStyle().copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                label: 'Values',
                                labelTextStyle: theme.getStyle().copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                maxLines: null,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _getDeviceModel() async {
    await execute(() async {
      for (var modelId in _selectedModel) {
        var mRes = await TwinnedSession.instance.twin.getDeviceModel(
          apikey: TwinnedSession.instance.authToken,
          modelId: modelId,
        );
        if (mRes.body != null) {
          refresh(sync: () {
            _modelNames[modelId] = mRes.body!.entity!.name;
          });
        } else {}
      }
    });

    loading = false;
    refresh();
  }

  Future _create() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height - 150,
            width: MediaQuery.of(context).size.width - 200,
            child: CreateEditConditionSnippet(),
          ),
        );
      },
    );
    _load();
  }

  Future _edit(tapi.Condition e) async {
    var res = await TwinnedSession.instance.twin.getDeviceModel(
        modelId: e.modelId, apikey: TwinnedSession.instance.authToken);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: CreateEditConditionSnippet(
            condition: e,
            selectedModel: res.body!.entity!,
          ),
        );
      },
    );
    _load();
  }

  Future _confirmDeletionDialog(
      BuildContext context, tapi.Condition condition) {
    Widget cancelButton = SecondaryButton(
      labelKey: 'Cancel',
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = PrimaryButton(
      leading: const Icon(
        Icons.delete_forever,
        color: Colors.white,
      ),
      labelKey: 'Delete',
      onPressed: () {
        Navigator.pop(context);
        _delete(condition);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: theme.getStyle().copyWith(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
      content: Text(
        "Deleting a Condition Rule can not be undone.\nYou will lose all of the Condition Rule data, history, etc.\n\nAre you sure you want to delete?",
        style: theme.getStyle(),
        maxLines: 10,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _delete(tapi.Condition e) async {
    if (loading) return;
    loading = true;

    await execute(() async {
      int index = _entities.indexWhere((element) => element.id == e.id);
      var res = await TwinnedSession.instance.twin.deleteCondition(
        apikey: TwinnedSession.instance.authToken,
        conditionId: e.id,
      );

      if (validateResponse(res)) {
        _entities.removeAt(index);
        _cards.removeAt(index);
        alert("Conditions Rules - ${e.name}", "Deleted Successfully!",
            contentStyle: theme.getStyle(),
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
      }
    });
    loading = false;
    refresh();
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _entities.clear();
    _cards.clear();

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.queryEqlCondition(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.EqlSearch(
              source: [],
              page: 0,
              size: 50,
              mustConditions: [
                {
                  "query_string": {
                    "query": '*$_search*',
                    "fields": ["name", "description", "tags"]
                  }
                },
                if (null != _selectedDeviceModel)
                  {
                    "match_phrase": {
                      "modelId": _selectedDeviceModel!.id,
                    }
                  }
              ]));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
        _selectedModel.addAll(_entities.map((condition) => condition.modelId));
        await _getDeviceModel();
      }

      for (tapi.Condition e in _entities) {
        _editable[e.id] = await super.canEdit(clientIds: e.clientIds);
        _cards.add(_buildCard(e));
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() async {
    _load();
  }
}
