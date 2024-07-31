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
  void setup() async {
    await _search('*');
  }

  bool _isSelected(Asset asset) {
    return _selected.any((element) => element.id == asset.id);
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
          if (widget.group.assetIds.contains(asset.id)) {
            _selected.add(asset);
          }
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
    return Tooltip(
      message:
          'Double click to associate ${_assets[idx].name} with ${widget.group.name}',
      child: InkWell(
        onDoubleTap: () {
          setState(() {
            _selected.add(_assets.removeAt(idx));
          });
        },
        child: Card(
          elevation: 5,
          child: Container(
            color: Colors.white,
            child: Stack(children: [
              Align(
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
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedAsset(int idx) {
    return Card(
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
    );
  }

  Future _save() async {
    await execute(() async {
      widget.group.assetIds.clear();
      for (var asset in _selected) {
        widget.group.assetIds.add(asset.id);
      }
      var res = await TwinnedSession.instance.twin.updateAssetGroup(
          apikey: TwinnedSession.instance.authToken,
          assetGroupId: widget.group.id,
          body: AssetGroupInfo(
              name: widget.group.name,
              description: widget.group.description,
              tags: widget.group.tags,
              target: AssetGroupInfoTarget.app,
              assetIds: widget.group.assetIds));
      if (validateResponse(res)) {
        await alert(widget.group.name, 'Saved successfully');
        _close();
      }
    });
  }

  Future _disassociate(int idx) async {
    await confirm(
      title: 'Are you sure?',
      message:
          'You want to disassociate ${_selected[idx].name} with ${widget.group.name}?',
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Asset Group - ${widget.group.name}',
                style: theme
                    .getStyle()
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
              )),
          divider(),
          SizedBox(
            height: 30,
            child: Align(
              alignment: Alignment.topRight,
              child: SearchBar(
                hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                textStyle: WidgetStatePropertyAll(theme.getStyle()),
                leading: const Icon(Icons.search),
                onChanged: (search) async {
                  await _search(search);
                },
              ),
            ),
          ),
          divider(),
          Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Available Assets',
                style: theme
                    .getStyle()
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
              )),
          SizedBox(
            height: 165,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8),
                  itemCount: _assets.length,
                  itemBuilder: (ctx, idx) {
                    return _buildAsset(idx);
                  }),
            ),
          ),
          divider(),
          Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Selected Assets',
                style: theme
                    .getStyle()
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
              )),
          SizedBox(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8),
                  itemCount: _selected.length,
                  itemBuilder: (ctx, idx) {
                    return _buildSelectedAsset(idx);
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
