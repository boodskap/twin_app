import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/role_snippet.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends BaseState<RolesPage> {
  String _search = '*';
  final List<Widget> _cards = [];
  final List<tapi.Role> _rolesList = [];
  bool _canEdit = false;

  Map<String, bool> _editable = Map<String, bool>();

  int totalCount = 0;
  @override
  void initState() {
    super.initState();
    _checkCanEdit();
  }

  Widget _buildCard(tapi.Role entity) {
    bool editable = _canEdit;
    if (!editable) {
      editable = _editable[entity.id] ?? false;
    }
    return SizedBox(
        width: 250,
        height: 250,
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
                              style: theme
                                  .getStyle()
                                  .copyWith(fontWeight: FontWeight.bold))),
                      divider(),
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
                          Tooltip(
                            message:
                                _canEdit ? "Update" : "No Permission to Update",
                            child: IconButton(
                                onPressed: _canEdit
                                    ? () {
                                        _addEditRoleDialog(role: entity);
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.edit,
                                  color: _canEdit
                                      ? theme.getPrimaryColor()
                                      : Colors.grey,
                                )),
                          ),
                          Tooltip(
                            message:
                                _canEdit ? "Delete" : "No Permission to Delete",
                            child: IconButton(
                                onPressed: _canEdit
                                    ? () {
                                        _confirmAndDeleteRole(
                                            context, entity.id);
                                      }
                                    : null,
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: _canEdit ? Colors.red : Colors.grey,
                                )),
                          ),
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
                  "Total Roles  :  $totalCount",
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
                          _load();
                        },
                        icon: const Icon(Icons.refresh)),
                  ),
                  divider(horizontal: true),
                  PrimaryButton(
                    minimumSize: Size(130, 40),
                    labelKey: 'Add Role',
                    leading: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onPressed: canCreate()
                        ? () {
                            _addEditRoleDialog();
                          }
                        : null,
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
                      hintText: "Search Role",
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
              child: Text('No Role found',
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

  void _addEditRoleDialog({tapi.Role? role}) async {
    await super.alertDialog(
        titleStyle: theme
            .getStyle()
            .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
        title: null == role ? 'Add New Role' : 'Update Role',
        body: RolesSnippet(
          roles: role,
        ),
        width: 750,
        height: MediaQuery.of(context).size.height / 3);
    _load();
  }

  void _confirmAndDeleteRole(BuildContext context, String id) {
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
      titleTextStyle: theme.getStyle().copyWith(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
      contentTextStyle: theme.getStyle(),
      title: Text(
        "WARNING",
        style: theme.getStyle().copyWith(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
      content: Text(
        "Deleting a Role can not be undone.\nYou will loose all of the role data, history, etc.\n\nAre you sure you want to delete?",
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
        int index = _rolesList.indexWhere((element) => element.id == id);
        var res = await TwinnedSession.instance.twin.deleteRole(
          apikey: TwinnedSession.instance.authToken,
          roleId: id,
        );
        if (validateResponse(res)) {
          refresh(
            sync: () {
              _rolesList.removeAt(index);
              _cards.removeAt(index);
              totalCount = _rolesList.length;
            },
          );
        }
      },
    );

    loading = false;
    refresh();
  }

  Future<void> _checkCanEdit() async {
    List<String> clientIds = await getClientIds();
    bool canEditResult = await canEdit(clientIds: clientIds);

    setState(() {
      _canEdit = canEditResult;
    });
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    refresh(sync: () {
      _cards.clear();
      _rolesList.clear();
    });

    execute(() async {
      var res = await TwinnedSession.instance.twin.searchRoles(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.SearchReq(search: _search, page: 0, size: 25));
      if (validateResponse(res)) {
        totalCount = res.body!.total;
        for (tapi.Role roles in res.body!.values!) {
          _editable[roles.id] = await super.canEdit(clientIds: roles.clientIds);

          refresh(sync: () {
            _rolesList.add(roles);
            _cards.add(_buildCard(roles));
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
