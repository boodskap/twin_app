import 'package:flutter/material.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
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

  static const TextStyle _warnTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle _labelPopupTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

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
                          style: theme
                              .getStyle()
                              .copyWith(fontWeight: FontWeight.bold),
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
                              child:
                                  TwinImageHelper.getDomainImage(entity.icon!)),
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
                                _confirmAndDeleteClient(client: entity);
                              },
                              icon: const Icon(Icons.delete)),
                          IconButton(
                              onPressed: () {
                                _addEditClientDialog(client: entity);
                              },
                              icon: const Icon(Icons.edit)),
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const BusyIndicator(),
              divider(horizontal: true),
              IconButton(
                  onPressed: () {
                    _search = '*';
                    _load();
                  },
                  icon: const Icon(Icons.refresh)),
              divider(horizontal: true),
              PrimaryButton(
                labelKey: 'New Client',
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
                height: 30,
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
                ),
              ),
              divider(
                horizontal: true,
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
              child: Text(
                'No clients found',
                style: theme.getStyle(),
              ),
            ),
          if (_cards.isNotEmpty)
            SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _cards,
              ),
            ),
        ],
      ),
    );
  }

  void _addEditClientDialog({tapi.Client? client}) async {
    await super.alertDialog(
        title: null == client ? 'Add New Client' : 'Update Client',
        body: ClientSnippet(
          client: client,
        ),
        width: 750,
        height: MediaQuery.of(context).size.height - 150);
    _load();
  }

  void _confirmAndDeleteClient({required tapi.Client client}) {
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
          _deleteClient(client);
        });

    AlertDialog alert = AlertDialog(
      title: const Text(
        "WARNING",
        style: _warnTextStyle,
      ),
      content: const Text(
        "Deleting a Client can not be undone.\nYou will loose all of the client data, history, etc.\n\nAre you sure you want to delete?",
        style: _labelPopupTextStyle,
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

  void _close() {
    Navigator.pop(context);
  }

  Future _deleteClient(tapi.Client client) async {
    if (loading) return;
    loading = true;

    bool deleted = false;

    execute(() async {
      var res = await TwinnedSession.instance.twin.deleteClient(
          apikey: TwinnedSession.instance.authToken, clientId: client.id);
      if (validateResponse(res)) {
        deleted = true;
        _close();
        alert('Success', 'Client ${client.name} deleted successfully');
      }
    });

    loading = false;

    if (deleted) {
      _load();
    }
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    refresh(sync: () {
      _cards.clear();
    });

    execute(() async {
      var res = await TwinnedSession.instance.twin.searchClients(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.SearchReq(search: _search, page: 0, size: 25));
      if (validateResponse(res)) {
        for (tapi.Client pp in res.body!.values!) {
          refresh(sync: () {
            _cards.add(_buildCard(pp));
          });
        }
      }
    });

    loading = false;
  }

  @override
  void setup() {
    _load();
  }
}
