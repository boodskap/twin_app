import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_commons/widgets/common/label_text_field.dart';

class MyConditions extends StatefulWidget {
  const MyConditions({super.key});

  @override
  State<MyConditions> createState() => _MyConditionsState();
}

class _MyConditionsState extends BaseState<MyConditions> {
  List<tapi.Condition> _conditionEntities = [];
  String _searchQuery = '*';
  bool isAdmin = false;
  bool isClientAdmin = false;

  Set<String> _selectedModel = {};
  Map<String, String> _modelNames = {};
  String mId = '';

  @override
  void initState() {
    super.initState();
    isAdmin = TwinnedSession.instance.isAdmin();
    isClientAdmin = TwinnedSession.instance.isClientAdmin();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const BusyIndicator(),
            divider(horizontal: true),
            Tooltip(
              message: "Refresh",
              child: IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
              ),
            ),
            divider(horizontal: true),
            if (isAdmin || isClientAdmin)
              PrimaryButton(
                leading: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                labelKey: 'Add New Condition',
                onPressed: (isAdmin || isClientAdmin) ? () {} : null,
              ),
            divider(horizontal: true),
            SizedBox(
              width: 250,
              height: 40,
              child: SearchBar(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = '*${value.trim()}*';
                  });
                  _load();
                },
                hintText: "Search Conditions",
                textStyle: WidgetStatePropertyAll(theme.getStyle()),
                hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                leading: const Icon(Icons.search),
              ),
            ),
            divider(horizontal: true),
          ],
        ),
        divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  spacing: 5.0,
                  runSpacing: 5.0,
                  children: _conditionEntities.map((condition) {
                    return _buildCard(condition);
                  }).toList(),
                ),
                divider(),
              ],
            ),
          ),
        ),
      ],
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

  Future _load() async {
    if (loading) return;
    loading = true;

    _conditionEntities.clear();
    _selectedModel.clear();
    _modelNames.clear();

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryEqlCondition(
        apikey: TwinnedSession.instance.authToken,
        body: tapi.EqlSearch(
          source: [],
          mustConditions: [
            {
              "query_string": {
                "query": _searchQuery,
                "fields": ["name", "description", "tags"]
              }
            }
          ],
          sort: {"namek": "asc"},
          page: 0,
          size: 25,
        ),
      );

      if (validateResponse(qRes)) {
        _conditionEntities.addAll(qRes.body!.values!);
        _selectedModel
            .addAll(_conditionEntities.map((condition) => condition.modelId));
        await _getDeviceModel();
      }
    });

    loading = false;
    refresh();
  }

  void _removeCondition(String id) async {
    if (loading) return;
    loading = true;

    await execute(() async {
      int index = _conditionEntities.indexWhere((element) => element.id == id);
      var res = await TwinnedSession.instance.twin.deleteCondition(
        apikey: TwinnedSession.instance.authToken,
        conditionId: id,
      );

      if (validateResponse(res)) {
        _conditionEntities.removeAt(index);
      }
    });

    loading = false;
    refresh();
  }

  _confirmDeletionDialog(BuildContext context, String id) {
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
        _removeCondition(id);
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
        "Deleting a Condition Rule can not be undone.\nYou will loose all of the Condition Rule data, history, etc.\n\nAre you sure you want to delete?",
        style: theme.getStyle().copyWith(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
        maxLines: 10,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void setup() {
    _load();
  }

  Widget _buildCard(tapi.Condition c) {
    mId = c.modelId;
    List<String> conditionsList = c.condition.toString().split(',');
    List<String>? values = c.values;
    TextEditingController valueController =
        TextEditingController(text: c.$value);
    TextEditingController leftValueController =
        TextEditingController(text: c.leftValue);
    TextEditingController rightValueController =
        TextEditingController(text: c.rightValue);
    TextEditingController valuesController = TextEditingController(
      text: values?.join('\n') ?? '',
    );

    bool showLeftRightValues = conditionsList.any((condition) {
      String conditionType = condition.split('.').last;
      return conditionType == 'between' || conditionType == 'nbetween';
    });
    Map<String, String> conditionTypeMapping = {
      'lt': '<',
      'lte': '<=',
      'gt': '>',
      'gte': '>=',
      'eq': '==',
      'neq': '!=',
      'between': 'BETWEEN',
      'nbetween': 'NOT BETWEEN',
      'contains': 'CONTAINS',
      'ncontains': 'NOT CONTAINS',
    };

    String conditionType =
        conditionsList.isNotEmpty ? conditionsList.first.split('.').last : '';
    if (!(conditionType == 'contains' || conditionType == 'ncontains')) {
      return Tooltip(
        message: c.description,
        child: Card(
          color: Colors.transparent,
          elevation: 5,
          child: Container(
            height: 350,
            width: 350,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: theme.getPrimaryColor(),
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        c.name,
                        style: theme.getStyle().copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isAdmin || isClientAdmin)
                      Expanded(
                        flex: 1,
                        child: Tooltip(
                          message: "Update",
                          child: InkWell(
                            onTap: (isAdmin || isClientAdmin) ? () {} : null,
                            child: const Icon(
                              Icons.edit,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    if (isAdmin || isClientAdmin)
                      Expanded(
                        flex: 1,
                        child: Tooltip(
                          message: 'Delete',
                          child: InkWell(
                            onTap: (isAdmin || isClientAdmin)
                                ? () {
                                    _confirmDeletionDialog(context, c.id);
                                  }
                                : null,
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Divider(
                  color: theme.getPrimaryColor(),
                  thickness: 2.0,
                ),
                divider(height: 20),
                Text(
                  'IN',
                  style: theme.getStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                divider(height: 10),
                Text(
                  _modelNames[mId] ?? '--',
                  style: theme.getStyle().copyWith(
                        color: theme.getPrimaryColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                divider(height: 10),
                Text(
                  'IF',
                  style: theme.getStyle().copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                divider(height: 10),
                Text(
                  c.field,
                  style: theme.getStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                divider(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: conditionsList.map((condition) {
                    String conditionType = condition.split('.').last;
                    String conditionText =
                        conditionTypeMapping[conditionType] ?? conditionType;
                    return Text(
                      conditionText,
                      style: theme.getStyle().copyWith(
                            color: theme.getPrimaryColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                    );
                  }).toList(),
                ),
                divider(height: 10),
                if (!showLeftRightValues)
                  SizedBox(
                    width: 150,
                    child: LabelTextField(
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
                if (showLeftRightValues)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 150,
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
                        width: 150,
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
                  )
              ],
            ),
          ),
        ),
      );
    }
    if (conditionType == 'contains' || conditionType == 'ncontains') {
      return Tooltip(
        message: c.description,
        child: Card(
          color: Colors.transparent,
          elevation: 5,
          child: Container(
            height: 350,
            width: 350,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: theme.getPrimaryColor(),
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        c.name,
                        style: theme.getStyle().copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isAdmin || isClientAdmin)
                      Expanded(
                        flex: 1,
                        child: Tooltip(
                          message: "Update",
                          child: InkWell(
                            onTap: (isAdmin || isClientAdmin) ? () {} : null,
                            child: const Icon(
                              Icons.edit,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    if (isAdmin || isClientAdmin)
                      Expanded(
                        flex: 1,
                        child: Tooltip(
                          message: 'Delete',
                          child: InkWell(
                            onTap: (isAdmin || isClientAdmin)
                                ? () {
                                    _confirmDeletionDialog(context, c.id);
                                  }
                                : null,
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Divider(
                  color: theme.getPrimaryColor(),
                  thickness: 2.0,
                ),
                divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'IN',
                      style: theme.getStyle().copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                    divider(
                      horizontal: true,
                    ),
                    Text(
                      _modelNames[mId] ?? '--',
                      style: theme.getStyle().copyWith(
                            color: theme.getPrimaryColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                    divider(
                      horizontal: true,
                    ),
                    Text(
                      'IF',
                      style: theme.getStyle().copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                  ],
                ),
                divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    divider(
                      horizontal: true,
                    ),
                    Text(
                      c.field,
                      style: theme.getStyle().copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                    divider(
                      horizontal: true,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: conditionsList.map((condition) {
                        String conditionType = condition.split('.').last;
                        String conditionText =
                            conditionTypeMapping[conditionType] ??
                                conditionType;
                        return Text(
                          conditionText,
                          style: theme.getStyle().copyWith(
                                color: theme.getPrimaryColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                divider(height: 20),
                Expanded(
                  child: SizedBox(
                    width: 200,
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
              ],
            ),
          ),
        ),
      );
    }
    return Container();
  }
}
