import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/core/twin_helper.dart';
import 'package:twin_app/pages/twin/components/widgets/asset_content_page.dart';
import 'package:twin_app/pages/twin/components/widgets/asset_snippet.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twinned_widgets/core/facility_dropdown.dart';
import 'package:twinned_widgets/core/floor_dropdown.dart';
import 'package:twinned_widgets/core/premise_dropdown.dart';
import 'package:uuid/uuid.dart';

typedef BasicInfoCallback = void Function(
    String name, String? description, String? tags);

class Assets extends StatefulWidget {
  const Assets({super.key});

  @override
  State<Assets> createState() => _AssetsState();
}

class _AssetsState extends BaseState<Assets> {
  final List<tapi.Asset> _entities = [];
  final List<Widget> _cards = [];
  final Map<String, tapi.DeviceModel> _models = <String, tapi.DeviceModel>{};
  final Map<String, tapi.Device> _devices = <String, tapi.Device>{};
  String _search = '';
  tapi.Premise? _selectedPremise;
  tapi.Facility? _selectedFacility;
  tapi.AssetModel? _selectedAssetModel;
  tapi.Floor? _selectedFloor;
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
                icon: Icon(Icons.refresh)),
            divider(horizontal: true),
            SizedBox(
              width: 250,
              child: PremiseDropdown(
                style: theme.getStyle(),
                key: Key(const Uuid().v4()),
                selectedItem: _selectedPremise?.id,
                onPremiseSelected: (e) {
                  setState(() {
                    if (e == null) {
                      _selectedPremise = null;
                      _selectedFacility = null;
                      _selectedFloor = null;
                    } else {
                      _selectedPremise = e;
                      _selectedFacility = null;
                      _selectedFloor = null;
                    }
                  });
                  _load();
                },
              ),
            ),
            divider(horizontal: true),
            SizedBox(
              width: 250,
              child: FacilityDropdown(
                style: theme.getStyle(),
                key: Key(const Uuid().v4()),
                selectedItem: _selectedFacility?.id,
                selectedPremise: _selectedPremise?.id,
                onFacilitySelected: (e) {
                  setState(() {
                    if (e == null) {
                      _selectedFacility = null;
                      _selectedFloor = null;
                    } else {
                      _selectedFacility = e;
                      _selectedFloor = null;
                    }
                  });
                  _load();
                },
              ),
            ),
            SizedBox(
              width: 250,
              child: FloorDropdown(
                style: theme.getStyle(),
                key: Key(const Uuid().v4()),
                selectedItem: _selectedFloor?.id,
                selectedPremise: _selectedPremise?.id,
                selectedFacility: _selectedFacility?.id,
                onFloorSelected: (e) {
                  setState(() {
                    _selectedFloor = e;
                  });
                  _load();
                },
              ),
            ),
            divider(horizontal: true),
            // if (canCreate())
            PrimaryButton(
              labelKey: 'Create New',
              leading: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: (canCreate())
                  ? () {
                      _addEditAssetDialog();
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
                  hintText: 'Search Assets',
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
                'No asset found',
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

  Future<void> _checkCanEdit() async {
    List<String> clientIds = await getClientIds();
    bool canEditResult = await canEdit(clientIds: clientIds);

    setState(() {
      _canEdit = canEditResult;
    });
  }

  Future<String> getImageId(tapi.Device e) async {
    String imageId = (e.images?.isNotEmpty ?? false) ? e.images!.first : '';

    if (imageId.isEmpty) {
      imageId = (null != _models[e.modelId])
          ? (_models[e.modelId]?.images?.first ?? '')
          : '';
    }

    if (imageId.isEmpty) {
      tapi.DeviceModel? dm = await TwinHelper.getDeviceModel(e.modelId);
      imageId = (dm?.images?.isNotEmpty ?? false) ? dm!.images!.first : '';
      if (null != dm) {
        _models[dm.id] = dm;
      }
    }

    return imageId;
  }

  Future<Widget> getDeviceChild(String deviceId) async {
    tapi.Device? device = _devices[deviceId];
    if (null == device) {
      device = await TwinHelper.getDevice(deviceId);
    }
    String imageId = await getImageId(device!);
    return Chip(
      label: Text(
        device!.name,
        style: theme
            .getStyle()
            .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      avatar: imageId.isEmpty
          ? Icon(Icons.image)
          : TwinImageHelper.getCachedDomainImage(imageId),
    );
  }

  Future<Widget> _buildCard(tapi.Asset e) async {
    bool editable = _canEdit;
    double width = MediaQuery.of(context).size.width / 8;
    List<Widget> children = [];

    if (!editable) {
      editable = _editable[e.id] ?? false;
    }

    if (null != e.devices && e.devices!.isNotEmpty) {
      for (String id in e.devices!) {
        children.add(await getDeviceChild(id));
      }
    } else {
      children.add(Chip(
          label: Text(
        'No device attached',
        style: theme
            .getStyle()
            .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
      )));
    }

    return SizedBox(
      width: width,
      height: width * 1.25,
      child: InkWell(
        onDoubleTap: () async {
          if (_canEdit) {
            await _edit(e);
          }
        },
        child: Tooltip(
          textStyle: theme.getStyle().copyWith(color: Colors.white),
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
                      overflow: TextOverflow.ellipsis,
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
                          onTap: _canEdit
                              ? () {
                                  // _edit(e);
                                  _addEditAssetDialog(asset: e);
                                }
                              : null,
                          child: Tooltip(
                              message: _canEdit
                                  ? "Update"
                                  : "No Permission to Update",
                              child: Icon(
                                Icons.edit,
                                color: _canEdit
                                    ? theme.getPrimaryColor()
                                    : Colors.grey,
                              )),
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
                              Icons.delete_forever,
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
                Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (null != e.images && e.images!.isNotEmpty)
                          TwinImageHelper.getCachedImage(
                              e.domainKey, e.images!.first,
                              width: width / 2, height: width / 2),
                        ...children,
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _edit(tapi.Asset e) async {
    var res = await TwinnedSession.instance.twin
        .getAsset(assetId: e.id, apikey: TwinnedSession.instance.authToken);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetContentPage(
          asset: res.body!.entity!,
          key: Key(
            Uuid().v4(),
          ),
          type: InfraType.asset,
        ),
      ),
    );
    await _load();
  }

  Future _delete(tapi.Asset e) async {
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
            var res = await TwinnedSession.instance.twin.deleteAsset(
                apikey: TwinnedSession.instance.authToken, assetId: e.id);
            if (validateResponse(res)) {
              await _load();
              _entities.removeAt(index);
              _cards.removeAt(index);
              alert(
                'Asset - ${e.name}',
                'Deleted Successfully!',
                titleStyle: theme
                    .getStyle()
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                contentStyle: theme.getStyle(),
              );
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
      var sRes = await TwinnedSession.instance.twin.queryEqlAsset(
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
                if (null != _selectedPremise)
                  {
                    "match_phrase": {
                      "premiseId": _selectedPremise!.id,
                    }
                  },
                if (null != _selectedFacility)
                  {
                    "match_phrase": {
                      "facilityId": _selectedFacility!.id,
                    }
                  },
                if (null != _selectedFloor)
                  {
                    "match_phrase": {
                      "floorId": _selectedFloor!.id,
                    }
                  },
              ]));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.Asset e in _entities) {
        _editable[e.id] = await super.canEdit(clientIds: e.clientIds);

        _cards.add(await _buildCard(e));
      }
    });

    loading = false;
    refresh();
  }

  void _addEditAssetDialog({tapi.Asset? asset}) async {
    tapi.Premise? selectedPremise;
    tapi.Facility? selectedFacility;
    tapi.Floor? selectedFloor;
    if (asset != null &&
        (_selectedPremise != null &&
            _selectedFacility != null &&
            _selectedFloor != null)) {
      var pRes = await TwinnedSession.instance.twin.getPremise(
        premiseId: asset.premiseId,
        apikey: TwinnedSession.instance.authToken,
      );
      selectedPremise = pRes.body?.entity;

      var fRes = await TwinnedSession.instance.twin.getFacility(
        facilityId: asset.facilityId,
        apikey: TwinnedSession.instance.authToken,
      );
      selectedFacility = fRes.body?.entity;
      var floorRes = await TwinnedSession.instance.twin.getFloor(
        floorId: asset.floorId,
        apikey: TwinnedSession.instance.authToken,
      );
      selectedFloor = floorRes.body?.entity;
    }

    await super.alertDialog(
      titleStyle:
          theme.getStyle().copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      title: null == asset ? 'Add New Asset' : 'Update Asset',
      body: AssetSnippet(
        selectedPremise: selectedPremise ?? _selectedPremise,
        selectedFacility: selectedFacility ?? _selectedFacility,
        selectedFloor: selectedFloor ?? _selectedFloor,
        asset: asset,
      ),
      width: 750,
      height: MediaQuery.of(context).size.height - 150,
    );
    _load();
  }

  @override
  void setup() async {
    _load();
  }
}
