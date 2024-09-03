import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/device_model_content_page.dart';
import 'package:twin_app/pages/twin/components/widgets/device_model_snippet.dart';
import 'package:twin_app/widgets/buy_button.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/purchase_change_addon_widget.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:uuid/uuid.dart';

class DeviceLibrary extends StatefulWidget {
  const DeviceLibrary({super.key});

  @override
  State<DeviceLibrary> createState() => _DeviceLibraryState();
}

class _DeviceLibraryState extends BaseState<DeviceLibrary> {
  final List<tapi.DeviceModel> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';
  bool _canEdit = false;
  Map<String, bool> _editable = Map<String, bool>();
  bool _exhausted = true;

  @override
  void initState() {
    super.initState();
    _checkCanEdit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                icon: Icon(Icons.refresh)),
            divider(horizontal: true),
            if (_exhausted)
              BuyButton(
                  label: 'Buy More License',
                  tooltip:
                      'Utilized ${orgPlan?.totalDeviceModelCount ?? '-'} licenses',
                  style: theme.getStyle().copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue),
                  onPressed: _buyAddon),
            if (!_exhausted)
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
                  leading: Icon(Icons.search),
                  hintText: 'Search device library',
                  hintStyle: WidgetStateProperty.all(
                    theme.getStyle(),
                  ),
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
                'No device library found',
                style: theme.getStyle(),
              ),
            ],
          ),
        if (!loading && _cards.isNotEmpty)
          SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _cards,
            ),
          ),
      ],
    );
  }

  Widget _buildCard(tapi.DeviceModel e) {
    double width = MediaQuery.of(context).size.width / 8;
    bool editable = _canEdit;
    if (!editable) {
      editable = _editable[e.id] ?? false;
    }
    return SizedBox(
      width: width,
      height: width,
      child: InkWell(
        onDoubleTap: () {
          if (_canEdit) {
            _edit(e, "");
          }
        },
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
                    style:
                        theme.getStyle().copyWith(fontWeight: FontWeight.bold),
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
                        onTap: _canEdit ? () => _edit(e, "") : null,
                        child: Icon(
                          Icons.edit,
                          color:
                              _canEdit ? theme.getPrimaryColor() : Colors.grey,
                        ),
                      ),
                      InkWell(
                        onTap: _canEdit ? () => _delete(e) : null,
                        child: Icon(
                          Icons.delete,
                          color:
                              _canEdit ? theme.getPrimaryColor() : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (null != e.images && e.images!.isNotEmpty)
                Align(
                  alignment: Alignment.center,
                  child: TwinImageHelper.getCachedImage(
                      e.domainKey, e.images!.first,
                      width: width / 2, height: width / 2),
                )
            ],
          ),
        ),
      ),
    );
  }

  Future _buyAddon() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            content: PurchaseChangeAddonWidget(
              orgId: orgs[selectedOrg].id,
              purchase: true,
              deviceModels: 1,
            ),
          );
        });
    await _checkExhausted();
    await _load();
  }

  Future<void> _checkCanEdit() async {
    List<String> clientIds = await getClientIds();
    bool canEditResult = await canEdit(clientIds: clientIds);

    setState(() {
      _canEdit = canEditResult;
    });
  }

  Future _addEditDeviceModelDialog({tapi.DeviceModel? deviceModel}) async {
    await super.alertDialog(
      title:
          null == deviceModel ? 'Add New Device Model' : 'Update Device Model',
      body: DeviceModelSnippet(
        deviceModel: deviceModel,
      ),
      width: 750,
      height: MediaQuery.of(context).size.height - 150,
    );
    await _checkExhausted();
    await _load();
  }

  Future _openDeviceModel(tapi.DeviceModel e, String type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceModelContentPage(
          key: Key(const Uuid().v4()),
          model: e,
          type: type,
          initialPage: 0,
        ),
      ),
    );
    await _load();
  }

  Future _delete(tapi.DeviceModel e) async {
    await confirm(
        title: 'Warning',
        message:
            'Deleting is unrecoverable\nIt may also delete all the related models and components\n\nDo you want to proceed?',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
        onPressed: () async {
          await execute(() async {
            int index = _entities.indexWhere((element) => element.id == e.id);
            var res = await TwinnedSession.instance.twin.deleteDeviceModel(
                apikey: TwinnedSession.instance.authToken, modelId: e.id);
            validateResponse(res);
            await _load();
            _entities.removeAt(index);
            _cards.removeAt(index);
            alert("Success", "DeviceModel ${e.name} Deleted Successfully!");
          });
        });
    await _load();
  }

  Future _create() async {
    await _addEditDeviceModelDialog();
  }

  Future _edit(tapi.DeviceModel e, String type) async {
    _openDeviceModel(e, type);
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _entities.clear();
    _cards.clear();

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.searchDeviceModels(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.DeviceModel e in _entities) {
        _editable[e.id] = await super.canEdit(clientIds: e.clientIds);
        _cards.add(_buildCard(e));
      }
    });

    loading = false;
    refresh();
  }

  Future _checkExhausted() async {
    _exhausted = await hasDeviceLibrariesExhausted();
    refresh();
  }

  @override
  void setup() async {
    _checkExhausted();
    _load();
  }
}
