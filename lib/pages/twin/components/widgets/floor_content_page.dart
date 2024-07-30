import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/pages/twin/components/widgets/client_infratsructure_widget.dart';
import 'package:twin_app/pages/twin/components/widgets/roles_infrastructure_widget.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/osm_location_picker.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twinned_api/twinned_api.dart' as twinned;
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:uuid/uuid.dart';

class FloorContentPage extends StatefulWidget {
  final Floor? floor;

  const FloorContentPage({
    super.key,
    this.floor,
  });

  @override
  State<FloorContentPage> createState() => _FloorContentPageState();
}

class _FloorContentPageState extends BaseState<FloorContentPage> {
  static const TextStyle _style = TextStyle(fontSize: 20);

  static const Widget _missingImage = Icon(
    Icons.question_mark,
    size: 50,
  );

  final TextEditingController _name = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _tags = TextEditingController();
  final TextEditingController _location = TextEditingController();

  Widget infraImage = const Icon(
    Icons.question_mark,
    size: 250,
  );
  late final String domainKey;
  int selectedImage = 0;
  String imageId = "";
  List<String> imageIds = [];
  late final String heading;
  late final String name;
  GeoLocation? _pickedLocation;
  String search = '*';
  bool loading = false;
  final List<Facility> _facilities = [];
  final List<Floor> _floors = [];
  final List<Asset> _assets = [];
  final List<Device> _devices = [];

  List<String> rolesSelected = [];
  List<String> clientsSelected = [];

  @override
  void initState() {
    domainKey = widget.floor!.domainKey;
    heading = 'Floor';
    name = widget.floor!.name;
    if (null != widget.floor!.floorPlan &&
        widget.floor!.floorPlan!.isNotEmpty) {
      imageIds.add(widget.floor!.floorPlan!);
    }
    _name.text = widget.floor!.name;
    _desc.text = widget.floor!.description ?? '';
    _tags.text = (widget.floor!.tags ?? []).join(' ');
    _pickedLocation = widget.floor!.location;
    rolesSelected = widget.floor!.roles!;
    clientsSelected = widget.floor!.clientIds!;

    if (null != _pickedLocation) {
      _location.text =
          '${_pickedLocation!.coordinates[0]}, ${_pickedLocation!.coordinates[1]}';
    }

    super.initState();
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

  Future _load() async {
    if (loading) return;

    if (search.trim().isEmpty) {
      search = '*';
    }

    loading = true;

    _facilities.clear();
    _floors.clear();
    _assets.clear();
    _devices.clear();

    await execute(() async {
      var res = await TwinnedSession.instance.twin.searchAssets(
          apikey: TwinnedSession.instance.authToken,
          floorId: widget.floor!.id,
          body: SearchReq(search: search, page: 0, size: 10000));
      if (validateResponse(res)) {
        _assets.addAll(res.body!.values!);
      }
    });

    loading = false;
    setState(() {});
  }

  Future _upload() async {
    await execute(() async {
      ImageFileEntityRes? res;

      res = await TwinImageHelper.uploadFloorImage(floorId: widget.floor!.id);
      if (null != res) {
        imageId = res.entity!.id;
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

  Future<void> _pickLocation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 1000,
            child: OSMLocationPicker(
              onPicked: (pickedData) {
                setState(() {
                  _pickedLocation = GeoLocation(
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

  Widget _buildFacility(Facility e) {
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
              builder: (context) => FloorContentPage(
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

  Widget _buildFloor(Floor e) {
    String imageId = '';
    if (null != e.floorPlan && e.floorPlan!.isNotEmpty) {
      imageId = e.floorPlan!;
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
              builder: (context) => FloorContentPage(
                key: Key(const Uuid().v4()),
                floor: e,
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

  Widget _buildAsset(Asset e) {
    int idx = e.selectedImage ?? 0;
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
              builder: (context) => FloorContentPage(
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

  Future _save() async {
    await _saveFloor();
  }

  static twinned.FloorInfo floorInfo(
    twinned.Floor e, {
    required String? name,
    String? description,
    List<String>? tags,
    List<String>? roles,
    List<String>? clientIds,
    String? floorPlan,
    twinned.GeoLocation? location,
    int? floorLevel,
    twinned.FloorInfoFloorType? floorType,
  }) {
    return twinned.FloorInfo(
      name: name ?? e.name,
      description: description ?? e.description,
      tags: tags ?? e.tags,
      roles: roles ?? e.roles,
      clientIds: clientIds ?? e.clientIds,
      floorPlan: floorPlan ?? e.floorPlan,
      location: location ?? e.location,
      premiseId: e.premiseId,
      facilityId: e.facilityId,
      floorLevel: floorLevel ?? e.floorLevel,
      floorType: twinned.FloorInfoFloorType.values
          .byName(null != floorType ? floorType.name : e.floorType.name),
      assets: e.assets,
    );
  }

  Future _saveFloor() async {
    await execute(() async {
      FloorInfo body = floorInfo(widget.floor!,
          name: _name.text,
          description: _desc.text,
          tags: _tags.text.trim().split(' '),
          location: _pickedLocation,
          floorPlan: imageId,
          roles: rolesSelected,
          clientIds: clientsSelected);

      var res = await TwinnedSession.instance.twin.updateFloor(
          apikey: TwinnedSession.instance.authToken,
          floorId: widget.floor!.id,
          body: body);

      if (validateResponse(res)) {
        _close();
      }
    });
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
                  label: 'Floor Name',
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
                                    icon: const Icon(Icons.upload)),
                              if (imageId.isNotEmpty)
                                IconButton(
                                    onPressed: () async {
                                      await _delete();
                                    },
                                    icon: const Icon(Icons.delete_forever)),
                            ],
                          )),
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
                                          "${widget.floor!.name} - Assets",
                                          style: _style,
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
                                      ..._floors.map((e) => _buildFloor(e)),
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
                labelKey: "Cancel",
                onPressed: () {
                  _close();
                },
              ),
              divider(horizontal: true),
              PrimaryButton(
                labelKey: "Save",
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
}
