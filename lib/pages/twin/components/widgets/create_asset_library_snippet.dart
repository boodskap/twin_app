import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/core/twin_helper.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'dart:math' as math;
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_devicemodel_dropdown.dart';
import 'package:uuid/uuid.dart';

class CreateEditAssetLibrary extends StatefulWidget {
  final twin.AssetModel? assetModel;
  const CreateEditAssetLibrary({super.key, this.assetModel});

  @override
  State<CreateEditAssetLibrary> createState() => _CreateEditAssetLibraryState();
}

class _CreateEditAssetLibraryState extends BaseState<CreateEditAssetLibrary>
    with TickerProviderStateMixin {
  late twin.AssetModelInfo _assetModelInfo;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final List<twin.AssetDeviceModel> _assetDeviceModels = [];

  @override
  void initState() {
    super.initState();

    _assetModelInfo = twin.AssetModelInfo(name: '', clientIds: []);

    if (null != widget.assetModel) {
      twin.AssetModel e = widget.assetModel!;
      _assetModelInfo = _assetModelInfo.copyWith(
        name: e.name,
        description: e.description,
        images: e.images,
        roles: e.roles,
        tags: e.tags,
        clientIds: e.clientIds,
        selectedImage: e.selectedImage,
        icon: e.icon,
        allowedDeviceModels: e.allowedDeviceModels,
        banners: e.banners,
        metadata: e.metadata,
        movable: e.movable,
        selectedBanner: e.selectedBanner,
      );

      _nameController.text = _assetModelInfo?.name ?? '';
      _descController.text = _assetModelInfo?.description ?? '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          LabelTextField(
            label: 'Name',
            labelTextStyle: theme.getStyle(),
            style: theme.getStyle(),
            controller: _nameController,
            onChanged: (val) {
              setState(() {
                _assetModelInfo = _assetModelInfo.copyWith(name: val);
              });
            },
          ),
          divider(),
          LabelTextField(
            label: 'Description',
            style: theme.getStyle(),
            labelTextStyle: theme.getStyle(),
            controller: _descController,
            onChanged: (val) {
              setState(() {
                _assetModelInfo = _assetModelInfo.copyWith(name: val);
              });
            },
          ),
          divider(),
          MultiDeviceModelDropdown(
            key: Key(Uuid().v4()),
            style: theme.getStyle(),
            selectedItems: _assetModelInfo.allowedDeviceModels?.map((d) {
                  return d.deviceModelId;
                }).toList() ??
                [],
            onDeviceModelsSelected: (models) {
              setState(() {
                var adModels = models.map((e) {
                  return twin.AssetDeviceModel(deviceModelId: e.id);
                }).toList();

                _assetDeviceModels.clear();
                _assetDeviceModels.addAll(adModels);

                _assetModelInfo =
                    _assetModelInfo.copyWith(allowedDeviceModels: adModels);
              });
              _prefill();
            },
            allowDuplicates: false,
          ),
          divider(),
          Center(
            child: Card(
              elevation: 5,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () {
                          _uploadImage();
                        },
                        icon: Icon(Icons.upload)),
                  ),
                  if (null != _assetModelInfo.images &&
                      _assetModelInfo.images!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: TwinImageHelper.getDomainImage(
                            _assetModelInfo.images!.first),
                      ),
                    ),
                ],
              ),
            ),
          ),
          divider(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const BusyIndicator(),
              SecondaryButton(
                labelKey: 'cancel',
                onPressed: () {
                  _close();
                },
              ),
              divider(horizontal: true),
              PrimaryButton(
                labelKey: null == widget.assetModel ? 'Create' : 'Update',
                onPressed: !_canSave()
                    ? null
                    : () {
                        if (null != widget.assetModel) {
                          _update();
                        } else {
                          _create();
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canSave() {
    bool isNameValid = _assetModelInfo.name.trim().length >= 3;

    bool hasDeviceModels = _assetDeviceModels.isNotEmpty;

    return isNameValid && hasDeviceModels;
  }

  Future _uploadImage() async {
    var uRes = await TwinImageHelper.uploadDomainImage();
    if (null != uRes && null != uRes.entity) {
      refresh(sync: () {
        _assetModelInfo = _assetModelInfo
            .copyWith(images: [uRes.entity!.id], selectedImage: 0);
      });
    }
  }

  Future _prefill() async {
    if (isClient()) {
      _assetModelInfo =
          _assetModelInfo.copyWith(clientIds: await getClientIds());
    }

    List<twin.AssetDeviceModel> adModels = [];

    for (twin.AssetDeviceModel adm in _assetDeviceModels) {
      twin.DeviceModel? dm = await TwinHelper.getDeviceModel(adm.deviceModelId);
      List<twin.AssetScrappingTable> asTables = [];

      if (null != dm &&
          null != dm.scrappingTableConfigs &&
          dm.scrappingTableConfigs!.isNotEmpty) {
        for (twin.ScrappingTableConfig sc in dm!.scrappingTableConfigs!) {
          List<twin.ScrappingTable> tables =
              await TwinHelper.getScrappingTables(sc.scrappingTableIds);

          for (twin.ScrappingTable t in tables) {
            twin.AssetScrappingTable as = twin.AssetScrappingTable(
              lookupName: sc.lookupName,
              scrappingTableName: sc.scrappingTableName,
              attributes: t.attributes,
              scrappingTableId: t.id,
            );

            asTables.add(as);
          }
        }
      }

      adModels.add(adm.copyWith(scrappingTables: asTables));
    }

    _assetModelInfo = _assetModelInfo.copyWith(allowedDeviceModels: adModels);
  }

  Future _update() async {
    if (loading) return;
    loading = true;
    await _prefill();
    await execute(() async {
      var uRes = await TwinnedSession.instance.twin.updateAssetModel(
          apikey: TwinnedSession.instance.authToken,
          assetModelId: widget.assetModel!.id,
          body: _assetModelInfo);
      if (validateResponse(uRes)) {
        _close();
        alert(
            'Asset Library - ${_assetModelInfo.name}', ' Updated successfully!',
            contentStyle: theme.getStyle(),
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
      }
    });
    loading = false;
  }

  Future _create() async {
    if (loading) return;
    loading = true;
    await _prefill();
    await execute(() async {
      var uRes = await TwinnedSession.instance.twin.createAssetModel(
          apikey: TwinnedSession.instance.authToken, body: _assetModelInfo);
      if (validateResponse(uRes)) {
        _close();
        alert(
            'Asset Library - ${_assetModelInfo.name}', ' Created successfully!',
            contentStyle: theme.getStyle(),
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
      }
    });
    loading = false;
  }

  void _close() {
    Navigator.pop(context);
  }

  @override
  void setup() {}
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
