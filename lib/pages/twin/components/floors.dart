import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/floor_content_page.dart';
import 'package:twin_app/pages/twin/components/widgets/floor_snippet.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twinned_widgets/core/facility_dropdown.dart';
import 'package:twinned_widgets/core/premise_dropdown.dart';
import 'package:uuid/uuid.dart';

class Floors extends StatefulWidget {
  const Floors({super.key});

  @override
  State<Floors> createState() => _FloorsState();
}

class _FloorsState extends BaseState<Floors> {
  final List<tapi.Floor> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';
  tapi.Premise? _selectedPremise;
  tapi.Facility? _selectedFacility;
  bool _canEdit = false;
  Map<String, bool> _editable = Map<String, bool>();

  @override
  void initState() {
    super.initState();
    _checkCanEdit();
  }

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
              icon: Icon(Icons.refresh),
            ),
            divider(horizontal: true),
            SizedBox(
              width: 250,
              child: PremiseDropdown(
                style: theme.getStyle(),
                key: Key(const Uuid().v4()),
                selectedItem: _selectedPremise?.id,
                onPremiseSelected: (e) {
                  setState(() {
                    if (e == null) {
                      _selectedPremise = null;
                      _selectedFacility = null;
                    } else {
                      _selectedPremise = e;
                      _selectedFacility = null;
                    }
                  });
                  _load();
                },
              ),
            ),
            divider(horizontal: true),
            SizedBox(
              width: 250,
              child: FacilityDropdown(
                style: theme.getStyle(),
                key: Key(const Uuid().v4()),
                selectedItem: _selectedFacility?.id,
                selectedPremise: _selectedPremise?.id,
                onFacilitySelected: (e) {
                  setState(() {
                    _selectedFacility = e;
                  });
                  _load();
                },
              ),
            ),
            divider(horizontal: true),
            PrimaryButton(
              labelKey: 'Create New',
              leading: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: (canCreate()) ? _addEditFloorDialog : null,
            ),
            divider(horizontal: true),
            SizedBox(
              height: 40,
              width: 250,
              child: SearchBar(
                textStyle: WidgetStatePropertyAll(theme.getStyle()),
                hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                leading: Icon(Icons.search),
                hintText: 'Search Floors',
                onChanged: (val) {
                  _search = val.trim();
                  _load();
                },
              ),
            ),
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
                'No floor found',
                style: theme.getStyle(),
              ),
            ],
          ),
        if (!loading && _cards.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _cards,
            ),
          ),
      ],
    );
  }

  Widget _buildCard(tapi.Floor e) {
    double width = MediaQuery.of(context).size.width / 8;
    bool editable = _canEdit;
    if (!editable) {
      editable = _editable[e.id] ?? false;
    }
    return SizedBox(
      width: width,
      height: width,
      child: InkWell(
        onDoubleTap: () {
          if (_canEdit) {
            _edit(e);
          }
        },
        child: Tooltip(
          message: '${e.name}\n${e.description ?? ""}',
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
                      style: theme
                          .getStyle()
                          .copyWith(fontWeight: FontWeight.bold),
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
                        Tooltip(
                          message:
                              _canEdit ? "Update" : "No Permission to Edit",
                          child: InkWell(
                            onTap: _canEdit
                                ? () {
                                    _addEditFloorDialog(floor: e);
                                  }
                                : null,
                            child: Icon(
                              Icons.edit,
                              color: _canEdit ? theme.getPrimaryColor() : null,
                            ),
                          ),
                        ),
                        Tooltip(
                          message:
                              _canEdit ? "Delete" : "No Permission to Delete",
                          child: InkWell(
                            onTap: _canEdit
                                ? () {
                                    _delete(e);
                                  }
                                : null,
                            child: Icon(
                              Icons.delete,
                              color: _canEdit ? theme.getPrimaryColor() : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (null != e.floorPlan && e.floorPlan!.isNotEmpty)
                  Align(
                    alignment: Alignment.center,
                    child: TwinImageHelper.getCachedImage(
                      e.domainKey,
                      e.floorPlan!,
                      width: width / 2,
                      height: width / 2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkCanEdit() async {
    List<String> clientIds = await getClientIds();
    bool canEditResult = await canEdit(clientIds: clientIds);

    setState(() {
      _canEdit = canEditResult;
    });
  }

  void _addEditFloorDialog({tapi.Floor? floor}) async {
    tapi.Premise? selectedPremise;
    tapi.Facility? selectedFacility;

    if (floor != null &&
        (_selectedPremise != null && _selectedFacility != null)) {
      var pRes = await TwinnedSession.instance.twin.getPremise(
        premiseId: floor.premiseId,
        apikey: TwinnedSession.instance.authToken,
      );
      selectedPremise = pRes.body?.entity;

      var fRes = await TwinnedSession.instance.twin.getFacility(
        facilityId: floor.facilityId,
        apikey: TwinnedSession.instance.authToken,
      );
      selectedFacility = fRes.body?.entity;
    }

    await super.alertDialog(
      title: floor == null ? 'Add New Floor' : 'Update Floor',
      titleStyle:
          theme.getStyle().copyWith(fontSize: 20, fontWeight: FontWeight.bold),
      body: FloorSnippet(
        selectedPremise: selectedPremise ?? _selectedPremise,
        selectedFacility: selectedFacility ?? _selectedFacility,
        floor: floor,
      ),
      width: 750,
      height: MediaQuery.of(context).size.height - 150,
    );

    _load();
  }

  Future _edit(tapi.Floor e) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FloorContentPage(
          key: Key(const Uuid().v4()),
          floor: e,
          type: InfraType.floor,
        ),
      ),
    );
    await _load();
    refresh();
  }

  Future _delete(tapi.Floor e) async {
    if (loading) return;
    loading = true;
    await confirm(
        title: 'Warning',
        message:
            'Deleting is unrecoverable\nIt may also delete all the related models and components\n\nDo you want to proceed?',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle(),
        onPressed: () async {
          await execute(() async {
            int index = _entities.indexWhere((element) => element.id == e.id);
            var res = await TwinnedSession.instance.twin.deleteFloor(
                apikey: TwinnedSession.instance.authToken, floorId: e.id);
            if (validateResponse(res)) {
              await _load();
              _entities.removeAt(index);
              _cards.removeAt(index);
              alert("Success", "Floor ${e.name} Deleted Successfully!",
                  contentStyle: theme.getStyle(),
                  titleStyle: theme
                      .getStyle()
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold));
            }
          });
        });
    loading = false;

    refresh();
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _entities.clear();
    _cards.clear();

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.queryEqlFloor(
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
          ],
        ),
      );

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.Floor e in _entities) {
        _editable[e.id] = await super.canEdit(clientIds: e.clientIds);
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
