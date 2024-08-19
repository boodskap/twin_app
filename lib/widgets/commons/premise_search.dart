import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/core/premise_dropdown.dart';
import 'package:twinned_api/twinned_api.dart' as twin;

class PremiseSearch extends StatefulWidget {
  final List<String> clientIds;
  final OnPremiseSelected onPremiseSelected;
  final TextStyle style;
  const PremiseSearch({
    super.key,
    required this.clientIds,
    required this.onPremiseSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<PremiseSearch> createState() => _PremiseSearchState();
}

class _PremiseSearchState extends BaseState<PremiseSearch> {
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
                  hintText: 'Search Premises',
                  trailing: [const BusyIndicator()],
                  onChanged: (value) async {
                    await _load(search: value);
                  },
                ),
              ),
            ],
          ),
          divider(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: _children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(twin.Premise entity) {
    return InkWell(
      onTap: () {
        widget.onPremiseSelected(entity);
        Navigator.pop(context);
      },
      child: Row(
        children: [
          if (entity.images?.isNotEmpty ?? false)
            SizedBox(
                width: 64,
                height: 48,
                child:
                    TwinImageHelper.getCachedDomainImage(entity.images!.first)),
          if (entity.images?.isEmpty ?? true)
            SizedBox(width: 64, height: 48, child: const Icon(Icons.image)),
          divider(horizontal: true),
          Text(
            entity.name,
            style: theme.getStyle(),
          ),
        ],
      ),
    );
  }

  Future _load({String search = '*'}) async {
    if (loading) return;
    loading = true;
    _children.clear();
    await execute(() async {
      List<Object> must = [
        if (widget.clientIds?.isNotEmpty ?? false)
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

      var res = await TwinnedSession.instance.twin.queryEqlPremise(
        apikey: TwinnedSession.instance.authToken,
        body: twin.EqlSearch(
            page: 0,
            size: 10,
            source: [],
            mustConditions: must,
            sort: {"namek": "asc"}),
      );

      if (validateResponse(res)) {
        for (twin.Premise entity in res.body?.values ?? []) {
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
