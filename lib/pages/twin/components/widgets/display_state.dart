import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/core/twin_theme.dart';
import 'package:twin_app/pages/twin/components/widgets/border_dropdown.dart';
import 'package:twin_app/pages/twin/components/widgets/card_layout.dart';
import 'package:twin_app/pages/twin/components/widgets/condition_dropdown.dart';
import 'package:twin_app/pages/twin/components/widgets/display_fiels_dropdown.dart';
import 'package:twin_app/pages/twin/components/widgets/dotted_divider.dart';
import 'package:twin_app/pages/twin/components/widgets/match_dropdown.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/twin_image_helper.dart';

enum PickTarget { value, left, right, top, bottom, border, background }

enum TextPaddingTarget { left, right, bottom, top }

typedef OnSave = void Function(twinned.DisplayMatchGroup group, int index);
typedef OnClose = void Function();

class DisplayStateSection extends StatefulWidget {
  final int index;
  final twinned.DeviceModel deviceModel;
  twinned.Display display;
  final OnSave onSave;
  final OnClose onClose;
  final bool isEditMode;

  DisplayStateSection(
      {super.key,
      required this.deviceModel,
      required this.display,
      required this.index,
      required this.onSave,
      required this.onClose,
      required this.isEditMode});

  @override
  State<DisplayStateSection> createState() => _DisplayStateSectionState();
}

class _DisplayStateSectionState extends BaseState<DisplayStateSection> {
  final TextEditingController _txtValue = TextEditingController();
  final TextEditingController _leftFontValue = TextEditingController();
  final TextEditingController _rightFontValue = TextEditingController();
  final TextEditingController _topFontValue = TextEditingController();
  final TextEditingController _bottomFontValue = TextEditingController();
  final TextEditingController _tooltipValue = TextEditingController();
  final List<twinned.Condition> _conditionsList = [];
  final List<twinned.Condition> _selecedConditionList = [];
  bool _apiCallSuccess = false;
  Widget? selectedDisplayImage;
  bool isDeviceModelSelected = false;
  bool isDisplayFieldSelected = false;
  bool isDisplayConditionSelected = false;
  String? selectedFieldValue;
  List<String> selectedConditionValue = [];
  String? _field;
  String? selectedModelID;
  final List<DropdownMenuItem<String>> _modelFields = [];
  List<String> conditions = [];
  String? selectedMatchValue;
  int? _leftFontColor;
  int? _rightFontColor;
  int? _topFontColor;
  int? _bottomFontColor;
  double _fontSize = 12;
  double? _leftFontSize;
  double? _rightFontSize;
  double? _bottomFontSize;
  double? _topFontSize;
  double? _leftPadding;
  double? _rightPadding;
  double? _topPadding;
  double? _bottomPadding;
  int? _borderColor;
  int? _bgColor;
  String? _value;
  String? _leftFont = "";
  String? _rightFont = "";
  String? _bottomFont = "";
  String? _topFont = "";
  double? _width;
  double? _height;
  String? _matchType;
  String? _borderType;
  String _font = 'Open Sans';
  String? _fontStyle = FontStyle.normal.name;
  int _fontColor = Colors.black.value;
  int? _fontWeight = 0;
  SizedBox hdivider = SizedBox(
    width: 8,
  );
  SizedBox vdivider = SizedBox(
    height: 8,
  );

  BoxDecoration? decoration;
  double iconSize = 16;

