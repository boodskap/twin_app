import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/card_layout.dart';
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
  Map<String, bool> _editable = Map<String, bool>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        divider(),
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
              onPressed: (isAdmin() || isClientAdmin()) ? _create : null,
            ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  leading: Icon(Icons.search),
                  hintText: 'Search Scrapping Table',
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _cards,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(tapi.ScrappingTable e) {
    bool editable = _editable[e.id] ?? false;
    return InkWell(
      onDoubleTap: () {
        if (editable) {
          _edit(e);
        }
      },
      child: Accordion(
          contentVerticalPadding: 0,
          headerBorderColor: theme.getPrimaryColor(),
          headerBorderColorOpened: theme.getPrimaryColor(),
          headerBackgroundColorOpened: theme.getPrimaryColor(),
          headerBackgroundColor: theme.getPrimaryColor(),
          contentBackgroundColor: Colors.white,
          contentBorderColor: theme.getPrimaryColor(),
          headerBorderRadius: 1.2,
          scaleWhenAnimating: true,
          openAndCloseAnimation: true,
          maxOpenSections: 1,
          headerPadding:
              const EdgeInsets.symmetric(vertical: 3.5, horizontal: 7.5),
          children: [
            AccordionSection(
              headerBorderColor: theme.getPrimaryColor(),
              headerBorderColorOpened: theme.getPrimaryColor(),
              headerBackgroundColorOpened: theme.getPrimaryColor(),
              isOpen: false,
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.name,
                    style: theme.getStyle().copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
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
                            color: editable ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                      Tooltip(
                        message:
                            editable ? "Delete" : "No Permission to Delete",
                        child: InkWell(
                          onTap: editable
                              ? () {
                                  confirmDeletion(context, e);
                                }
                              : null,
                          child: Icon(
                            Icons.delete_forever,
                            color: editable ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                      divider(
                        horizontal: true,
                      ),
                    ],
                  ),
                ],
              ),
              content: SizedBox(
                height: 300,
                child: CardLayoutSection(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Parameter Info",
                            style: theme.getStyle().copyWith(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      divider(),
                      ScrappingTableParametersTable(
                        rows: _buildTableRows(e),
                      ),
                      divider(),
                    ],
                  ),
                ),
              ),
            ),
          ]),
    );
  }

  List<TableRow> _buildTableRows(tapi.ScrappingTable e) {
    List<TableRow> rows = [
      TableRow(
        children: [
          Center(
              child: Text(
            'Name',
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.w700,
                ),
          )),
          Center(
              child: Text(
            'Description',
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.w700,
                ),
          )),
          Center(
              child: Text(
            'Label',
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.w700,
                ),
          )),
          Center(
              child: Text(
            'Type',
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.w700,
                ),
          )),
          Center(
              child: Text(
            'Value',
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.w700,
                ),
          )),
          Center(
              child: Text(
            'Editable',
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.w700,
                ),
          )),
        ],
      ),
    ];

    for (var parameter in e.attributes) {
      rows.add(
        TableRow(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                parameter.name,
                style: theme.getStyle().copyWith(fontWeight: FontWeight.w200),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                parameter.description ?? '',
                style: theme.getStyle(),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                parameter.label ?? '',
                style: theme.getStyle(),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                parameter.attributeType.name,
                style: theme.getStyle(),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                parameter.$value,
                style: theme.getStyle(),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                parameter.editable.toString(),
                style: theme.getStyle(),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
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

  Future _edit(tapi.ScrappingTable e) async {
    var res = await TwinnedSession.instance.twin.getScrappingTable(
      scrappingTableId: e.id,
      apikey: TwinnedSession.instance.authToken,
    );
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScrappingTablesContentPage(
          model: res.body!.entity!,
        ),
      ),
    );
    _load();
  }

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
        style: theme.getStyle().copyWith(color: Colors.red),
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
    await execute(() async {
      int index = _entities.indexWhere((element) => element.id == e.id);

      var res = await TwinnedSession.instance.twin.deleteScrappingTable(
        apikey: TwinnedSession.instance.authToken,
        scrappingTableid: e.id,
      );

      if (validateResponse(res)) {
        await _load();
        _entities.removeAt(index);
        _cards.removeAt(index);
        alert("Scrapping Table - ${e.name}", "Deleted Successfully!",
            contentStyle: theme.getStyle(),
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
      }
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
      var sRes = await TwinnedSession.instance.twin.searchScrappingTables(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.ScrappingTable e in _entities) {
        _editable[e.id] = await canEdit(clientIds: e.clientIds);
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

class ScrappingTableParametersTable extends StatelessWidget {
  final List<TableRow> rows;

  ScrappingTableParametersTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Table(
        border: TableBorder.all(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(2),
          5: FlexColumnWidth(1),
        },
        children: rows,
      ),
    );
  }
}
