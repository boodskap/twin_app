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

class DeviceModelSnippet extends StatefulWidget {
  final tapi.DeviceModel? deviceModel;
  const DeviceModelSnippet({super.key, this.deviceModel});

  @override
  State<DeviceModelSnippet> createState() => _DeviceModelSnippetState();
}

class _DeviceModelSnippetState extends BaseState<DeviceModelSnippet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  TextEditingController modelController = TextEditingController(text: '-');
  TextEditingController versionController = TextEditingController(text: '-');
  TextEditingController makeController = TextEditingController(text: '-');

  Future<List<String>>? clientIds =
      isClientAdmin() ? TwinnedSession.instance.getClientIds() : null;

  tapi.DeviceModelInfo _deviceModelInfo = const tapi.DeviceModelInfo(
    name: '',
    clientIds: [],
    tags: [],
    roles: [],
    parameters: [],
    images: [],
    make: '-',
    model: '-',
    version: '-',
    description: '',
  );

  @override
  void initState() {
    super.initState();
    if (null != widget.deviceModel) {
      tapi.DeviceModel p = widget.deviceModel!;
      _deviceModelInfo = _deviceModelInfo.copyWith(
          clientIds: p.clientIds,
          description: p.description,
          images: p.images,
          name: p.name,
          model: p.model,
          make: p.make,
          version: p.version,
          roles: p.roles,
          selectedImage: p.selectedImage,
          tags: p.tags);
    }

    nameController.text = _deviceModelInfo.name;
    descController.text = _deviceModelInfo.description ?? '';

    nameController.addListener(_onNameChanged);
    descController.addListener(_onNameChanged);
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
                          label: 'Tags',
                          style: theme.getStyle(),
                          controller: tagController,
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
                          label: 'Model',
                          style: theme.getStyle(),
                          controller: modelController,
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
                          label: 'version',
                          style: theme.getStyle(),
                          controller: versionController,
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
                          label: 'make',
                          style: theme.getStyle(),
                          controller: makeController,
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
                                  if (_deviceModelInfo.images!.isEmpty)
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Upload DeviceModel image',
                                          style: theme.getStyle(),
                                        )),
                                  if (_deviceModelInfo.images!.isNotEmpty)
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 250,
                                        height: 250,
                                        child: TwinImageHelper
                                            .getCachedDomainImage(
                                                _deviceModelInfo.images!.first),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          divider(horizontal: true),
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
                      labelKey:
                          (null == widget.deviceModel) ? 'Create' : 'Update',
                      onPressed: _canCreateOrUpdate()
                          ? () {
                              _save();
                            }
                          : null),
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

    super.dispose();
  }

  void _onNameChanged() {
    setState(() {});
  }

  bool _canCreateOrUpdate() {
    final text = nameController.text.trim();
    print(text.isNotEmpty && text.length >= 3);
    return text.isNotEmpty && text.length >= 3;
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

    _deviceModelInfo = _deviceModelInfo.copyWith(
      name: nameController.text.trim(),
      description: descController.text.trim(),
      tags: [],
      make: makeController.text.trim(),
      model: modelController.text.trim(),
      version: versionController.text.trim(),
      clientIds: clientIds ?? _deviceModelInfo.clientIds,
    );
    await execute(() async {
      if (null == widget.deviceModel) {
        var cRes = await TwinnedSession.instance.twin.createDeviceModel(
            apikey: TwinnedSession.instance.authToken, body: _deviceModelInfo);
        if (validateResponse(cRes)) {
          _close();
          alert('Success', 'Device Model ${_deviceModelInfo.name} created');
        }
      } else {
        var uRes = await TwinnedSession.instance.twin.updateDeviceModel(
            apikey: TwinnedSession.instance.authToken,
            modelId: widget.deviceModel!.id,
            body: _deviceModelInfo);
        if (validateResponse(uRes)) {
          if (!silent) {
            _close();
            alert('Success',
                'Device Model ${_deviceModelInfo.name} updated successfully');
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
          _deviceModelInfo = _deviceModelInfo.copyWith(images: [tempImageId!]);
        },
      );
    }

    loading = false;
    refresh();
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}
