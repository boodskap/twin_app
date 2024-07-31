import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/scrapping_tables_content_page.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

class ScrappingTables extends StatefulWidget {
  const ScrappingTables({super.key});

  @override
  State<ScrappingTables> createState() => _ScrappingTablesState();
}

class _ScrappingTablesState extends BaseState<ScrappingTables> {
  final List<tapi.ScrappingTable> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';

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
                  hintText: 'Search device library',
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
                'No scrapping tables found',
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

  Widget _buildCard(tapi.ScrappingTable e) {
    double width = MediaQuery.of(context).size.width / 8;
    double height = 72;
    return SizedBox(
      width: width,
      height: height,
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
                  style: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
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
                        onTap: () {
                          _edit(e);
                        },
                        child:
                            Icon(Icons.edit, color: theme.getPrimaryColor())),
                    InkWell(
                      onTap: () {
                        confirmDeletion(context, e);
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
          ],
        ),
      ),
    );
  }

  Future _create() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScrappingTablesContentPage(),
      ),
    );
    _load();
  }

  Future _edit(tapi.ScrappingTable e) async {}

  confirmDeletion(BuildContext context, tapi.ScrappingTable e) {
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
        "Deleting a Scrapping Table can not be undone.\nAre you sure you want to delete?",
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

  Future _delete(tapi.ScrappingTable e) async {
    int index = _entities.indexWhere((element) => element.id == e.id);

    var res = await TwinnedSession.instance.twin.deleteScrappingTable(
      apikey: TwinnedSession.instance.authToken,
      scrappingTableid: e.id,
    );

    if (validateResponse(res)) {
      _entities.removeAt(index);
      _cards.removeAt(index);
    }
    refresh();
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _entities.clear();
    _cards.clear();

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.searchScrappingTables(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.ScrappingTable e in _entities) {
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
