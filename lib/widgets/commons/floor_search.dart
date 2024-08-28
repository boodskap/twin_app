import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/floor_dropdown.dart';

class FloorSearch extends StatefulWidget {
  final String? premiseId;
  final String? facilityId;
  final OnFloorSelected onFloorSelected;
  final TextStyle style;
  const FloorSearch({
    super.key,
    required this.premiseId,
    required this.facilityId,
    required this.onFloorSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<FloorSearch> createState() => _FloorSearchState();
}

class _FloorSearchState extends BaseState<FloorSearch> {
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
                  hintText: 'Search Floors',
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

  Widget _buildRow(twin.Floor entity) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          widget.onFloorSelected(entity);
          Navigator.pop(context);
        },
        child: Row(
          children: [
            if (entity.floorPlan?.isNotEmpty ?? false)
              SizedBox(
                  width: 64,
                  height: 48,
                  child:
                      TwinImageHelper.getCachedDomainImage(entity.floorPlan!)),
            if (entity.floorPlan?.isEmpty ?? true)
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
      var res = await TwinnedSession.instance.twin.searchFloors(
        apikey: TwinnedSession.instance.authToken,
        premiseId: widget.premiseId,
        facilityId: widget.facilityId,
        body: twin.SearchReq(search: search, page: 0, size: 10),
      );

      if (validateResponse(res)) {
        for (twin.Floor entity in res.body?.values ?? []) {
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
