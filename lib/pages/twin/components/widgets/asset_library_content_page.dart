import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/asset_device_model_snippet.dart';
import 'package:twin_app/pages/twin/components/widgets/showoverlay_widget.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/core/device_model_dropdown.dart';

class AssetLibraryContentPage extends StatefulWidget {
  tapi.AssetModel assetModel;

  AssetLibraryContentPage({super.key, required this.assetModel});

  @override
  State<AssetLibraryContentPage> createState() =>
      _AssetLibraryContentPageState();
}

class _AssetLibraryContentPageState extends BaseState<AssetLibraryContentPage> {
  static const Color openColor = Colors.blue;
  static const Color closeColor = Colors.blueGrey;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _tags = TextEditingController();
  int selectedImage = -1;
  tapi.DeviceModel? selectedModel;
  Map<String, String> deviceModelNames = {};

  @override
  void initState() {
    _name.text = widget.assetModel.name;
    _desc.text = widget.assetModel.description ?? '';
    _tags.text = widget.assetModel.tags?.join(' ') ?? '';
    _name.addListener(() {
      widget.assetModel = widget.assetModel.copyWith(name: _name.text);
    });
    _desc.addListener(() {
      widget.assetModel = widget.assetModel.copyWith(description: _desc.text);
    });
    _tags.addListener(() {
      widget.assetModel =
          widget.assetModel.copyWith(tags: _tags.text.split(' '));
    });
    super.initState();
  }

  void _changeModel(tapi.DeviceModel? model) {
    setState(() {
      selectedModel = model;
    });
  }

