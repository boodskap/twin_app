import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/display_content_page.dart';
import 'package:twin_app/pages/twin/components/widgets/display_model_snippet.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/core/device_model_dropdown.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:uuid/uuid.dart';

typedef BasicInfoCallback = void Function(
    String name, String? description, String? tags);

class VisualDisplays extends StatefulWidget {
  const VisualDisplays({super.key});

  @override
  State<VisualDisplays> createState() => _VisualDisplaysState();
}

class _VisualDisplaysState extends BaseState<VisualDisplays> {
  final List<tapi.Display> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';
  tapi.DeviceModel? _selectedDeviceModel;
  Map<String, bool> _editable = Map<String, bool>();

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
                  ? () {
                      _create();
                    }
                  : null,
            ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  leading: Icon(Icons.search),
                  hintText: 'Search Visual Displays',
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
                  'No visual displays found',
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

  Widget _buildCard(tapi.Display e) {
    bool editable = _editable[e.id] ?? false;

    double width = MediaQuery.of(context).size.width / 8;
    return SizedBox(
      width: width,
      height: width,
      child: InkWell(
        onDoubleTap: () {
          if (editable) {
            _edit(e);
          }
        },
        child: Tooltip(
          message: '${e.name}\n${e.description ?? ""}',
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
                      style: theme
                          .getStyle()
                          .copyWith(fontWeight: FontWeight.bold),
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
                            onTap: editable
                                ? () {
                                    _edit(e);
                                  }
                                : null,
                            child: Tooltip(
                              message:
                                  editable ? "Update" : "No Permission to Edit",
                              child: Icon(
                                Icons.edit,
                                color: editable
                                    ? theme.getPrimaryColor()
                                    : Colors.grey,
                              ),
                            )),
                        InkWell(
                          onTap: editable
                              ? () {
                                  _delete(e);
                                }
                              : null,
                          child: Tooltip(
                            message:
                                editable ? "Delete" : "No Permission to Delete",
                            child: Icon(
                              Icons.delete_forever,
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
                Align(
                  alignment: Alignment.center,
                  child: SimpleDisplaySnippet(
                    display: e,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _create() async {
    if (loading) return;
    loading = true;
    List<String> clientIds = [];
    if (isClient()) {
      clientIds = await getClientIds();
    }
    await _getBasicInfo(context, 'New Display',
        onPressed: (name, desc, t) async {
      List<String> tags = [];
      if (null != t) {
        tags = t.trim().split(' ');
      }

      var mRes = await TwinnedSession.instance.twin.createDisplay(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.DisplayInfo(
            modelId: _selectedDeviceModel!.id,
            name: name,
            description: desc,
            tags: tags,
            conditions: [],
            clientIds: clientIds,
          ));
      if (validateResponse(mRes)) {
        await _edit(mRes.body!.entity!);
      }
    });
    loading = false;
    refresh();
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
                labelKey: "Ok",
              ),
            ],
          );
        });
  }

  Future _edit(tapi.Display e) async {
    var res = await TwinnedSession.instance.twin.getDeviceModel(
        modelId: e.modelId, apikey: TwinnedSession.instance.authToken);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayContentStatePage(
          deviceModel: res.body!.entity!,
          display: e,
          key: Key(
            Uuid().v4(),
          ),
        ),
      ),
    );
    await _load();
  }

  Future _delete(tapi.Display e) async {
    if (loading) return;
    loading = true;
    await confirm(
        title: 'Warning',
        message:
            'Deleting is unrecoverable\nIt may also delete all the related models and components\n\nDo you want to proceed?',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle(),
        onPressed: () async {
          await execute(() async {
            int index = _entities.indexWhere((element) => element.id == e.id);
            var res = await TwinnedSession.instance.twin.deleteDisplay(
              apikey: TwinnedSession.instance.authToken,
              displayId: e.id,
            );
            if (validateResponse(res)) {
              await _load();
              _entities.removeAt(index);
              _cards.removeAt(index);
              alert('Display - ${e.name}', ' Deleted successfully!',
                  contentStyle: theme.getStyle(),
                  titleStyle: theme
                      .getStyle()
                      .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
            }
          });
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
      var sRes = await TwinnedSession.instance.twin.queryEqlDisplay(
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

      for (tapi.Display e in _entities) {
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
