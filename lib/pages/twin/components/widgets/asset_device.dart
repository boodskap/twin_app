import 'package:flutter/material.dart';
import 'package:twin_app/pages/twin/components/widgets/device_info_snippet.dart';
import 'package:twin_app/pages/twin/components/widgets/utils.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class AssetDevice extends StatefulWidget {
  final Asset asset;

  const AssetDevice({super.key, required this.asset});

  @override
  State<AssetDevice> createState() => _AssetDeviceState();
}

class _AssetDeviceState extends BaseState<AssetDevice> {
  final List<Device> _devices = [];
  final List<Device> _selected = [];

  @override
  void setup() async {
    if (widget.asset.devices!.isNotEmpty) {
      var res = await TwinnedSession.instance.twin.getDevices(
          apikey: TwinnedSession.instance.authToken,
          body: GetReq(ids: widget.asset.devices!));
      if (validateResponse(res)) {
        setState(() {
          _selected.addAll(res.body!.values!);
        });
      }
    }
    await _search('*');
  }

  bool _isSelected(Device dev) {
    return _selected.any((element) => element.id == dev.id);
  }

  Future _search(String search) async {
    if (loading) return;
    loading = true;

    await execute(() async {
      _devices.clear();

      var res = await TwinnedSession.instance.twin.searchDevices(
          apikey: TwinnedSession.instance.authToken,
          body: SearchReq(search: search, page: 0, size: 25));

      if (validateResponse(res)) {
        List<Device> devices = [];
        for (var dev in res.body!.values!) {
          if (!_isSelected(dev)) {
            devices.add(dev);
          }
        }

        refresh(sync: () {
          _devices.addAll(devices);
        });
      }
    });

    loading = false;
  }

  Widget _buildDevice(int idx) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: Colors.white,
          child: DeviceInfoSnippet(
            device: _devices[idx],
          ),
        ),
        Align(
            alignment: Alignment.topRight,
            child: InkWell(
                child: Tooltip(
                    message: 'Associate with ${widget.asset.name}',
                    child: const Icon(Icons.link)),
                onDoubleTap: () {
                  setState(() {
                    _selected.add(_devices.removeAt(idx));
                  });
                }))
      ],
    );
  }

  Widget _buildSelectedDevice(int idx) {
    return Card(
      elevation: 5,
      child: Container(
        color: Colors.white,
        child: Stack(alignment: Alignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DeviceInfoSnippet(
              device: _selected[idx],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Tooltip(
              message: 'Disassociate from ${widget.asset.name}',
              child: IconButton(
                  onPressed: () {
                    _disassociate(idx);
                  },
                  icon: const Icon(Icons.link_off)),
            ),
          ),
        ]),
      ),
    );
  }

  Future _save() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      widget.asset.devices!.clear();
      for (var element in _selected) {
        widget.asset.devices!.add(element.id);
        var res = await TwinnedSession.instance.twin.updateAsset(
            apikey: TwinnedSession.instance.authToken,
            assetId: widget.asset.id,
            body: Utils.assetInfo(widget.asset));
        if (validateResponse(res)) {
          await alert("Asset - ${widget.asset.name}", 'Saved successfully!');
          _close();
        }
      }
    });
    loading = false;
    refresh();
  }

  Future _disassociate(int idx) async {
    await confirm(
      title: 'Are you sure?',
      message:
          'You want to disassociate ${_selected[idx].name} with ${widget.asset.name}?',
      onPressed: () {
        setState(() {
          _devices.add(_selected.removeAt(idx));
        });
      },
    );
  }

  void _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Asset - ${widget.asset.name}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              )),
          divider(),
          SizedBox(
            height: 30,
            child: Align(
              alignment: Alignment.topRight,
              child: SearchBar(
                leading: const Icon(Icons.search),
                onChanged: (search) async {
                  await _search(search);
                },
              ),
            ),
          ),
          divider(),
          const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Available Devices',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              )),
          SizedBox(
            height: 165,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: _devices.length,
                  itemBuilder: (ctx, idx) {
                    return _buildDevice(idx);
                  }),
            ),
          ),
          divider(),
          const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Linked Devices',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              )),
          SizedBox(
            height: 320,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: _selected.length,
                  itemBuilder: (ctx, idx) {
                    return _buildSelectedDevice(idx);
                  }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const BusyIndicator(),
              divider(horizontal: true),
              SecondaryButton(
                labelKey: "Close",
                onPressed: () {
                  _close();
                },
              ),
              divider(horizontal: true),
              PrimaryButton(
                leading: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                labelKey: "Save",
                onPressed: () async {
                  await _save();
                },
              ),
              divider(horizontal: true),
            ],
          ),
        ],
      ),
    );
  }
}
