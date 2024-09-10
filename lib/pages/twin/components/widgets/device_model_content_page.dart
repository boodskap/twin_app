// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/device_model_add_params.dart';
import 'package:twin_app/pages/twin/components/widgets/custom_setting_snippet.dart';
import 'package:twin_app/pages/twin/components/widgets/preprocessor_dropdown.dart';
import 'package:twin_app/pages/twin/components/widgets/showoverlay_widget.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';

enum PickTarget { border, background }

class DeviceModelContentPage extends StatefulWidget {
  twinned.DeviceModel? model;
  final String type;
  final PageController? pageController;
  int initialPage;

  DeviceModelContentPage({
    super.key,
    this.model,
    required this.type,
    this.pageController,
    required this.initialPage,
  });

  @override
  State<DeviceModelContentPage> createState() => _DeviceModelContentPageState();
}

class _DeviceModelContentPageState extends BaseState<DeviceModelContentPage> {
  final GlobalKey<FormState> _basicFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _hwFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  late PageController _pageController = PageController();

  final List<String> _imageIds = [];
  final List<Widget> _imageCards = [];
  List<TableRow> paramHeaders = [];

  late Image modelIcon;
  bool displayCards = true;
  int _selectedImage = -1;
  String? _preprocessor;

  int editIndex = -1;
  int _currentPage = 0;

  String enteredName = '';
  String enteredDescription = '';
  String enteredTags = '';
  String enteredModel = '';
  String enteredVersion = '';
  String enteredMake = '';
  String deviceModelName = '';
  String iconParamId = '';
  twinned.SensorWidget? sensorWidget;

  final TextEditingController paramName = TextEditingController();
  final TextEditingController paramUnit = TextEditingController();
  final TextEditingController paramDesc = TextEditingController();
  final TextEditingController paramLabel = TextEditingController();
  final TextEditingController paramValue = TextEditingController();
  ValueNotifier<bool> paramRequired = ValueNotifier(true);
  ValueNotifier<bool> enableTrend = ValueNotifier(false);
  ValueNotifier<bool> enableTimeSeries = ValueNotifier(false);
  ValueNotifier<twinned.ParameterParameterType> paramType = ValueNotifier(
    twinned.ParameterParameterType.numeric,
  );

  List<TableRow> rows = [];
  static const Map<String, dynamic> emptyAttributes = {};

  List<twinned.Parameter> paramList = [
    const twinned.Parameter(
      name: 'dummy',
      unit: "",
      parameterType: twinned.ParameterParameterType.numeric,
      required: true,
      description: 'auto generated, change this',
      defaultValue: '0',
      enableTimeSeries: false,
      enableTrend: false,
      sensorWidget:
          twinned.SensorWidget(widgetId: 'none', attributes: emptyAttributes),
    ),
  ];

  List<twinned.ScrappingTableConfig> scrappingTableConfigs = [];
  List<twinned.Parameter> customParamList = [];
  twinned.CustomWidget? customWidget;
  int? _borderColor;
  int? _bgColor;
  double? _borderWidth;
  String? field;
  String? viewType;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    if (widget.initialPage == 2) {
      _currentPage = 2;
    }

    paramHeaders.add(TableRow(children: [
      Center(
        child: Text(
          'Name',
          style: theme.getStyle().copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Unit',
          style: theme.getStyle().copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Description',
          style: theme.getStyle().copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Label',
          style: theme.getStyle().copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Type',
          style: theme.getStyle().copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Default Value',
          style: theme.getStyle().copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Required',
          style: theme.getStyle().copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Enable Trend',
          style: theme.getStyle().copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Enable Time Series',
          style: theme.getStyle().copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Action',
          style: theme.getStyle().copyWith(
                color: Colors.black,
                fontSize: 16,
              ),
        ),
      ),
    ]));
    rows.add(paramHeaders.first);

    modelIcon = Image.asset(
      'images/new-devicemodel-icon.png',
      fit: BoxFit.contain,
    );

