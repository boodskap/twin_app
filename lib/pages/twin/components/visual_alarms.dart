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
              onPressed: () {
                _create();
              },
            ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  leading: Icon(Icons.search),
                  hintText: 'Search installation database',
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
    return SizedBox(
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
                  style: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
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
                    InkWell(
                        onTap: () {
                          _edit(e);
                        },
                        child:
                            Icon(Icons.edit, color: theme.getPrimaryColor())),
                    InkWell(
                      onTap: () {
                        _delete(e);
                      },
                      child: Icon(
                        Icons.delete,
                        color: theme.getPrimaryColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            title: Text(title),
            content: SizedBox(
              width: 500,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        nameText = value;
                      });
                    },
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        descText = value;
                      });
                    },
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        tagsText = value;
                      });
                    },
                    decoration: const InputDecoration(
                        hintText: 'Tags (space separated)'),
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
                        'Name is required and should be minimum 3 characters');
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
          ));
      if (validateResponse(mRes)) {
        await _edit(mRes.body!.entity!);
        // await _edit(mRes.body!.entity!);
        alert('Success', 'Alarm ${name} created successfully');
      }
    });
    loading = false;
    refresh();
  }

  Future _edit(tapi.Alarm e) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisualAlarmsContentPage(
          key: Key(const Uuid().v4()),
          model: _selectedDeviceModel!,
          alarm: e,
        ),
      ),
    );
    await _load();
  }

  Future _delete(tapi.Alarm e) async {}

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
