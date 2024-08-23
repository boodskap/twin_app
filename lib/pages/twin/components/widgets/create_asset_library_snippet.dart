import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/utils/twin_app_utils.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/core/scrapping_table_dropdown.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'dart:math' as math;
import 'package:twinned_api/twinned_api.dart' as twin;

class CreateEditAssetLibrary extends StatefulWidget {
  final twin.AssetModel? tankModel;
  const CreateEditAssetLibrary({super.key, this.tankModel});

  @override
  State<CreateEditAssetLibrary> createState() => _CreateEditAssetLibraryState();
}

class _CreateEditAssetLibraryState extends BaseState<CreateEditAssetLibrary>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  late twin.AssetModelInfo _tankModelInfo;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  twin.AssetScrappingTable? _scrappingTable;
  final List<TextEditingController> _controllers = [];
  final List<DataRow2> _configRows = [];

  @override
  void initState() {
    super.initState();

    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _tankModelInfo = twin.AssetModelInfo(name: '');

    if (null != widget.tankModel) {
      twin.AssetModel e = widget.tankModel!;
      _tankModelInfo = _tankModelInfo.copyWith(
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
          selectedBanner: e.selectedBanner);

      _nameController.text = _tankModelInfo?.name ?? '';
      _descController.text = _tankModelInfo?.description ?? '';

      _scrappingTable =
          widget.tankModel!.allowedDeviceModels?.first.scrappingTables?.first;
      _generateRows();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
    _nameController.dispose();
    _descController.dispose();
    for (TextEditingController c in _controllers) {
      c.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (null != _scrappingTable) divider(height: 25.0),
                if (null == _scrappingTable)
                  Text(
                    'Select Tank Configuration',
                    style: theme.getStyle(),
                  ),
                if (null == _scrappingTable) divider(height: 25),
                if (null == widget.tankModel)
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: ScrappingTableDropdown(
                        filterTags: const ['RIOT_TANK'],
                        selectedItem: _scrappingTable?.scrappingTableId,
                        onScrappingTableSelected: (val) {
                          _changeScrappingTable(val);
                        }),
                  ),
                if (null != _scrappingTable) divider(height: 8.0),
                if (null != _scrappingTable)
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: TextField(
                      decoration: InputDecoration(
                          label: Text(
                        "Tank Name",
                        style: theme.getStyle(),
                      )),
                      onChanged: (v) {
                        setState(() {
                          _tankModelInfo = _tankModelInfo.copyWith(name: v);
                        });
                      },
                      controller: _nameController,
                    ),
                  ),
                if (null != _scrappingTable) divider(height: 8.0),
                if (null != _scrappingTable)
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: TextField(
                      decoration: InputDecoration(
                          label: Text(
                        "Tank Description",
                        style: theme.getStyle(),
                      )),
                      onChanged: (v) {
                        setState(() {
                          _tankModelInfo =
                              _tankModelInfo.copyWith(description: v);
                        });
                      },
                      controller: _descController,
                    ),
                  ),
                if (null != _scrappingTable) divider(height: 8.0),
                if (null != _scrappingTable)
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: 600,
                              height: 300,
                              child: DataTable2(
                                empty: Text(
                                  'No parameters',
                                  style: theme.getStyle(),
                                ),
                                columns: [
                                  DataColumn2(
                                      label: Text('Parameter',
                                          style: theme.getStyle().copyWith(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn2(
                                      label: Text('Description',
                                          style: theme.getStyle().copyWith(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn2(
                                      label: Text('Value',
                                          style: theme.getStyle().copyWith(
                                              fontWeight: FontWeight.bold))),
                                ],
                                rows: _configRows,
                              ),
                            ),
                          ),
                        ),
                        divider(horizontal: true),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 250,
                              height: 250,
                              child: Card(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                            onPressed: () async {
                                              await _uploadImage();
                                            },
                                            icon: const Icon(Icons.upload))),
                                    if (_tankModelInfo.images?.isNotEmpty ??
                                        false)
                                      SizedBox(
                                        width: 200,
                                        height: 200,
                                        child: TwinImageHelper.getDomainImage(
                                            _tankModelInfo.images!.first),
                                      ),
                                    if (_tankModelInfo.images?.isEmpty ?? true)
                                      Text(
                                        'Upload an image',
                                        style: theme.getStyle(),
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
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 25),
                  child: Row(
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
                        labelKey:
                            null == widget.tankModel ? 'Create' : 'Update',
                        onPressed: !_canSave()
                            ? null
                            : () {
                                if (null != widget.tankModel) {
                                  _update();
                                } else {
                                  _create();
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canSave() {
    if (null == _scrappingTable) return false;
    if (_scrappingTable!.attributes.isEmpty) return false;
    for (twin.Attribute a in _scrappingTable!.attributes) {
      if (a.$value.trim().isEmpty) return false;
    }
    if (_tankModelInfo.name.trim().length < 3) return false;
    return true;
  }

  void _changeScrappingTable(twin.ScrappingTable? value) {
    setState(() {
      if (null != value) {
        _scrappingTable = twin.AssetScrappingTable(
          lookupName: 'config',
          scrappingTableId: value!.id,
          scrappingTableName: value!.name,
          attributes: value!.attributes,
        );
      } else {
        _scrappingTable = null;
      }
    });

    _generateRows();
  }

  Future _uploadImage() async {
    var uRes = await TwinImageHelper.uploadDomainImage();
    if (null != uRes && null != uRes.entity) {
      refresh(sync: () {
        _tankModelInfo = _tankModelInfo
            .copyWith(images: [uRes.entity!.id], selectedImage: 0);
      });
    }
  }

  void _generateRows() {
    for (TextEditingController c in _controllers) {
      c.dispose();
    }
    _configRows.clear();
    _controllers.clear();

    if (null != _scrappingTable) {
      for (int i = 0; i < _scrappingTable!.attributes.length; i++) {
        twin.Attribute a = _scrappingTable!.attributes[i];
        if (null != a.editable && !a.editable!) continue;

        TextEditingController c = TextEditingController(text: a.$value);
        _controllers.add(c);

        _configRows.add(DataRow2(cells: [
          DataCell(Text(a.name)),
          DataCell(Text(a.label ?? a.description ?? '-')),
          DataCell(TextField(
            onChanged: (v) {
              _changeAttribute(i, a, v);
            },
            controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              //FilteringTextInputFormatter.digitsOnly,
              DecimalTextInputFormatter(decimalRange: 2),
            ], // Only numbers can be entered
          )),
        ]));
      }
    }
  }

  void _changeAttribute(int idx, twin.Attribute a, String value) {
    value = value.trim();
    var attr = a.copyWith($value: value);
    setState(() {
      _scrappingTable!.attributes[idx] = attr;
    });
  }

  Future _prefill() async {
    if (TwinnedSession.instance.isClient()) {
      final List<String> ids = await TwinnedSession.instance.getClientIds();
      _tankModelInfo.copyWith(clientIds: ids);
    }
    List<twin.AssetDeviceModel> models = [];

    List<String> ids = await TwinAppUtils.getTankDeviceModels();
    for (String id in ids) {
      models.add(twin.AssetDeviceModel(
          deviceModelId: id, scrappingTables: [_scrappingTable!]));
    }

    _tankModelInfo = _tankModelInfo
        .copyWith(allowedDeviceModels: models, tags: ['RIOT_TANK']);
  }

  Future _update() async {
    if (loading) return;
    loading = true;
    await _prefill();
    await execute(() async {
      var uRes = await TwinnedSession.instance.twin.updateAssetModel(
          apikey: TwinnedSession.instance.authToken,
          assetModelId: widget.tankModel!.id,
          body: _tankModelInfo);
      if (validateResponse(uRes)) {
        _close();
        alert('Tank Type', '${_tankModelInfo.name} updated successfully');
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
          apikey: TwinnedSession.instance.authToken, body: _tankModelInfo);
      if (validateResponse(uRes)) {
        _close();
        alert('Tank Type', '${_tankModelInfo.name} created successfully');
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
