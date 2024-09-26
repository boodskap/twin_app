import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/device_model_content_page.dart';
import 'package:twin_app/pages/twin/components/widgets/device_model_snippet.dart';
import 'package:twin_app/widgets/buy_button.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
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
  final Map<String, bool> _editable = Map<String, bool>();
  bool _exhausted = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const BusyIndicator(),
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
                leading: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: (canCreate()) ? _create : null,
              ),
            divider(horizontal: true),
            ElevatedButton(
              onPressed: isAdmin() ? confirmWipeAllData : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: Size(150, 50),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                children: [
                  const Icon(
                    Icons.auto_delete_rounded,
                    color: Colors.white,
                  ),
                  Text(
                    'Wipe All Data',
                    style: theme.getStyle().copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                  ),
                ],
              ),
            ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  leading: Icon(Icons.search),
                  hintText: 'Search Device Library',
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
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

  Future<Widget> _buildCard(tapi.DeviceModel e) async {
    debugPrint('Model:${e.name} ClientIds:${e.clientIds}');
    double width = MediaQuery.of(context).size.width / 8;
    bool editable = _editable[e.id] ?? false;

    return SizedBox(
      width: width,
      height: width,
      child: InkWell(
        onDoubleTap: () {
          if (editable) {
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
                        onTap: editable ? () => _edit(e, "") : null,
                        child: Icon(
                          Icons.edit,
                          color:
                              editable ? theme.getPrimaryColor() : Colors.grey,
                        ),
                      ),
                      InkWell(
                        onTap: editable ? () => _delete(e) : null,
                        child: Icon(
                          Icons.delete_forever,
                          color:
                              editable ? theme.getPrimaryColor() : Colors.grey,
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

  void wipeAllData() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      dynamic res = await TwinnedSession.instance.twin.cleanupData(
        apikey: TwinnedSession.instance.authToken,
        modelId: null,
        deviceId: null,
      );
      if (validateResponse(res)) {
        Navigator.pop(context);
        alert('', "All data wiped out successfully!",
            contentStyle: theme.getStyle(),
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
      }
    });
    loading = false;
    refresh();
  }

  void confirmWipeAllData() {
    Widget cancelButton = SecondaryButton(
      labelKey: "Cancel",
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = PrimaryButton(
      labelKey: "Delete",
      onPressed: () {
        wipeAllData();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: theme.getStyle().copyWith(color: Colors.red, fontSize: 18),
      ),
      content: Text(
        "This action can't be undone!\n This will wipe out all of your device data including the historical data.\nDo you really want to proceed?",
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

  Future _addEditDeviceModelDialog({tapi.DeviceModel? deviceModel}) async {
    await super.alertDialog(
      titleStyle:
          theme.getStyle().copyWith(fontWeight: FontWeight.bold, fontSize: 20),
      title:
          null == deviceModel ? 'Add New Device Library' : 'Update Device Library',
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
            'Deleting is unrecoverable\nIt may also delete all the related library and components\n\nDo you want to proceed?',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle(),
        onPressed: () async {
          await execute(() async {
            int index = _entities.indexWhere((element) => element.id == e.id);
            var res = await TwinnedSession.instance.twin.deleteDeviceModel(
                apikey: TwinnedSession.instance.authToken, modelId: e.id);
            validateResponse(res);
            await _load();
            _entities.removeAt(index);
            _cards.removeAt(index);
            alert("Device Library - ${e.name}", " Deleted Successfully!",
                contentStyle: theme.getStyle(),
                titleStyle: theme
                    .getStyle()
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
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
        _cards.add(await _buildCard(e));
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
