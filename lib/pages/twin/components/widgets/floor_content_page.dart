import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/asset_content_page.dart';
import 'package:twin_app/pages/twin/components/widgets/asset_snippet.dart';
import 'package:twin_app/pages/twin/components/widgets/client_infratsructure_widget.dart';
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

class FloorContentPage extends StatefulWidget {
  final Premise? premise;
  final Facility? facility;
  final Floor floor;

  const FloorContentPage({
    super.key,
    this.premise,
    this.facility,
    required this.floor,
  });

  @override
  State<FloorContentPage> createState() => _FloorContentPageState();
}

class _FloorContentPageState extends BaseState<FloorContentPage> {
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
    domainKey = widget.floor.domainKey;
    heading = 'Floor';
    name = widget.floor.name;
    if (null != widget.floor.floorPlan && widget.floor.floorPlan!.isNotEmpty) {
      imageIds.add(widget.floor.floorPlan!);
    }
    _name.text = widget.floor.name;
    _desc.text = widget.floor.description ?? '';
    _tags.text = (widget.floor.tags ?? []).join(' ');
    _pickedLocation = widget.floor.location;
    rolesSelected = widget.floor.roles!;
    clientsSelected = widget.floor.clientIds;

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
        infraImage = TwinImageHelper.getCachedImage(domainKey, imageId,
            fit: BoxFit.fill);
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
          floorId: widget.floor.id,
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
      ImageFileEntityRes? res =
          await TwinImageHelper.uploadFloorImage(floorId: widget.floor.id);
      if (null != res) {
        imageId = res.entity!.id;
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
        titleStyle: theme.getStyle().copyWith(color: Colors.red, fontSize: 20),
        messageStyle: theme.getStyle(),
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
        return 'Facility Name';
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
                              Navigator.of(context).pop();
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

  Widget _buildAsset(Asset e) {
    int idx = e.selectedImage ?? 0;
    String imageId = '';
    if (null != e.images && e.images!.length > idx) {
      imageId = e.images![idx];
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
              builder: (context) => AssetContentPage(
                key: Key(const Uuid().v4()),
                premise: widget.premise,
                facility: widget.facility,
                floor: widget.floor,
                asset: e,
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
      FloorInfo body = Utils.floorInfo(widget.floor,
          name: _name.text,
          description: _desc.text,
          tags: _tags.text.trim().split(' '),
          location: _pickedLocation,
          floorPlan: imageId,
          roles: rolesSelected,
          clientIds: clientsSelected);

      var res = await TwinnedSession.instance.twin.updateFloor(
          apikey: TwinnedSession.instance.authToken,
          floorId: widget.floor.id,
          body: body);

      if (validateResponse(res)) {
        _close();
        alert('Floor - ${_name.text}', ' Saved successfully!',
            contentStyle: theme.getStyle(),
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 20, fontWeight: FontWeight.bold));
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
                  label: _getLabelName(InfraType.floor),
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
                                          "${widget.floor.name} - Assets",
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
                                                  leading:
                                                      const Icon(Icons.search),
                                                  hintText: _getSearchHint(
                                                      InfraType.asset),
                                                  hintStyle:
                                                      WidgetStatePropertyAll(
                                                          theme.getStyle()),
                                                  textStyle:
                                                      WidgetStatePropertyAll(
                                                          theme.getStyle()),
                                                  onChanged: (value) async {
                                                    search = value;
                                                    await _load();
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                      divider(),
                                      if (canCreate())
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            PrimaryButton(
                                              labelKey: 'Create Asset',
                                              leading: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              onPressed: (canCreate())
                                                  ? () {
                                                      _addEditAssetDialog();
                                                    }
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      divider(),
                                      ..._assets.map((e) => _buildAsset(e)),
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

  void _addEditAssetDialog({Asset? asset}) async {
    await super.alertDialog(
      titleStyle:
          theme.getStyle().copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      title: null == asset ? 'Add New Asset' : 'Update Asset',
      body: AssetSnippet(
        selectedPremise: widget.premise,
        selectedFacility: widget.facility,
        selectedFloor: widget.floor,
        asset: asset,
      ),
      width: 750,
      height: MediaQuery.of(context).size.height - 150,
    );
    _load();
  }
}
