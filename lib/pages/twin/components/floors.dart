import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/floor_content_page.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twinned_widgets/core/facility_dropdown.dart';
import 'package:twinned_widgets/core/premise_dropdown.dart';
import 'package:twinned_widgets/core/top_bar.dart';
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
                selectedItem: _selectedPremise?.id,
                onPremiseSelected: (e) {
                  setState(() {
                    _selectedPremise = e;
                  });
                  _load();
                },
              ),
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
              onPressed: (_selectedPremise != null && _selectedFacility != null)
                  ? () {
                      _create();
                    }
                  : null,
            ),
            divider(horizontal: true),
            SizedBox(
              height: 40,
              width: 250,
              child: SearchBar(
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
                      child: Icon(Icons.edit, color: primaryColor),
                    ),
                    InkWell(
                      onTap: () {
                        _delete(e);
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (null != e.floorPlan && e.floorPlan!.isNotEmpty)
              Align(
                alignment: Alignment.center,
                child: TwinImageHelper.getImage(
                  e.domainKey,
                  e.floorPlan!,
                  width: width / 2,
                  height: width / 2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getBasicInfo(
    BuildContext context,
    String title, {
    required Function(String, String, String?) onPressed,
  }) async {
    String? nameText = '';
    String? descText = '';
    String? tagsText = '';
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 500,
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) {
                    nameText = value;
                  },
                  style: theme.getStyle(),
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: theme.getStyle(),
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    descText = value;
                  },
                  style: theme.getStyle(),
                  decoration: InputDecoration(
                    hintText: 'Description',
                    hintStyle: theme.getStyle(),
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    tagsText = value;
                  },
                  style: theme.getStyle(),
                  decoration: InputDecoration(
                    hintText: 'Tags (space separated)',
                    hintStyle: theme.getStyle(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            SecondaryButton(
              labelKey: "Cancel",
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            divider(horizontal: true),
            PrimaryButton(
              labelKey: "OK",
              onPressed: () {
                if (nameText!.length < 3) {
                  alert(
                    'Invalid',
                    'Name is required and should be minimum 3 characters',
                  );
                  return;
                }
                onPressed(nameText!, descText!, tagsText);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future _create() async {
    if (loading) return;
    loading = true;
    await _getBasicInfo(
      context,
      'New Floor',
      onPressed: (name, desc, t) async {
        List<String> tags = [];
        if (null != t) {
          tags = t.trim().split(' ');
        }
        var mRes = await TwinnedSession.instance.twin.createFloor(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.FloorInfo(
            premiseId: _selectedPremise!.id,
            facilityId: _selectedFacility!.id,
            floorLevel: _cards.length,
            floorType: tapi.FloorInfoFloorType.onground,
            name: name,
            description: desc,
            tags: tags,
            roles: _selectedFacility!.roles,
          ),
        );
        if (validateResponse(mRes)) {
          await _edit(mRes.body!.entity!);
          alert("Floor${mRes.body!.entity!.name}", "Saved Successfully!");
        }
      },
    );
    loading = false;
    refresh();
  }

  Future _edit(tapi.Floor e) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FloorContentPage(
          key: Key(const Uuid().v4()),
          floor: e,
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
        titleStyle: const TextStyle(color: Colors.red),
        messageStyle: const TextStyle(fontWeight: FontWeight.bold),
        onPressed: () async {
          await execute(() async {
            int index = _entities.indexWhere((element) => element.id == e.id);
            var res = await TwinnedSession.instance.twin.deleteFloor(
                apikey: TwinnedSession.instance.authToken, floorId: e.id);
            if (validateResponse(res)) {
              await _load();
              _entities.removeAt(index);
              _cards.removeAt(index);
              alert("Success", "Floor ${e.name} Deleted Successfully!");
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
