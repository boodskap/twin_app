import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/client_infratsructure_widget.dart';
import 'package:twin_app/pages/twin/components/widgets/floor_content_page.dart';
import 'package:twin_app/pages/twin/components/widgets/floor_snippet.dart';
import 'package:twin_app/pages/twin/components/widgets/roles_infrastructure_widget.dart';
import 'package:twin_app/pages/twin/components/widgets/utils.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_app/widgets/google_map.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:uuid/uuid.dart';

class FacilityContentPage extends StatefulWidget {
  final Premise? premise;
  final Facility facility;
  const FacilityContentPage({
    super.key,
    this.premise,
    required this.facility,
  });

  @override
  State<FacilityContentPage> createState() => _FacilityContentPageState();
}

class _FacilityContentPageState extends BaseState<FacilityContentPage> {
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
    super.initState();

    domainKey = widget.facility.domainKey;
    heading = 'Facility';
    name = widget.facility.name;
    selectedImage = 0;
    imageIds = widget.facility.images ?? [];
    _name.text = widget.facility.name;
    _desc.text = widget.facility.description ?? '';
    _tags.text = (widget.facility.tags ?? []).join(' ');
    _pickedLocation = widget.facility.location;
    rolesSelected = widget.facility.roles!;
    clientsSelected = widget.facility.clientIds;

