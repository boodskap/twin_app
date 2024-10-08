import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/facilities_content_page.dart';
import 'package:twin_app/pages/twin/components/widgets/facility_snippet.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/core/premise_dropdown.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:uuid/uuid.dart';

typedef BasicInfoCallback = void Function(
    String name, String? description, String? tags);

class Facilities extends StatefulWidget {
  const Facilities({super.key});

  @override
  State<Facilities> createState() => _FacilitiesState();
}

class _FacilitiesState extends BaseState<Facilities> {
  final List<tapi.Facility> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';
  tapi.Premise? _selectedPremise;
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
                icon: Icon(Icons.refresh)),
            divider(horizontal: true),
            SizedBox(
              width: 250,
              child: PremiseDropdown(
                  style: theme.getStyle(),
                  selectedItem: _selectedPremise?.id,
                  onPremiseSelected: (e) {
                    setState(() {
                      _selectedPremise = e;
                    });
                    _load();
                  }),
            ),
            divider(horizontal: true),
            if (canCreate())
              PrimaryButton(
                labelKey: 'Create New',
                leading: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: (canCreate())
                    ? () {
                        _addEditFacilityDialog();
                      }
                    : null,
              ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  leading: Icon(Icons.search),
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintText: 'Search Facilities',
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
                'No facility found',
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

  Widget _buildCard(tapi.Facility e) {
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0, top: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message:
                              _canEdit ? "Update" : "No Permission to Edit",
                          child: InkWell(
                              onTap: _canEdit
                                  ? () async {
                                      _addEditFacilityDialog(facility: e);
                                    }
                                  : null,
                              child: Icon(
                                Icons.edit,
                                color: _canEdit
                                    ? theme.getPrimaryColor()
                                    : Colors.grey,
                              )),
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
                              Icons.delete_forever,
                              color: _canEdit ? theme.getPrimaryColor() : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (null != e.images && e.images!.isNotEmpty)
                  Align(
                    alignment: Alignment.center,
                    child: TwinImageHelper.getCachedImage(
                        e.domainKey, e.images!.first,
                        width: width / 2, height: width / 2),
                  )
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

  void _addEditFacilityDialog({tapi.Facility? facility}) async {
    var res;
    tapi.Premise? selectedPremise;

    if (facility != null && _selectedPremise != null) {
      res = await TwinnedSession.instance.twin.getPremise(
        premiseId: facility.premiseId,
        apikey: TwinnedSession.instance.authToken,
      );
      selectedPremise = res.body?.entity;
    }

    await super.alertDialog(
      titleStyle:
          theme.getStyle().copyWith(fontSize: 20, fontWeight: FontWeight.bold),
      title: facility == null ? 'Add New Facility' : 'Update Facility',
      body: FacilitySnippet(
        selectedPremise: selectedPremise ?? _selectedPremise,
        facility: facility,
      ),
      width: 750,
      height: MediaQuery.of(context).size.height - 150,
    );

    _load();
  }

  Future _edit(tapi.Facility e) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacilityContentPage(
          facility: e,
          key: Key(
            Uuid().v4(),
          ),
        ),
      ),
    );
    await _load();
  }

  Future _delete(tapi.Facility e) async {
    if (loading) return;
    loading = true;
    await confirm(
        title: 'Warning',
        message:
            'Deleting is unrecoverable\nIt may also delete all the related models and components\n\nDo you want to proceed?',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle().copyWith(),
        onPressed: () async {
          await execute(() async {
            int index = _entities.indexWhere((element) => element.id == e.id);
            var res = await TwinnedSession.instance.twin.deleteFacility(
                apikey: TwinnedSession.instance.authToken, facilityId: e.id);
            if (validateResponse(res)) {
              await _load();
              _entities.removeAt(index);
              _cards.removeAt(index);
              alert('Facility - ${e.name}', ' Deleted successfully!',
                  contentStyle: theme.getStyle(),
                  titleStyle: theme
                      .getStyle()
                      .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
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
      var sRes = await TwinnedSession.instance.twin.queryEqlFacility(
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
                  }
              ]));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.Facility e in _entities) {
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
