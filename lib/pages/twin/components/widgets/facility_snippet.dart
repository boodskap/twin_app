import 'package:flutter/Material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_app/widgets/google_map.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twinned_widgets/core/client_dropdown.dart';
import 'package:twinned_widgets/core/premise_dropdown.dart';
import 'package:uuid/uuid.dart';

class FacilitySnippet extends StatefulWidget {
  final tapi.Facility? facility;
  final tapi.Premise? selectedPremise;
  FacilitySnippet({super.key, this.facility, this.selectedPremise});

  @override
  State<FacilitySnippet> createState() => _FacilitySnippetState();
}

class _FacilitySnippetState extends BaseState<FacilitySnippet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isPhoneValid = true;
  String countryCode = 'US';
  tapi.FacilityInfo _facility = const tapi.FacilityInfo(
      premiseId: '',
      name: '',
      address: '',
      clientIds: [],
      tags: [],
      roles: [],
      phone: '',
      images: [],
      email: '',
      description: '',
      countryCode: 'US');

  @override
  void initState() {
    super.initState();

    if (widget.selectedPremise != null) {
      _facility = _facility.copyWith(premiseId: widget.selectedPremise!.id);
    }
    if (null != widget.facility) {
      tapi.Facility p = widget.facility!;
      _facility = _facility.copyWith(
          premiseId: p.premiseId,
          address: p.address,
          clientIds: p.clientIds,
          description: p.description,
          email: p.email,
          images: p.images,
          location: p.location,
          name: p.name,
          phone: p.phone,
          countryCode: p.countryCode,
          reportedStamp: p.reportedStamp,
          roles: p.roles,
          selectedImage: p.selectedImage,
          tags: p.tags);
    }

    nameController.text = _facility.name;
    descController.text = _facility.description ?? '';
    addressController.text = _facility.address ?? '';
    phoneController.text = _facility.phone ?? '';
    countryCode = _facility.countryCode ?? '';
    emailController.text = _facility.email ?? '';
    nameController.addListener(_onNameChanged);
    phoneController.addListener(_onNameChanged);
    emailController.addListener(_onNameChanged);
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
                          selectedItem: (null != _facility.clientIds &&
                                  _facility.clientIds!.isNotEmpty)
                              ? _facility.clientIds!.first
                              : null,
                          onClientSelected: (client) {
                            setState(() {
                              _facility = _facility.copyWith(
                                  clientIds:
                                      null != client ? [client!.id] : []);
                            });
                          },
                        ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: PremiseDropdown(
                          style: theme.getStyle(),
                          selectedItem: _facility.premiseId,
                          onPremiseSelected: (tapi.Premise? selectedPremise) {
                            setState(() {
                              if (selectedPremise != null) {
                                _facility = _facility.copyWith(
                                    premiseId: selectedPremise.id);
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Facility Name',
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
                          label: 'Address',
                          style: theme.getStyle(),
                          labelTextStyle: theme.getStyle(),
                          controller: addressController,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.getPrimaryColor(),
                            ),
                          ),
                          maxLines: 5,
                        ),
                      ),
                      divider(height: 15),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Email',
                          style: theme.getStyle(),
                          labelTextStyle: theme.getStyle(),
                          controller: emailController,
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
                        child: IntlPhoneField(
                          style: theme.getStyle(),
                          dropdownTextStyle: theme.getStyle(),
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          initialCountryCode: countryCode,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintStyle: theme.getStyle(),
                            labelStyle: theme.getStyle(),
                            errorStyle: theme.getStyle(),
                            labelText: 'Enter Phone Number',
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              borderSide: BorderSide(
                                color: theme.getPrimaryColor(),
                              ),
                            ),
                          ),
                          validator: (phone) {
                            if (phone == null || phone.number.isEmpty) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                          onChanged: (phone) {
                            setState(() {
                              _isPhoneValid = phone.completeNumber.isNotEmpty &&
                                  phone.completeNumber.length >= 10 &&
                                  phone.isValidNumber();

                              countryCode = phone.countryISOCode;
                              _facility = _facility.copyWith(
                                  countryCode: phone.countryISOCode);
                            });
                          },
                          onCountryChanged: (country) {
                            setState(() {
                              countryCode = country.code;

                              _facility = _facility.copyWith(
                                countryCode: country.code,
                              );
                            });
                          },
                        ),
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
                                  if (_facility.images!.isEmpty)
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Upload Facility image',
                                          style: theme.getStyle(),
                                        )),
                                  if (_facility.images!.isNotEmpty)
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 250,
                                        height: 250,
                                        child: TwinImageHelper
                                            .getCachedDomainImage(
                                                _facility.images!.first),
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
                                  _facility.location != null
                                      ? GoogleMapWidget(
                                          longitude: _facility
                                              .location!.coordinates[0],
                                          latitude: _facility
                                              .location!.coordinates[1],
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
                    labelKey: (null == widget.facility) ? 'Create' : 'Update',
                    onPressed: !_canCreateOrUpdate()
                        ? null
                        : () {
                            _save();
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.removeListener(_onNameChanged);
    phoneController.removeListener(_onNameChanged);
    emailController.removeListener(_onNameChanged);
    nameController.dispose();
    descController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {});
  }

  bool _canCreateOrUpdate() {
    final text = nameController.text.trim();
    final email = emailController.text;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return text.isNotEmpty &&
        text.length >= 3 &&
        (_isPhoneValid || phoneController.text.trim().isEmpty) &&
        (email.isEmpty || emailRegex.hasMatch(email));
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Future _save({bool silent = false}) async {
    // List<String>? clientIds = super.isClientAdmin()
    //     ? await TwinnedSession.instance.getClientIds()
    //     : null;
    List<String>? clientIds = _facility.clientIds?.isNotEmpty == true
        ? _facility.clientIds
        : (super.isClientAdmin()
            ? await TwinnedSession.instance.getClientIds()
            : null);
    if (loading) return;
    loading = true;

    _facility = _facility.copyWith(
      name: nameController.text.trim(),
      description: descController.text.trim(),
      address: addressController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      countryCode: countryCode,
      clientIds: clientIds ?? _facility.clientIds,
    );
    await execute(() async {
      if (null == widget.facility) {
        var cRes = await TwinnedSession.instance.twin.createFacility(
            apikey: TwinnedSession.instance.authToken, body: _facility);
        if (validateResponse(cRes)) {
          _close();
          alert('Facility - ${_facility.name}', ' Created successfully!',
              contentStyle: theme.getStyle(),
              titleStyle: theme
                  .getStyle()
                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
        }
      } else {
        var uRes = await TwinnedSession.instance.twin.updateFacility(
            apikey: TwinnedSession.instance.authToken,
            facilityId: widget.facility!.id,
            body: _facility);
        if (validateResponse(uRes)) {
          if (!silent) {
            _close();
            alert('Facility - ${_facility.name}', ' Updated successfully!',
                contentStyle: theme.getStyle(),
                titleStyle: theme
                    .getStyle()
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
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
          _facility = _facility.copyWith(images: [tempImageId!]);
        },
      );
    }

    loading = false;
    refresh();
  }

  /// using google map
  Future<void> _showLocationDialog(BuildContext context) async {
    double pickedLatitude = _facility.location != null
        ? _facility.location!.coordinates[1]
        : 39.6128;
    double pickedLongitude = _facility.location != null
        ? _facility.location!.coordinates[0]
        : -101.5382;

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
        _facility = _facility.copyWith(
          location: tapi.GeoLocation(coordinates: [
            result['longitude']!,
            result['latitude']!,
          ]),
        );
      });
    }
  }

  @override
  void setup() {}
}
