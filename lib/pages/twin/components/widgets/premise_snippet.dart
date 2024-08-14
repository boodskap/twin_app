import 'package:flutter/Material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_commons/util/osm_location_picker.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PremiseSnippet extends StatefulWidget {
  final tapi.Premise? premise;
  const PremiseSnippet({super.key, this.premise});

  @override
  State<PremiseSnippet> createState() => _PremiseSnippetState();
}

class _PremiseSnippetState extends BaseState<PremiseSnippet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isPhoneValid = true;
  Future<List<String>>? clientIds = isClientAdmin()
        ? TwinnedSession.instance.getClientIds()
        : null;
  tapi.PremiseInfo _premise = const tapi.PremiseInfo(
    
      name: '',
      address: '',
      clientIds: [],
      tags: [],
      roles: [],
      phone: '',
      images: [],
      email: '',
      description: '');
  String fullNumber = "";
  String countryCode = "";
  @override
  void initState() {
    super.initState();
    if (null != widget.premise) {
      tapi.Premise p = widget.premise!;
      _premise = _premise.copyWith(
          address: p.address,
          clientIds: p.clientIds,
          description: p.description,
          email: p.email,
          images: p.images,
          location: p.location,
          name: p.name,
          phone: p.phone,
          reportedStamp: p.reportedStamp,
          roles: p.roles,
          selectedImage: p.selectedImage,
          tags: p.tags);
    }

    nameController.text = _premise.name;
    descController.text = _premise.description ?? '';
    addressController.text = _premise.address ?? '';

    emailController.text = _premise.email ?? '';
    nameController.addListener(_onNameChanged);
    phoneController.addListener(_onNameChanged);
    emailController.addListener(_onNameChanged);
    String? input = _premise.phone;
    List<String> splitString = input!.split('/');
    if (splitString.length > 1) {
      countryCode = splitString[0];
      phoneController.text = splitString[1];
    } else {
      countryCode = "IN";
      phoneController.text=_premise.phone!;
    }
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Name',
                          style: theme.getStyle(),
                          controller: nameController,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.getPrimaryColor(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Description',
                          style: theme.getStyle(),
                          controller: descController,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.getPrimaryColor(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Address',
                          style: theme.getStyle(),
                          controller: addressController,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.getPrimaryColor(),
                            ),
                          ),
                          maxLines: 5,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Email',
                          style: theme.getStyle(),
                          controller: emailController,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.getPrimaryColor(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: IntlPhoneField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          initialCountryCode: countryCode,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
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
                              fullNumber =
                                  "${phone.countryISOCode}/${phone.number}";
                              _isPhoneValid = phone.completeNumber.isNotEmpty &&
                                  phone.completeNumber.length >= 10 &&
                                  phone.isValidNumber();
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
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
                                  if (_premise.images!.isEmpty)
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Upload Premise image',
                                          style: theme.getStyle(),
                                        )),
                                  if (_premise.images!.isNotEmpty)
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 250,
                                        height: 250,
                                        child: TwinImageHelper.getDomainImage(
                                            _premise.images!.first),
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
                                  _premise.location != null
                                      ? OSMLocationPicker(
                                          key: Key(const Uuid().v4()),
                                          viewMode: true,
                                          longitude: _premise
                                              ?.location?.coordinates[0],
                                          latitude: _premise
                                              ?.location?.coordinates[1],
                                          onPicked: (_) {},
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
                    labelKey: (null == widget.premise) ? 'Create' : 'Update',
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
    List<String>? clientIds = super.isClientAdmin()
      ? await TwinnedSession.instance.getClientIds()
      : null;
    if (loading) return;
    loading = true;

    _premise = _premise.copyWith(
      name: nameController.text.trim(),
      description: descController.text.trim(),
      address: addressController.text.trim(),
      email: emailController.text.trim(),
      phone: fullNumber.trim(),
      clientIds: clientIds??_premise.clientIds,
    );
    await execute(() async {
      if (null == widget.premise) {
        var cRes = await TwinnedSession.instance.twin.createPremise(
            apikey: TwinnedSession.instance.authToken, body: _premise);
        if (validateResponse(cRes)) {
          _close();
          alert('Success', 'Premise ${_premise.name} created');
        }
      } else {
        var uRes = await TwinnedSession.instance.twin.updatePremise(
            apikey: TwinnedSession.instance.authToken,
            premiseId: widget.premise!.id,
            body: _premise);
        if (validateResponse(uRes)) {
          if (!silent) {
            _close();
            alert('Success', 'Premise ${_premise.name} updated successfully');
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
          _premise = _premise.copyWith(images: [tempImageId!]);
        },
      );
    }

    loading = false;
    refresh();
  }

  Future<void> _showLocationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 1000,
            child: OSMLocationPicker(
              longitude: _premise.location?.coordinates[0],
              latitude: _premise.location?.coordinates[1],
              onPicked: (pickedData) {
                Navigator.of(context).pop();
                setState(() {
                  _premise = _premise.copyWith(
                      location: tapi.GeoLocation(coordinates: [
                    pickedData.longitude,
                    pickedData.latitude
                  ]));
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}