  @override
  Widget build(BuildContext context) {
    selectedImage = widget.assetModel.selectedImage ?? -1;
    if (selectedImage >= 0 &&
        widget.assetModel.images!.length <= selectedImage) {
      selectedImage = -1;
    }

    String imageId =
        selectedImage >= 0 ? widget.assetModel.images![selectedImage] : '';

    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: 'Digital Twin Asset Type  - ${widget.assetModel.name}',
            style: theme.getStyle().copyWith(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          divider(),
          Row(
            children: [
              Expanded(
                flex: 30,
                child: LabelTextField(
                  suffixIcon: Tooltip(
                    message: 'Copy asset library id',
                    preferBelow: false,
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: widget.assetModel!.id),
                        );
                        OverlayWidget.showOverlay(
                          context: context,
                          topPosition: 140,
                          leftPosition: 250,
                          message: 'Asset library id copied!',
                        );
                      },
                      child: const Icon(
                        Icons.content_copy,
                        size: 20,
                      ),
                    ),
                  ),
                  label: 'Name',
                  controller: _name,
                ),
              ),
              divider(
                horizontal: true,
              ),
              Expanded(
                flex: 30,
                child: LabelTextField(
                  label: 'Description',
                  controller: _desc,
                ),
              ),
              divider(
                horizontal: true,
              ),
              Expanded(
                flex: 40,
                child: LabelTextField(
                  label: 'Tags',
                  controller: _tags,
                ),
              ),
            ],
          ),
          divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              divider(horizontal: true),
              const BusyIndicator(),
              divider(horizontal: true),
              PrimaryButton(
                labelKey: 'Save',
                onPressed: () async {
                  await _save(close: true);
                },
              ),
            ],
          ),
          divider(),
          Expanded(
            child: Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 450,
                          height: 450,
                          child: Stack(
                            children: [
                              if (imageId.isEmpty)
                                Container(
                                  color: Colors.grey,
                                ),
                              if (imageId.isNotEmpty)
                                SizedBox(
                                  width: 450,
                                  height: 450,
                                  child: TwinImageHelper.getCachedImage(
                                      widget.assetModel.domainKey, imageId,
                                      fit: BoxFit.cover),
                                ),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      spacing: 4,
                                      children: [
                                        if (selectedImage > 0)
                                          ElevatedButton(
                                              onPressed: () async {
                                                await _setSelectedImage(
                                                    --selectedImage);
                                              },
                                              child:
                                                  const Icon(Icons.arrow_back)),
                                        if (selectedImage + 1 <
                                            widget.assetModel.images!.length)
                                          ElevatedButton(
                                              onPressed: () async {
                                                await _setSelectedImage(
                                                    ++selectedImage);
                                              },
                                              child: const Icon(
                                                  Icons.arrow_forward)),
                                        ElevatedButton(
                                            onPressed: () async {
                                              await _uploadImage();
                                            },
                                            child: const Icon(Icons.upload)),
                                        if (selectedImage >= 0)
                                          ElevatedButton(
                                              onPressed: () async {
                                                await _removeImage(
                                                    selectedImage);
                                              },
                                              child: const Icon(
                                                  Icons.delete_forever)),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                    divider(),
                    Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Device Models',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  divider(
                                    horizontal: true,
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: DeviceModelDropdown(
                                        onDeviceModelSelected: (sm) {
                                          _changeModel(sm);
                                        },
                                        selectedItem: ''),
                                  ),
                                  divider(
                                    horizontal: true,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_box,
                                        color: Colors.deepPurple),
                                    onPressed: !canAddModel()
                                        ? null
                                        : () {
                                            addModel(selectedModel!);
                                          },
                                  )
                                ],
                              ),
                              divider(),
                              const Text(
                                'Allowed Device Models',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              divider(
                                horizontal: true,
                              ),
                              if (widget.assetModel.allowedDeviceModels
                                      ?.isNotEmpty ??
                                  false)
                                Accordion(
                                  contentBorderColor: theme.getSecondaryColor(),
                                  contentBackgroundColor: Colors.white,
                                  contentBorderWidth: 1,
                                  scaleWhenAnimating: true,
                                  openAndCloseAnimation: true,
                                  maxOpenSections: 1,
                                  headerPadding: const EdgeInsets.symmetric(
                                      vertical: 3.5, horizontal: 7.5),
                                  sectionOpeningHapticFeedback:
                                      SectionHapticFeedback.heavy,
                                  sectionClosingHapticFeedback:
                                      SectionHapticFeedback.light,
                                  children: widget
                                      .assetModel.allowedDeviceModels!
                                      .map((e) {
                                    return AccordionSection(
                                        isOpen: true,
                                        headerBackgroundColorOpened: openColor,
                                        headerBackgroundColor: closeColor,
                                        leftIcon: Icon(
                                          Icons.departure_board_rounded,
                                          // color: UserSession.getIconColor(),
                                          // size: UserSession.getIconSize(),
                                        ),
                                        header: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                deviceModelNames[
                                                        e.deviceModelId] ??
                                                    '-',
                                                style: theme.getStyle()),
                                            IconButton(
                                                onPressed: () {
                                                  _deleteDeviceModel(widget
                                                      .assetModel
                                                      .allowedDeviceModels!
                                                      .indexOf(e));
                                                },
                                                icon: const Icon(
                                                    Icons.delete_forever))
                                          ],
                                        ),
                                        content: AssetDeviceModelSnippet(
                                          assetDeviceModel: e,
                                          onSave: () {
                                            _save();
                                          },
                                        ));
                                  }).toList(),
                                ),
                            ],
                          ),
                        ))
                  ],
                )),
          ),
        ],
      ),
    );
  }

  void _deleteDeviceModel(int index) async {
    setState(() {
      widget.assetModel.allowedDeviceModels!.removeAt(index);
    });
    await alert(
        'Asset Model - ${widget.assetModel.name}', 'Deleted Successfully');

    refresh();
  }

  Future _save({bool close = false}) async {
    await execute(() async {
      var res = await TwinnedSession.instance.twin.updateAssetModel(
          apikey: TwinnedSession.instance.authToken,
          assetModelId: widget.assetModel.id,
          body: tapi.AssetModelInfo(
            name: widget.assetModel.name,
            description: widget.assetModel.description,
            tags: widget.assetModel.tags,
            icon: widget.assetModel.icon,
            images: widget.assetModel.images,
            selectedImage: selectedImage,
            banners: widget.assetModel.banners,
            metadata: widget.assetModel.metadata,
            movable: widget.assetModel.movable,
            // selectedBanner: selectedBanner,
            allowedDeviceModels: widget.assetModel.allowedDeviceModels,
            clientIds: widget.assetModel.clientIds,
            roles: widget.assetModel.roles,
          ));
      if (validateResponse(res)) {
        await alert(
            'Asset Model - ${widget.assetModel.name}', 'Saved successfully');
        if (close) {
          _close();
        }
      }
    });
  }

  void _close() {
    Navigator.pop(context);
  }

  bool canAddModel() {
    if (null != selectedModel) {
      for (var e in widget.assetModel.allowedDeviceModels!) {
        if (e.deviceModelId == selectedModel!.id) return false;
      }
      return true;
    }
    return false;
  }

  void addModel(tapi.DeviceModel deviceModel) {
    setState(() {
      widget.assetModel.allowedDeviceModels!.add(tapi.AssetDeviceModel(
          deviceModelId: deviceModel.id, scrappingTables: []));
    });
  }

  Future _removeImage(int index) async {
    setState(() {
      widget.assetModel.images!.removeAt(index);
    });
    await _save();
  }

  Future _setSelectedImage(int index) async {
    widget.assetModel = widget.assetModel.copyWith(selectedImage: index);
    setState(() {
      selectedImage = index;
    });
    await _save();
  }

  Future _uploadImage() async {
    var uRes = await TwinImageHelper.uploadDomainImage();
    if (null == uRes) return;
    setState(() {
      widget.assetModel.images!.add(uRes!.entity!.id);
      selectedImage = widget.assetModel.images!.length - 1;
    });
    await _save();
  }

  Future load() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      for (var element in widget.assetModel.allowedDeviceModels!) {
        var dmRes = await TwinnedSession.instance.twin.getDeviceModel(
            apikey: TwinnedSession.instance.authToken,
            modelId: element.deviceModelId);
        if (validateResponse(dmRes)) {
          setState(() {
            deviceModelNames[element.deviceModelId] = dmRes.body!.entity!.name;
          });
        }
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {
    load();
  }
}