    if (null != _pickedLocation) {
      _location.text =
          '${_pickedLocation!.coordinates[0]}, ${_pickedLocation!.coordinates[1]}';
    }
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
      var res = await TwinnedSession.instance.twin.searchFloors(
          apikey: TwinnedSession.instance.authToken,
          facilityId: widget.facility.id,
          body: SearchReq(search: search, page: 0, size: 10000));
      if (validateResponse(res)) {
        _floors.addAll(res.body!.values!);
      }
    });

    loading = false;
    refresh();
  }

  Future _upload() async {
    await execute(() async {
      ImageFileEntityRes? res = await TwinImageHelper.uploadFacilityImage(
          facilityId: widget.facility.id);
      if (null != res) {
        imageId = res.entity!.id;
        widget.facility.images!.add(imageId);
      }

      if (imageId.isNotEmpty) {
        setState(() {
          infraImage = TwinImageHelper.getCachedImage(domainKey, imageId);
        });
      }
    });
  }

  Future _delete() async {
    await confirm(
        title: 'Are you sure?',
        message: 'you want to delete this image?',
        titleStyle: theme.getStyle().copyWith(fontSize: 20, color: Colors.red),
        messageStyle: theme.getStyle(),
        onPressed: () async {
          await execute(() async {
            var res = await TwinnedSession.instance.twin.deleteImage(
                apikey: TwinnedSession.instance.authToken, id: imageId);
            if (res.body!.ok) {
              widget.facility.images!.remove(imageId);
              refresh(sync: () {
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

  String _getSearchHint(InfraType type) {
    switch (type) {
      case InfraType.premise:
        return 'Search Facilities';
      case InfraType.facility:
        return 'Search Floors';
      case InfraType.floor:
        return 'Search Assets';
      case InfraType.asset:
        return 'Search Devices';
      default:
        return 'Search';
    }
  }

  String _getLabelName(InfraType type) {
    switch (type) {
      case InfraType.premise:
        return 'Premise Name';
      case InfraType.facility:
        return 'Faciliy Name';
      case InfraType.floor:
        return 'Floor Name';
      case InfraType.asset:
        return 'Asset Name';
      default:
        return 'Name';
    }
  }

  Future<void> _pickLocation(BuildContext context) async {
    double pickedLatitude =
        _pickedLocation != null ? _pickedLocation!.coordinates[1] : 39.6128;
    double pickedLongitude =
        _pickedLocation != null ? _pickedLocation!.coordinates[0] : -101.5382;

    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.97,
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 1000,
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: GoogleMapWidget(
                          longitude: pickedLongitude,
                          latitude: pickedLatitude,
                          saveLocation: (pickedData) {
                            setState(() {
                              pickedLatitude = double.parse(
                                  pickedData.latitude.toStringAsFixed(4));
                              pickedLongitude = double.parse(
                                  pickedData.longitude.toStringAsFixed(4));
                            });
                          },
                          viewMode: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Latitude: ${pickedLatitude.toStringAsFixed(4)}',
                            style: theme.getStyle().copyWith(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Longitude: ${pickedLongitude.toStringAsFixed(4)}',
                            style: theme.getStyle().copyWith(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          SecondaryButton(
                            labelKey: 'Cancel',
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Close without saving
                            },
                          ),
                          SizedBox(width: 5),
                          PrimaryButton(
                            labelKey: 'Select',
                            onPressed: () {
                              Navigator.of(context).pop({
                                'latitude': pickedLatitude,
                                'longitude': pickedLongitude,
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _pickedLocation = GeoLocation(
            type: 'point',
            coordinates: [result['longitude']!, result['latitude']!]);
        _location.text =
            '${_pickedLocation!.coordinates[0]}, ${_pickedLocation!.coordinates[1]}';
      });
    }
  }

  Widget _buildFloor(Floor e) {
    String imageId = '';
    if (null != e.floorPlan && e.floorPlan!.isNotEmpty) {
      imageId = e.floorPlan!;
    }
    Widget image = imageId.isNotEmpty
        ? TwinImageHelper.getCachedImage(e.domainKey, imageId)
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
                premise: widget.premise,
                facility: widget.facility,
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
                          style: theme.getStyle().copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          e.description ?? "",
                          style: theme.getStyle().copyWith(fontSize: 16),
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
    await execute(() async {
      FacilityInfo body = Utils.facilityInfo(widget.facility,
          name: _name.text,
          description: _desc.text,
          tags: _tags.text.trim().split(' '),
          selectedImage: selectedImage,
          location: _pickedLocation,
          roles: rolesSelected,
          clientIds: clientsSelected);

      var res = await TwinnedSession.instance.twin.updateFacility(
          apikey: TwinnedSession.instance.authToken,
          facilityId: widget.facility.id,
          body: body);

      if (validateResponse(res)) {
        _close();
        alert('Facility - ${res.body!.entity!.name}', ' Saved successfully!',
            contentStyle: theme.getStyle(),
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
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
            style: theme.getStyle().copyWith(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          divider(),
          Row(
            children: [
              divider(horizontal: true),
              Expanded(
                flex: 1,
                child: LabelTextField(
                  style: theme.getStyle(),
                  labelTextStyle: theme.getStyle(),
                  label: _getLabelName(InfraType.facility),
                  controller: _name,
                ),
              ),
              divider(horizontal: true),
              Expanded(
                flex: 1,
                child: LabelTextField(
                  style: theme.getStyle(),
                  labelTextStyle: theme.getStyle(),
                  label: 'Description',
                  controller: _desc,
                ),
              ),
              divider(horizontal: true),
              Expanded(
                flex: 1,
                child: LabelTextField(
                  style: theme.getStyle(),
                  labelTextStyle: theme.getStyle(),
                  label: 'Tags',
                  controller: _tags,
                ),
              ),
              divider(horizontal: true),
              Expanded(
                flex: 1,
                child: LabelTextField(
                  style: theme.getStyle(),
                  labelTextStyle: theme.getStyle(),
                  suffixIcon: Tooltip(
                    message: 'Pick a Location',
                    preferBelow: false,
                    child: InkWell(
                      onTap: () async {
                        await _pickLocation(context);
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
                                          "${widget.facility.name} - Floors",
                                          style: theme
                                              .getStyle()
                                              .copyWith(fontSize: 20),
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
                                                  hintText: _getSearchHint(
                                                      InfraType.facility),
                                                  hintStyle:
                                                      WidgetStatePropertyAll(
                                                          theme.getStyle()),
                                                  textStyle:
                                                      WidgetStatePropertyAll(
                                                          theme.getStyle()),
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
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: PrimaryButton(
                                          labelKey: 'Create Floor',
                                          leading: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                          onPressed: (canCreate())
                                              ? _addEditFloorDialog
                                              : null,
                                        ),
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
                labelKey: "Close",
                onPressed: () {
                  _close();
                },
              ),
              divider(horizontal: true),
              PrimaryButton(
                leading: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
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

  void _addEditFloorDialog({Floor? floor}) async {
    Premise? selectedPremise;
    Facility? selectedFacility;

    if (floor != null && (widget.premise != null)) {
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
        selectedFacilityId: widget.facility.id,
        selectedPremiseId: widget.facility.premiseId,
        selectedPremise: selectedPremise,
        selectedFacility: selectedFacility ?? widget.facility,
        floor: floor,
      ),
      width: 750,
      height: MediaQuery.of(context).size.height - 150,
    );

    _load();
  }

  @override
  void setup() async {
    if (imageIds.length > selectedImage) {
      setState(() {
        imageId = imageIds[selectedImage];
        infraImage = TwinImageHelper.getCachedImage(domainKey, imageId,
            fit: BoxFit.fill);
      });
    }
    await _load();
  }
}
