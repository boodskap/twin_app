import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;
import 'package:twin_commons/core/twinned_session.dart';

typedef OnSave = void Function();

class AssetDeviceModelSnippet extends StatefulWidget {
  final OnSave onSave;
  final tapi.AssetDeviceModel assetDeviceModel;

  const AssetDeviceModelSnippet(
      {super.key, required this.assetDeviceModel, required this.onSave});

  @override
  State<AssetDeviceModelSnippet> createState() =>
      _AssetDeviceModelSnippetState();
}

class _AssetDeviceModelSnippetState extends BaseState<AssetDeviceModelSnippet> {
  tapi.DeviceModel? deviceModel;
  final Map<String, tapi.ScrappingTableConfig> _scrappingTableConfigs = {};
  final Map<String, List<tapi.ScrappingTable>> _scrappingTables = {};
  final Map<String, tapi.ScrappingTable?> _selectedTables = {};
  final Map<String, tapi.ScrappingTable> _allTables = {};

  String getAttrValue(String lookupName, String name, String defValue) {
    for (var element in widget.assetDeviceModel!.scrappingTables!) {
      if (element.lookupName == lookupName) {
        for (var attr in element.attributes) {
          if (attr.name == name) {
            return attr.$value;
          }
        }
      }
    }
    return defValue;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    _scrappingTableConfigs.forEach((lookupName, config) {
      List<DropdownMenuItem<tapi.ScrappingTable>> entries = [];
      List<Widget> params = [];

      for (tapi.ScrappingTable t in _scrappingTables[lookupName] ?? []) {
        entries.add(DropdownMenuItem<tapi.ScrappingTable>(
            value: t, child: Text(t.name)));
      }
      var selected = _selectedTables[lookupName];
      if (null != selected) {
        for (var p in selected.attributes) {
          if (!(p.editable ?? true)) continue;
          TextEditingController controller = TextEditingController(
              text: getAttrValue(lookupName, p.name, p.$value));
          int idx = selected.attributes.indexOf(p);
          params.add(SizedBox(
            width: 250,
            child: LabelTextField(
              label: '${p.label} - [${p.name}]',
              controller: controller,
              onChanged: (value) {
                var np = p.copyWith($value: value);
                selected.attributes[idx] = np;
              },
            ),
          ));
        }
      }

      children.add(Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${config.scrappingTableName} (${config.lookupName})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              divider(horizontal: true),
              DropdownButton<tapi.ScrappingTable>(
                  value: _selectedTables[lookupName],
                  onChanged: (selected) {
                    setState(() {
                      _selectedTables[lookupName] = selected;
                    });
                  },
                  items: entries),
            ],
          ),
          divider(),
          Wrap(
            spacing: 8.0,
            children: params,
          ),
          divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    _save(lookupName);
                  },
                  icon: const Icon(Icons.save)),
            ],
          )
        ],
      ));
      children.add(divider());
    });

    return Column(children: children);
  }

  void _save(String lookupName) {
    tapi.ScrappingTable scrappingTable = _selectedTables[lookupName]!;
    tapi.AssetScrappingTable assetScrappingTable =
        tapi.AssetScrappingTable(
            lookupName: lookupName,
            scrappingTableId: scrappingTable.id,
            scrappingTableName: scrappingTable.name,
            attributes: scrappingTable.attributes);

    widget.assetDeviceModel.scrappingTables!
        .removeWhere((element) => element.lookupName == lookupName);

    widget.assetDeviceModel.scrappingTables!.add(assetScrappingTable);

    widget.onSave();
  }

  Future load() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var mRes = await TwinnedSession.instance.twin.getDeviceModel(
          apikey: TwinnedSession.instance.authToken,
          modelId: widget.assetDeviceModel.deviceModelId);

      if (validateResponse(mRes)) {
        deviceModel = mRes.body!.entity;
      }

      if (null == deviceModel) return;

      for (var e in deviceModel!.scrappingTableConfigs!) {
        _scrappingTableConfigs[e.lookupName] = e;

        var sRes = await TwinnedSession.instance.twin.getScrappingTables(
            apikey:TwinnedSession.instance.authToken,
            body: tapi.GetReq(ids: e.scrappingTableIds));

        if (validateResponse(sRes)) {
          _scrappingTables[e.lookupName] = sRes.body!.values ?? [];
          if (_scrappingTables[e.lookupName]!.isNotEmpty) {
            _selectedTables[e.lookupName] =
                _scrappingTables[e.lookupName]!.first;
          }
        }
      }

      for (var e in widget.assetDeviceModel.scrappingTables!) {
        List<tapi.ScrappingTable>? tables = _scrappingTables[e.lookupName];
        if (null != tables) {
          for (var t in tables) {
            if (t.id == e.scrappingTableId) {
              _selectedTables[e.lookupName] = t;
            }
          }
        }
      }

      _scrappingTables.forEach((key, value) {
        for (var t in value) {
          _allTables[t.id] = t;
        }
      });
    });

    refresh();

    loading = false;
  }

  @override
  void setup() {
    load();
  }
}
