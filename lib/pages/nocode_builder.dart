import 'package:flutter/material.dart';
import 'package:twin_app/pages/nocodebuilder/nocode_builder_content_page.dart';
import 'package:twin_app/widgets/buy_button.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/purchase_change_addon_widget.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:uuid/uuid.dart';

typedef DashboardBasicInfoCallback = void Function(
    String name, String title, String description, String tags);

class NocodeBuilderPage extends StatefulWidget {
  const NocodeBuilderPage({super.key});

  @override
  State<NocodeBuilderPage> createState() => _NocodeBuilderPageState();
}

class _NocodeBuilderPageState extends BaseState<NocodeBuilderPage> {
  final List<Widget> _cards = [];
  final List<twinned.DashboardScreen> _entities = [];
  bool _exhausted = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void setup() {
    _checkExhausted();
    _load();
  }

  Future<void> _getBasicInfo(BuildContext context, String title,
      {required DashboardBasicInfoCallback onPressed}) async {
    String nameText = '';
    String titleText = '';
    String descText = '';
    String tagsText = '';
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            contentTextStyle: theme.getStyle(),
            titleTextStyle: theme
                .getStyle()
                .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            title: Text(
              title,
              style: theme
                  .getStyle()
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: SizedBox(
              width: 500,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        nameText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Name',
                      errorStyle: theme.getStyle(),
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        titleText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Title',
                      errorStyle: theme.getStyle(),
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        descText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Description',
                      errorStyle: theme.getStyle(),
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        tagsText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tags (space separated)',
                      errorStyle: theme.getStyle(),
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              SecondaryButton(
                labelKey: "Cancel",
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              PrimaryButton(
                labelKey: "OK",
                onPressed: () {
                  if (nameText.length < 3) {
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
                  if (titleText.length < 3) {
                    alert(
                      'Invalid',
                      'Title is required and should be minimum 3 characters',
                      titleStyle: theme
                          .getStyle()
                          .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      contentStyle: theme.getStyle(),
                    );
                    return;
                  }
                  setState(() {
                    onPressed(nameText, titleText, descText, tagsText);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future _addNew() async {
    if (loading) return;
    loading = true;
    await _getBasicInfo(
      context,
      'New Dashboard',
      onPressed: (name, title, description, tags) async {
        await execute(() async {
          var res = await TwinnedSession.instance.twin.createDashboardScreen(
              apikey: TwinnedSession.instance.authToken,
              body: twinned.DashboardScreenInfo(
                name: name,
                titleConfig: twinned.TitleConfig(title: title),
                description: description,
                tags: tags.split(' '),
                rows: [],
                clientIds: await getClientIds(),
              ));
          if (validateResponse(res)) {
            await _edit(res.body!.entity!);
          }
        });
      },
    );
    loading = false;
    refresh();
  }

  Future _edit(tapi.DashboardScreen e) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NocodeBuilderContentPage(
          entity: e,
        ),
      ),
    );
    await _load();
  }

  Future _buyAddon() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            contentTextStyle: theme.getStyle(),
            titleTextStyle: theme
                .getStyle()
                .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            content: PurchaseChangeAddonWidget(
              orgId: orgs[selectedOrg].id,
              purchase: true,
              dashboards: 1,
            ),
          );
        });
    await _checkExhausted();
    await _load();
  }

  Future _checkExhausted() async {
    _exhausted = await hasDashboardsExhausted();
    refresh();
  }

  Future _load({String search = '*'}) async {
    if (loading) return;
    loading = true;

    execute(() async {
      List<Widget> cards = [];
      List<twinned.DashboardScreen> entities = [];

      var res = await TwinnedSession.instance.twin.searchDashboardScreens(
          apikey: TwinnedSession.instance.authToken,
          body: twinned.SearchReq(search: search, page: 0, size: 10000));

      if (validateResponse(res)) {
        for (twinned.DashboardScreen e in res.body!.values!) {
          _buildCard(e, cards);
          entities.add(e);
        }
      }

      refresh(sync: () {
        _entities.clear();
        _cards.clear();
        _cards.addAll(cards);
        _entities.addAll(entities);
      });
    });

    loading = false;
  }

  void _buildCard(twinned.DashboardScreen entity, List<Widget> cards) {
    Widget newCard = Tooltip(
      message: '${entity.name}\n${entity.description ?? ""}',
      child: InkWell(
        onDoubleTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NocodeBuilderContentPage(
                key: Key(const Uuid().v4()),
                entity: entity,
              ),
            ),
          );

          _load();
        },
        child: Card(
          color: Colors.transparent,
          elevation: 5,
          child: Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Stack(
              children: [
                Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    )),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        entity.name,
                        // clippedName,
                        style: theme.getStyle().copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          confirmDeletion(context, entity);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: theme.getPrimaryColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    cards.add(newCard);
  }

  void confirmDeletion(BuildContext context, e) {
    // set up the buttons
    Widget cancelButton = SecondaryButton(
      labelKey: "Cancel",
      onPressed: () {
        setState(() {
          Navigator.pop(context);
        });
      },
    );
    Widget continueButton = PrimaryButton(
      onPressed: () {
        Navigator.pop(context);
        _removeEntity(e);
      },
      labelKey: "Delete",
    );

    AlertDialog alert = AlertDialog(
      contentTextStyle: theme.getStyle(),
      titleTextStyle: theme.getStyle().copyWith(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
      title: Text(
        "WARNING",
        style: theme.getStyle().copyWith(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
      content: Text(
        "Deleting a Dashboard can not be undone.\nAre you sure you want to delete?",
        style: theme.getStyle().copyWith(
              color: Colors.black,
              fontSize: 16,
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

  void _removeEntity(e) async {
    if (loading) return;
    loading = true;
    await execute(
      () async {
        int index = _entities.indexWhere((element) => element.id == e.id);

        var res = await TwinnedSession.instance.twin.deleteDashboardScreen(
            apikey: TwinnedSession.instance.authToken, screenId: e.id);

        if (validateResponse(res)) {
          await _load();
          _entities.removeAt(index);
          _cards.removeAt(index);
          alert(
            'Success',
            'Dashboard ${e.name} deleted!',
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            contentStyle: theme.getStyle(),
          );
        }
      },
    );
    loading = false;
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const BusyIndicator(),
            divider(horizontal: true),
            Tooltip(
              message: 'Refresh',
              child: IconButton(
                onPressed: () {
                  _load();
                },
                icon: Icon(Icons.refresh),
              ),
            ),
            divider(horizontal: true),
            if (_exhausted)
              BuyButton(
                  label: 'Buy More License',
                  tooltip:
                      'Utilized ${orgPlan?.totalDashboardCount ?? '-'} licenses',
                  style: theme.getStyle().copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue),
                  onPressed: _buyAddon),
            if (!_exhausted)
              Tooltip(
                message: "",
                child: PrimaryButton(
                  leading: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await _addNew();
                  },
                  labelKey: 'Add New',
                ),
              ),
            divider(horizontal: true),
            SizedBox(
              width: 250,
              height: 40,
              child: SearchBar(
                textStyle: WidgetStatePropertyAll(theme.getStyle()),
                hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                onChanged: (value) async {
                  await _load(search: value);
                },
                hintText: "Search Dashboard",
              ),
            ),
            divider(horizontal: true)
          ],
        ),
        divider(horizontal: true),
        if (_cards.isEmpty)
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Center(
                child: Text(
              'No dashboards found',
              style: theme.getStyle(),
            )),
          ),
        if (_cards.isNotEmpty)
          Expanded(
            flex: 1,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  itemCount: _cards.length,
                  itemBuilder: (ctx, index) {
                    return _cards[index];
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
