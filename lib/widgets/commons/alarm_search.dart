import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;

typedef OnAlarmSelected = void Function(twin.Alarm? event);

class AlarmSearch extends StatefulWidget {
  final List<String> clientIds;
  final OnAlarmSelected onAlarmSelected;
  final TextStyle style;
  const AlarmSearch({
    super.key,
    required this.clientIds,
    required this.onAlarmSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<AlarmSearch> createState() => _AlarmSearchState();
}

class _AlarmSearchState extends BaseState<AlarmSearch> {
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
                  hintText: 'Search Alarms',
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
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

  Widget _buildRow(twin.Alarm entity) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          widget.onAlarmSelected(entity);
          Navigator.pop(context);
        },
        child: Row(
          children: [
            if (entity.stateIcons?.isNotEmpty ?? false)
              SizedBox(
                  width: 64,
                  height: 48,
                  child: TwinImageHelper.getCachedDomainImage(
                      entity.stateIcons!.first)),
            if (entity.stateIcons?.isEmpty ?? true)
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
              "fields": ["name", "description", "tags"]
            }
          }
      ];

      var res = await TwinnedSession.instance.twin.queryEqlAlarm(
        apikey: TwinnedSession.instance.authToken,
        body: twin.EqlSearch(
            page: 0,
            size: 10,
            source: [],
            mustConditions: must,
            sort: {"namek": "asc"}),
      );

      if (validateResponse(res)) {
        for (twin.Alarm entity in res.body?.values ?? []) {
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
