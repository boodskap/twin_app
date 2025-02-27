import 'package:flutter/material.dart';
import 'package:twin_app/auth.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/core/twin_helper.dart';
import 'package:twin_app/pages/login/login.dart';
import 'package:twin_app/widgets/buy_button.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_app/widgets/country_codes.dart';
import 'package:twin_app/widgets/purchase_change_addon_widget.dart';
import 'package:twin_app/widgets/user_add_update_snippet.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

var userdefaultImage = Center(
  child: Image.asset(
    'assets/images/user.png',
    height: 100.0,
    width: 100.0,
    fit: BoxFit.contain,
  ),
);

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends BaseState<Users> {
  final List<Widget> _cards = [];
  final List<tapi.TwinUser> _twinUsers = [];
  String _searchQuery = '*';
  int totalCount = 0;
  bool _isTableView = true;
  bool _isCardView = false;
  List<String> rolesSelected = [];
  List<String> clientSelected = [];
  bool _exhausted = false;
  late StreamAuth auth;

  @override
  Widget build(BuildContext context) {
    auth = StreamAuthScope.of(context);
    return Column(
      children: [
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Total Users  :  $totalCount",
                style: theme.getStyle().copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: const Color(0xFF000000),
                    ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const BusyIndicator(),
                divider(horizontal: true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: !_isTableView
                            ? Colors.blue[200]
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.view_array,
                          color: !_isTableView
                              ? Colors.black
                              : theme.getPrimaryColor(),
                        ),
                        onPressed: () {
                          setState(() {
                            _isCardView = true;
                            _isTableView = false;
                          });
                        },
                      ),
                    ),
                    divider(horizontal: true),
                    Container(
                      decoration: BoxDecoration(
                        color: _isTableView
                            ? Colors.blue[200]
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.grid_on,
                          color: _isTableView
                              ? Colors.black
                              : theme.getPrimaryColor(),
                        ),
                        onPressed: () {
                          setState(() {
                            _isCardView = false;
                            _isTableView = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Tooltip(
                  message: 'Refresh',
                  child: IconButton(
                    onPressed: () => _load(),
                    icon: const Icon(Icons.refresh),
                  ),
                ),
                divider(horizontal: true),
                if (_exhausted)
                  BuyButton(
                      label: 'Buy More License',
                      tooltip:
                          'Utilized ${orgPlan?.totalUserCount ?? '-'} licenses',
                      style: theme.getStyle().copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue),
                      onPressed: _buyAddon),
                if (!_exhausted)
                  PrimaryButton(
                    minimumSize: const Size(130, 40),
                    leading: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    labelKey: 'Add User',
                    onPressed: _addUpdateUserDialog,
                  ),
                divider(horizontal: true),
                SizedBox(
                  width: 250,
                  height: 40,
                  child: SearchBar(
                    hintText: "Search User",
                    leading: const Icon(Icons.search),
                    textStyle: WidgetStatePropertyAll(theme.getStyle()),
                    hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = '*${value.trim()}*';
                      });
                      _load();
                    },
                  ),
                ),
                divider(horizontal: true),
              ],
            ),
          ],
        ),
        Expanded(
          child: _isTableView ? _buildTable() : _buildCardView(),
        ),
      ],
    );
  }

  Widget _buildTable() {
    if (_twinUsers.isEmpty) {
      return Center(
        child: Text(
          'No Users Available',
          style: theme.getStyle().copyWith(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        Table(
          border: TableBorder.all(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[300]),
              children: const [
                TableHeader(title: 'Name'),
                TableHeader(title: 'Email Address'),
                TableHeader(title: 'Phone Number'),
                TableHeader(title: 'Action'),
              ],
            ),
            for (var user in _twinUsers) _buildTableRow(user),
          ],
        ),
      ],
    );
  }

  Widget _buildCardView() {
    if (_twinUsers.isEmpty) {
      return Center(
        child: Text(
          'No Users Available',
          style: theme.getStyle().copyWith(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 3 / 2,
      ),
      itemCount: _twinUsers.length,
      itemBuilder: (context, index) {
        final entity = _twinUsers[index];
        return _buildCard(entity);
      },
    );
  }

  TableRow _buildTableRow(tapi.TwinUser user) {
    rolesSelected = user.roles!;
    clientSelected = user.clientIds!;
    setState(() {});

    bool isAdminStatus = false;
    if (user.platformRoles!.contains("domainadmin")) {
      isAdminStatus = true;
    }
    bool isClientAdminStatus = false;

    if (user.platformRoles!.contains("clientadmin")) {
      isClientAdminStatus = true;
      
    }
    String? countryCode = countryCodeMap[user.countryCode];
    String formattedPhone = user.phone != null && user.phone!.isNotEmpty
        ? (user.countryCode!.isNotEmpty && countryCode!.isNotEmpty
            ? '$countryCode ${user.phone}'
            : user.phone!)
        : '';

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(user.name, style: theme.getStyle()),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(user.email, style: theme.getStyle()),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('${formattedPhone}', style: theme.getStyle()),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8.0,
            children: [
              if (isAdmin())
                Tooltip(
                  message: isAdminStatus
                      ? 'Remove Admin Privilege'
                      : 'Assign Admin Privilege',
                  child: IconButton(
                    onPressed: () {
                      confirm(
                          title: 'Info',
                          message: !isAdminStatus
                              ? "Are you sure you want to assign this person as administrator?"
                              : "Are you sure you want to remove administrative privilege from this person?",
                          titleStyle: theme.getStyle(),
                          messageStyle: theme
                              .getStyle()
                              .copyWith(fontWeight: FontWeight.bold),
                          // const TextStyle(fontWeight: FontWeight.bold),
                          onPressed: () async {
                            await execute(() async {
                              if (isAdminStatus) {
                                var res = await TwinnedSession.instance.twin
                                    .unsetAdmin(
                                        apikey:
                                            TwinnedSession.instance.authToken,
                                        twinUserId: user.id);
                                validateResponse(res);
                                _load();
                              } else {
                                var res = await TwinnedSession.instance.twin
                                    .setAdmin(
                                        apikey:
                                            TwinnedSession.instance.authToken,
                                        twinUserId: user.id);
                                validateResponse(res);
                                _load();
                              }
                              TwinHelper.navigateToLogin(auth);
                            });
                          });
                    },
                    icon: Icon(
                      Icons.admin_panel_settings,
                      size: 18,
                      color: isAdminStatus ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              if (!isAdminStatus && user.clientIds.isNotEmpty)
                Tooltip(
                  message: isClientAdminStatus
                      ? 'Remove ClientAdmin Privilege'
                      : 'Assign ClientAdmin Privilege',
                  child: IconButton(
                    onPressed: () {
                      confirm(
                          title: 'Info',
                          message: !isClientAdminStatus
                              ? "Are you sure you want to assign this person as client administrator?"
                              : "Are you sure you want to remove client administrative privilege from this person?",
                          titleStyle: theme.getStyle(),
                          messageStyle: theme
                              .getStyle()
                              .copyWith(fontWeight: FontWeight.bold),
                          onPressed: () async {
                            await execute(() async {
                              if (isClientAdminStatus) {
                                var res = await TwinnedSession.instance.twin
                                    .unsetClientAdmin(
                                        apikey:
                                            TwinnedSession.instance.authToken,
                                        twinUserId: user.id,
                                        clientId: user.clientIds!.first);
                                validateResponse(res);
                                _load();
                              } else {
                                var res = await TwinnedSession.instance.twin
                                    .setClientAdmin(
                                        apikey:
                                            TwinnedSession.instance.authToken,
                                        twinUserId: user.id,
                                        clientId: user.clientIds!.first);
                                validateResponse(res);
                                _load();
                              }
                              TwinHelper.navigateToLogin(auth);
                            });
                          });
                    },
                    icon: Icon(
                      Icons.account_circle,
                      size: 18,
                      color: isClientAdminStatus ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              Tooltip(
                message: 'Update',
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    _addUpdateUserDialog(twinUser: user);
                  },
                ),
              ),
              Tooltip(
                message: 'Delete',
                child: IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () {
                    _confirmDeletionDialog(context, user.id);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(tapi.TwinUser entity) {
    String? countryCode = countryCodeMap[entity.countryCode];
    String formattedPhone = entity.phone != null && entity.phone!.isNotEmpty
        ? (entity.countryCode!.isNotEmpty && countryCode!.isNotEmpty
            ? '$countryCode ${entity.phone}'
            : entity.phone!)
        : '';

    return Card(
      color: Colors.transparent,
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: theme.getPrimaryColor(),
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        height: 300,
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entity.name,
                    style: theme.getStyle().copyWith(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Wrap(
                    children: [
                      Tooltip(
                        message: 'Update',
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            _addUpdateUserDialog(twinUser: entity);
                          },
                        ),
                      ),
                      Tooltip(
                        message: 'Delete',
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _confirmDeletionDialog(context, entity.id);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: theme.getPrimaryColor(),
              thickness: 2.0,
            ),
            Expanded(
              child: (entity.images != null && entity.images!.isNotEmpty)
                  ? Center(
                      child: TwinImageHelper.getCachedDomainImage(
                          entity.images!.first),
                    )
                  : userdefaultImage,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name : ${entity.name}',
                    style: theme.getStyle(),
                  ),
                  Text(
                    'Email : ${entity.email}',
                    style: theme.getStyle(),
                  ),
                  Text(
                    'Phone : ${formattedPhone}',
                    style: theme.getStyle(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addUpdateUserDialog({tapi.TwinUser? twinUser}) async {
    await super.alertDialog(
      titleStyle:
          theme.getStyle().copyWith(fontWeight: FontWeight.bold, fontSize: 18),
      title: null == twinUser ? 'Add New User' : 'Update User',
      body: UserAddUpdateSnippet(
        twinUser: twinUser,
      ),
      width: 750,
      height: MediaQuery.of(context).size.height - 250,
    );
    _load();
  }

  _confirmDeletionDialog(BuildContext context, String id) {
    Widget cancelButton = SecondaryButton(
      labelKey: 'Cancel',
      onPressed: () => Navigator.pop(context),
    );
    Widget deleteButton = PrimaryButton(
      leading: const Icon(
        Icons.delete_forever,
        color: Colors.white,
      ),
      labelKey: 'Delete',
      onPressed: () {
        _removeEntity(id);
        Navigator.pop(context);
      },
    );
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
        "Deleting a User can not be undone.\nYou will loose all of the user data, history, etc.\n\nAre you sure you want to delete?",
        style: theme.getStyle().copyWith(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
        maxLines: 10,
      ),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
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
        int index = _twinUsers.indexWhere((element) => element.id == id);
        var res = await TwinnedSession.instance.twin.deleteTwinUser(
          apikey: TwinnedSession.instance.authToken,
          twinUserId: id,
        );
        if (validateResponse(res)) {
          refresh(
            sync: () {
              _twinUsers.removeAt(index);
              // _cards.removeAt(index);
              totalCount = _twinUsers.length;
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
            titleTextStyle: theme.getStyle().copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
            contentTextStyle: theme.getStyle(),
            content: PurchaseChangeAddonWidget(
              orgId: orgs[selectedOrg].id,
              purchase: true,
              users: 1,
            ),
          );
        });
    await _checkExhausted();
    await _load();
  }

  Future _checkExhausted() async {
    _exhausted = await hasUsersExhausted();
    refresh();
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _twinUsers.clear();

    await execute(() async {
      var qres = await TwinnedSession.instance.twin.queryEqlTwinUser(
        apikey: TwinnedSession.instance.authToken,
        body: tapi.EqlSearch(
          source: [],
          page: 0,
          size: 25,
          sort: {"namek": "asc"},
          mustConditions: [
            {
              "query_string": {
                "query": _searchQuery,
                "fields": ["name"]
              }
            },
            if (isClient())
              {
                "terms": {"clientIds.keyword": await getClientIds()}
              },
          ],
        ),
      );
      if (validateResponse(qres)) {
        totalCount = qres.body!.total;
        refresh(
          sync: () {
            _twinUsers.addAll(qres.body!.values!);
          },
        );
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {
    _checkExhausted();
    _load();
  }
}

class TableHeader extends StatelessWidget {
  final String title;
  const TableHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          title,
          style: theme.getStyle().copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
        ),
      ),
    );
  }
}
