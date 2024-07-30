import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/premises_content_page.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_commons/util/osm_location_picker.dart';
import 'package:uuid/uuid.dart';

class Premises extends StatefulWidget {
  const Premises({super.key});

  @override
  State<Premises> createState() => _PremisesState();
}

class _PremisesState extends BaseState<Premises> {
  final List<tapi.Premise> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';

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
            PrimaryButton(
              labelKey: 'Create New',
              leading: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                _addPremiseDialog(context);
              },
            ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  leading: Icon(Icons.search),
                  hintText: 'Search Premises',
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
                'No premises found',
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

  Widget _buildCard(tapi.Premise e) {
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
                        _confirmDeletionDialog(context, e);
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

  Future<void> _mapDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ],
          content: SizedBox(
            width: 1000,
            child: OSMLocationPicker(
              onPicked: (pickedData) {
                setState(
                  () {},
                );
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void _addPremiseDialog(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController premiseName = TextEditingController();
    TextEditingController premiseDescription = TextEditingController();
    TextEditingController premiseTags = TextEditingController();
    tapi.GeoLocation? location;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          title: Container(
            decoration: BoxDecoration(
              color: theme.getPrimaryColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Premise',
                    style: theme.getStyle(),
                  ),
                                    MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  divider(),
                  TextFormField(
                    controller: premiseName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter valid name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Name',
                      errorStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                  divider(),
                  TextFormField(
                    controller: premiseDescription,
                    onFieldSubmitted: (value) {
                      if (formKey.currentState!.validate()) {
                        _addNewEntity(
                          premiseName.text,
                          premiseDescription.text,
                          premiseTags.text.split(' '),
                          location,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Description',
                      errorStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                  divider(),
                  TextFormField(
                    controller: premiseTags,
                    onFieldSubmitted: (value) {
                      if (formKey.currentState!.validate()) {
                        _addNewEntity(
                          premiseName.text,
                          premiseDescription.text,
                          premiseTags.text.split(' '),
                          location,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Tags',
                      errorStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                  divider(),
                  TextFormField(
                    readOnly: true,
                    onChanged: (value) {
                      location = location;
                    },
                    onFieldSubmitted: (value) {
                      if (formKey.currentState!.validate()) {
                        _addNewEntity(
                          premiseName.text,
                          premiseDescription.text,
                          premiseTags.text.split(' '),
                          location,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Location',
                      errorStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _mapDialog(context);
                        },
                        icon: const Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ),
                  divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SecondaryButton(
                        labelKey: 'Cancel',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      divider(
                        horizontal: true,
                      ),
                      PrimaryButton(
                        labelKey: 'Save',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.of(context).pop();
                            _addNewEntity(
                              premiseName.text,
                              premiseDescription.text,
                              premiseTags.text.split(' '),
                              location,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _addNewEntity(
    String premiseName,
    String description,
    List<String> tags,
    tapi.GeoLocation? location,
  ) async {
    busy();

    try {
      var res = await TwinnedSession.instance.twin.createPremise(
        apikey: TwinnedSession.instance.authToken,
        body: tapi.PremiseInfo(
          name: premiseName,
          description: description,
          location: location,
          tags: tags,
        ),
      );

      if (validateResponse(res)) {
        tapi.Premise entity = res.body!.entity!;
        _entities.add(entity);
        _buildCard(
          entity,
        );
      }

      refresh();
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    busy(busy: false);
  }

  Future _edit(tapi.Premise e) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PremiseContentPage(
          premise: e,
          key: Key(
            Uuid().v4(),
          ),
        ),
      ),
    );
    await _load();
  }

  _confirmDeletionDialog(BuildContext context, tapi.Premise e) {
    Widget cancelButton = SecondaryButton(
      labelKey: 'Cancel',
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = PrimaryButton(
      labelKey: 'Delete',
      onPressed: () {
        Navigator.pop(context);
        _delete(e);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: theme.getStyle(),
      ),
      content: Text(
        "Deleting a Premisw can not be undone.\nYou will loose all of the premise data, history, etc.\n\nAre you sure you want to delete?",
        style: theme.getStyle(),
        maxLines: 10,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _delete(tapi.Premise e) async {
    busy();

    try {
      int index = _entities.indexWhere((element) => element.id == e.id);
      var res = await TwinnedSession.instance.twin.deletePremise(
        apikey: TwinnedSession.instance.authToken,
        premiseId: e.id,
      );

      if (validateResponse(res)) {
        _entities.removeAt(index);
        _cards.removeAt(index);
      }
      refresh();
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    busy(busy: false);
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _entities.clear();
    _cards.clear();

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.searchPremises(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.Premise e in _entities) {
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
