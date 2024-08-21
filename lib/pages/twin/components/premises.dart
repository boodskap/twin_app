import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/premise_snippet.dart';
import 'package:twin_app/pages/twin/components/widgets/premises_content_page.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:uuid/uuid.dart';

class Premises extends StatefulWidget {
  const Premises({super.key});

  @override
  State<Premises> createState() => _PremisesState();
}

class _PremisesState extends BaseState<Premises> {
  final List<tapi.Premise> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';
  bool _canEdit = false;
  Map<String, bool> _editable = Map<String, bool>();

  @override
  void initState() {
    super.initState();
    _checkCanEdit();
  }

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
              onPressed: (canCreate()) ? _addEditPremiseDialog : null,
            ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  leading: Icon(Icons.search),
                  hintText: 'Search Premises',
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
                'No premises found',
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

  Widget _buildCard(tapi.Premise e) {
    double width = MediaQuery.of(context).size.width / 8;
    bool editable = _canEdit;
    if (!editable) {
      editable = _editable[e.id] ?? false;
    }
    return InkWell(
      onDoubleTap: () {
        if (_canEdit) {
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
                      Tooltip(
                        message: _canEdit ? "Update" : "No Permission to Edit",
                        child: InkWell(
                          onTap: _canEdit
                              ? () {
                                  _addEditPremiseDialog(premise: e);
                                }
                              : null,
                          child: Icon(
                            Icons.edit,
                            color: _canEdit
                                ? theme.getPrimaryColor()
                                : Colors.grey,
                          ),
                        ),
                      ),
                      Tooltip(
                        message:
                            _canEdit ? "Delete" : "No Permission to Delete",
                        child: InkWell(
                          onTap: _canEdit
                              ? () {
                                  _confirmDeletionDialog(context, e);
                                }
                              : null,
                          child: Icon(
                            Icons.delete_forever_rounded,
                            color: _canEdit
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

  Future<void> _checkCanEdit() async {
    List<String> clientIds = await getClientIds();
    bool canEditResult = await canEdit(clientIds: clientIds);

    setState(() {
      _canEdit = canEditResult;
    });
  }

  Future _edit(tapi.Premise e) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PremiseContentPage(
          premise: e,
          key: Key(
            Uuid().v4(),
          ),
          type: InfraType.premise,
        ),
      ),
    );
    await _load();
  }

  _confirmDeletionDialog(BuildContext context, tapi.Premise e) {
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
        "Deleting a Premise can not be undone.\nYou will loose all of the premise data, history, etc.\n\nAre you sure you want to delete?",
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

  Future _delete(tapi.Premise e) async {
    if (loading) return;
    loading = true;
    await execute(() async {
      int index = _entities.indexWhere((element) => element.id == e.id);
      var res = await TwinnedSession.instance.twin.deletePremise(
        apikey: TwinnedSession.instance.authToken,
        premiseId: e.id,
      );

      if (validateResponse(res)) {
        _entities.removeAt(index);
        _cards.removeAt(index);
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
      var sRes = await TwinnedSession.instance.twin.searchPremises(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.Premise e in _entities) {
        _editable[e.id] = await super.canEdit(clientIds: e.clientIds);
        _cards.add(_buildCard(e));
      }
    });

    loading = false;
    refresh();
  }

  void _addEditPremiseDialog({tapi.Premise? premise}) async {
    await super.alertDialog(
      title: null == premise ? 'Add New Premise' : 'Update Premise',
      body: PremiseSnippet(
        premise: premise,
      ),
      width: 750,
      height: MediaQuery.of(context).size.height - 150,
    );
    _load();
  }

  @override
  void setup() async {
    _load();
  }
}
