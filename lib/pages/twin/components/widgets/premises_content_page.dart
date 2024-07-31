import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/client_infratsructure_widget.dart';
import 'package:twin_app/pages/twin/components/widgets/roles_infrastructure_widget.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_commons/util/osm_location_picker.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:uuid/uuid.dart';

class PremiseContentPage extends StatefulWidget {
  final tapi.Premise premise;
  const PremiseContentPage({super.key, required this.premise});

  @override
  State<PremiseContentPage> createState() => _PremiseContentPageState();
}

class _PremiseContentPageState extends BaseState<PremiseContentPage> {
  static const Widget _missingImage = Icon(
    Icons.question_mark,
    size: 50,
  );

  Widget infraImage = const Icon(
    Icons.question_mark,
    size: 250,
  );

  List<String> rolesSelected = [];
  List<String> clientsSelected = [];
  late final String heading;
  late final String name;
  tapi.GeoLocation? _pickedLocation;
  String imageId = "";
  List<String> imageIds = [];
  late final String domainKey;
  String search = '*';
  int selectedImage = 0;
  bool loading = false;
  final List<tapi.Premise> _premises = [];

  final TextEditingController _name = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _tags = TextEditingController();
  final TextEditingController _location = TextEditingController();

  @override
  void initState() {
    domainKey = widget.premise.domainKey;
    heading = 'Premise';
    selectedImage = 0;
    imageIds = widget.premise.images ?? [];
    name = widget.premise.name;
    _name.text = widget.premise.name;
    _desc.text = widget.premise.description ?? '';
    _tags.text = (widget.premise.tags ?? []).join(' ');
    _pickedLocation = widget.premise.location;
    rolesSelected = widget.premise.roles!;
    clientsSelected = widget.premise.clientIds!;

    if (null != _pickedLocation) {
      _location.text =
          '${_pickedLocation!.coordinates[0]}, ${_pickedLocation!.coordinates[1]}';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: '$heading - $name',
          ),
          divider(),
          Row(
            children: [
              divider(horizontal: true),
              Expanded(
                flex: 1,
                child: LabelTextField(
                  label: 'Premise Name',
                  controller: _name,
                ),
              ),
              divider(horizontal: true),
              Expanded(
                flex: 1,
                child: LabelTextField(
                  label: 'Description',
                  controller: _desc,
                ),
              ),
              divider(horizontal: true),
              Expanded(
                flex: 1,
                child: LabelTextField(
                  label: 'Tags',
                  controller: _tags,
                ),
              ),
              divider(horizontal: true),
              Expanded(
                flex: 1,
                child: LabelTextField(
                  suffixIcon: Tooltip(
                    message: 'Pick a Location',
                    preferBelow: false,
                    child: InkWell(
                      onTap: () async {
                        await _pickLocation();
                      },
                      child: const Icon(
                        Icons.location_pin,
                        size: 30,
                      ),
                    ),
                  ),
                  readOnlyVal: true,
                  label: 'Location',
                  controller: _location,
                ),
              ),
              divider(horizontal: true),
              const BusyIndicator(),
              divider(horizontal: true),
            ],
          ),
          divider(),
          Expanded(
              child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Center(child: infraImage),
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          children: [
                            if (imageId.isEmpty)
                              IconButton(
                                onPressed: () async {
                                  await _upload();
                                },
                                icon: const Icon(Icons.upload),
                              ),
                            if (imageId.isNotEmpty)
                              IconButton(
                                onPressed: () async {
                                  await _delete();
                                },
                                icon: const Icon(Icons.delete_forever),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              divider(horizontal: true),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraint) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: constraint.maxHeight),
                                child: IntrinsicHeight(
                                  child: Column(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          "${widget.premise.name} - Premise",
                                          style: theme.getStyle(),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Tooltip(
                                              message: "Roles",
                                              child: RolesInfrastructeWidget(
                                                currentRoles: rolesSelected,
                                                valueChanged: (value) {
                                                  if (value.isNotEmpty) {
                                                    setState(() {
                                                      rolesSelected = value;
                                                    });
                                                  }
                                                },
                                                saveConfirm: (value) {},
                                              )),
                                          divider(horizontal: true),
                                          Tooltip(
                                              message: "Clients",
                                              child: ClientInfrastructeWidget(
                                                currentClients: clientsSelected,
                                                valueChanged: (value) {
                                                  if (value.isNotEmpty) {
                                                    setState(() {
                                                      clientsSelected = value;
                                                    });
                                                  }
                                                },
                                                saveConfirm: (value) {},
                                              )),
                                          divider(horizontal: true),
                                          Expanded(
                                            child: Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: SearchBar(
                                                  leading:
                                                      const Icon(Icons.search),
                                                  onChanged: (value) async {
                                                    search = value;
                                                    await _load();
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                      divider(),
                                      ..._premises.map((e) => _buildPremise(e)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
          divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SecondaryButton(
                labelKey: 'Close',
                onPressed: () {
                  _close();
                },
              ),
              divider(horizontal: true),
              PrimaryButton(
                labelKey: 'Save',
                onPressed: () async {
                  await _save();
                },
              ),
              divider(horizontal: true),
            ],
          ),
          divider(),
        ],
      ),
    );
  }

  Future<void> _pickLocation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 1000,
            child: OSMLocationPicker(
              longitude: _pickedLocation?.coordinates[0],
              latitude: _pickedLocation?.coordinates[1],
              onPicked: (pickedData) {
                setState(() {
                  _pickedLocation = tapi.GeoLocation(
                      type: 'point',
                      coordinates: [pickedData.longitude, pickedData.latitude]);
                  _location.text =
                      '${_pickedLocation!.coordinates[0]}, ${_pickedLocation!.coordinates[1]}';
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  Future _upload() async {
    await execute(() async {
      tapi.ImageFileEntityRes? res;

      res = await TwinImageHelper.uploadPremiseImage(
          premiseId: widget.premise.id);
      if (null != res) {
        imageId = res.entity!.id;
        widget.premise.images!.add(imageId);
      }
      if (imageId.isNotEmpty) {
        setState(() {
          infraImage = TwinImageHelper.getImage(domainKey, imageId);
        });
      }
    });
  }

  Future _delete() async {
    await confirm(
        title: 'Are you sure?',
        message: 'you want to delete this image?',
        onPressed: () async {
          await execute(() async {
            var res = await TwinnedSession.instance.twin.deleteImage(
                apikey: TwinnedSession.instance.authToken, id: imageId);
            if (res.body!.ok) {
              widget.premise.images!.remove(imageId);
              setState(() {
                imageId = '';
                infraImage = const Icon(
                  Icons.question_mark,
                  size: 250,
                );
              });
            }
          });
        });
  }

  static tapi.PremiseInfo premiseInfo(tapi.Premise e,
      {required String? name,
      String? description,
      List<String>? tags,
      List<String>? roles,
      List<String>? clientIds,
      List<String>? images,
      tapi.GeoLocation? location,
      int? selectedImage}) {
    return tapi.PremiseInfo(
      name: name ?? e.name,
      description: description ?? e.description,
      tags: tags ?? e.tags,
      roles: roles ?? e.roles,
      clientIds: clientIds ?? e.clientIds,
      images: images ?? e.images,
      location: location ?? e.location,
      selectedImage: selectedImage ?? e.selectedImage,
    );
  }

  Future _savePremise() async {
    await execute(() async {
      tapi.PremiseInfo body = premiseInfo(widget.premise,
          name: _name.text,
          description: _desc.text,
          tags: _tags.text.trim().split(' '),
          selectedImage: selectedImage,
          location: _pickedLocation,
          roles: rolesSelected,
          clientIds: clientsSelected);

      var res = await TwinnedSession.instance.twin.updatePremise(
          apikey: TwinnedSession.instance.authToken,
          premiseId: widget.premise.id,
          body: body);

      if (validateResponse(res)) {
        _close();
      }
    });
  }

  Future _save() async {
    await _savePremise();
  }

  Widget _buildPremise(tapi.Premise e) {
    int idx = e.selectedImage ?? 0;
    if (idx < 0) idx = 0;
    String imageId = '';
    if (null != e.images && e.images!.length > idx) {
      imageId = e.images![idx];
    }
    Widget image = imageId.isNotEmpty
        ? TwinImageHelper.getImage(e.domainKey, imageId)
        : _missingImage;

    return Card(
      elevation: 10,
      child: InkWell(
        onDoubleTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PremiseContentPage(
                premise: e,
                key: Key(const Uuid().v4()),
              ),
            ),
          );
          await _load();
        },
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              SizedBox(
                  width: 100,
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: image,
                  )),
              divider(horizontal: true),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          e.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          e.description ?? "",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _close() {
    Navigator.pop(context);
  }

  Future _load() async {
    if (loading) return;

    if (search.trim().isEmpty) {
      search = '*';
    }

    loading = true;

    _premises.clear();

    await execute(() async {
      var res = await TwinnedSession.instance.twin.searchPremises(
        apikey: TwinnedSession.instance.authToken,
        body: tapi.SearchReq(
          search: search,
          page: 0,
          size: 10000,
        ),
      );
      if (validateResponse(res)) {
        // _premises.addAll(res.body!.values!);
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() async {
    if (imageIds.length > selectedImage) {
      setState(() {
        imageId = imageIds[selectedImage];
        infraImage =
            TwinImageHelper.getImage(domainKey, imageId, fit: BoxFit.fill);
      });
    }
    await _load();
  }
}
