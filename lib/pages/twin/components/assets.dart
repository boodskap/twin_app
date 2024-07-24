import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/core/premise_dropdown.dart';
import 'package:twinned_widgets/core/facility_dropdown.dart';
import 'package:twinned_widgets/core/floor_dropdown.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

class Assets extends StatefulWidget {
  const Assets({super.key});

  @override
  State<Assets> createState() => _AssetsState();
}

class _AssetsState extends BaseState<Assets> {
  final List<tapi.Asset> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';
  tapi.Premise? _selectedPremise;
  tapi.Facility? _selectedFacility;
  tapi.Floor? _selectedFloor;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            SizedBox(
              width: 250,
              child: PremiseDropdown(
                  selectedItem: _selectedPremise?.id,
                  onPremiseSelected: (e) {
                    setState(() {
                      _selectedPremise = e;
                    });
                    _load();
                  }),
            ),
            divider(horizontal: true),
            SizedBox(
              width: 250,
              child: FacilityDropdown(
                  selectedItem: _selectedFacility?.id,
                  selectedPremise: _selectedPremise?.id,
                  onFacilitySelected: (e) {
                    setState(() {
                      _selectedFacility = e;
                    });
                    _load();
                  }),
            ),
            SizedBox(
              width: 250,
              child: FloorDropdown(
                  selectedItem: _selectedFloor?.id,
                  selectedPremise: _selectedPremise?.id,
                  selectedFacility: _selectedFacility?.id,
                  onFloorSelected: (e) {
                    setState(() {
                      _selectedFloor = e;
                    });
                    _load();
                  }),
            ),
            divider(horizontal: true),
            PrimaryButton(
              labelKey: 'Create New',
              leading: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                _create();
              },
            ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  leading: Icon(Icons.search),
                  hintText: 'Search assets',
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
    );
  }

  Widget _buildCard(tapi.Asset e) {
    double width = MediaQuery.of(context).size.width / 8;
    return SizedBox(
      width: width,
      height: width,
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
                  style: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
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
                          _edit(e);
                        },
                        child:
                            Icon(Icons.edit, color: theme.getPrimaryColor())),
                    InkWell(
                      onTap: () {
                        _delete(e);
                      },
                      child: Icon(
                        Icons.delete,
                        color: theme.getPrimaryColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (null != e.images && e.images!.isNotEmpty)
              Align(
                alignment: Alignment.center,
                child: TwinImageHelper.getImage(e.domainKey, e.images!.first,
                    width: width / 2, height: width / 2),
              )
          ],
        ),
      ),
    );
  }

  Future _create() async {}

  Future _edit(tapi.Asset e) async {}

  Future _delete(tapi.Asset e) async {}

  Future _load() async {
    if (loading) return;
    loading = true;

    _entities.clear();
    _cards.clear();

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.queryEqlAsset(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.EqlSearch(
              source: [],
              page: 0,
              size: 50,
              mustConditions: [
                {
                  "query_string": {
                    "query": '*$_search*',
                    "fields": ["name", "description", "tags"]
                  }
                },
                if (null != _selectedPremise)
                  {
                    "match_phrase": {
                      "premiseId": _selectedPremise!.id,
                    }
                  },
                if (null != _selectedFacility)
                  {
                    "match_phrase": {
                      "facilityId": _selectedFacility!.id,
                    }
                  },
                if (null != _selectedFloor)
                  {
                    "match_phrase": {
                      "floorId": _selectedFloor!.id,
                    }
                  },
              ]));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.Asset e in _entities) {
        _cards.add(_buildCard(e));
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() async {
    _load();
  }
}
