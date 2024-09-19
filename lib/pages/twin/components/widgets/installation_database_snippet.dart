import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/core/client_dropdown.dart';
import 'package:uuid/uuid.dart';

class InstallationDatabaseSnippet extends StatefulWidget {
  final tapi.Device? device;
  final String? modelId;

  const InstallationDatabaseSnippet({super.key, this.device, this.modelId});

  @override
  State<InstallationDatabaseSnippet> createState() =>
      _InstallationDatabaseSnippetState();
}

class _InstallationDatabaseSnippetState
    extends BaseState<InstallationDatabaseSnippet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController hardwareIdController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  // Future<List<String>>? clientIds =[]
  //     isClientAdmin() ? TwinnedSession.instance.getClientIds() : null;
  tapi.DeviceInfo _device = const tapi.DeviceInfo(
    name: '',
    description: '',
    tags: [],
    modelId: '',
    deviceId: '',
    images: [],
    selectedImage: 0,
    banners: [],
    selectedBanner: 0,
    movable: false,
    metadata: {},
    icon: '',
    clientIds: [],
    defaultView: '',
    hasGeoLocation: false,
    parameters: [],
    reportedStamp: 0,
  );

  @override
  void initState() {
    super.initState();
    if (widget.device == null) {
      _device = _device.copyWith(modelId: widget.modelId!);
    }
    if (null != widget.device) {
      tapi.Device d = widget.device!;
      _device = _device.copyWith(
        clientIds: d.clientIds,
        description: d.description,
        banners: d.banners,
        customWidget: d.customWidget,
        defaultView: d.defaultView,
        deviceId: d.deviceId,
        geolocation: d.geolocation,
        hasGeoLocation: d.hasGeoLocation,
        icon: d.icon,
        metadata: d.metadata,
        modelId: d.modelId,
        movable: d.movable,
        parameters: d.parameters,
        selectedBanner: d.selectedBanner,
        images: d.images,
        name: d.name,
        reportedStamp: d.reportedStamp,
        selectedImage: d.selectedImage,
        tags: d.tags,
      );
    }
    nameController.text = _device.name;
    descController.text = _device.description ?? '';
    tagController.text = null != _device.tags ? _device.tags!.join(' ') : '';
    hardwareIdController.text = _device.deviceId;
    nameController.addListener(_onNameChanged);
    descController.addListener(_onNameChanged);
    hardwareIdController.addListener(_onNameChanged);
    tagController.addListener(_onNameChanged);
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
                          selectedItem: (null != _device.clientIds &&
                                  _device.clientIds!.isNotEmpty)
                              ? _device.clientIds!.first
                              : null,
                          onClientSelected: (client) {
                            setState(() {
                              _device = _device.copyWith(
                                  clientIds:
                                      null != client ? [client!.id] : []);
                            });
                          },
                        ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Name',
                          labelTextStyle: theme.getStyle(),
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
                          label: 'Device Hardware ID',
                          style: theme.getStyle(),
                          labelTextStyle: theme.getStyle(),
                          controller: hardwareIdController,
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
                          labelTextStyle: theme.getStyle(),
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
                          labelTextStyle: theme.getStyle(),
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
                      Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.0),
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
                            if (_device.images!.isEmpty)
                              Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Upload Device image',
                                    style: theme.getStyle(),
                                  )),
                            if (_device.images!.isNotEmpty)
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 250,
                                  height: 250,
                                  child: TwinImageHelper.getCachedDomainImage(
                                      _device.images!.first),
                                ),
                              ),
                          ],
                        ),
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
                    labelKey: (null == widget.device) ? 'Create' : 'Update',
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
    descController.removeListener(_onNameChanged);
    hardwareIdController.removeListener(_onNameChanged);
    tagController.removeListener(_onNameChanged);
    nameController.dispose();
    descController.dispose();
    hardwareIdController.dispose();
    tagController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {});
  }

  bool _canCreateOrUpdate() {
    final text = nameController.text.trim();
    final hText = hardwareIdController.text.trim();
    return text.isNotEmpty && hText.isNotEmpty && text.length >= 3;
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Future _save({bool silent = false}) async {
    // List<String>? clientIds = super.isClientAdmin()
    //     ? await TwinnedSession.instance.getClientIds()
    //     : null;
    List<String>? clientIds = _device.clientIds?.isNotEmpty == true
        ? _device.clientIds
        : (super.isClientAdmin()
            ? await TwinnedSession.instance.getClientIds()
            : null);
    if (loading) return;
    loading = true;

    _device = _device.copyWith(
      name: nameController.text.trim(),
      description: descController.text.trim(),
      tags: [tagController.text.trim()],
      banners: _device.banners,
      customWidget: _device.customWidget,
      defaultView: _device.defaultView,
      deviceId: hardwareIdController.text.trim(),
      geolocation: _device.geolocation,
      hasGeoLocation: _device.hasGeoLocation,
      icon: _device.icon,
      images: _device.images,
      metadata: _device.metadata,
      modelId: _device.modelId,
      movable: _device.movable,
      parameters: _device.parameters,
      reportedStamp: _device.reportedStamp,
      selectedBanner: _device.selectedBanner,
      selectedImage: _device.selectedImage,
      clientIds: clientIds ?? _device.clientIds,
    );

    await execute(() async {
      if (null == widget.device) {
        var cRes = await TwinnedSession.instance.twin.createDevice(
            apikey: TwinnedSession.instance.authToken, body: _device);
        if (validateResponse(cRes)) {
          _close();
          alert('Device - ${_device.name}', ' Created successfully!',
              contentStyle: theme.getStyle(),
              titleStyle: theme
                  .getStyle()
                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
        }
      } else {
        var uRes = await TwinnedSession.instance.twin.updateDevice(
            apikey: TwinnedSession.instance.authToken,
            deviceId: widget.device!.id,
            body: _device);
        if (validateResponse(uRes)) {
          if (!silent) {
            _close();
            alert('Device - ${_device.name}', ' Updated successfully!',
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
          _device = _device.copyWith(images: [tempImageId!]);
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
