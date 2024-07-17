import 'package:flutter/Material.dart';
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

class ClientLocationSnippet extends StatefulWidget {
  final twinned.Premise? location;
  const ClientLocationSnippet({super.key, this.location});

  @override
  State<ClientLocationSnippet> createState() => _ClientLocationSnippetState();
}

class _ClientLocationSnippetState extends BaseState<ClientLocationSnippet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  twinned.PremiseInfo _location = const twinned.PremiseInfo(
      name: '',
      address: '',
      clientIds: [],
      tags: [],
      roles: [],
      phone: '',
      images: [],
      email: '',
      description: '');

  @override
  void initState() {
    super.initState();
    if (null != widget.location) {
      twinned.Premise p = widget.location!;
      _location = _location.copyWith(
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

    nameController.text = _location.name;
    descController.text = _location.description ?? '';
    addressController.text = _location.address ?? '';
    phoneController.text = _location.phone ?? '';
    emailController.text = _location.email ?? '';
    nameController.addListener(_onNameChanged);
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
                          controller: nameController,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Description',
                          controller: descController,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Address',
                          controller: addressController,
                          maxLines: 5,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Phone',
                          controller: phoneController,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Email',
                          controller: emailController,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
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
                                if (_location.images!.isEmpty)
                                  Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Upload location image',
                                        style: theme.getStyle(),
                                      )),
                                if (_location.images!.isNotEmpty)
                                  Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                          width: 250,
                                          height: 250,
                                          child: TwinImageHelper.getDomainImage(
                                              _location.images!.first))),
                              ],
                            ),
                          ),
                          Container(
                            height: 300,
                            width: 300,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1.0),
                            ),
                            child: Stack(
                              children: [
                                _location.location != null
                                    ? OSMLocationPicker(
                                        key: Key(const Uuid().v4()),
                                        viewMode: true,
                                        longitude:
                                            _location?.location?.coordinates[0],
                                        latitude:
                                            _location?.location?.coordinates[1],
                                        onPicked: (_) {},
                                      )
                                    : const Center(
                                        child: Text('No location selected')),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Tooltip(
                                    message: "Select Location",
                                    child: IconButton(
                                      icon:
                                          const Icon(Icons.location_on_rounded),
                                      onPressed: () {
                                        _showLocationDialog(context);
                                      },
                                    ),
                                  ),
                                ),
                              ],
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
                    labelKey: (null == widget.location) ? 'Create' : 'Update',
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
    return text.isNotEmpty && text.length >= 3;
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Future _save({bool silent = false}) async {
    if (loading) return;
    loading = true;

    _location = _location.copyWith(
      name: nameController.text.trim(),
      description: descController.text.trim(),
      address: addressController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
    );

    await execute(() async {
      if (null == widget.location) {
        var cRes = await TwinnedSession.instance.twin.createPremise(
            apikey: TwinnedSession.instance.authToken, body: _location);
        if (validateResponse(cRes)) {
          _close();
          alert('Success', 'Location ${_location.name} created');
        }
      } else {
        var uRes = await TwinnedSession.instance.twin.updatePremise(
            apikey: TwinnedSession.instance.authToken,
            premiseId: widget.location!.id,
            body: _location);
        if (validateResponse(uRes)) {
          if (!silent) {
            _close();
            alert('Success', 'Location ${_location.name} updated successfully');
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
        _location = _location.copyWith(images: [uRes!.entity!.id]);
      }
    });

    loading = false;
    refresh();

    if (imageUploaded && null != widget.location) {
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
              longitude: _location.location?.coordinates[0],
              latitude: _location.location?.coordinates[1],
              onPicked: (pickedData) {
                Navigator.of(context).pop();
                setState(() {
                  _location = _location.copyWith(
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
  void setup() {
    // TODO: implement setup
  }
}
