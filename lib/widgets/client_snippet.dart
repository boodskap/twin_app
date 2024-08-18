import 'package:flutter/Material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_commons/util/osm_location_picker.dart';
import 'package:twinned_api/twinned_api.dart' as twinned;
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';

class ClientSnippet extends StatefulWidget {
  final twinned.Client? client;
  final ValueNotifier<twinned.Client>? changeNotifier;
  const ClientSnippet({super.key, this.client, this.changeNotifier});

  @override
  State<ClientSnippet> createState() => _ClientSnippetState();
}

class _ClientSnippetState extends BaseState<ClientSnippet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isPhoneValid = true;
  String countryCode = 'US';
  twinned.ClientInfo _client = const twinned.ClientInfo(
      name: '',
      address: '',
      tags: [],
      phone: '',
      email: '',
      icon: '',
      description: '',
      countryCode: 'US');

  @override
  void initState() {
    super.initState();
    if (null != widget.client) {
      twinned.Client c = widget.client!;
      _client = _client.copyWith(
          address: c.address,
          description: c.description,
          email: c.email,
          icon: c.icon,
          location: c.location,
          name: c.name,
          phone: c.phone,
          countryCode: c.countryCode,
          tags: c.tags);
    }

    nameController.text = _client.name;
    descController.text = _client.description ?? '';
    addressController.text = _client.address ?? '';

    emailController.text = _client.email ?? '';
    phoneController.text = _client.phone ?? '';
    countryCode = _client.countryCode ?? '';
    nameController.addListener(_onNameChanged);
    emailController.addListener(_onNameChanged);
    phoneController.addListener(_onNameChanged);
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
                            borderSide:
                                BorderSide(color: theme.getPrimaryColor()),
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
                            borderSide:
                                BorderSide(color: theme.getPrimaryColor()),
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
                            borderSide:
                                BorderSide(color: theme.getPrimaryColor()),
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
                            borderSide:
                                BorderSide(color: theme.getPrimaryColor()),
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
                                _isPhoneValid =
                                    phone.completeNumber.isNotEmpty &&
                                        phone.completeNumber.length >= 10 &&
                                        phone.isValidNumber();

                                countryCode = phone.countryISOCode;
                                _client = _client.copyWith(
                                  countryCode: phone.countryISOCode,
                                );
                              });
                            },
                            onCountryChanged: (country) {
                              setState(() {
                                countryCode = country.code;

                                _client =
                                    _client.copyWith(countryCode: country.code);
                              });
                            }),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Container(
                              height: 300,
                              width: 300,
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
                                        icon: const Icon(Icons.upload),
                                        onPressed: () {
                                          _uploadImage();
                                        },
                                      ),
                                    ),
                                  ),
                                  if (_client.icon!.isEmpty)
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Upload client image',
                                          style: theme.getStyle(),
                                        )),
                                  if (_client.icon!.isNotEmpty)
                                    Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                            width: 250,
                                            height: 250,
                                            child: TwinImageHelper
                                                .getCachedDomainImage(
                                                    _client.icon!))),
                                ],
                              ),
                            ),
                          ),
                          divider(horizontal: true),
                          Expanded(
                            child: Container(
                              height: 300,
                              width: 300,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1.0),
                              ),
                              child: Stack(
                                children: [
                                  _client.location != null
                                      ? OSMLocationPicker(
                                          key: Key(const Uuid().v4()),
                                          viewMode: true,
                                          longitude:
                                              _client.location?.coordinates[0],
                                          latitude:
                                              _client.location?.coordinates[1],
                                          onPicked: (_) {},
                                        )
                                      : const Center(
                                          child: Text('No location selected')),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Tooltip(
                                      message: "Select Location",
                                      child: IconButton(
                                        icon: const Icon(
                                            Icons.location_on_rounded),
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
                    labelKey: (null == widget.client) ? 'Create' : 'Update',
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
    emailController.removeListener(_onNameChanged);
    phoneController.removeListener(_onNameChanged);
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
        email.isNotEmpty &&
        emailRegex.hasMatch(email);
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Future _save({bool silent = false}) async {
    if (loading) return;
    loading = true;

    _client = _client.copyWith(
        name: nameController.text.trim(),
        description: descController.text.trim(),
        address: addressController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        countryCode: countryCode);

    await execute(() async {
      if (null == widget.client) {
        var cRes = await TwinnedSession.instance.twin.createClient(
            apikey: TwinnedSession.instance.authToken, body: _client);
        if (validateResponse(cRes)) {
          _close();
          alert('Success', 'Client ${_client.name} created');
        }
      } else {
        var uRes = await TwinnedSession.instance.twin.updateClient(
            apikey: TwinnedSession.instance.authToken,
            clientId: widget.client!.id,
            body: _client);
        if (validateResponse(uRes)) {
          if (!silent) {
            _close();
            alert('Success', 'Client ${_client.name} updated successfully');
          }
          if (null != widget.changeNotifier) {
            widget.changeNotifier!.value = uRes.body!.entity!;
          }
        }
      }
    });

    loading = false;
    refresh();
  }

  Future _uploadImage() async {
    if (loading) return;
    loading = true;

    bool imageUploaded = false;

    await execute(() async {
      var uRes = await TwinImageHelper.uploadDomainImage();
      if (null != uRes && null != uRes.entity) {
        imageUploaded = true;
        _client = _client.copyWith(icon: uRes.entity!.id);
      }
    });

    loading = false;
    refresh();

    if (imageUploaded && null != widget.client) {
      await _save(silent: true);
    }
  }

  Future<void> _showLocationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 1000,
            child: OSMLocationPicker(
              longitude: _client.location?.coordinates[0],
              latitude: _client.location?.coordinates[1],
              onPicked: (pickedData) {
                Navigator.of(context).pop();
                setState(() {
                  _client = _client.copyWith(
                      location: twinned.GeoLocation(coordinates: [
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
  void setup() {}
}
