import 'package:flutter/material.dart';
import 'package:twin_app/widgets/buy_button.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_app/widgets/purchase_change_addon_widget.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_app/widgets/client_snippet.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/twin_image_helper.dart';

class Clients extends StatefulWidget {
  const Clients({super.key});

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends BaseState<Clients> {
  String _search = '*';
  final List<Widget> _cards = [];
  final List<tapi.Client> _clientList = [];
  bool _exhausted = true;

  int totalCount = 0;

  Widget _buildCard(tapi.Client entity) {
    return SizedBox(
        width: 350,
        height: 350,
        child: Card(
          color: Colors.transparent,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white,
              child: Stack(
                children: [
                  Column(
                    children: [
                      divider(),
                      Center(
                        child: Text(
                          entity.name,
                          style: theme.getStyle().copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      divider(),
                      Center(
                          child: Text(entity.description ?? '',
                              style: theme.getStyle())),
                      divider(),
                      if (null != entity.icon && entity.icon!.isNotEmpty)
                        Center(
                          child: SizedBox(
                              width: 250,
                              height: 250,
                              child: TwinImageHelper.getCachedDomainImage(
                                  entity.icon!)),
                        ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, right: 4.0),
                      child: Wrap(
                        spacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                _addEditClientDialog(client: entity);
                              },
                              icon: const Icon(Icons.edit)),
                          IconButton(
                              onPressed: () {
                                _confirmAndDeleteClient(context, entity.id);
                              },
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Color(0xFFF44336),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Total Clients  :  $totalCount",
                  style: theme.getStyle().copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: const Color(
                        0xFF000000,
                      )),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const BusyIndicator(),
                  divider(horizontal: true),
                  Tooltip(
                    message: "Refresh",
                    child: IconButton(
                        onPressed: () {
                          _search = '*';
                          _checkExhausted();
                          _load();
                        },
                        icon: const Icon(Icons.refresh)),
                  ),
                  divider(horizontal: true),
                  if (_exhausted && canBuyClientPlan())
                    BuyButton(
                        label: 'Buy More License',
                        tooltip:
                            'Utilized ${orgPlan?.totalClientCount ?? '-'} licenses',
                        style: theme.getStyle().copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue),
                        onPressed: _buyAddon),
                  if (!_exhausted)
                    PrimaryButton(
                      minimumSize: Size(130, 40),
                      labelKey: 'Add Client',
                      leading: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _addEditClientDialog();
                      },
                    ),
                  divider(horizontal: true),
                  SizedBox(
                    width: 250,
                    height: 40,
                    child: SearchBar(
                      onChanged: (value) {
                        setState(() {
                          _search = value.trim();
                        });
                        if (_search.isEmpty) {
                          _search = '*';
                        }
                        _load();
                      },
                      hintText: "Search Clients",
                      leading: const Icon(Icons.search),
                      textStyle: WidgetStatePropertyAll(theme.getStyle()),
                      hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                    ),
                  ),
                  divider(
                    horizontal: true,
                  ),
                ],
              ),
            ],
          ),
          if (_cards.isEmpty && loading)
            Center(
              child: Text(
                'Loading...',
                style: theme.getStyle(),
              ),
            ),
          if (_cards.isEmpty && !loading)
            Center(
              child: Text('No clients found',
                  style: theme.getStyle().copyWith(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          if (_cards.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _cards,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addEditClientDialog({tapi.Client? client}) async {
    await super.alertDialog(
        titleStyle: theme
            .getStyle()
            .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
        title: null == client ? 'Add New Client' : 'Update Client',
        body: ClientSnippet(
          client: client,
        ),
        width: 750,
        height: MediaQuery.of(context).size.height - 150);
    _load();
  }

  void _confirmAndDeleteClient(BuildContext context, String id) {
    Widget cancelButton = SecondaryButton(
        labelKey: 'Cancel',
        onPressed: () {
          Navigator.pop(context);
        });
    Widget continueButton = PrimaryButton(
        leading: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
        labelKey: 'Delete',
        onPressed: () {
          _removeEntity(id);
          Navigator.pop(context);
        });

    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: theme.getStyle().copyWith(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
      content: Text(
        "Deleting a Client can not be undone.\nYou will loose all of the client data, history, etc.\n\nAre you sure you want to delete?",
        style: theme.getStyle().copyWith(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
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

  void _removeEntity(String id) async {
    if (loading) return;
    loading = true;
    await execute(
      () async {
        int index = _clientList.indexWhere((element) => element.id == id);
        var res = await TwinnedSession.instance.twin.deleteClient(
          apikey: TwinnedSession.instance.authToken,
          clientId: id,
        );
        if (validateResponse(res)) {
          refresh(
            sync: () {
              _clientList.removeAt(index);
              _cards.removeAt(index);
              totalCount = _clientList.length;
            },
          );
        }
      },
    );

    loading = false;
    refresh();
  }

  Future _buyAddon() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            content: PurchaseChangeAddonWidget(
              orgId: orgs[selectedOrg].id,
              purchase: true,
              clients: 1,
            ),
          );
        });
    await _checkExhausted();
    await _load();
  }

  Future _checkExhausted() async {
    _exhausted = await hasClientsExhausted();
    refresh();
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    refresh(sync: () {
      _cards.clear();
      _clientList.clear();
    });

    execute(() async {
      var res = await TwinnedSession.instance.twin.searchClients(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.SearchReq(search: _search, page: 0, size: 25));
      if (validateResponse(res)) {
        totalCount = res.body!.total;
        for (tapi.Client client in res.body!.values!) {
          refresh(sync: () {
            _clientList.add(client);
            _cards.add(_buildCard(client));
          });
        }
      }
    });

    loading = false;
  }

  @override
  void setup() {
    _checkExhausted();
    _load();
  }
}
