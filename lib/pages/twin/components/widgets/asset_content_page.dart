import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/asset_device.dart';
import 'package:twin_app/pages/twin/components/widgets/device_info_snippet.dart';
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
import 'package:twinned_widgets/core/client_dropdown.dart';
import 'package:twinned_widgets/core/facility_dropdown.dart';
import 'package:twinned_widgets/core/floor_dropdown.dart';
import 'package:twinned_widgets/core/premise_dropdown.dart';
import 'package:twinned_widgets/core/top_bar.dart';

class AssetContentPage extends StatefulWidget {
  final Premise? premise;
  final Facility? facility;
  final Floor? floor;
  final Asset asset;

  const AssetContentPage(
      {super.key,
      this.premise,
      this.facility,
      this.floor,
      required this.asset});

  @override
  State<AssetContentPage> createState() => _AssetContentPageState();
}

class _AssetContentPageState extends BaseState<AssetContentPage> {
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
  String? selectedClient;
  String? selectedPremise;
  String? selectedFacility;
  String? selectedFloor;

  @override
  void initState() {
    super.initState();

    domainKey = widget.asset.domainKey;
    heading = 'Asset';
    name = widget.asset.name;
    selectedImage = 0;
    imageIds = widget.asset.images ?? [];
    _name.text = widget.asset.name;
    _desc.text = widget.asset.description ?? '';
    _tags.text = (widget.asset.tags ?? []).join(' ');
    _pickedLocation = widget.asset.location;
    rolesSelected = widget.asset.roles!;
    selectedClient =
        widget.asset.clientIds.isNotEmpty ? widget.asset.clientIds.first : null;
    selectedPremise = widget.asset.premiseId;
    selectedFacility = widget.asset.facilityId;
    selectedFloor = widget.asset.floorId;

    if (null != _pickedLocation) {
      _location.text =
          '${_pickedLocation!.coordinates[0]}, ${_pickedLocation!.coordinates[1]}';
    }
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
      var res = await TwinnedSession.instance.twin.searchDevices(
          apikey: TwinnedSession.instance.authToken,
          assetId: widget.asset.id,
          body: SearchReq(search: search, page: 0, size: 10000));
      if (validateResponse(res)) {
        _devices.addAll(res.body!.values!);
      }
    });

    loading = false;
    setState(() {});
  }

  Future _upload() async {
    await execute(() async {
      ImageFileEntityRes? res =
          await TwinImageHelper.uploadAssetImage(assetId: widget.asset.id);
      if (null != res) {
        imageId = res.entity!.id;
        widget.asset.images!.add(imageId);
      }

      if (imageId.isNotEmpty) {
        refresh(sync: () {
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
              widget.asset.images!.remove(imageId);
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

  // using google map
  Future<void> _pickLocation(BuildContext context) async {
    double pickedLatitude =
        _pickedLocation != null ? _pickedLocation!.coordinates[1] : 39.6128;
    double pickedLongitude =
        _pickedLocation != null ? _pickedLocation!.coordinates[0] : -101.5382;

    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: theme.getStyle().copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
          contentTextStyle: theme.getStyle(),
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
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Longitude: ${pickedLongitude.toStringAsFixed(4)}',
                            style: const TextStyle(
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

  Widget _buildDevice(Device e) {
    return Card(
      elevation: 10,
      child: Container(
        color: Colors.white,
        child: DeviceInfoSnippet(
          device: e,
          axis: Axis.horizontal,
        ),
      ),
    );
  }

  void _close() {
    Navigator.pop(context);
  }

  Future _save() async {
    await execute(() async {
      AssetInfo body = Utils.assetInfo(
        widget.asset,
        name: _name.text,
        description: _desc.text,
        tags: _tags.text.trim().split(' '),
        selectedImage: selectedImage,
        location: _pickedLocation,
        roles: rolesSelected,
        clientIds: selectedClient != null ? [selectedClient!] : [],
        premiseId: selectedPremise,
        facilityId: selectedFacility,
        floorId: selectedFloor,
      );
      var res = await TwinnedSession.instance.twin.updateAsset(
          apikey: TwinnedSession.instance.authToken,
          assetId: widget.asset.id,
          body: body);
      if (validateResponse(res)) {
        _close();
        alert('Asset - ${res.body!.entity!.name}', 'Saved successfully!',
            titleStyle: theme
                .getStyle()
                .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            contentStyle: theme.getStyle());
      }
    });
  }

  Future _editAsset() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            titleTextStyle: theme.getStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
            contentTextStyle: theme.getStyle(),
            scrollable: true,
            content: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: 670,
              child: AssetDevice(
                asset: widget.asset,
              ),
            ),
          );
        });
    await _load();
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
                  label: 'Asset Name',
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
                                        child: Column(
                                          children: [
                                            if (!isClientAdmin())
                                              ClientDropdown(
                                                  selectedItem: selectedClient,
                                                  style: theme.getStyle(),
                                                  onClientSelected: (entity) {
                                                    setState(() {
                                                      if (entity == null) {
                                                        selectedClient = null;
                                                      } else {
                                                        selectedClient =
                                                            entity.id;
                                                      }
                                                    });
                                                  }),
                                            PremiseDropdown(
                                                selectedItem: selectedPremise,
                                                style: theme.getStyle(),
                                                onPremiseSelected: (entity) {
                                                  setState(() {
                                                    if (entity == null) {
                                                      selectedPremise = null;
                                                    } else {
                                                      selectedPremise =
                                                          entity.id;
                                                      selectedFacility = null;
                                                    }
                                                  });
                                                }),
                                            FacilityDropdown(
                                                selectedItem: selectedFacility,
                                                style: theme.getStyle(),
                                                selectedPremise:
                                                    selectedPremise,
                                                onFacilitySelected: (entity) {
                                                  setState(() {
                                                    if (entity == null) {
                                                      selectedFacility = null;
                                                    } else {
                                                      selectedFacility =
                                                          entity.id;
                                                      selectedFloor = null;
                                                    }
                                                  });
                                                }),
                                            FloorDropdown(
                                                selectedItem: selectedFloor,
                                                selectedPremise:
                                                    selectedPremise,
                                                selectedFacility:
                                                    selectedFacility,
                                                style: theme.getStyle(),
                                                onFloorSelected: (entity) {
                                                  setState(() {
                                                    if (entity == null) {
                                                      selectedFloor = null;
                                                    } else {
                                                      selectedFloor = entity.id;
                                                    }
                                                  });
                                                }),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "${widget.asset.name} - Devices",
                                                  style: theme
                                                      .getStyle()
                                                      .copyWith(fontSize: 20),
                                                ),
                                                divider(horizontal: true),
                                                IconButton(
                                                    onPressed: () async {
                                                      await _editAsset();
                                                    },
                                                    icon:
                                                        const Icon(Icons.edit)),
                                              ],
                                            ),
                                          ],
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
                                          Expanded(
                                            child: Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: SearchBar(
                                                  hintStyle:
                                                      WidgetStatePropertyAll(
                                                          theme.getStyle()),
                                                  textStyle:
                                                      WidgetStatePropertyAll(
                                                          theme.getStyle()),
                                                  hintText: 'Search Devices',
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
                                      ..._devices.map((e) => _buildDevice(e)),
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
}