    if (null != widget.model) {
      paramList.clear();
      paramList.addAll(widget.model!.parameters);
    }
    _preprocessor = widget.model?.preprocessorId;

    _borderColor = Colors.black.value;
    _bgColor = Colors.black.value;
    _borderWidth = 4;
    field = "";
  }

  @override
  void setup() async {
    _imageIds.clear();
    _imageCards.clear();
    _selectedImage = -1;
    // customParamList.clear();

    if (null != widget.model) {
      twinned.DeviceModel e = widget.model!;
      _nameController.text = e.name;
      _descController.text = e.description ?? '';
      _makeController.text = e.make.isEmpty ? '-' : e.make;
      _modelController.text = e.model.isEmpty ? '-' : e.model;
      _versionController.text = e.version.isEmpty ? '-' : e.version;
      _tagsController.text = null != e.tags ? e.tags!.join(' ') : '';
      _selectedImage = e.selectedImage ?? -1;
      scrappingTableConfigs = e.scrappingTableConfigs ?? [];
      customParamList = e.parameters;

      /// Custom View
      if (e.customWidget != null) {
        customWidget = e.customWidget!;
        Object data = customWidget!.attributes;
        Map<String, dynamic> map = data as Map<String, dynamic>;
        _borderColor = data["borderColor"] ?? Colors.black.value;
        _bgColor = data["fillColor"] ?? Colors.black.value;
        _borderWidth = data["borderWidth"] ?? 4;
        field = data["field"] ?? "";
      }

      for (var image in e.images!) {
        _imageIds.add(image);
        print(e);
        _imageCards.add(GestureDetector(
          onLongPress: () {
            if (e.images!.length > 1) {
              _deleteImage(image);
            } else {
              alert('Delete Prohibited', 'You need to have at least one image',
                  contentStyle: theme.getStyle(),
                  titleStyle: theme.getStyle().copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red));
            }
          },
          child: TwinImageHelper.getCachedImage(e.domainKey, image),
        ));
      }

      paramList.clear();
      paramList.addAll(e.parameters);

      _rebuild();
      setState(() {});
    } else {
      _rebuild();
    }
  }

  Future _save({
    required List<twinned.ScrappingTableConfig> scrappingTableConfigs,
    bool shouldPop = false,
  }) async {
    busy();

    try {
      List<twinned.ScrappingTableConfig> swap = [];
      swap.addAll(scrappingTableConfigs);
      this.scrappingTableConfigs.clear();
      this.scrappingTableConfigs.addAll(swap);

      if (null == widget.model) {
        var res = await TwinnedSession.instance.twin.createDeviceModel(
            apikey: TwinnedSession.instance.authToken,
            body: twinned.DeviceModelInfo(
              name: _nameController.text,
              description: _descController.text,
              make: _makeController.text,
              model: _modelController.text,
              version: _versionController.text,
              tags: _tagsController.text.split(','),
              images: _imageIds,
              selectedImage: _selectedImage,
              preprocessorId: _preprocessor,
              parameters: paramList,
              scrappingTableConfigs: scrappingTableConfigs,
            ));

        if (validateResponse(res)) {
          setState(() {
            widget.model = res.body!.entity;
          });
          await alert(
              'Device Model', ' ${_nameController.text} saved successfully!',
              contentStyle: theme.getStyle(),
              titleStyle: theme
                  .getStyle()
                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
          if (shouldPop) {
            _cancel();
          }
        }
      } else {
        var res = await TwinnedSession.instance.twin.updateDeviceModel(
            apikey: TwinnedSession.instance.authToken,
            modelId: widget.model!.id,
            body: twinned.DeviceModelInfo(
              name: _nameController.text,
              description: _descController.text,
              make: _makeController.text,
              model: _modelController.text,
              version: _versionController.text,
              tags: _tagsController.text.split(','),
              images: _imageIds,
              selectedImage: _selectedImage,
              preprocessorId: _preprocessor,
              parameters: paramList,
              scrappingTableConfigs: scrappingTableConfigs,
            ));

        if (validateResponse(res)) {
          setState(() {
            widget.model = res.body?.entity;
          });
          await alert(
              'Device Model ', '${_nameController.text} saved successfully!',
              contentStyle: theme.getStyle(),
              titleStyle: theme
                  .getStyle()
                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
          if (shouldPop) {
            _cancel();
          }
        }
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    busy(busy: false);
  }

  Future _upload() async {
    await execute(() async {
      var res = await TwinImageHelper.uploadDomainImage();
      if (null != res) {
        iconParamId = res.entity!.id;
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _uploadImage() async {
    busy();
    try {
      var res = await TwinImageHelper.uploadDeviceModelImage(
          modelId: widget.model!.id);

      if (null != res) {
        setState(() {
          String id = res.entity!.id;
          _imageIds.add(id);
          _imageCards.add(TwinImageHelper.getCachedImage(
              TwinnedSession.instance.domainKey, id));
        });
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    } finally {
      busy(busy: false);
    }
  }

  void _deleteImage(String image) async {
    confirm(
        title: 'Warning',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle(),
        message: 'Are you sure you want to delete this image?',
        onPressed: () async {
          busy();
          try {
            var res = await TwinnedSession.instance.twin.deleteImage(
                apikey: TwinnedSession.instance.authToken, id: image);

            if (validateResponse(res)) {
              widget.model!.images!.remove(image);
              setup();
              alert('Image', 'Device model image deleted',
                  contentStyle: theme.getStyle(),
                  titleStyle: theme
                      .getStyle()
                      .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
            }
          } catch (e, x) {
            debugPrint('$e\n$x');
          }
          busy(busy: false);
        });
  }

  void _addNewRow() {
    var param = twinned.Parameter(
      name: paramName.text,
      unit: paramUnit.text,
      parameterType: paramType.value,
      required: paramRequired.value,
      description: paramDesc.text,
      defaultValue: paramValue.text,
      enableTimeSeries: enableTimeSeries.value,
      enableTrend: enableTrend.value,
      label: paramLabel.text,
      icon: iconParamId,
      sensorWidget: sensorWidget,
    );
    setState(() {
      paramList.add(param);
    });
    _rebuild();
    iconParamId = '';
  }

  void _updateRow() {
    var param = twinned.Parameter(
        name: paramName.text,
        unit: paramUnit.text,
        parameterType: paramType.value,
        required: paramRequired.value,
        description: paramDesc.text,
        defaultValue: paramValue.text,
        enableTimeSeries: enableTimeSeries.value,
        enableTrend: enableTrend.value,
        label: paramLabel.text,
        icon: iconParamId,
        sensorWidget: sensorWidget);

    setState(() {
      paramList[editIndex] = param;
    });
    _rebuild();
  }

  void _removeRow(var param) {
    setState(() {
      paramList.remove(param);
    });
    _rebuild();
  }

  void _addParameter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ParameterUpsertDialog(
          paramName: paramName,
          paramUnit: paramUnit,
          paramDesc: paramDesc,
          paramLabel: paramLabel,
          paramValue: paramValue,
          paramType: paramType,
          paramRequired: paramRequired,
          enableTrend: enableTrend,
          enableTimeSeries: enableTimeSeries,
          addRow: _addNewRow,
          isEdit: false,
          paramIcon: "",
          sensorWidget: sensorWidget ??
              const twinned.SensorWidget(
                  widgetId: 'none', attributes: emptyAttributes),
          onUpload: (icon) {
            iconParamId = icon;
          },
          onSensorWidgetUpdated: (s) {
            sensorWidget = s;
          },
        );
      },
    );
  }

  void _editParameter(twinned.Parameter param, int index) {
    setState(() {
      paramName.text = param.name;
      paramUnit.text = param.unit ?? "";
      paramDesc.text = param.description ?? '';
      paramLabel.text = param.label ?? '';
      paramValue.text = param.defaultValue ?? '';
      paramType = ValueNotifier(param.parameterType);
      paramRequired = ValueNotifier(param.required);
      enableTrend = ValueNotifier(param.enableTrend!);
      enableTimeSeries = ValueNotifier(param.enableTimeSeries!);
      // isEdit = true;
      editIndex = index;
      iconParamId = param.icon ?? '';
      sensorWidget = param.sensorWidget ??
          const twinned.SensorWidget(
              widgetId: 'none', attributes: emptyAttributes);
    });

    showDialog(
      context: context,
      builder: (context) {
        return ParameterUpsertDialog(
          addRow: _updateRow,
          paramName: paramName,
          paramUnit: paramUnit,
          paramDesc: paramDesc,
          paramLabel: paramLabel,
          paramType: paramType,
          paramValue: paramValue,
          paramRequired: paramRequired,
          enableTrend: enableTrend,
          enableTimeSeries: enableTimeSeries,
          isEdit: true,
          paramIcon: iconParamId,
          sensorWidget: sensorWidget!,
          onUpload: (icon) {
            iconParamId = icon;
          },
          onSensorWidgetUpdated: (s) {
            sensorWidget = s;
          },
        );
      },
    );
  }

  Future _editScrappingTable() async {
    if (null == widget.model!.scrappingTableConfigs) {
      widget.model = widget.model!.copyWith(scrappingTableConfigs: []);
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle:
              theme.getStyle().copyWith(fontWeight: FontWeight.bold),
          title: const Text('Scrapping Tables'),
          content: SingleChildScrollView(
            child: SizedBox(
                width: 600,
                height: 500,
                child: CustomSettingsSnippet(
                  scrappingTableConfigs: widget.model!.scrappingTableConfigs!,
                  onSave: _save,
                )),
          ),
        );
      },
    );
  }

  void _rebuild() {
    rows.clear();
    rows.add(paramHeaders.first);
    for (var p in paramList) {
      _buildRow(p);
    }
  }

  void _buildRow(var param) {
    TableRow row = TableRow(children: [
      Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (param.icon != null && param.icon != "")
                SizedBox(
                  height: 27,
                  width: 27,
                  child: TwinImageHelper.getCachedImage(
                    TwinnedSession.instance.domainKey,
                    param.icon,
                    fit: BoxFit.contain,
                  ),
                ),
              SizedBox(width: 5),
              Text(
                param.name,
                style: theme.getStyle(),
              ),
            ],
          )),
      Align(
        alignment: Alignment.center,
        child: Text(
          param.unit ?? '',
          style: theme.getStyle(),
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: Text(
          param.description ?? '',
          style: theme.getStyle(),
        ),
      ),
      Align(
          alignment: Alignment.center,
          child: Text(
            param.label ?? '',
            style: theme.getStyle(),
          )),
      Align(
        alignment: Alignment.center,
        child: Text(
          param.parameterType.value!,
          style: theme.getStyle(),
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: Text(
          param.defaultValue ?? '',
          style: theme.getStyle(),
        ),
      ),
      Checkbox(value: param.required, onChanged: (value) {}),
      Visibility(
        visible:
            param.parameterType == twinned.ParameterParameterType.numeric ||
                param.parameterType == twinned.ParameterParameterType.floating,
        child: Checkbox(
          value: param.enableTrend,
          onChanged: (value) {},
        ),
      ),
      Visibility(
        visible:
            param.parameterType == twinned.ParameterParameterType.numeric ||
                param.parameterType == twinned.ParameterParameterType.floating,
        child: Checkbox(value: param.enableTimeSeries, onChanged: (value) {}),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              _editParameter(param, paramList.indexOf(param));
            },
            icon: const Icon(
              Icons.edit,
              size: 18,
            ),
          ),
          IconButton(
            onPressed: () {
              _removeRow(param);
            },
            icon: const Icon(
              Icons.delete,
              size: 18,
            ),
          ),
        ],
      ),
    ]);
    rows.add(row);
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> imageItems = [
      DropdownMenuItem<int>(
          value: -1,
          child: Text(
            'Selected Image',
            style: theme.getStyle(),
          ))
    ];

    for (int i = 0; i < _imageIds.length; i++) {
      imageItems.add(DropdownMenuItem<int>(
          value: i,
          child: Center(
              child: Text(
            '$i',
            style: theme.getStyle(),
          ))));
    }

    if (_selectedImage == -1 && _imageIds.isNotEmpty) {
      _selectedImage = 0;
    }

    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: 'Digital Twin - Device Model',
            style: theme.getStyle().copyWith(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (null == widget.model) const SizedBox(height: 60),
          if (null != widget.model) const SizedBox(height: 10),
          if (null != widget.model)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox.fromSize(
                  size: const Size(90, 90), // button width and height
                  child: ClipOval(
                    child: Material(
                      color: _currentPage == 0
                          ? Colors.orange
                          : Colors.grey, // button color
                      child: InkWell(
                        splashColor: Colors.green, // splash color
                        onTap: _currentPage == 0
                            ? null
                            : () {
                                _pageController.jumpToPage(0);
                              }, // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.home_filled), // icon
                            Text(
                              "Basic",
                              style: theme.getStyle(),
                            ), // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox.fromSize(
                  size: const Size(90, 90), // button width and height
                  child: ClipOval(
                    child: Material(
                      color: _currentPage == 1
                          ? Colors.orange
                          : Colors.grey, // button color
                      child: InkWell(
                        splashColor: Colors.green, // splash color
                        onTap: _currentPage == 1
                            ? null
                            : () {
                                _pageController.jumpToPage(1);
                              }, // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.devices), // icon
                            Text(
                              "Hardware",
                              style: theme.getStyle(),
                            ), // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox.fromSize(
                  size: const Size(90, 90), // button width and height
                  child: ClipOval(
                    child: Material(
                      color: _currentPage == 2
                          ? Colors.orange
                          : Colors.grey, // button color
                      child: InkWell(
                        splashColor: Colors.green, // splash color
                        onTap: _currentPage == 2
                            ? null
                            : () {
                                _pageController.jumpToPage(2);
                              }, // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.menu), // icon
                            Text(
                              "Parameters",
                              style: theme.getStyle(),
                            ), // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox.fromSize(
                  size: const Size(90, 90), // button width and height
                  child: ClipOval(
                    child: Material(
                      color: _currentPage == 3
                          ? Colors.orange
                          : Colors.grey, // button color
                      child: InkWell(
                        splashColor: Colors.green, // splash color
                        onTap: _currentPage == 3
                            ? null
                            : () {
                                _pageController.jumpToPage(3);
                              }, // button pressed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.image), // icon
                            Text(
                              "Appearance",
                              style: theme.getStyle(),
                            ), // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                Card(
                  elevation: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    child: Form(
                        key: _basicFormKey,
                        child: Row(
                          children: [
                            const Expanded(child: SizedBox()),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Basic Info",
                                        style: theme
                                            .getStyle()
                                            .copyWith(fontSize: 24),
                                      ),
                                    ],
                                  ),
                                  divider(),
                                  TextFormField(
                                    style: theme.getStyle(),
                                    controller: _nameController,
                                    onChanged: (value) {
                                      enteredName = value;
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a valid name';
                                      }
                                      return null;
                                    },
                                    inputFormatters: const [
                                      //CapitalizeAndDisallowSpacesFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                      hintStyle: theme.getStyle(),
                                      suffixIcon: Tooltip(
                                        message: 'Copy device library id',
                                        preferBelow: false,
                                        child: InkWell(
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                  text: widget.model!.id),
                                            );
                                            OverlayWidget.showOverlay(
                                              context: context,
                                              topPosition: 140,
                                              leftPosition: 250,
                                              message:
                                                  'Device library id copied!',
                                            );
                                          },
                                          child: const Icon(
                                            Icons.content_copy,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      labelText: 'Enter Name',
                                      errorStyle: theme.getStyle(),
                                      labelStyle: theme.getStyle(),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(),
                                      ),
                                    ),
                                  ),
                                  divider(),
                                  LabelTextField(
                                    style: theme.getStyle(),
                                    labelTextStyle: theme.getStyle(),
                                    label: "Description",
                                    controller: _descController,
                                    onChanged: (value) {
                                      enteredDescription = value;
                                    },
                                  ),
                                  divider(),
                                  LabelTextField(
                                    style: theme.getStyle(),
                                    labelTextStyle: theme.getStyle(),
                                    label: "Tags",
                                    controller: _tagsController,
                                    onChanged: (value) {
                                      enteredTags = value;
                                    },
                                  ),
                                  divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (widget.type == 'Update') ...[
                                        PrimaryButton(
                                          labelKey: "Update & Close",
                                          onPressed: () {
                                            _save(
                                                scrappingTableConfigs:
                                                    scrappingTableConfigs);
                                          },
                                        ),
                                        divider(horizontal: true),
                                      ],
                                      SecondaryButton(
                                        labelKey: "Cancel",
                                        onPressed: () {
                                          _cancel();
                                        },
                                      ),
                                      divider(horizontal: true),
                                      PrimaryButton(
                                        labelKey: "Next",
                                        onPressed: () {
                                          if (_basicFormKey.currentState!
                                              .validate()) {
                                            // Save entered values
                                            enteredName = _nameController.text;
                                            enteredDescription =
                                                _descController.text;
                                            enteredTags = _tagsController.text;

                                            _pageController.jumpToPage(1);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        )),
                  ),
                ),
                Card(
                  elevation: 10,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Form(
                        key: _hwFormKey,
                        child: Row(
                          children: [
                            const Expanded(child: SizedBox()),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Hardware Info",
                                        style: theme
                                            .getStyle()
                                            .copyWith(fontSize: 24),
                                      ),
                                    ],
                                  ),
                                  divider(),
                                  TextFormField(
                                    style: theme.getStyle(),
                                    controller: _modelController,
                                    onChanged: (value) {
                                      enteredModel = value;
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a valid model name';
                                      }
                                      return null;
                                    },
                                    inputFormatters: const [
                                      //CapitalizeAndDisallowSpacesFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Model',
                                      errorStyle: theme.getStyle(),
                                      labelStyle: theme.getStyle(),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(),
                                      ),
                                    ),
                                  ),
                                  divider(),
                                  TextFormField(
                                    controller: _versionController,
                                    onChanged: (value) {
                                      enteredVersion = value;
                                    },
                                    style: theme.getStyle(),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a valid version name';
                                      }
                                      return null;
                                    },
                                    inputFormatters: const [
                                      //CapitalizeAndDisallowSpacesFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Version',
                                      errorStyle: theme.getStyle(),
                                      labelStyle: theme.getStyle(),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(),
                                      ),
                                    ),
                                  ),
                                  divider(),
                                  TextFormField(
                                    style: theme.getStyle(),
                                    controller: _makeController,
                                    onChanged: (value) {
                                      enteredMake = value;
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a valid make name';
                                      }
                                      return null;
                                    },
                                    inputFormatters: const [
                                      //CapitalizeAndDisallowSpacesFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Make',
                                      errorStyle: theme.getStyle(),
                                      labelStyle: theme.getStyle(),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(),
                                      ),
                                    ),
                                  ),
                                  divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (widget.type == 'Update') ...[
                                        PrimaryButton(
                                          labelKey: "Update",
                                          onPressed: () {
                                            _save(
                                                scrappingTableConfigs:
                                                    scrappingTableConfigs);
                                          },
                                        ),
                                        divider(horizontal: true),
                                      ],
                                      SecondaryButton(
                                        labelKey: "Cancel",
                                        onPressed: () {
                                          _cancel();
                                        },
                                      ),
                                      divider(horizontal: true),
                                      SecondaryButton(
                                        labelKey: "Previous",
                                        onPressed: () {
                                          _pageController.previousPage(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                          setState(() {
                                            _currentPage--;
                                          });
                                        },
                                      ),
                                      divider(horizontal: true),
                                      PrimaryButton(
                                        labelKey: "Next",
                                        onPressed: () {
                                          if (_hwFormKey.currentState!
                                              .validate()) {
                                            enteredModel =
                                                _modelController.text;
                                            enteredVersion =
                                                _versionController.text;
                                            enteredMake = _makeController.text;

                                            if (_nameController
                                                .text.isNotEmpty) {
                                              _pageController.jumpToPage(2);
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      )),
                ),
                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Parameter Info",
                            style: theme.getStyle().copyWith(fontSize: 24),
                          ),
                        ],
                      ),
                      divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // TagList(tagDataList: settingList),
                          if (null != widget.model) divider(horizontal: true),
                          if (null != widget.model)
                            Tooltip(
                              textStyle: theme.getStyle(),
                              message: "Scrapping Tables",
                              child: IconButton(
                                icon: const Icon(Icons.manage_search),
                                onPressed: () async {
                                  await _editScrappingTable();
                                },
                                iconSize: 28,
                                color: Colors.black,
                              ),
                            ),
                          divider(horizontal: true),
                          PreprocessorDropDown(
                            valueChanged: (p) {
                              _preprocessor = null != p ? p.id : '';
                            },
                            selected: _preprocessor,
                          ),
                          divider(horizontal: true),
                          PrimaryButton(
                            labelKey: "Add Parameters",
                            onPressed: _addParameter,
                          ),

                          divider(horizontal: true),
                        ],
                      ),
                      divider(),
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Table(
                                border: TableBorder.all(),
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: rows,
                              ),
                            ),
                          ],
                        ),
                      ),
                      divider(horizontal: true),
                      divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.type == 'Update') ...[
                            PrimaryButton(
                              labelKey: "Update",
                              onPressed: () {
                                _save(
                                    scrappingTableConfigs:
                                        scrappingTableConfigs);
                              },
                            ),
                            divider(horizontal: true),
                          ],
                          SecondaryButton(
                            labelKey: "Cancel",
                            onPressed: () {
                              _cancel();
                            },
                          ),
                          divider(horizontal: true),
                          SecondaryButton(
                            labelKey: "Previous",
                            onPressed: () {
                              if (_currentPage > 0) {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                setState(() {
                                  _currentPage--;
                                });
                              }
                            },
                          ),
                          divider(horizontal: true),
                          PrimaryButton(
                            labelKey: null == widget.model
                                ? 'Save & Proceed'
                                : 'Next',
                            onPressed: () {
                              if (null == widget.model) {
                                _save(
                                    scrappingTableConfigs:
                                        scrappingTableConfigs);
                              }
                              enteredModel = _modelController.text;
                              enteredVersion = _versionController.text;
                              enteredMake = _makeController.text;

                              if (_nameController.text.isNotEmpty) {
                                _pageController.jumpToPage(3);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Appearance",
                              style: theme.getStyle().copyWith(fontSize: 24),
                            ),
                          ],
                        ),
                        divider(horizontal: true),
                        Column(
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
                                PrimaryButton(
                                  labelKey: "Upload Image",
                                  onPressed: () {
                                    _uploadImage();
                                  },
                                ),
                              ],
                            ),
                            divider(horizontal: true),
                            if (displayCards)
                              SafeArea(
                                child: SizedBox(
                                  height: 200,
                                  child: GridView.builder(
                                    itemCount: _imageCards.length,
                                    itemBuilder: (ctx, index) {
                                      return SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: _imageCards[index],
                                      );
                                    },
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8,
                                      childAspectRatio: 1.0,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SecondaryButton(
                              labelKey: "Cancel",
                              onPressed: () {
                                _cancel();
                              },
                            ),
                            divider(horizontal: true),
                            SecondaryButton(
                              labelKey: "Previous",
                              onPressed: () {
                                if (_currentPage > 0) {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                  setState(() {
                                    _currentPage--;
                                  });
                                }
                              },
                            ),
                            divider(horizontal: true),
                            PrimaryButton(
                              labelKey: "Save",
                              onPressed: () {
                                _save(
                                    shouldPop: true,
                                    scrappingTableConfigs:
                                        scrappingTableConfigs);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
