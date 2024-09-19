import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/asset_type_dropdown.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_app/widgets/google_map.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twinned_widgets/core/facility_dropdown.dart';
import 'package:twinned_widgets/core/floor_dropdown.dart';
import 'package:twinned_widgets/core/premise_dropdown.dart';
import 'package:twinned_widgets/core/client_dropdown.dart';

import 'package:uuid/uuid.dart';

class AssetSnippet extends StatefulWidget {
  final tapi.Asset? asset;
  final tapi.Premise? selectedPremise;
  final tapi.Facility? selectedFacility;
  final tapi.Floor? selectedFloor;
  String? selectedPremiseId;
  String? selectedFacilityId;
  String? selectedFloorId;
  AssetSnippet(
      {super.key,
      this.asset,
      this.selectedPremise,
      this.selectedFacility,
      this.selectedFloor,
      this.selectedPremiseId,
      this.selectedFacilityId,
      this.selectedFloorId});

  @override
  State<AssetSnippet> createState() => _AssetSnippetState();
}

class _AssetSnippetState extends BaseState<AssetSnippet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController tagController = TextEditingController();

  // Future<List<String>>? clientIds =
  //     isClientAdmin() ? TwinnedSession.instance.getClientIds() : null;
  tapi.AssetInfo _asset = const tapi.AssetInfo(
    name: '',
    clientIds: [],
    tags: [],
    roles: [],
    images: [],
    description: '',
    assetModelId: '',
    premiseId: '',
    facilityId: '',
    floorId: '',
    devices: [],
  );

  @override
  void initState() {
    super.initState();

    _asset = _asset.copyWith(
      premiseId: widget.selectedPremise != null
          ? (widget.selectedPremise?.id ?? widget.asset?.premiseId ?? '')
          : (widget.selectedPremiseId ?? ''),
    );

    _asset = _asset.copyWith(
      facilityId: widget.selectedFacility != null
          ? (widget.selectedFacility?.id ?? widget.asset?.facilityId ?? '')
          : (widget.selectedFacilityId ?? ''),
    );

    _asset = _asset.copyWith(
      floorId: widget.selectedFloor != null
          ? (widget.selectedFloor?.id ?? '')
          : (widget.selectedFloorId ?? ''),
    );
    if (null != widget.asset) {
      tapi.Asset a = widget.asset!;
      _asset = _asset.copyWith(
        clientIds: a.clientIds,
        description: a.description,
        images: a.images,
        location: a.location,
        name: a.name,
        reportedStamp: a.reportedStamp,
        roles: a.roles,
        selectedImage: a.selectedImage,
        tags: a.tags,
        assetModelId: a.assetModelId,
        premiseId: a.premiseId,
        devices: a.devices,
        facilityId: a.facilityId,
        floorId: a.floorId,
      );
    }
    nameController.text = _asset.name;
    descController.text = _asset.description ?? '';
    tagController.text = (_asset.tags ?? []).join(' ');
    // nameController.addListener(_onNameChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        height: MediaQuery.of(context).size.height / 1.1,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.getPrimaryColor(),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      if (!isClientAdmin())
                        ClientDropdown(
                          key: Key(const Uuid().v4()),
                          selectedItem: (null != _asset.clientIds &&
                                  _asset.clientIds!.isNotEmpty)
                              ? _asset.clientIds!.first
                              : null,
                          onClientSelected: (client) {
                            setState(() {
                              _asset = _asset.copyWith(
                                  clientIds:
                                      null != client ? [client!.id] : []);
                            });
                          },
                        ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: PremiseDropdown(
                          key: Key(const Uuid().v4()),
                          selectedItem: _asset.premiseId,
                          onPremiseSelected: (tapi.Premise? selectedPremise) {
                            setState(() {
                              if (selectedPremise == null) {
                                _asset = _asset.copyWith(
                                  premiseId: '',
                                  facilityId: '',
                                  floorId: '',
                                );
                              } else {
                                _asset = _asset.copyWith(
                                  premiseId: selectedPremise.id,
                                  facilityId: '',
                                  floorId: '',
                                );
                              }
                            });
                          },
                        ),
                      ),
                      FacilityDropdown(
                          key: Key(const Uuid().v4()),
                          selectedItem: _asset.facilityId,
                          selectedPremise: _asset.premiseId,
                          onFacilitySelected:
                              (tapi.Facility? selectedFacility) {
                            setState(() {
                              if (selectedFacility == null) {
                                _asset = _asset.copyWith(
                                  facilityId: '',
                                  floorId: '',
                                );
                              } else {
                                _asset = _asset.copyWith(
                                  facilityId: selectedFacility.id,
                                  floorId: '',
                                );
                              }
                            });
                          }),
                      FloorDropdown(
                          key: Key(const Uuid().v4()),
                          selectedItem: _asset.floorId,
                          selectedPremise: _asset.premiseId,
                          selectedFacility: _asset.facilityId,
                          onFloorSelected: (tapi.Floor? selectedFloor) {
                            setState(() {
                              if (selectedFloor != null) {
                                _asset = _asset.copyWith(
                                  floorId: selectedFloor.id,
                                );
                              } else {
                                _asset = _asset.copyWith(floorId: '');
                              }
                            });
                          }),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Name',
                          style: theme.getStyle(),
                          labelTextStyle: theme.getStyle(),
                          controller: nameController,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.getPrimaryColor(),
                            ),
                          ),
                        ),
                      ),
                      divider(height: 15),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Description',
                          style: theme.getStyle(),
                          labelTextStyle: theme.getStyle(),
                          controller: descController,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.getPrimaryColor(),
                            ),
                          ),
                        ),
                      ),
                      divider(height: 15),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Tags (space separated)',
                          style: theme.getStyle(),
                          labelTextStyle: theme.getStyle(),
                          controller: tagController,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.getPrimaryColor(),
                            ),
                          ),
                        ),
                      ),
                      divider(height: 15),
                      AssetTypeDropdown(
                        key: Key(const Uuid().v4()),
                        assetModelId: _asset.assetModelId,
                        onTankTypeSelected: (tankType) {
                          if (tankType != null) {
                            setState(() {
                              _asset = _asset.copyWith(
                                  assetModelId: tankType?.id ?? '');
                            });
                          } else {
                            setState(() {
                              _asset = _asset.copyWith(assetModelId: '');
                            });
                          }
                        },
                      ),
                      divider(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Container(
                              height: 300,
                              width: 290,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1.0),
                              ),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Tooltip(
                                      message: "Upload Image",
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.upload,
                                          color: theme.getPrimaryColor(),
                                        ),
                                        onPressed: () {
                                          _uploadImage();
                                        },
                                      ),
                                    ),
                                  ),
                                  if (_asset.images!.isEmpty)
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Upload Asset image',
                                          style: theme.getStyle(),
                                        )),
                                  if (_asset.images!.isNotEmpty)
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 250,
                                        height: 250,
                                        child: TwinImageHelper
                                            .getCachedDomainImage(
                                                _asset.images!.first),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          divider(horizontal: true),
                          Expanded(
                            child: Container(
                              height: 300,
                              width: 290,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1.0),
                              ),
                              child: Stack(
                                children: [
                                  _asset.location != null
                                      ? GoogleMapWidget(
                                          longitude:
                                              _asset.location!.coordinates[0],
                                          latitude:
                                              _asset.location!.coordinates[1],
                                          viewMode: false,
                                        )
                                      : Center(
                                          child: Text(
                                          'No location selected',
                                          style: theme.getStyle(),
                                        )),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Tooltip(
                                      message: "Select Location",
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.pin_drop_outlined,
                                          color: theme.getPrimaryColor(),
                                        ),
                                        onPressed: () {
                                          _showLocationDialog(context);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: theme.getPrimaryColor(),
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(
                    labelKey: 'Cancel',
                    onPressed: () {
                      _close();
                    },
                  ),
                  divider(horizontal: true),
                  PrimaryButton(
                    labelKey: (null == widget.asset) ? 'Create' : 'Update',
                    onPressed: () {
                      if (_canCreateOrUpdate()) {
                        _save();
                      } else {
                        alert("Please check",
                            "Name and Asset model type can't be empty",
                            contentStyle: theme.getStyle(),
                            titleStyle: theme.getStyle().copyWith(
                                fontSize: 18, fontWeight: FontWeight.bold));
                      }
                    },
                    // onPressed: !_canCreateOrUpdate()
                    // ? null
                    // : () {
                    //     _save();
                    //   },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNameChanged() {
    setState(() {});
  }

  bool _canCreateOrUpdate() {
    final text = nameController.text.trim();

    return text.isNotEmpty &&
        text.length >= 3 &&
        _asset.assetModelId.isNotEmpty;
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Future _save({bool silent = false}) async {
    // List<String>? clientIds = super.isClientAdmin()
    //     ? await TwinnedSession.instance.getClientIds()
    //     : null;
    List<String>? clientIds = _asset.clientIds?.isNotEmpty == true
        ? _asset.clientIds
        : (super.isClientAdmin()
            ? await TwinnedSession.instance.getClientIds()
            : null);
    if (loading) return;
    loading = true;

    _asset = _asset.copyWith(
      name: nameController.text.trim(),
      description: descController.text.trim(),
      tags: tagController.text.trim().split(' '),
      clientIds: clientIds ?? _asset.clientIds,
    );

    await execute(() async {
      if (null == widget.asset) {
        var cRes = await TwinnedSession.instance.twin.createAsset(
            apikey: TwinnedSession.instance.authToken, body: _asset);
        if (validateResponse(cRes)) {
          _close();
          alert(
            'Asset - ${_asset.name}',
            'Created successfully!',
            titleStyle: theme.getStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
            contentStyle: theme.getStyle(),
          );
        }
      } else {
        var uRes = await TwinnedSession.instance.twin.updateAsset(
            apikey: TwinnedSession.instance.authToken,
            assetId: widget.asset!.id,
            body: _asset);
        if (validateResponse(uRes)) {
          if (!silent) {
            _close();
            alert(
              'Asset - ${_asset.name}',
              'Updated successfully!',
              titleStyle: theme.getStyle().copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
              contentStyle: theme.getStyle(),
            );
          }
        }
      }
    });

    loading = false;
    refresh();
  }

  Future<void> _uploadImage() async {
    if (loading) return;
    loading = true;

    String? tempImageId;

    await execute(() async {
      var uRes = await TwinImageHelper.uploadDomainImage();
      if (null != uRes && null != uRes.entity) {
        tempImageId = uRes.entity!.id;
      }
    });

    if (tempImageId != null) {
      refresh(
        sync: () {
          _asset = _asset.copyWith(images: [tempImageId!]);
        },
      );
    }

    loading = false;
    refresh();
  }

  Future<void> _showLocationDialog(BuildContext context) async {
    double pickedLatitude =
        _asset.location != null ? _asset.location!.coordinates[1] : 39.6128;
    double pickedLongitude =
        _asset.location != null ? _asset.location!.coordinates[0] : -101.5382;

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
        _asset = _asset.copyWith(
          location: tapi.GeoLocation(coordinates: [
            result['longitude']!,
            result['latitude']!,
          ]),
        );
      });
    }
  }

  @override
  void setup() {
    // TODO: implement setup
  }

  @override
  void dispose() {
    // nameController.removeListener(_onNameChanged);
    // nameController.dispose();
    // descController.dispose();
    // tagController.dispose();
    super.dispose();
  }
}
