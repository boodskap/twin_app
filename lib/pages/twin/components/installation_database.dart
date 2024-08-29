import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/database_content_page.dart';
import 'package:twin_app/pages/twin/components/widgets/installation_database_snippet.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/core/device_model_dropdown.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:uuid/uuid.dart';

typedef BasicInfoCallback = void Function(
    String name, String? description, String? tags);

class InstallationDatabase extends StatefulWidget {
  const InstallationDatabase({super.key});

  @override
  State<InstallationDatabase> createState() => _InstallationDatabaseState();
}

class _InstallationDatabaseState extends BaseState<InstallationDatabase> {
  final List<tapi.Device> _entities = [];
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 15),
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
                onPressed: (canCreate() && _selectedDeviceModel != null)
                    ? () =>
                        _addEditDeviceDialog(modelId: _selectedDeviceModel!.id)
                    : null,
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No installations found',
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
      ),
    );
  }

  Widget _buildCard(tapi.Device e) {
    bool editable = _canEdit;
    if (!editable) {
      editable = _editable[e.id] ?? false;
    }
    double width = MediaQuery.of(context).size.width / 8;
    return SizedBox(
      width: width,
      height: width,
      child: InkWell(
        onDoubleTap: () {
          if (_canEdit) {
            _edit(e);
          }
        },
        child: Card(
          elevation: 8,
          color: Colors.white,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: _canEdit
                            ? () {
                                _addEditDeviceDialog(device: e);
                              }
                            : null,
                        child: Tooltip(
                          message:
                              _canEdit ? "Update" : "No Permission to Edit",
                          child: Icon(
                            Icons.edit,
                            color: _canEdit
                                ? theme.getPrimaryColor()
                                : Colors.grey,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _canEdit
                            ? () {
                                _delete(e);
                              }
                            : null,
                        child: Tooltip(
                          message:
                              _canEdit ? "Delete" : "No Permission to Delete",
                          child: Icon(
                            Icons.delete,
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
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: (null != e.images && e.images!.isNotEmpty)
                        ? TwinImageHelper.getCachedImage(
                            e.domainKey,
                            e.images!.first,
                            width: width / 2,
                            height: width / 2,
                          )
                        : Icon(
                            Icons.image,
                            size: width / 2.5,
                          ),
                  ),
                  Text(
                    e.name,
                    style: theme.getStyle().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (e.name != e.deviceId)
                    Text(
                      e.deviceId,
                      style: theme.getStyle().copyWith(),
                    ),
                  divider(),
                ],
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

  void _addEditDeviceDialog({
    tapi.Device? device,
    String? modelId,
  }) async {
    await super.alertDialog(
      title: null == device ? 'Add New Device' : 'Update Device',
      body: InstallationDatabaseSnippet(
        device: device,
        modelId: modelId,
      ),
      width: 750,
      height: MediaQuery.of(context).size.height - 150,
    );
    _load();
  }

  Future _edit(tapi.Device e) async {
    var res = await TwinnedSession.instance.twin.getDeviceModel(
        modelId: e.modelId, apikey: TwinnedSession.instance.authToken);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceContentPage(
          deviceModel: res.body!.entity!,
          device: e,
          key: Key(
            Uuid().v4(),
          ),
        ),
      ),
    );
    await _load();
  }

  Future _delete(tapi.Device e) async {
    if (loading) return;
    loading = true;

    await confirm(
      title: 'Warning',
      message:
          'Deleting is unrecoverable\nIt may also delete all the related models and components\n\nDo you want to proceed?',
      titleStyle: const TextStyle(color: Colors.red),
      messageStyle: const TextStyle(fontWeight: FontWeight.bold),
      onPressed: () async {
        await execute(() async {
          int index = _entities.indexWhere((element) => element.id == e.id);
          var res = await TwinnedSession.instance.twin.deleteDevice(
              apikey: TwinnedSession.instance.authToken, deviceId: e.id);
          if (validateResponse(res)) {
            await _load();
            _entities.removeAt(index);
            _cards.removeAt(index);
            alert("Success", "Installation Databse ${e.name} deleted!");
          }
        });
      },
    );
    loading = false;
    refresh();
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _entities.clear();
    _cards.clear();

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.queryEqlDevice(
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

      for (tapi.Device e in _entities) {
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
