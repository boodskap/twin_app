import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/facilities_content_page.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
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
            PrimaryButton(
              labelKey: 'Create New',
              leading: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: (_selectedPremise != null)
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
    return SizedBox(
      width: width,
      height: width,
      child: InkWell(
        onDoubleTap: () => _edit(e),
        child: Tooltip(
          textStyle: theme.getStyle().copyWith(color: Colors.white),
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
                        InkWell(
                            onTap: () {
                              _edit(e);
                            },
                            child: Icon(Icons.edit,
                                color: theme.getPrimaryColor())),
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
                    child: TwinImageHelper.getImage(
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

  Future _create() async {
    if (loading) return;
    loading = true;
    await _getBasicInfo(context, 'New Facility',
        onPressed: (name, desc, t) async {
      List<String> tags = [];
      if (null != t) {
        tags = t.trim().split(' ');
      }
      var mRes = await TwinnedSession.instance.twin.createFacility(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.FacilityInfo(
              premiseId: _selectedPremise!.id,
              name: name,
              description: desc,
              tags: tags,
              roles: _selectedPremise!.roles));
      if (validateResponse(mRes)) {
        await _edit(mRes.body!.entity!);
        alert('Success', 'Facility ${name} created successfully!');
      }
    });
    loading = false;
    refresh();
  }

  Future _edit(tapi.Facility e) async {
    var res = await TwinnedSession.instance.twin.getFacility(
        facilityId: e.id, apikey: TwinnedSession.instance.authToken);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacilityContentPage(
          facility: res.body!.entity!,
          key: Key(
            Uuid().v4(),
          ),
          type: InfraType.facility,
        ),
      ),
    );
    await _load();
  }

  Future<void> _getBasicInfo(BuildContext context, String title,
      {required BasicInfoCallback onPressed}) async {
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
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        nameText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: theme.getStyle(),
                    ),
                  ),
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        descText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Description',
                      hintStyle: theme.getStyle(),
                    ),
                  ),
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        tagsText = value;
                      });
                    },
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
                labelKey: 'Cancel',
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              PrimaryButton(
                labelKey: 'Ok',
                onPressed: () {
                  if (nameText!.length < 3) {
                    alert('Invalid',
                        'Name is required and should be minimum 3 characters');
                    return;
                  }
                  setState(() {
                    onPressed(nameText!, descText, tagsText);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future _delete(tapi.Facility e) async {
    if (loading) return;
    loading = true;
    await confirm(
        title: 'Warning',
        message:
            'Deleting is unrecoverable\nIt may also delete all the related models and components\n\nDo you want to proceed?',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
        onPressed: () async {
          await execute(() async {
            int index = _entities.indexWhere((element) => element.id == e.id);
            var res = await TwinnedSession.instance.twin.deleteFacility(
                apikey: TwinnedSession.instance.authToken, facilityId: e.id);
            if (validateResponse(res)) {
              await _load();
              _entities.removeAt(index);
              _cards.removeAt(index);
              alert('Success', 'Facility ${e.name} deleted!');
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
