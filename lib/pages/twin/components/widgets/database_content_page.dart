import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/pages/twin/components/widgets/custom_color_palatte.dart';
import 'package:twin_app/pages/twin/components/widgets/custom_parameter_dropdown.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_app/pages/twin/components/widgets/custom_view_dropdown.dart';
import 'package:twin_app/pages/twin/components/widgets/device_view_default.dart';
import 'package:twin_app/pages/twin/components/widgets/showoverlay_widget.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/osm_location_picker.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:twin_app/core/session_variables.dart';

class DeviceContentPage extends StatefulWidget {
  final twinned.DeviceModel deviceModel;
  twinned.Device? device;
  DeviceContentPage({
    super.key,
    required this.deviceModel,
    this.device,
  });

  @override
  State<DeviceContentPage> createState() => _DeviceContentPageState();
}

class _DeviceContentPageState extends BaseState<DeviceContentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final List<String> _imageIds = [];
  final List<Widget> _imageCards = [];
  final List<Widget> _bannerCards = [];
  final List<twinned.Parameter> _parameters = [];
  bool _obscureText = true;
  bool? _hasLocation = false;
  bool? _hasTracked = false;
  bool imageVisible = false;
  // ignore: prefer_typing_uninitialized_variables
  twinned.GeoLocation? _pickedLocation;

  final List<TableRow> paramHeaders = [];

  bool _displayCards = false;
  int _selectedImage = -1;
  int _selectedBanner = -1;

  ValueNotifier<bool> location = ValueNotifier(false);
  List<twinned.Parameter> customParamList = [];
  twinned.CustomWidget? customWidgetList;
  int? _borderColor;
  int? _bgColor;
  double? _borderWidth;
  String? field;
  String? viewType;
  @override
  void initState() {
    paramHeaders.add(TableRow(children: [
      Center(
        child: Text(
          'Name',
          style: theme.getStyle().copyWith(color: Colors.black, fontSize: 16),
        ),
      ),
      Center(
        child: Text(
          'Description',
          style: theme.getStyle().copyWith(color: Colors.black, fontSize: 16),
        ),
      ),
      Center(
        child: Text(
          'Label',
          style: theme.getStyle().copyWith(color: Colors.black, fontSize: 16),
        ),
      ),
      Center(
        child: Text(
          'Type',
          style: theme.getStyle().copyWith(color: Colors.black, fontSize: 16),
        ),
      ),
      Center(
        child: Text(
          'Default Value',
          style: theme.getStyle().copyWith(color: Colors.black, fontSize: 16),
        ),
      ),
      Center(
        child: Text(
          'Required',
          style: theme.getStyle().copyWith(color: Colors.black, fontSize: 16),
        ),
      ),
    ]));

    _parameters.addAll(widget.deviceModel.parameters);

    _borderColor = Colors.black.value;
    _bgColor = Colors.black.value;
    _borderWidth = 4;
    field = "";

    super.initState();
  }

  @override
  void setup() async {
    _imageIds.clear();
    _imageCards.clear();
    _bannerCards.clear();
    _selectedImage = -1;
    _selectedBanner = -1;
    _nameController.text = widget.deviceModel.name;
// customParamList.clear();
    if (null != widget.device) {
      twinned.Device e = widget.device!;

      refresh(sync: () {
        _nameController.text = e.name;
        _idController.text = e.deviceId;
        _descController.text = e.description ?? '';
        _tagsController.text = null != e.tags ? e.tags!.join(' ') : '';
        _selectedImage = e.selectedImage ?? -1;
        _selectedBanner = e.selectedBanner ?? -1;
        customParamList = widget.deviceModel.parameters;

        /// Custom View

        if (e.customWidget != null) {
          customWidgetList = e.customWidget!;
          Object data = customWidgetList!.attributes;
          Map<String, dynamic> map = data as Map<String, dynamic>;
          _borderColor = data["borderColor"] ?? Colors.black.value;
          _bgColor = data["fillColor"] ?? Colors.black.value;
          _borderWidth = data["borderWidth"] ?? 4;
          field = data["field"] ?? "";
        }
        for (var image in e.images!) {
          _imageIds.add(image);
          _imageCards.add(_createImageCard(e.domainKey, image));
        }

        _hasLocation = e.hasGeoLocation;
        location.value = _hasLocation!;
        _hasTracked = e.movable;
        _pickedLocation = e.geolocation;

        _displayCards = (_imageIds.isEmpty);
      });
    }
  }

  Future _save({bool shouldPop = false}) async {
    if (loading) return;
    loading = true;

    execute(() async {
      if (_nameController.text.isEmpty) {
        alert('Missing', 'Name is required');
        return;
      }

      if (_idController.text.isEmpty) {
        alert('Missing', 'Hardware device id is required');
        return;
      }

      chopper.Response<twinned.DeviceEntityRes> res;

      if (null == widget.device) {
        res = await TwinnedSession.instance.twin.createDevice(
            apikey: TwinnedSession.instance.authToken,
            body: twinned.DeviceInfo(
              name: _nameController.text,
              modelId: widget.deviceModel.id,
              deviceId: _idController.text,
              description: _descController.text,
              banners: widget.deviceModel.banners,
              images: widget.deviceModel.images,
              selectedBanner: widget.deviceModel.selectedBanner,
              selectedImage: widget.deviceModel.selectedImage,
              tags: _tagsController.text.split(' '),
              customWidget: customWidgetList,
            ));
      } else {
        res = await TwinnedSession.instance.twin.updateDevice(
            apikey: TwinnedSession.instance.authToken,
            deviceId: widget.device!.id,
            body: twinned.DeviceInfo(
                name: _nameController.text,
                modelId: widget.deviceModel.id,
                deviceId: _idController.text,
                description: _descController.text,
                images: _imageIds,
                selectedBanner: _selectedBanner,
                selectedImage: _selectedImage,
                tags: _tagsController.text.split(' '),
                icon: widget.device!.icon,
                // hasGeoLocation: true,
                hasGeoLocation: _hasLocation,
                movable: _hasTracked,
                geolocation: _pickedLocation,
                customWidget: customWidgetList));
      }

      if (validateResponse(res)) {
        widget.device = res.body!.entity;
        alert(widget.device!.name, 'Saved successfully');
        _cancel();

        setup();
        if (shouldPop) {
          _cancel();
        }
      }
    });

    loading = false;
    refresh();
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void removedata() async {
    if (loading) return;
    loading = true;
    try {
      dynamic res = await TwinnedSession.instance
        ..twin.cleanupData(
          apikey: TwinnedSession.instance.authToken,
          modelId: widget.deviceModel.id,
          deviceId: widget.device!.id,
        );
      if (validateResponse(res)) {
        Navigator.pop(context);
        alert(widget.device!.name, "All data wiped out successfully!");
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
    loading = false;
    refresh();
  }

  void confirmWipeallData() {
    Widget cancelButton = SecondaryButton(
      labelKey: "Cancel",
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = PrimaryButton(
      labelKey: "Delete",
      onPressed: () {
        removedata();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: theme.getStyle().copyWith(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
      content: Text(
        "Cleaning this Device will clean this device's data,\n This deletion can't be undone. Do you want to delete it ",
        style: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
        maxLines: 10,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _uploadImage() async {
    if (loading) return;
    loading = true;
    try {
      var res = await TwinImageHelper.uploadDeviceImage(
        deviceId: widget.device!.id,
      );

      if (null != res) {
        setState(() {
          String id = res.entity!.id;
          _imageIds.add(id);
          _imageCards.add(
            TwinImageHelper.getImage(
              TwinnedSession.instance.domainKey,
              id,
            ),
            // fit: BoxFit.contain,
          );
        });
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    } finally {
      loading = false;
      refresh();
    }
  }

  Widget _createImageCard(String domainKey, String image) {
    return GestureDetector(
      onLongPress: () {
        _deleteImage(image);
      },
      child: TwinImageHelper.getImage(domainKey, image),
      // fit: BoxFit.contain,
    );
  }

  void _deleteImage(String image) async {
    if (loading) return;
    loading = true;
    confirm(
        title: 'Warning',
        message: 'Are you sure you want to delete this image?',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle(),
        onPressed: () async {
          try {
            var res = await TwinnedSession.instance.twin.deleteImage(
                apikey: TwinnedSession.instance.authToken, id: image);

            if (validateResponse(res)) {
              widget.device!.images!.remove(image);
              setup();
              alert('Image', 'Device model image deleted');
            }
          } catch (e, x) {
            debugPrint('$e\n$x');
          }
          // busy(busy: false);
        });
    loading = false;
    refresh();
  }

  Future<void> _showMapDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 1000,
            child: OSMLocationPicker(
              longitude: _pickedLocation?.coordinates[0],
              latitude: _pickedLocation?.coordinates[1],
              onPicked: (pickedData) {
                setState(() {
                  _pickedLocation = twinned.GeoLocation(
                      coordinates: [pickedData.longitude, pickedData.latitude]);
                  ;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  _showCustomViewPopup(BuildContext context, String type) {
    customParamList = widget.deviceModel.parameters;
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom View',
                    style: theme.getStyle(),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Select Field",
                      style: theme.getStyle().copyWith(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(height: 8),
                  CustomParametersDropDown(
                      dropDownParamList: customParamList,
                      fieldValue: field.toString(),
                      valueChanged: (value) {
                        if (value != null) {
                          field = value.name;
                        }
                      }),
                  const SizedBox(height: 15),
                  CustomColorPalette(
                    onColorChanged: (borderColor, bgColor) {
                      _borderColor = borderColor;
                      _bgColor = bgColor;
                    },
                    currentBorderColor: _borderColor ?? Colors.black.value,
                    currentBgColor: _bgColor ?? Colors.black.value,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Border Width",
                          style: theme.getStyle().copyWith(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                      SizedBox(
                        width: 180,
                        child: SpinBox(
                          min: 1,
                          max: 50,
                          value: _borderWidth!.toDouble(),
                          textStyle: theme.getStyle().copyWith(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                          showCursor: true,
                          autofocus: true,
                          decoration: InputDecoration(
                              labelText: '',
                              counterStyle: theme.getStyle().copyWith(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                              floatingLabelStyle: theme.getStyle().copyWith(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                          onChanged: (value) {
                            _borderWidth = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SecondaryButton(
                        labelKey: "Cancel",
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      divider(horizontal: true),
                      PrimaryButton(
                        labelKey: "Submit",
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            var customView =
                                twinned.CustomWidget(id: type, attributes: {
                              "borderColor": _borderColor,
                              "fillColor": _bgColor,
                              "borderWidth": _borderWidth,
                              "field": field
                            });
                            customWidgetList = customView;
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> imageItems = [
      const DropdownMenuItem<int>(value: -1, child: Text('Selected Image'))
    ];

    for (int i = 0; i < _imageIds.length; i++) {
      imageItems.add(
          DropdownMenuItem<int>(value: i, child: Center(child: Text('$i'))));
    }

    if (_selectedImage == -1 && _imageIds.isNotEmpty) {
      _selectedImage = 0;
    }

    final List<TableRow> rows = [paramHeaders.first];

    for (var param in _parameters) {
      TableRow row = TableRow(children: [
        // Align(alignment: Alignment.center, child: Text(param.name)),
        Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (param.icon != null && param.icon != "")
                  SizedBox(
                    height: 27, // Set your desired height
                    width: 27, // Set your desired width
                    child: TwinImageHelper.getImage(
                      TwinnedSession.instance.domainKey,
                      param.icon.toString(),
                      fit: BoxFit.contain,
                    ),
                  ),
                const SizedBox(width: 5),
                Text(param.name),
              ],
            )),
        Align(
            alignment: Alignment.center, child: Text(param.description ?? '')),
        Align(alignment: Alignment.center, child: Text(param.label ?? '')),
        Align(
            alignment: Alignment.center,
            child: Text(param.parameterType.value!)),
        Align(
            alignment: Alignment.center, child: Text(param.defaultValue ?? '')),
        Checkbox(value: param.required, onChanged: (value) {}),
      ]);
      rows.add(row);
    }

    return Scaffold(
      body: Column(
        children: [
          if (null == widget.device)
            const TopBar(
              title: 'New Digital Twin Device',
            ),
          if (null != widget.device)
            TopBar(
              title: 'Digital Twin Device  - ${widget.device!.name}',
            ),
          divider(),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    divider(),
                    Row(
                      children: [
                        divider(horizontal: true),
                        Expanded(
                          flex: 20,
                          child: LabelTextField(
                            suffixIcon: Tooltip(
                              message: 'Copy device id',
                              preferBelow: false,
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: widget.device!.id),
                                  );
                                  OverlayWidget.showOverlay(
                                    context: context,
                                    topPosition: 140,
                                    leftPosition: 250,
                                    message: 'Device id copied!',
                                  );
                                },
                                child: const Icon(
                                  Icons.content_copy,
                                  size: 20,
                                ),
                              ),
                            ),
                            label: 'Device Name',
                            controller: _nameController,
                          ),
                        ),
                        divider(horizontal: true),
                        Expanded(
                          flex: 15,
                          child: LabelTextField(
                              label: 'Hardware Device ID',
                              controller: _idController),
                        ),
                        divider(horizontal: true),
                        Expanded(
                            flex: 15,
                            child: LabelTextField(
                              label: 'Tags',
                              controller: _tagsController,
                            )),
                        divider(horizontal: true),
                        Expanded(
                            flex: 15,
                            child: LabelTextField(
                              label: 'Description',
                              controller: _descController,
                            )),
                        divider(horizontal: true),
                        if (null != widget.device &&
                            null != widget.device!.apiKey)
                          Expanded(
                            flex: 20,
                            child: TextFormField(
                              readOnly: true,
                              obscureText: _obscureText,
                              initialValue: widget.device!.apiKey,
                              decoration: InputDecoration(
                                labelText: 'Api Key',
                                suffixIcon: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                    Tooltip(
                                      message: 'Copy Api Key',
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.copy,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: widget.device!.apiKey));
                                          OverlayWidget.showOverlay(
                                            context: context,
                                            topPosition: 140,
                                            rightPosition: 50,
                                            message: 'API key copied!',
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: 'Custom View',
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CustomViewDropdown(
                              onChanged: (item) {
                                String customType = MenuItems.getItemType(item);
                                _showCustomViewPopup(context, customType);
                              },
                            ),
                          ),
                        ),
                        divider(horizontal: true),
                        Checkbox(
                          value: _hasLocation,
                          onChanged: (value) {
                            setState(() {
                              _hasLocation = value;
                              location.value = value!;
                            });
                          },
                        ),
                        Text(
                          'Has Location',
                          style: theme.getStyle(),
                        ),
                        divider(horizontal: true, width: 10),
                        Visibility(
                          visible: _hasLocation ?? false,
                          child: Row(
                            children: [
                              Checkbox(
                                value: _hasTracked,
                                onChanged: (value) {
                                  setState(() {
                                    _hasTracked = value;
                                  });
                                },
                              ),
                              Text(
                                'Enable Tracking',
                                style: theme.getStyle(),
                              ),
                              divider(horizontal: true, width: 10),
                              PrimaryButton(
                                labelKey: "Pick Location",
                                onPressed: () {
                                  _showMapDialog(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        divider(horizontal: true, width: 10),
                        ElevatedButton(
                          onPressed: () {
                            confirmWipeallData();
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(150, 50),
                            backgroundColor: const Color(0XFF8B0000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          child: Text(
                            'Wipe All Data',
                            style: theme.getStyle().copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                          ),
                        ),
                      ],
                    ),
                    if (null != widget.device) divider(),
                    if (null != widget.device)
                      if (imageVisible) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 40,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      DropdownButton<int>(
                                        items: imageItems,
                                        onChanged: (int? value) {
                                          setState(() {
                                            _selectedImage = value ?? -1;
                                          });
                                        },
                                        value: _selectedImage,
                                      ),
                                      divider(horizontal: true),
                                      ElevatedButton(
                                          onPressed: () {
                                            _uploadImage();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            // backgroundColor: primaryColor,
                                            minimumSize: const Size(140, 40),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                          child: Text(
                                            'Upload Image',
                                            // style:
                                            //     UserSession.getLabelTextStyle()
                                            //         .copyWith(
                                            //             color: secondaryColor),
                                          )),
                                    ],
                                  ),
                                  if (_displayCards)
                                    SafeArea(
                                      child: SizedBox(
                                        height: 200,
                                        child: GridView.builder(
                                          itemCount: _imageCards.length,
                                          itemBuilder: (ctx, index) {
                                            return SizedBox(
                                                width: 180,
                                                height: 180,
                                                child: _imageCards[index]);
                                          },
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 4,
                                                  childAspectRatio: 1.0,
                                                  crossAxisSpacing: 8,
                                                  mainAxisSpacing: 8),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            divider(horizontal: true),
                            Expanded(
                              flex: 60,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      // DropdownButton<int>(
                                      //   items: bannerItems,
                                      //   onChanged: (int? value) {
                                      //     setState(() {
                                      //       _selectedBanner = value ?? -1;
                                      //     });
                                      //   },
                                      //   value: _selectedBanner,
                                      // ),
                                      divider(horizontal: true),
                                      // ElevatedButton(
                                      //     onPressed: () {
                                      //       _uploadBanner();
                                      //     },
                                      //     style: ElevatedButton.styleFrom(
                                      //       // backgroundColor: primaryColor,
                                      //       minimumSize: const Size(140, 40),
                                      //       shape: RoundedRectangleBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(3),
                                      //       ),
                                      //     ),
                                      //     child: Text(
                                      //       'Upload Banner',
                                      //       // style:
                                      //       //     UserSession.getLabelTextStyle()
                                      //       //         .copyWith(
                                      //       //             color: secondaryColor),
                                      //     )),
                                      divider(horizontal: true),
                                      Tooltip(
                                        message: _displayCards
                                            ? 'Hide images'
                                            : 'Show images',
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _displayCards = !_displayCards;
                                              });
                                            },
                                            icon: _displayCards
                                                ? const Icon(Icons.arrow_upward)
                                                : const Icon(
                                                    Icons.arrow_downward)),
                                      ),
                                    ],
                                  ),
                                  divider(),
                                  // if (_displayCards)
                                  //   SafeArea(
                                  //     child: SizedBox(
                                  //       height: 200,
                                  //       child: ListView.builder(
                                  //         itemCount: _bannerCards.length,
                                  //         itemBuilder: (ctx, index) {
                                  //           return SizedBox(
                                  //               height: 180,
                                  //               child: _bannerCards[index]);
                                  //         },
                                  //       ),
                                  //     ),
                                  //   ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        divider(),
                      ],
                    if (null != widget.device)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DeviceViewDefault(
                            location: location,
                            device: widget.device!,
                            deviceModel: widget.deviceModel,
                          ),
                        ],
                      ),
                    divider(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Table(
                        border: TableBorder.all(),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(2.0),
                          2: FlexColumnWidth(),
                          3: FlexColumnWidth(),
                          4: FlexColumnWidth(),
                          5: FlexColumnWidth(),
                          6: FlexColumnWidth(),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: rows,
                      ),
                    ),
                    divider(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const BusyIndicator(padding: 4.0),
                        divider(horizontal: true),
                        SecondaryButton(
                          labelKey: "Cancel",
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        divider(horizontal: true),
                        PrimaryButton(
                          labelKey: "Save",
                          onPressed: () {
                            _save(shouldPop: true);
                          },
                        ),
                      ],
                    ),
                    divider(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
