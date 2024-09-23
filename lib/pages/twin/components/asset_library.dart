import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/asset_library_content_page.dart';
import 'package:twin_app/pages/twin/components/widgets/create_asset_library_snippet.dart';
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
  Map<String, bool> _editable = Map<String, bool>();

  @override
  void initState() {
    super.initState();
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
              icon: Icon(Icons.refresh),
            ),
            divider(horizontal: true),
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
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
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
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _cards,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(tapi.AssetModel e) {
    double width = MediaQuery.of(context).size.width / 8;
    bool editable = _editable[e.id] ?? false;
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
                    style: theme.getStyle().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                      Tooltip(
                        message: editable ? "Update" : "No Permission to Edit",
                        child: InkWell(
                          onTap: editable
                              ? () {
                                  _edit(e);
                                }
                              : null,
                          child: Icon(
                            Icons.edit,
                            color: editable
                                ? theme.getPrimaryColor()
                                : Colors.grey,
                          ),
                        ),
                      ),
                      Tooltip(
                        message:
                            editable ? "Delete" : "No Permission to Delete",
                        child: InkWell(
                          onTap: editable
                              ? () {
                                  _confirmDeletionDialog(context, e);
                                }
                              : null,
                          child: Icon(
                            Icons.delete_forever_rounded,
                            color: editable
                                ? theme.getPrimaryColor()
                                : Colors.grey,
                          ),
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

  Future _create() async {
    await super.alertDialog(
      titleStyle:
          theme.getStyle().copyWith(fontSize: 20, fontWeight: FontWeight.bold),
      title: 'New Asset Type',
      width: MediaQuery.of(context).size.width / 2 + 100,
      height: MediaQuery.of(context).size.height / 2 + 100,
      body: const CreateEditAssetLibrary(),
    );
    _load();
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
        style: theme.getStyle().copyWith(color: Colors.red),
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
    if (loading) return;
    loading = true;

    await execute(() async {
      int index = _entities.indexWhere((element) => element.id == e.id);
      var res = await TwinnedSession.instance.twin.deleteAssetModel(
          apikey: TwinnedSession.instance.authToken, assetModelId: e.id);
      validateResponse(res);
      await _load();
      _entities.removeAt(index);
      _cards.removeAt(index);
      alert("Asset Library - ${e.name}", " Deleted Successfully!",
          contentStyle: theme.getStyle(),
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
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
