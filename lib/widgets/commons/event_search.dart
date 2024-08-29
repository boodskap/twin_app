import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;

typedef OnEventSelected = void Function(twin.Event? event);

class EventSearch extends StatefulWidget {
  final List<String> clientIds;
  final OnEventSelected onEventSelected;
  final TextStyle style;
  const EventSearch({
    super.key,
    required this.clientIds,
    required this.onEventSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<EventSearch> createState() => _EventSearchState();
}

class _EventSearchState extends BaseState<EventSearch> {
  final List<Widget> _children = [];

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
            children: [
              Expanded(
                child: SearchBar(
                  hintText: 'Search Events',
                  trailing: [const BusyIndicator()],
                  onChanged: (value) async {
                    await _load(search: value);
                  },
                ),
              ),
            ],
          ),
          divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: _children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(twin.Event entity) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          widget.onEventSelected(entity);
          Navigator.pop(context);
        },
        child: Row(
          children: [
            if (entity.icon?.isNotEmpty ?? false)
              SizedBox(
                  width: 64,
                  height: 48,
                  child: TwinImageHelper.getCachedDomainImage(entity.icon!)),
            if (entity.icon?.isEmpty ?? true)
              SizedBox(width: 64, height: 48, child: const Icon(Icons.image)),
            divider(horizontal: true),
            Text(
              entity.name,
              style: theme.getStyle(),
            ),
          ],
        ),
      ),
    );
  }

  Future _load({String search = '*'}) async {
    if (loading) return;
    loading = true;
    _children.clear();
    await execute(() async {
      List<Object> must = [
        if (widget.clientIds.isNotEmpty)
          {
            "terms": {"clientIds.keyword": widget.clientIds}
          },
        if (search.isNotEmpty && '*' != search)
          {
            "query_string": {
              "query": '*$search*',
              "fields": [
                "name",
                "asset",
                "deviceName",
                "modelName",
                "premise",
                "facility",
                "floor",
                "client",
                "description",
                "tags"
              ]
            }
          }
      ];

      var res = await TwinnedSession.instance.twin.queryEqlEvent(
        apikey: TwinnedSession.instance.authToken,
        body: twin.EqlSearch(
            page: 0,
            size: 10,
            source: [],
            mustConditions: must,
            sort: {"namek": "asc"}),
      );

      if (validateResponse(res)) {
        for (twin.Event entity in res.body?.values ?? []) {
          _children.add(_buildRow(entity));
        }
      }
    });
    loading = false;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}
