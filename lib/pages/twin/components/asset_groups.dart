import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/group_assets.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;

// Define the callback type
typedef BasicInfoCallback = Future<void> Function(
    String name, String? description, String? tags);

class AssetGroupList extends StatefulWidget {
  final twinned.AssetGroupInfoTarget target;

  const AssetGroupList({
    super.key,
    required this.target,
  });

  @override
  State<AssetGroupList> createState() => _AssetGroupListState();
}

class _AssetGroupListState extends BaseState<AssetGroupList> {
  final List<twinned.AssetGroup> _groups = [];
  Map<String, bool> _editable = Map<String, bool>();
  double cardWidth = 200;
  double cardHeight = 200;

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = [];

    if (smallScreen) {
      cardWidth = (MediaQuery.of(context).size.width / 2) - 15;
      cardHeight = cardWidth;
    }

    for (var group in _groups) {
      bool editable = _editable[group.id] ?? false;
      Widget? image;
      if (group.icon != null && group.icon!.isNotEmpty) {
        image = TwinImageHelper.getCachedImage(group.domainKey, group.icon!);
      }

      cards.add(InkWell(
        onDoubleTap: () async {
          if (editable) {
            await _editGroup(group);
          }
        },
        child: Card(
          elevation: 10,
          child: Container(
            color: Colors.white,
            width: cardWidth,
            height: cardHeight,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (image != null)
                        SizedBox(width: 48, height: 48, child: image),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          group.name,
                          style: theme.getStyle().copyWith(fontSize: 14),
                        ),
                      ),
                      Text(
                        '${group.assetIds.length} assets',
                        style: theme
                            .getStyle()
                            .copyWith(fontSize: 10, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 8,
                  child: Tooltip(
                    message: editable ? "Delete" : "No Permission to Delete",
                    child: IconButton(
                      onPressed: editable
                          ? () async {
                              await _delete(group);
                            }
                          : null,
                      icon: Icon(
                        Icons.delete_forever,
                        color: editable ? theme.getPrimaryColor() : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 45,
                  child: Tooltip(
                    message: editable ? "Update" : "No Permission to Edit",
                    child: IconButton(
                      onPressed: editable
                          ? () async {
                              await _editGroup(group);
                            }
                          : null,
                      icon: Icon(
                        Icons.edit,
                        color: editable ? theme.getPrimaryColor() : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  child: Tooltip(
                    message: editable ? "Upload" : "No Permission to Upload",
                    child: IconButton(
                      onPressed: editable
                          ? () async {
                              await _upload(group);
                            }
                          : null,
                      icon: Icon(
                        Icons.upload,
                        color: editable ? theme.getPrimaryColor() : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const BusyIndicator(),
            IconButton(
              onPressed: () async {
                await _load();
              },
              icon: const Icon(Icons.refresh),
            ),
            divider(horizontal: true),
            PrimaryButton(
              labelKey: 'Create New',
              leading: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: (widget.target == twinned.AssetGroupInfoTarget.user ||
                      canCreate())
                  ? () {
                      _addNew();
                    }
                  : null,
            ),
            divider(horizontal: true),
          ],
        ),
        divider(),
        if (_groups.isEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (loading) const BusyIndicator(),
              if (!loading)
                Text('No asset group found', style: theme.getStyle()),
            ],
          ),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              runAlignment: WrapAlignment.start,
              children: cards,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _load() async {
    if (loading) return;
    loading = true;
    _groups.clear();

    await execute(() async {
      final res = await TwinnedSession.instance.twin.searchAssetGroups(
        apikey: TwinnedSession.instance.authToken,
        myGroups: widget.target == twinned.AssetGroupInfoTarget.user,
        body: const twinned.SearchReq(search: '*', page: 0, size: 10000),
      );

      if (validateResponse(res)) {
        _groups.addAll(res.body!.values!);
      }
    });

    for (twinned.AssetGroup ag in _groups) {
      _editable[ag.id] = await canEdit(clientIds: ag.clientIds);
    }

    loading = false;
    refresh();
  }

  Future<void> _addNew() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      await _getBasicInfo(
        context,
        'New Asset Group',
        onPressed: (String name, String? description, String? tags) async {
          final res = await TwinnedSession.instance.twin.createAssetGroup(
            apikey: TwinnedSession.instance.authToken,
            body: twinned.AssetGroupInfo(
              name: name,
              description: description,
              tags: (tags ?? '').split(' '),
              icon: '',
              target: widget.target,
              assetIds: [],
              clientIds: await getClientIds(),
            ),
          );

          if (validateResponse(res)) {
            await _load();
            await alert(
              'Assert Group - ${res.body!.entity!.name}',
              'Created successfully',
              titleStyle: theme.getStyle().copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
              contentStyle: theme.getStyle().copyWith(
                    color: Colors.black,
                  ),
            );
          }
        },
      );
    });
    loading = false;
    refresh();
  }

  Future<void> _delete(twinned.AssetGroup e) async {
    if (loading) return;
    loading = true;

    await confirm(
      title: 'Warning',
      message: 'Deleting is unrecoverable\n\nDo you want to proceed?',
      titleStyle: theme.getStyle().copyWith(color: Colors.red),
      messageStyle: theme.getStyle(),
      onPressed: () async {
        await execute(() async {
          int index = _groups.indexWhere((element) => element.id == e.id);

          final res = await TwinnedSession.instance.twin.deleteAssetGroup(
            apikey: TwinnedSession.instance.authToken,
            assetGroupId: e.id,
          );

          if (validateResponse(res)) {
            await _load();

            _groups.removeAt(index);
            alert(
              "Asset Group - ${e.name}",
              "Deleted successfully!",
              titleStyle: theme.getStyle().copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
              contentStyle: theme.getStyle().copyWith(
                    color: Colors.black,
                  ),
            );
          }
          ;
        });
        loading = false;
        refresh();
      },
    );
  }

  Future<void> _editGroup(twinned.AssetGroup group) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          //backgroundColor: Colors.white,
          titleTextStyle: theme.getStyle().copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
          contentTextStyle: theme.getStyle(),
          scrollable: true,
          content: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            height: 650,
            child: SingleChildScrollView(child: GroupAssets(group: group)),
          ),
        );
      },
    );

    await _load();
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
          contentTextStyle: theme.getStyle(),
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
                      nameText = value;
                    },
                    style: theme.getStyle(),
                    decoration: InputDecoration(
                        hintText: 'Name',
                        labelStyle: theme.getStyle(),
                        hintStyle: theme.getStyle())),
                TextField(
                  onChanged: (value) {
                    descText = value;
                  },
                  style: theme.getStyle(),
                  decoration: InputDecoration(
                      hintText: 'Description',
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle()),
                ),
                TextField(
                  style: theme.getStyle(),
                  onChanged: (value) {
                    tagsText = value;
                  },
                  decoration: InputDecoration(
                      hintText: 'Tags (space separated)',
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle()),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            if (smallScreen)
              SecondaryButton(
                minimumSize: Size(50, 50),
                labelKey: "Cancel",
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            if (!smallScreen)
              SecondaryButton(
                labelKey: "Cancel",
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            divider(horizontal: true),
            if (smallScreen)
              PrimaryButton(
                minimumSize: Size(50, 50),
                labelKey: "OK",
                onPressed: () {
                  if (nameText!.length < 3) {
                    alert(
                      'Invalid',
                      'Name is required and should be minimum 3 characters',
                      titleStyle: theme
                          .getStyle()
                          .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      contentStyle: theme.getStyle(),
                    );
                    return;
                  }
                  onPressed(nameText!, descText, tagsText);
                  Navigator.pop(context);
                },
              ),
            if (!smallScreen)
              PrimaryButton(
                labelKey: "OK",
                onPressed: () {
                  if (nameText!.length < 3) {
                    alert(
                      'Invalid',
                      'Name is required and should be minimum 3 characters',
                      titleStyle: theme
                          .getStyle()
                          .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      contentStyle: theme.getStyle(),
                    );
                    return;
                  }
                  onPressed(nameText!, descText, tagsText);
                  Navigator.pop(context);
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _upload(twinned.AssetGroup group) async {
    if (loading) return;
    loading = true;
    await execute(() async {
      final res = await TwinImageHelper.uploadDomainIcon();
      if (res?.entity != null) {
        final rRes = await TwinnedSession.instance.twin.updateAssetGroup(
          apikey: TwinnedSession.instance.authToken,
          assetGroupId: group.id,
          body: twinned.AssetGroupInfo(
            name: group.name,
            description: group.description,
            tags: group.tags,
            icon: res!.entity!.id,
            target: widget.target,
            assetIds: group.assetIds,
            clientIds: await getClientIds(),
          ),
        );

        if (validateResponse(rRes)) {
          await _load();
          await alert(
            'Asset Group - ${rRes.body!.entity!.name}',
            'Saved successfully',
            titleStyle: theme.getStyle().copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
            contentStyle: theme.getStyle().copyWith(
                  color: Colors.black,
                ),
          );
        }
      }
    });
    loading = false;
    refresh();
  }

  @override
  void setup() async {
    await _load();
  }
}
