import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/asset_library_content_page.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:uuid/uuid.dart';

typedef BasicInfoCallback = void Function(
    String name, String? description, String? tags);

class AssetLibrary extends StatefulWidget {
  const AssetLibrary({super.key});

  @override
  State<AssetLibrary> createState() => _AssetLibraryState();
}

class _AssetLibraryState extends BaseState<AssetLibrary> {
  final List<tapi.AssetModel> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';
  bool _canEdit = false;
  Map<String, bool> _editable = Map<String, bool>();

  @override
  void initState() {
    super.initState();
    _canEdit = TwinnedSession.instance.isAdmin();
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
              icon: Icon(Icons.refresh),
            ),
            divider(horizontal: true),
            if (canCreate())
              PrimaryButton(
                labelKey: 'Create New',
                leading: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  _create();
                },
              ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  leading: Icon(Icons.search),
                  hintText: 'Search Asset Library',
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
                'No asset library found',
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

  Widget _buildCard(tapi.AssetModel e) {
    double width = MediaQuery.of(context).size.width / 8;
    bool editable = _canEdit;
    if (!editable) {
      editable = _editable[e.id] ?? false;
    }
    return InkWell(
      onDoubleTap: () {
        if (editable) {
          _edit(e);
        }
      },
      child: SizedBox(
        width: width,
        height: width,
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
                      if (editable)
                        InkWell(
                            onTap: () {
                              _edit(e);
                            },
                            child: Icon(Icons.edit,
                                color: theme.getPrimaryColor())),
                      if (editable)
                        InkWell(
                          onTap: () {
                            _confirmDeletionDialog(
                              context,
                              e,
                            );
                          },
                          child: Icon(
                            Icons.delete,
                            color: theme.getPrimaryColor(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (null != e.images && e.images!.isNotEmpty)
                Align(
                  alignment: Alignment.center,
                  child: TwinImageHelper.getImage(e.domainKey, e.images!.first,
                      width: width / 2, height: width / 2),
                )
            ],
          ),
        ),
      ),
    );
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
                      setState(() {
                        nameText = value;
                      });
                    },
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        descText = value;
                      });
                    },
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        tagsText = value;
                      });
                    },
                    decoration: const InputDecoration(
                        hintText: 'Tags (space separated)'),
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
                labelKey: 'Ok',
                onPressed: () {
                  if (nameText!.length < 3) {
                    alert('Invalid',
                        'Name is required and should be minimum 3 characters');
                    return;
                  }
                  setState(() {
                    onPressed(nameText!, descText, tagsText);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future _create() async {
    List<String>? clientIds = super.isClientAdmin()
        ? await TwinnedSession.instance.getClientIds()
        : null;

    if (loading) return;
    loading = true;
    await _getBasicInfo(context, 'New Asset Type',
        onPressed: (name, desc, t) async {
      List<String> tags = [];
      if (null != t) {
        tags = t.trim().split(' ');
      }
      var mRes = await TwinnedSession.instance.twin.createAssetModel(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.AssetModelInfo(
            name: name,
            description: desc,
            tags: tags,
            clientIds: clientIds,
          ));
      if (validateResponse(mRes)) {
        // Twinned.selectedAssetModel = mRes.body!.entity!;
        // await _openAssetModel(mRes.body!.entity!);
        // if (null != widget.newAssetModelAdded) {
        //   widget.newAssetModelAdded!(mRes.body!.entity!);
        //   BaseState.emitPageEvent(PageEvent.assetModelCreated,
        //       sender: this, data: UserSession().selectedModel?.id);
        // }
      }
    });
    loading = false;
    refresh();
  }

  Future _edit(tapi.AssetModel e) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AssetLibraryContentPage(key: Key(const Uuid().v4()), assetModel: e),
      ),
    );
    await _load();
  }

  _confirmDeletionDialog(BuildContext context, tapi.AssetModel e) {
    Widget cancelButton = SecondaryButton(
      labelKey: 'Cancel',
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = PrimaryButton(
      labelKey: 'Delete',
      onPressed: () {
        Navigator.pop(context);
        _delete(e);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: theme.getStyle(),
      ),
      content: Text(
        "Deleting a Asset Library can not be undone.\nYou will loose all of the premise data, history, etc.\n\nAre you sure you want to delete?",
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

  Future _delete(tapi.AssetModel e) async {
    await execute(() async {
      var res = await TwinnedSession.instance.twin.deleteAssetModel(
          apikey: TwinnedSession.instance.authToken, assetModelId: e.id);
      validateResponse(res);
      await _load();
    });
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _entities.clear();
    _cards.clear();

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.searchAssetModels(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.AssetModel e in _entities) {
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
