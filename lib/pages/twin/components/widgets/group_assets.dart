import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class GroupAssets extends StatefulWidget {
  final AssetGroup group;

  const GroupAssets({super.key, required this.group});

  @override
  State<GroupAssets> createState() => _GroupAssetsState();
}

class _GroupAssetsState extends BaseState<GroupAssets> {
  final List<Asset> _assets = [];
  final List<Asset> _selected = [];

  @override
  void setup() {
    _load();
  }

  bool _isSelected(Asset asset) {
    return _selected.any((element) => element.id == asset.id);
  }

  Future _load() async {
    _selected.clear();
    _assets.clear();

    await execute(() async {
      var res = await TwinnedSession.instance.twin.getAssets(
          apikey: TwinnedSession.instance.authToken,
          body: GetReq(ids: widget.group.assetIds));
      if (validateResponse(res)) {
        _selected.addAll(res.body?.values ?? []);
      }
    });

    refresh();

    await _search('*');
  }

  Future _search(String search) async {
    if (loading) return;

    loading = true;
    await execute(() async {
      _assets.clear();
      var res = await TwinnedSession.instance.twin.searchAssets(
          apikey: TwinnedSession.instance.authToken,
          body: SearchReq(search: search, page: 0, size: 100));
      if (validateResponse(res)) {
        for (var asset in res.body!.values!) {
          if (!_isSelected(asset)) {
            _assets.add(asset);
          }
        }
        setState(() {});
      }
    });
    loading = false;
  }

  Widget _buildAsset(int idx) {
    return InkWell(
      onDoubleTap: () {
        setState(() {
          _selected.add(_assets.removeAt(idx));
        });
      },
      child: SizedBox(
        width: 250,
        child: Card(
          elevation: 5,
          child: Container(
            color: Colors.white,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text(
                  _assets[idx].name,
                  style: theme.getStyle().copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedAsset(int idx) {
    return SizedBox(
      width: 250,
      child: Card(
        elevation: 5,
        child: Container(
          color: Colors.white,
          child: Stack(children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _selected[idx].name,
                  style: theme.getStyle().copyWith(
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Tooltip(
                message: 'Disassociate from ${widget.group.name}',
                child: IconButton(
                    onPressed: () {
                      _disassociate(idx);
                    },
                    icon: const Icon(Icons.link_off)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future _save() async {
    await execute(() async {
      widget.group.assetIds.clear();
      for (var asset in _selected) {
        widget.group.assetIds.add(asset.id);
      }
      List<String> clientIds = [];

      if (isClient()) {
        clientIds = await getClientIds();
      }

      debugPrint('Saving associated assets ${widget.group.assetIds}');

      var res = await TwinnedSession.instance.twin.updateAssetGroup(
          apikey: TwinnedSession.instance.authToken,
          assetGroupId: widget.group.id,
          body: AssetGroupInfo(
            name: widget.group.name,
            description: widget.group.description,
            tags: widget.group.tags,
            target: widget.group.target == AssetGroupTarget.app
                ? AssetGroupInfoTarget.app
                : AssetGroupInfoTarget.user,
            assetIds: widget.group.assetIds,
            clientIds: clientIds,
          ));
      if (validateResponse(res)) {
        debugPrint('Saved associated assets ${res.body?.entity?.assetIds}');
        await alert(
          "Asset Group - ${widget.group.name}",
          'Saved successfully!',
          titleStyle: theme.getStyle().copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
          contentStyle: theme.getStyle().copyWith(
                color: Colors.black,
              ),
        );
        _close();
      }
    });
  }

  Future _disassociate(int idx) async {
    await confirm(
      title: 'Are you sure?',
      message:
          'You want to disassociate ${_selected[idx].name} with ${widget.group.name}?',
      titleStyle: theme.getStyle().copyWith(color: Colors.red),
      messageStyle: theme.getStyle(),
      onPressed: () {
        setState(() {
          _assets.add(_selected.removeAt(idx));
        });
      },
    );
  }

  void _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> availableChildren = [];
    List<Widget> selectedChildren = [];

    for (int i = 0; i < _assets.length; i++) {
      availableChildren.add(_buildAsset(i));
    }

    for (int i = 0; i < _selected.length; i++) {
      selectedChildren.add(_buildSelectedAsset(i));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Asset Group - ${widget.group.name}',
                style: theme.getStyle().copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
              )),
          divider(height: 12),
          SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.topRight,
              child: SearchBar(
                hintText: 'search assets',
                hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                textStyle: WidgetStatePropertyAll(theme.getStyle()),
                leading: const Icon(Icons.search),
                onChanged: (search) async {
                  await _search(search);
                },
              ),
            ),
          ),
          divider(height: 12),
          Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Text(
                    'Available Assets',
                    style: theme.getStyle().copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                  ),
                  divider(horizontal: true),
                  Text(
                    '(double click to select)',
                    style: theme.getStyle().copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                  ),
                ],
              )),
          SizedBox(
            height: 165,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: availableChildren,
                ),
              ),
            ),
          ),
          divider(),
          Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Selected Assets',
                style: theme.getStyle().copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
              )),
          SizedBox(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: selectedChildren,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!smallScreen) const BusyIndicator(),
              divider(horizontal: true),
              if (smallScreen)
                SecondaryButton(
                  minimumSize: Size(50, 50),
                  labelKey: "Close",
                  onPressed: () {
                    _close();
                  },
                ),
              if (!smallScreen)
                SecondaryButton(
                  labelKey: "Close",
                  onPressed: () {
                    _close();
                  },
                ),
              divider(horizontal: true),
              if (smallScreen)
                PrimaryButton(
                  minimumSize: Size(50, 50),
                  labelKey: "Save",
                  onPressed: () async {
                    await _save();
                  },
                ),
              if (!smallScreen)
                PrimaryButton(
                  labelKey: "Save",
                  onPressed: () async {
                    await _save();
                  },
                ),
              if (smallScreen) divider(horizontal: true),
            ],
          ),
          divider(),
          if (smallScreen)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BusyIndicator(),
                divider(),
              ],
            ),
        ],
      ),
    );
  }
}