  @override
  void initState() {
    super.initState();
    twinned.Display e = widget.display;
    twinned.DisplayMatchGroup g = e.conditions[widget.index];
    _field = g.field;
    _matchType = g.matchType.value;
    _borderType = g.borderType?.value ?? 'BOX';
    _font = g.font;
    _fontStyle = g.fontStyle ?? FontStyle.normal.name;
    _fontWeight = g.fontWeight ?? 0;
    _fontColor = g.fontColor;
    _leftFontColor = g.prefixFontColor ?? Colors.black.value;
    _rightFontColor = g.suffixFontColor ?? Colors.black.value;
    _borderColor = g.bordorColor ?? Colors.black.value;
    _bgColor = g.bgColor == null
        ? Colors.white.value
        : Color(g.bgColor!).alpha < 10
            ? Colors.white.value
            : g.bgColor;
    _value = g.$value ?? '{{#}}';
    _leftFont = g.prefixText ?? '';
    _rightFont = g.suffixText ?? '';
    _fontSize = g.fontSize;
    _leftFontSize = g.prefixFontSize ?? 10;
    _rightFontSize = g.suffixFontSize ?? 10;
    _leftPadding = g.prefixPadding ?? 2;
    _rightPadding = g.suffixPadding ?? 2;
    _width = g.width;
    _height = g.height;
    _topFontColor = Colors.black.value;
    _topFont = '';
    _topPadding = 2;
    _topFontSize = 10;
    _bottomFontColor = Colors.black.value;
    _bottomFont = '';
    _bottomPadding = 2;
    _bottomFontSize = 10;
    _txtValue.text = _value!;
    _leftFontValue.text = _leftFont!;
    _rightFontValue.text = _rightFont!;
    _topFontValue.text = _topFont!;
    _bottomFontValue.text = _bottomFont!;
    _tooltipValue.text = g.tooltip ?? '';

    selectedFieldValue = _field ?? '';

    if (null != _field && _field!.isNotEmpty) {
      _txtValue.text = '{{${_field}}}';
      _value = '{{#}}';
    }

    _modelFields.add(DropdownMenuItem<String>(
      value: '',
      child: Text('Value Field',
          style: theme.getStyle().copyWith(color: Colors.black)),
    ));

    for (var element in widget.deviceModel.parameters) {
      _modelFields.add(DropdownMenuItem<String>(
        value: element.name,
        child: Text(
          '${element.label} (${element.name})',
          style: theme.getStyle().copyWith(color: Colors.black),
        ),
      ));
    }

    // selectedDisplayImage = const AssetImage('images/new-devicemodel.png');
    selectedDisplayImage = const Icon(Icons.question_mark, size: 250);

    if (null != widget.deviceModel.selectedImage &&
        widget.deviceModel.selectedImage! >= 0) {
      if (null != widget.deviceModel.images &&
          widget.deviceModel.images!.length >=
              widget.deviceModel.selectedImage! + 1) {
        selectedDisplayImage = TwinImageHelper.getCachedImage(
            widget.deviceModel.domainKey,
            widget.deviceModel.images![widget.deviceModel.selectedImage!],
            fit: BoxFit.fill);
        // selectedDisplayImage = NetworkImage(UserSession.twinImageUrl(
        // baseUrl(),
        //     widget.deviceModel.domainKey,
        //     widget.deviceModel.images![widget.deviceModel.selectedImage!]));
      }
    }
    loadConditions(widget.deviceModel.id);
  }

  @override
  void setup() async {
    var g = widget.display!.conditions[widget.index];
    _matchType = g.matchType.value;

    if (g.conditions.isNotEmpty) {
      var res = await TwinnedSession.instance.twin.getConditions(
          apikey: TwinnedSession.instance.authToken,
          body: twinned.GetReq(ids: g.conditions));

      if (validateResponse(res)) {
        _selecedConditionList.addAll(res.body!.values!);
        if (_selecedConditionList.length > 0) {
          for (var i = 0; i < _selecedConditionList.length; i++) {
            selectedConditionValue.add(_selecedConditionList[i].name);
          }
        }
      }
    }

    setState(() {});
  }

