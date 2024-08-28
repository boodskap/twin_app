import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;

typedef OnDataFilterSelected = void Function(twin.DataFilter? filter);
typedef OnFieldFilterSelected = void Function(twin.FieldFilter? filter);

class DataSearch extends StatefulWidget {
  final List<String> clientIds;
  final OnDataFilterSelected onDataFilterSelected;
  final OnFieldFilterSelected onFieldFilterSelected;
  final TextStyle style;
  const DataSearch({
    super.key,
    required this.clientIds,
    required this.onDataFilterSelected,
    required this.onFieldFilterSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<DataSearch> createState() => _DataSearchState();
}

class _DataSearchState extends BaseState<DataSearch> {
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
                  hintText: 'Search Data Filters',
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

  Widget _buildRow(
      {twin.DataFilter? dataFilter, twin.FieldFilter? fieldFilter}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          if (null != dataFilter) {
            widget.onDataFilterSelected(dataFilter!);
          } else {
            widget.onFieldFilterSelected(fieldFilter!);
          }
          Navigator.pop(context);
        },
        child: Row(
          children: [
            if (null != dataFilter && (dataFilter?.icon?.isNotEmpty ?? false))
              SizedBox(
                  width: 64,
                  height: 48,
                  child:
                      TwinImageHelper.getCachedDomainImage(dataFilter!.icon!)),
            if (null != dataFilter && (dataFilter?.icon?.isEmpty ?? true))
              SizedBox(width: 64, height: 48, child: const Icon(Icons.image)),
            if (null != fieldFilter && (fieldFilter?.icon?.isNotEmpty ?? false))
              SizedBox(
                  width: 64,
                  height: 48,
                  child:
                      TwinImageHelper.getCachedDomainImage(fieldFilter!.icon!)),
            if (null != fieldFilter && (fieldFilter?.icon?.isEmpty ?? true))
              SizedBox(width: 64, height: 48, child: const Icon(Icons.image)),
            divider(horizontal: true),
            if (null != dataFilter) Icon(Icons.dataset_linked),
            if (null != fieldFilter) Icon(Icons.text_fields),
            divider(horizontal: true),
            Text(
              null != dataFilter ? dataFilter!.name : fieldFilter!.name,
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

      var dRes = await TwinnedSession.instance.twin.queryEqlDataFilter(
        apikey: TwinnedSession.instance.authToken,
        body: twin.EqlSearch(
            page: 0,
            size: 10,
            source: [],
            mustConditions: must,
            sort: {"namek": "asc"}),
      );

      if (validateResponse(dRes)) {
        for (twin.DataFilter entity in dRes.body?.values ?? []) {
          _children.add(_buildRow(dataFilter: entity));
        }
      }

      var fRes = await TwinnedSession.instance.twin.queryEqlFieldFilter(
        apikey: TwinnedSession.instance.authToken,
        body: twin.EqlSearch(
            page: 0,
            size: 10,
            source: [],
            mustConditions: must,
            sort: {"namek": "asc"}),
      );

      _children.add(Divider());

      if (validateResponse(fRes)) {
        for (twin.FieldFilter entity in fRes.body?.values ?? []) {
          _children.add(_buildRow(fieldFilter: entity));
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
