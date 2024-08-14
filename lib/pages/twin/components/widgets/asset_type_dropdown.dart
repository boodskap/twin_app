import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/twin_image_helper.dart';

typedef OnTankTypeSelected = void Function(twin.AssetModel? assetModel);

class AssetTypeDropdown extends StatefulWidget {
  final String? assetModelId;
  final OnTankTypeSelected onTankTypeSelected;

  const AssetTypeDropdown(
      {super.key,
      required this.assetModelId,
      required this.onTankTypeSelected});

  @override
  State<AssetTypeDropdown> createState() => _AssetTypeDropdownState();
}

class _AssetTypeDropdownState extends BaseState<AssetTypeDropdown> {
  twin.AssetModel? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.AssetModel>.single(
      value: _selectedItem,
      hint: 'Select Asset Type',
      style: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
      searchHint: 'Search Asset Types',
      isExpanded: true,
      futureSearchFn: (String? keyword, String? orderBy, bool? orderAsc,
          List<Tuple2<String, String>>? filters, int? pageNb) async {
        pageNb = pageNb ?? 1;
        --pageNb;
        var result = await _search(search: keyword ?? '*', page: pageNb);
        return result;
      },
      dialogBox: true,
      dropDownDialogPadding: const EdgeInsets.fromLTRB(250, 50, 250, 50),
      selectedValueWidgetFn: (value) {
        twin.AssetModel entity = value;
        return Text('${entity.name} ${entity.description}');
      },
      onChanged: (selected) {
        setState(() {
          _selectedItem = selected;
        });
        widget.onTankTypeSelected(_selectedItem);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<twin.AssetModel>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<twin.AssetModel>> items = [];
    int total = 0;
    try {
      var pRes = await TwinnedSession.instance.twin.queryEqlAssetModel(
          apikey: TwinnedSession.instance.authToken,
          body: twin.EqlSearch(source: [], mustConditions: [
            {
              "query_string": {
                "query": '*$search*',
                "fields": ["name", "description"]
              }
            }
          ]));
      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.assetModelId) {
            _selectedItem = entity;
          }
          items.add(DropdownMenuItem<twin.AssetModel>(
              value: entity,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                children: [
                  if (null != entity.images && entity.images!.isNotEmpty)
                    SizedBox(
                        width: 48,
                        height: 48,
                        child: TwinImageHelper.getDomainImage(
                            entity.images!.first)),
                  Text(
                    '${entity.name} ${entity.description}',
                    style: theme
                        .getStyle()
                        .copyWith(overflow: TextOverflow.ellipsis),
                  ),
                ],
              )));
        }

        total = pRes.body!.total;
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    loading = false;

    return Tuple2(items, total);
  }

  Future _load() async {
    if (widget.assetModelId?.isEmpty ?? true) {
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getAssetModel(
        apikey: TwinnedSession.instance.authToken,
        assetModelId: widget.assetModelId,
      );
      if (eRes.body != null) {
        setState(() {
          _selectedItem = eRes.body!.entity;
        });
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  @override
  void setup() {
    _load();
  }
}