  void _saveDisplayState() {
    if (loading) return;
    loading = true;

    if (selectedConditionValue.isEmpty) {
      alert('Error', 'Display should have at least one condition');
      return;
    }
    List<String> selectedConditions = [];
    for (var cond in _conditionsList) {
      if (selectedConditionValue.contains(cond.name))
        selectedConditions.add(cond.id);
    }

    twinned.DisplayMatchGroup group = twinned.DisplayMatchGroup(
        matchType: twinned.DisplayMatchGroupMatchType.values
            .byName(_matchType!.toLowerCase()),
        conditions: selectedConditions,
        width: _width!,
        height: _height!,
        $value: _value,
        field: _field ?? '',
        font: _font,
        fontSize: _fontSize,
        fontColor: _fontColor,
        fontStyle: _fontStyle,
        fontWeight: _fontWeight,
        bgColor: _bgColor,
        borderType: twinned.DisplayMatchGroupBorderType.values
            .byName(_borderType!.toLowerCase()),
        bordorColor: _borderColor,
        prefixFont: _font,
        prefixFontColor: _leftFontColor,
        prefixFontSize: _leftFontSize,
        prefixFontStyle: _fontStyle,
        prefixFontWeight: _fontWeight,
        prefixText: _leftFont,
        prefixPadding: _leftPadding,
        suffixFont: _font,
        suffixFontColor: _rightFontColor,
        suffixFontSize: _rightFontSize,
        suffixFontStyle: _fontStyle,
        suffixFontWeight: _fontWeight,
        suffixText: _rightFont,
        suffixPadding: _rightPadding,
        tooltip: _tooltipValue.text);

    widget.onSave(group, widget.index);
    //setState(() {});
    loading = false;
    refresh();
  }

  void loadConditions(dmodelID) async {
    if (loading) return;
    loading = true;
    _conditionsList.clear();
    conditions.clear();
    // conditions = [];
    var res = await TwinnedSession.instance.twin.listConditions(
        apikey: TwinnedSession.instance.authToken,
        modelId: dmodelID,
        body: const twinned.ListReq(page: 0, size: 10000));

    if (validateResponse(res)) {
      for (twinned.Condition e in res.body!.values!) {
        _conditionsList.add(e);
        conditions.add(e.name);
      }
      _apiCallSuccess = true;
      _refresh();
    }
    loading = false;
    refresh();
  }

