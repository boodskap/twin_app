import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/create_entity_snippet.dart';
import 'package:twin_app/pages/twin/components/widgets/create_field_snippet.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

class CustomEntities extends StatefulWidget {
  const CustomEntities({super.key});

  @override
  State<CustomEntities> createState() => _CustomEntitiesState();
}

class _CustomEntitiesState extends BaseState<CustomEntities> {
  final List<tapi.CustomEntityMapping> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
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
                onPressed: (canCreate())
                    ? () {
                        _createNew();
                      }
                    : null,
              ),
              divider(horizontal: true),
              SizedBox(
                  height: 40,
                  width: 250,
                  child: SearchBar(
                    textStyle: WidgetStatePropertyAll(theme.getStyle()),
                    hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                    leading: Icon(Icons.search),
                    hintText: 'Search Assets',
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
                  'No asset found',
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
      ),
    );
  }

  Future<Widget> _buildCard(tapi.CustomEntityMapping e) async {
    double width = MediaQuery.of(context).size.width / 7;
    List<Widget> children = [];

    children.add(Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Checkbox(
            key: Key(Uuid().v4()),
            value: !e.relaxed,
            onChanged: (value) {
              e = e.copyWith(relaxed: value ?? false);
              _updateRelaxed(e);
            }),
        Text(
          'Strict field check',
          style: theme.getStyle(),
        )
      ],
    ));

    children.add(const SizedBox(
      height: 10,
    ));

    for (tapi.CustomEntityField f in e.fields) {
      children.add(Wrap(
        spacing: 5,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            f.name,
            style: theme
                .getStyle()
                .copyWith(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            f.type.name,
            style: theme.getStyle().copyWith(fontSize: 12, color: Colors.blue),
          ),
        ],
      ));
      children.add(const SizedBox(
        height: 5,
      ));
    }

    return SizedBox(
      width: width,
      height: width * 2,
      child: Tooltip(
        textStyle: theme.getStyle().copyWith(color: Colors.white),
        message: e.name,
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
                    overflow: TextOverflow.ellipsis,
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
                          _addNewField(e);
                        },
                        child: Tooltip(
                            message: "Add new field",
                            child: Icon(
                              Icons.add,
                              color: theme.getPrimaryColor(),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 50,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 30),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _entities.clear();
    _cards.clear();

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.listCustomEntityMapping(
        apikey: TwinnedSession.instance.authToken,
      );

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.CustomEntityMapping e in _entities) {
        _cards.add(await _buildCard(e));
      }
    });

    loading = false;
    refresh();
  }

  Future _updateRelaxed(tapi.CustomEntityMapping mapping) async {
    if (loading) return;
    loading = true;

    tapi.CustomEntityMappingInfo entity = tapi.CustomEntityMappingInfo(
        name: mapping.name, relaxed: !mapping.relaxed, fields: mapping.fields);

    await execute(() async {
      var cRes = await TwinnedSession.instance.twin.upsertCustomEntityMapping(
          apikey: TwinnedSession.instance.authToken, body: entity);
      validateResponse(cRes);
    });

    loading = false;

    _load();
  }

  Future _addNewField(tapi.CustomEntityMapping e) async {
    await super.alertDialog(
      titleStyle:
          theme.getStyle().copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      title: 'Add New Field',
      body: CreateFieldSnippet(mapping: e),
      width: 400,
      height: 200,
    );
    _load();
  }

  void _createNew() async {
    await super.alertDialog(
      titleStyle:
          theme.getStyle().copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      title: 'Create New Custom Entity',
      body: CreateEntitySnippet(),
      width: 400,
      height: 200,
    );
    _load();
  }

  @override
  void setup() async {
    _load();
  }
}
