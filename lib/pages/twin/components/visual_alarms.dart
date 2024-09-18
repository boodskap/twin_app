import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/facilities.dart';
import 'package:twin_app/pages/twin/components/widgets/visual_alarms_content_page.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/core/device_model_dropdown.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:uuid/uuid.dart';
import 'package:twin_commons/core/twin_image_helper.dart';

class VisualAlarms extends StatefulWidget {
  const VisualAlarms({super.key});

  @override
  State<VisualAlarms> createState() => _VisualAlarmsState();
}

class _VisualAlarmsState extends BaseState<VisualAlarms> {
  final List<tapi.Alarm> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';
  tapi.DeviceModel? _selectedDeviceModel;
  bool _canEdit = false;
  Map<String, bool> _editable = Map<String, bool>();

  @override
  void initState() {
    super.initState();
    _checkCanEdit();
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
              icon: Icon(Icons.refresh),
            ),
            divider(horizontal: true),
            SizedBox(
              width: 250,
              child: DeviceModelDropdown(
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
              onPressed: (canCreate()) ? _create : null,
            ),
            divider(horizontal: true),
            SizedBox(
              height: 40,
              width: 250,
              child: SearchBar(
                hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                textStyle: WidgetStatePropertyAll(theme.getStyle()),
                leading: Icon(Icons.search),
                hintText: 'Search Alarms',
                onChanged: (val) {
                  _search = val.trim();
                  _load();
                },
              ),
            ),
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No visual alarms found',
                  style: theme.getStyle(),
                ),
              ],
            ),
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

  Widget _buildCard(tapi.Alarm e) {
    double width = MediaQuery.of(context).size.width / 8;
    bool editable = _canEdit;
    if (!editable) {
      editable = _editable[e.id] ?? false;
    }
    Widget icon = const Icon(
      Icons.question_mark,
      size: 45,
    );
    var group = e.conditions.isNotEmpty
        ? e.conditions.first
        : tapi.AlarmMatchGroup(
            matchType: tapi.AlarmMatchGroupMatchType.all,
            conditions: [],
            alarmState: 0);

    if (e.stateIcons!.length > group.alarmState) {
      icon = TwinImageHelper.getCachedImage(
          e.domainKey, e.stateIcons![group.alarmState]);
    }
    return InkWell(
      onDoubleTap: () {
        if (_canEdit) {
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
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: icon,
                ),
              ),
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
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: _canEdit ? "Update" : "No Permission to Edit",
                        child: InkWell(
                          onTap: _canEdit
                              ? () {
                                  _edit(e);
                                }
                              : null,
                          child: Icon(
                            Icons.edit,
                            color: _canEdit
                                ? theme.getPrimaryColor()
                                : Colors.grey,
                          ),
                        ),
                      ),
                      Tooltip(
                        message:
                            _canEdit ? "Delete" : "No Permission to Delete",
                        child: InkWell(
                          onTap: _canEdit
                              ? () {
                                  _confirmDeletionDialog(context, e);
                                }
                              : null,
                          child: Icon(
                            Icons.delete_forever_rounded,
                            color: _canEdit
                                ? theme.getPrimaryColor()
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkCanEdit() async {
    List<String> clientIds = await getClientIds();
    bool canEditResult = await canEdit(clientIds: clientIds);

    setState(() {
      _canEdit = canEditResult;
    });
  }

  Future<void> _getBasicInfo(BuildContext context, String title,
      {required BasicInfoCallback onPressed}) async {
    String? nameText = '';
    String? descText = '';
    String? tagsText = '';
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            titleTextStyle: theme
                .getStyle()
                .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            title: Text(title),
            content: SizedBox(
              width: 500,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        nameText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        descText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Description',
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        tagsText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tags (space separated)',
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              SecondaryButton(
                labelKey: 'Cancel',
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              PrimaryButton(
                labelKey: 'Ok',
                onPressed: () {
                  if (nameText!.length < 3) {
                    alert('Invalid',
                        'Name is required and should be minimum 3 characters',
                        contentStyle: theme.getStyle(),
                        titleStyle: theme.getStyle().copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold));
                    return;
                  }
                  setState(() {
                    onPressed(nameText!, descText, tagsText);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future _create() async {
    if (loading) return;
    loading = true;
    await _getBasicInfo(context, 'New Alarm', onPressed: (name, desc, t) async {
      List<String> tags = [];
      if (null != t) {
        tags = t.trim().split(' ');
      }
      var mRes = await TwinnedSession.instance.twin.createAlarm(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.AlarmInfo(
            modelId: _selectedDeviceModel!.id,
            name: name,
            description: desc,
            tags: tags,
            state: -1,
            conditions: [],
            clientIds: await getClientIds(),
          ));
      if (validateResponse(mRes)) {
        await _edit(mRes.body!.entity!);
        alert('Visual Alarm - ${name}', ' Created successfully!',
            contentStyle: theme.getStyle(),
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
      }
    });
    loading = false;
    refresh();
  }

  Future _edit(tapi.Alarm e) async {
    var res = await TwinnedSession.instance.twin.getDeviceModel(
        modelId: e.modelId, apikey: TwinnedSession.instance.authToken);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisualAlarmsContentPage(
          key: Key(const Uuid().v4()),
          model: res.body!.entity!,
          alarm: e,
        ),
      ),
    );
    await _load();
  }

  _confirmDeletionDialog(BuildContext context, tapi.Alarm e) {
    Widget cancelButton = SecondaryButton(
      labelKey: 'Cancel',
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = PrimaryButton(
      labelKey: 'Delete',
      onPressed: () {
        Navigator.pop(context);
        _delete(e);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: theme.getStyle().copyWith(color: Colors.red),
      ),
      content: Text(
        "Deleting a Alarm can not be undone.\nYou will loose all of the premise data, history, etc.\n\nAre you sure you want to delete?",
        style: theme.getStyle(),
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

  Future _delete(tapi.Alarm e) async {
    await execute(() async {
      int index = _entities.indexWhere((element) => element.id == e.id);
      var res = await TwinnedSession.instance.twin.deleteAlarm(
        apikey: TwinnedSession.instance.authToken,
        alarmId: e.id,
      );

      if (validateResponse(res)) {
        await _load();
        _entities.removeAt(index);
        _cards.removeAt(index);
        alert("Visual Alarm - ${e.name}", " Deleted Successfully!",
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
      var sRes = await TwinnedSession.instance.twin.queryEqlAlarm(
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
      }

      for (tapi.Alarm e in _entities) {
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