  void _pickColor(PickTarget target) {
    Color existingColor;
    switch (target) {
      case PickTarget.value:
        existingColor = Color(_fontColor);
        break;
      case PickTarget.left:
        existingColor = Color(_leftFontColor!);
        break;
      case PickTarget.right:
        existingColor = Color(_rightFontColor!);
        break;
      case PickTarget.bottom:
        existingColor = Color(_bottomFontColor!);
        break;
      case PickTarget.top:
        existingColor = Color(_topFontColor!);
        break;

      case PickTarget.border:
        existingColor = Color(_borderColor!);
        break;
      case PickTarget.background:
        existingColor = Color(_bgColor!);
        break;
    }
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Pick a Color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                hexInputBar: true,
                labelTypes: [],
                pickerColor: existingColor,
                displayThumbColor: true,
                onColorChanged: (color) {
                  switch (target) {
                    case PickTarget.value:
                      _fontColor = color.value;
                      break;
                    case PickTarget.left:
                      _leftFontColor = color.value;
                      break;

                    case PickTarget.right:
                      _rightFontColor = color.value;
                      break;
                    case PickTarget.bottom:
                      _bottomFontColor = color.value;
                      break;
                    case PickTarget.top:
                      _topFontColor = color.value;
                      break;
                    case PickTarget.border:
                      _borderColor = color.value;
                      break;
                    case PickTarget.background:
                      _bgColor = color.value;
                      break;
                  }
                  _refresh();
                },
              ),
            ),
          );
        });
  }

  void _pickFontSize(PickTarget target) {
    double existingSize = 0;
    switch (target) {
      case PickTarget.value:
        existingSize = _fontSize;
        break;
      case PickTarget.left:
        existingSize = _leftFontSize!;
        break;
      case PickTarget.right:
        existingSize = _rightFontSize!;
        break;
      case PickTarget.top:
        existingSize = _topFontSize!;
        break;
      case PickTarget.bottom:
        existingSize = _bottomFontSize!;
        break;
      default:
        break;
    }
    showDialog(
        context: context,
        builder: (ctx) {
          return SizedBox(
            child: AlertDialog(
              title: const Text('Font Size'),
              content: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    SpinBox(
                      min: 5,
                      max: 50,
                      value: existingSize,
                      onSubmitted: (value) {
                        switch (target) {
                          case PickTarget.value:
                            _fontSize = value;
                            break;
                          case PickTarget.left:
                            _leftFontSize = value;
                            break;
                          case PickTarget.right:
                            _rightFontSize = value;
                            break;
                          case PickTarget.bottom:
                            _bottomFontSize = value;
                            break;
                          case PickTarget.top:
                            _topFontSize = value;
                            break;
                          default:
                            break;
                        }
                        _refresh();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _pickFontPadding(TextPaddingTarget target) {
    double existingPadding = 0;
    switch (target) {
      case TextPaddingTarget.left:
        existingPadding = _leftPadding!;
        break;
      case TextPaddingTarget.right:
        existingPadding = _rightPadding!;
        break;
      case TextPaddingTarget.top:
        existingPadding = _topPadding!;
        break;
      case TextPaddingTarget.bottom:
        existingPadding = _bottomPadding!;
        break;
    }
    showDialog(
        context: context,
        builder: (ctx) {
          return SizedBox(
            child: AlertDialog(
              title: const Text('Padding'),
              content: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    SpinBox(
                      min: 0,
                      max: 50,
                      value: existingPadding,
                      onSubmitted: (value) {
                        switch (target) {
                          case TextPaddingTarget.left:
                            _leftPadding = value;
                            break;
                          case TextPaddingTarget.right:
                            _rightPadding = value;
                            break;
                          case TextPaddingTarget.top:
                            _topPadding = value;
                            break;
                          case TextPaddingTarget.bottom:
                            _bottomPadding = value;
                            break;
                        }
                        _refresh();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (twinned.DisplayMatchGroupBorderType.values
        .byName(_borderType!.toLowerCase())) {
      case twinned.DisplayMatchGroupBorderType.box:
        decoration = BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.zero),
            color: Color(_bgColor!),
            border: Border.all(
                style: BorderStyle.solid, color: Color(_borderColor!)));
        break;
      case twinned.DisplayMatchGroupBorderType.rounded:
        decoration = BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.elliptical(_width!, _height!)),
            color: Color(_bgColor!),
            border: Border.all(
                style: BorderStyle.solid, color: Color(_borderColor!)));
        break;
      case twinned.DisplayMatchGroupBorderType.circle:
        decoration = BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(_width!)),
            color: Color(_bgColor!),
            border: Border.all(
                style: BorderStyle.solid, color: Color(_borderColor!)));
        break;
      default:
        decoration = BoxDecoration(color: Color(_bgColor!));
    }
    return _apiCallSuccess
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CardLayoutSection(
                        child: Column(
                      children: [
                        vdivider,
                        Text(widget.deviceModel.name,
                            style:
                                theme.getStyle().copyWith(color: Colors.black)),
                        vdivider,
                        SizedBox(
                          child: selectedDisplayImage!,
                          //  fit: BoxFit.contain,
                          width: 240,
                          height: 240,
                        ),
                        vdivider,
                        DisplayFieldDropdown(
                          selectedValue: selectedFieldValue,
                          onChanged: (String? value) {
                            setState(() {
                              selectedFieldValue = value;
                              isDisplayFieldSelected = true;
                            });

                            if (null != value) {
                              _txtValue.text = '{{$value}}';
                              _field = value;
                            } else {
                              _txtValue.text = '';
                              _field = null;
                            }
                          },
                          fieldList: _modelFields,
                        ),
                        if (isDisplayFieldSelected || widget.isEditMode) ...[
                          SizedBox(height: 15),
                          SizedBox(
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: _txtValue,
                                enabled: null != _field && _field!.isEmpty,
                                onSubmitted: (value) {
                                  _value = value;
                                  _refresh();
                                },
                                decoration: InputDecoration(
                                  hintStyle: theme.getStyle(),
                                  labelStyle: theme.getStyle(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 3.0, horizontal: 6.0),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.zero),
                                  labelText: 'Value',
                                ),
                                style: theme.getStyle().copyWith(
                                      color: Color(_fontColor),
                                      fontSize: _fontSize,
                                    ),
                              )),
                          Container(
                            width: 150,
                            decoration: BoxDecoration(border: Border.all()),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Tooltip(
                                  textStyle: theme
                                      .getStyle()
                                      .copyWith(color: Colors.white),
                                  message: "Choose value text color",
                                  child: IconButton(
                                      onPressed: () {
                                        _pickColor(PickTarget.value);
                                      },
                                      icon: Icon(Icons.color_lens_outlined,
                                          color: Color(_fontColor),
                                          size: iconSize)),
                                ),
                                Tooltip(
                                  textStyle: theme
                                      .getStyle()
                                      .copyWith(color: Colors.white),
                                  message: "Enter value text size",
                                  child: IconButton(
                                      onPressed: () {
                                        _pickFontSize(PickTarget.value);
                                      },
                                      icon: Icon(Icons.format_size,
                                          color: Color(_fontColor),
                                          size: iconSize)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                        ],
                      ],
                    )),
                    if (isDisplayFieldSelected || widget.isEditMode) ...[
                      DottedDivider(),
                      CardLayoutSection(
                          child: Column(
                        children: [
                          SizedBox(height: 20),
                          MatchDropdown(
                            selectedValue: _matchType,
                            onChanged: (String? value) {
                              setState(() {
                                // selectedMatchValue = value;
                                _matchType = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          ConditonDropdown(
                            selectedValue: selectedConditionValue,
                            conditionList: conditions,
                            onConfirm: (List<String> values) {
                              setState(() {
                                selectedConditionValue = values;
                                isDisplayConditionSelected = true;
                              });
                            },
                          ),
                        ],
                      ))
                    ],
                    if ((isDisplayConditionSelected && conditions.isNotEmpty) ||
                        widget.isEditMode) ...[
                      DottedDivider(),
                      CardLayoutSection(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Row(
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: SpinBox(
                                    textStyle: theme.getStyle(),
                                    iconSize: 15,
                                    decoration: InputDecoration(
                                      labelStyle: theme.getStyle(),
                                      hintStyle: theme.getStyle(),
                                      labelText: 'Width',
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 2.0),
                                    ),
                                    min: 25,
                                    max: 90,
                                    value: _width!,
                                    onSubmitted: (value) {
                                      _width = value;
                                      _refresh();
                                    },
                                  ),
                                ),
                                hdivider,
                                SizedBox(
                                  width: 110,
                                  child: SpinBox(
                                    textStyle: theme.getStyle(),
                                    iconSize: 15,
                                    decoration: InputDecoration(
                                      labelStyle: theme.getStyle(),
                                      hintStyle: theme.getStyle(),
                                      labelText: 'Height',
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 2.0),
                                    ),
                                    min: 25,
                                    max: 75,
                                    value: _height!,
                                    onSubmitted: (value) {
                                      _height = value;
                                      _refresh();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            vdivider,
                            Row(
                              children: [
                                SizedBox(
                                  width: 160,
                                  child: BorderDropdown(
                                    selectedValue: _borderType,
                                    onChanged: (String? value) {
                                      // selectedborderValue = value;
                                      _borderType = value;
                                      _refresh();
                                    },
                                  ),
                                ),
                                hdivider,
                                Tooltip(
                                    textStyle: theme
                                        .getStyle()
                                        .copyWith(color: Colors.white),
                                    message: 'Choose border color',
                                    child: IconButton(
                                        onPressed: () {
                                          _pickColor(PickTarget.border);
                                        },
                                        icon: Icon(
                                          Icons.border_color,
                                          size: iconSize,
                                          color: (Colors.white.value ==
                                                      _borderColor ||
                                                  Colors.transparent.value ==
                                                      _borderColor!)
                                              ? Colors.black
                                              : Color(_borderColor!),
                                        ))),
                                hdivider,
                                Tooltip(
                                    textStyle: theme
                                        .getStyle()
                                        .copyWith(color: Colors.white),
                                    message: 'Choose background color',
                                    child: IconButton(
                                        onPressed: () {
                                          _pickColor(PickTarget.background);
                                        },
                                        icon: Icon(
                                          Icons.format_color_fill,
                                          size: iconSize,
                                          color: (Colors.white.value ==
                                                      _bgColor! ||
                                                  Colors.transparent.value ==
                                                      _bgColor!)
                                              ? Colors.black
                                              : Color(_bgColor!),
                                        ))),
                              ],
                            ),
                            vdivider,
                            SizedBox(
                                width: 226,
                                height: 40,
                                child: TextField(
                                  style: theme.getStyle(),
                                  maxLines: null,
                                  controller: _tooltipValue,
                                  onSubmitted: (value) {
                                    // _value = value;
                                    // _refresh();
                                  },
                                  decoration: InputDecoration(
                                    hintStyle: theme.getStyle(),
                                    labelStyle: theme.getStyle(),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 3.0, horizontal: 6.0),
                                    border: OutlineInputBorder(),
                                    labelText: 'Tooltip',
                                  ),
                                )),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                      DottedDivider(),
                      CardLayoutSection(
                        child: Container(
                            width: 375,
                            height: 270,
                            child: Stack(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Container(
                                      decoration: decoration,
                                      child: SizedBox(
                                        width: _width,
                                        height: _height,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            if (_topFont != "") ...[
                                              Text(
                                                _topFont!,
                                                style: theme
                                                    .getStyle()
                                                    .copyWith(
                                                      fontSize: _topFontSize,
                                                      color:
                                                          Color(_topFontColor!),
                                                    ),
                                              ),
                                              SizedBox(height: _topPadding)
                                            ],
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                RichText(
                                                  text: TextSpan(children: [
                                                    TextSpan(
                                                      text: _leftFont,
                                                      style: theme
                                                          .getStyle()
                                                          .copyWith(
                                                              fontSize:
                                                                  _leftFontSize!,
                                                              color: Color(
                                                                  _leftFontColor!)),
                                                    ),
                                                    WidgetSpan(
                                                        child: SizedBox(
                                                      width: _leftPadding,
                                                    )),
                                                    TextSpan(
                                                      text: null != _field &&
                                                              _field!.isEmpty
                                                          ? _value
                                                          : '{{#}}',
                                                      style: theme
                                                          .getStyle()
                                                          .copyWith(
                                                              fontSize:
                                                                  _fontSize,
                                                              color: Color(
                                                                  _fontColor)),
                                                    ),
                                                    WidgetSpan(
                                                        child: SizedBox(
                                                      width: _rightPadding,
                                                    )),
                                                    TextSpan(
                                                      text: _rightFont,
                                                      style: theme
                                                          .getStyle()
                                                          .copyWith(
                                                              fontSize:
                                                                  _rightFontSize!,
                                                              color: Color(
                                                                  _rightFontColor!)),
                                                    ),
                                                  ]),
                                                ),
                                              ],
                                            ),
                                            if (_bottomFont != "") ...[
                                              SizedBox(height: _bottomPadding),
                                              Text(_bottomFont!,
                                                  style: theme.getStyle().copyWith(
                                                      fontSize: _bottomFontSize,
                                                      color: Color(
                                                          _bottomFontColor!))),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 96,
                                  left: 248,
                                  child: Column(children: [
                                    SizedBox(
                                        width: 125,
                                        height: 40,
                                        child: TextField(
                                          controller: _rightFontValue,
                                          onSubmitted: (value) {
                                            _rightFont = value;
                                            _refresh();
                                          },
                                          decoration: InputDecoration(
                                            hintStyle: theme.getStyle(),
                                            labelStyle: theme.getStyle(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 3.0,
                                                    horizontal: 6.0),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.zero),
                                            labelText: 'Right',
                                          ),
                                          style: theme.getStyle().copyWith(
                                                color: Color(_rightFontColor!),
                                                fontSize: _rightFontSize,
                                              ),
                                        )),
                                    Container(
                                      width: 125,
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message: "Choose right text color",
                                            child: IconButton(
                                                onPressed: () {
                                                  _pickColor(PickTarget.right);
                                                },
                                                icon: Icon(
                                                  Icons.color_lens_outlined,
                                                  size: iconSize,
                                                  color:
                                                      Color(_rightFontColor!),
                                                )),
                                          ),
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message: "Enter right text size",
                                            child: IconButton(
                                                onPressed: () {
                                                  _pickFontSize(
                                                      PickTarget.right);
                                                },
                                                icon: Icon(
                                                  Icons.format_size,
                                                  size: iconSize,
                                                  color:
                                                      Color(_rightFontColor!),
                                                )),
                                          ),
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message:
                                                "Enter right padding value",
                                            child: IconButton(
                                                onPressed: () {
                                                  Text("right padding");
                                                  _pickFontPadding(
                                                      TextPaddingTarget.right);
                                                },
                                                icon: Icon(
                                                  Icons.align_horizontal_right,
                                                  size: iconSize,
                                                  color:
                                                      Color(_rightFontColor!),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                                Positioned(
                                  top: 96,
                                  left: 0,
                                  child: Column(children: [
                                    SizedBox(
                                        width: 125,
                                        height: 40,
                                        child: TextField(
                                          controller: _leftFontValue,
                                          onSubmitted: (value) {
                                            _leftFont = value;
                                            _refresh();
                                          },
                                          decoration: InputDecoration(
                                            hintStyle: theme.getStyle(),
                                            labelStyle: theme.getStyle(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 3.0,
                                                    horizontal: 6.0),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.zero),
                                            labelText: 'Left',
                                          ),
                                          style: theme.getStyle().copyWith(
                                                color: Color(_leftFontColor!),
                                                fontSize: _leftFontSize,
                                              ),
                                        )),
                                    Container(
                                      width: 125,
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message: "Choose left text color",
                                            child: IconButton(
                                                onPressed: () {
                                                  _pickColor(PickTarget.left);
                                                },
                                                icon: Icon(
                                                  Icons.color_lens_outlined,
                                                  size: iconSize,
                                                  color: Color(_leftFontColor!),
                                                )),
                                          ),
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message: "Enter left text size",
                                            child: IconButton(
                                                onPressed: () {
                                                  _pickFontSize(
                                                      PickTarget.left);
                                                },
                                                icon: Icon(
                                                  Icons.format_size,
                                                  size: iconSize,
                                                  color: Color(_leftFontColor!),
                                                )),
                                          ),
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message: "Enter left padding value",
                                            child: IconButton(
                                                onPressed: () {
                                                  _pickFontPadding(
                                                      TextPaddingTarget.left);
                                                },
                                                icon: Icon(
                                                  Icons.align_horizontal_left,
                                                  size: iconSize,
                                                  color: Color(_leftFontColor!),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                                Positioned(
                                  top: 178,
                                  left: 124,
                                  child: Column(children: [
                                    SizedBox(
                                        width: 125,
                                        height: 40,
                                        child: TextField(
                                          controller: _bottomFontValue,
                                          onSubmitted: (value) {
                                            _bottomFont = value;
                                            _refresh();
                                          },
                                          decoration: InputDecoration(
                                            labelStyle: theme.getStyle(),
                                            hintStyle: theme.getStyle(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 3.0,
                                                    horizontal: 6.0),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.zero),
                                            labelText: 'Bottom',
                                          ),
                                          style: theme.getStyle().copyWith(
                                                color: Color(_bottomFontColor!),
                                                fontSize: _bottomFontSize,
                                              ),
                                        )),
                                    Container(
                                      width: 125,
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message: "Choose bottom text color",
                                            child: IconButton(
                                                onPressed: () {
                                                  _pickColor(PickTarget.bottom);
                                                },
                                                icon: Icon(
                                                  Icons.color_lens_outlined,
                                                  size: iconSize,
                                                  color:
                                                      Color(_bottomFontColor!),
                                                )),
                                          ),
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message: "Enter bottom text size",
                                            child: IconButton(
                                                onPressed: () {
                                                  _pickFontSize(
                                                      PickTarget.bottom);
                                                },
                                                icon: Icon(
                                                  Icons.format_size,
                                                  size: iconSize,
                                                  color:
                                                      Color(_bottomFontColor!),
                                                )),
                                          ),
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message:
                                                "Enter bottom padding value",
                                            child: IconButton(
                                                onPressed: () {
                                                  _pickFontPadding(
                                                      TextPaddingTarget.bottom);
                                                },
                                                icon: Icon(
                                                  Icons.align_vertical_bottom,
                                                  size: iconSize,
                                                  color:
                                                      Color(_bottomFontColor!),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                                Positioned(
                                  top: 15,
                                  left: 124,
                                  child: Column(children: [
                                    SizedBox(
                                        width: 125,
                                        height: 40,
                                        child: TextField(
                                          controller: _topFontValue,
                                          onSubmitted: (value) {
                                            _topFont = value;
                                            _refresh();
                                          },
                                          decoration: InputDecoration(
                                            labelStyle: theme.getStyle(),
                                            hintStyle: theme.getStyle(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 3.0,
                                                    horizontal: 6.0),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.zero),
                                            labelText: 'Top',
                                          ),
                                          style: theme.getStyle().copyWith(
                                                color: Color(_topFontColor!),
                                                fontSize: _topFontSize,
                                              ),
                                        )),
                                    Container(
                                      width: 125,
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message: "Choose top text color",
                                            child: IconButton(
                                                onPressed: () {
                                                  _pickColor(PickTarget.top);
                                                },
                                                icon: Icon(
                                                  Icons.color_lens_outlined,
                                                  size: iconSize,
                                                  color: Color(_topFontColor!),
                                                )),
                                          ),
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message: "Enter top text size",
                                            child: IconButton(
                                                onPressed: () {
                                                  _pickFontSize(PickTarget.top);
                                                },
                                                icon: Icon(
                                                  Icons.format_size,
                                                  size: iconSize,
                                                  color: Color(_topFontColor!),
                                                )),
                                          ),
                                          Tooltip(
                                            textStyle: theme
                                                .getStyle()
                                                .copyWith(color: Colors.white),
                                            message: "Enter top padding value",
                                            child: IconButton(
                                                onPressed: () {
                                                  _pickFontPadding(
                                                      TextPaddingTarget.top);
                                                },
                                                icon: Icon(
                                                  Icons.align_vertical_top,
                                                  size: iconSize,
                                                  color: Color(_topFontColor!),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            )),
                      ),
                    ]
                  ],
                ),
                if ((isDisplayConditionSelected && conditions.isNotEmpty) ||
                    widget.isEditMode) ...[
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SecondaryButton(
                        labelKey: "Close",
                        onPressed: widget.onClose,
                      ),
                      hdivider,
                      PrimaryButton(
                        labelKey: "Save",
                        onPressed: () {
                          _saveDisplayState();
                        },
                      ),
                    ],
                  ),
                ]
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
