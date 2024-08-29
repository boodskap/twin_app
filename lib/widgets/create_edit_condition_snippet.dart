import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twinned_widgets/core/device_model_dropdown.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:twin_commons/core/twinned_session.dart';

class CreateEditConditionSnippet extends StatefulWidget {
  tapi.Condition? condition;
  final tapi.DeviceModel? selectedModel;
  CreateEditConditionSnippet({super.key, this.condition, this.selectedModel});

  @override
  State<CreateEditConditionSnippet> createState() =>
      _CreateEditConditionSnippetState();
}

class _CreateEditConditionSnippetState
    extends BaseState<CreateEditConditionSnippet>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _lvalueController = TextEditingController();
  final TextEditingController _rvalueController = TextEditingController();
  final TextEditingController _valuesController = TextEditingController();
  final List<tapi.Parameter> _parameters = [];
  final List<tapi.DeviceModel> _models = [];
  final List<DropdownMenuItem<tapi.DeviceModel>> _modelItems = [];
  final List<DropdownMenuItem<tapi.Parameter>> _parameterItems = [];
  final List<DropdownMenuItem<tapi.ConditionCondition>> _conditionItems = [];

  tapi.DeviceModel? _selectedModel;
  tapi.Parameter? _selectedParameter;
  tapi.ConditionCondition? _selectedCondition;
  bool _showValue = false;
  bool _showLRValues = false;
  bool _showNDValues = false;
  bool _showTValues = false;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _selectedModel = widget.selectedModel;

    for (var con in tapi.ConditionCondition.values) {}

    _conditionItems.add(DropdownMenuItem<tapi.ConditionCondition>(
        value: tapi.ConditionCondition.lt,
        child: Center(
          child: Text(
            '<',
            style: theme.getStyle(),
            textAlign: TextAlign.center,
          ),
        )));
    _conditionItems.add(DropdownMenuItem<tapi.ConditionCondition>(
        value: tapi.ConditionCondition.lte,
        child: Center(
          child: Text(
            '<=',
            style: theme.getStyle(),
            textAlign: TextAlign.center,
          ),
        )));
    _conditionItems.add(DropdownMenuItem<tapi.ConditionCondition>(
        value: tapi.ConditionCondition.gt,
        child: Center(
          child: Text(
            '>',
            style: theme.getStyle(),
            textAlign: TextAlign.center,
          ),
        )));
    _conditionItems.add(DropdownMenuItem<tapi.ConditionCondition>(
        value: tapi.ConditionCondition.gte,
        child: Center(
          child: Text(
            '>=',
            style: theme.getStyle(),
            textAlign: TextAlign.center,
          ),
        )));
    _conditionItems.add(DropdownMenuItem<tapi.ConditionCondition>(
        value: tapi.ConditionCondition.eq,
        child: Center(
          child: Text(
            '==',
            style: theme.getStyle(),
            textAlign: TextAlign.center,
          ),
        )));
    _conditionItems.add(DropdownMenuItem<tapi.ConditionCondition>(
        value: tapi.ConditionCondition.neq,
        child: Center(
          child: Text(
            '!=',
            style: theme.getStyle(),
            textAlign: TextAlign.center,
          ),
        )));
    _conditionItems.add(DropdownMenuItem<tapi.ConditionCondition>(
        value: tapi.ConditionCondition.between,
        child: Center(
          child: Text(
            'BETWEEN',
            style: theme.getStyle(),
            textAlign: TextAlign.center,
          ),
        )));
    _conditionItems.add(DropdownMenuItem<tapi.ConditionCondition>(
        value: tapi.ConditionCondition.nbetween,
        child: Center(
          child: Text(
            'NOT BETWEEN',
            style: theme.getStyle(),
            textAlign: TextAlign.center,
          ),
        )));
    _conditionItems.add(DropdownMenuItem<tapi.ConditionCondition>(
        value: tapi.ConditionCondition.contains,
        child: Center(
          child: Text(
            'CONTAINS',
            style: theme.getStyle(),
            textAlign: TextAlign.center,
          ),
        )));
    _conditionItems.add(DropdownMenuItem<tapi.ConditionCondition>(
        value: tapi.ConditionCondition.ncontains,
        child: Center(
          child: Text(
            'NOT CONTAINS',
            style: theme.getStyle(),
            textAlign: TextAlign.center,
          ),
        )));
    _selectedCondition = tapi.ConditionCondition.eq;
    setup();
  }

  Future<void> _loadModels() async {
    _selectedParameter = null;
    _selectedCondition = null;
    _models.clear();
    _modelItems.clear();
    _parameters.clear();
    _parameterItems.clear();

    if (_selectedModel != null) {
      _models.add(_selectedModel!);

      if (_models.isNotEmpty) {
        _selectedModel = _models.first;

        if (_selectedModel != null) {
          _parameters.addAll(_selectedModel!.parameters);

          if (_parameters.isNotEmpty) {
            _selectedParameter = _parameters.first;
          }

          _parameterItems.addAll(_parameters.map((param) {
            return DropdownMenuItem<tapi.Parameter>(
              value: param,
              child: Center(
                child: Text(
                  param.name,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList());

          if (widget.condition != null) {
            _selectedCondition = widget.condition!.condition;
            _selectedParameter = _parameters.firstWhere(
              (param) => param.name == widget.condition!.field,
              orElse: () => _parameters.first,
            );
          }
        }
      }
    }

    refresh();
  }

  @override
  void setup() async {
    await _loadModels();

    if (null != widget.condition) {
      tapi.Condition e = widget.condition!;
      _nameController.text = e.name;
      _descController.text = e.description ?? '';
      _tagsController.text = null != e.tags ? e.tags!.join(' ') : '';

      _selectedCondition = e.condition;

      _valueController.text = e.$value ?? '';
      _lvalueController.text = e.leftValue ?? '';
      _rvalueController.text = e.rightValue ?? '';
      _valuesController.text = (null != e.values ? e.values!.join('\n') : '');

      switch (_selectedCondition!) {
        case tapi.ConditionCondition.between:
        case tapi.ConditionCondition.nbetween:
          _showLRValues = true;
          break;
        case tapi.ConditionCondition.contains:
        case tapi.ConditionCondition.ncontains:
          if (_selectedParameter!.parameterType ==
              tapi.ParameterParameterType.text) {
            _showTValues = true;
          } else {
            _showNDValues = true;
          }
          break;
        case tapi.ConditionCondition.lt:
        case tapi.ConditionCondition.lte:
        case tapi.ConditionCondition.gt:
        case tapi.ConditionCondition.gte:
        case tapi.ConditionCondition.eq:
        case tapi.ConditionCondition.neq:
        default:
          _showValue = true;
          break;
      }
    } else {
      _showValue = true;
      _selectedCondition = tapi.ConditionCondition.eq;
    }

    refresh();
  }

  void _changeParameter(tapi.Parameter? parameter) {
    _selectedParameter = parameter;
    _valueController.text = '';
    _lvalueController.text = '';
    _rvalueController.text = '';
    _valuesController.text = '';
    _changeCondition(tapi.ConditionCondition.eq);
  }

  void _changeCondition(tapi.ConditionCondition? condition) {
    _showValue = false;
    _showLRValues = false;
    _showNDValues = false;
    _showTValues = false;

    _selectedCondition = condition;

    switch (condition!) {
      case tapi.ConditionCondition.between:
      case tapi.ConditionCondition.nbetween:
        _showLRValues = true;
        break;
      case tapi.ConditionCondition.contains:
      case tapi.ConditionCondition.ncontains:
        if (_selectedParameter!.parameterType ==
            tapi.ParameterParameterType.text) {
          _showTValues = true;
        } else {
          _showNDValues = true;
        }
        break;
      case tapi.ConditionCondition.lt:
      case tapi.ConditionCondition.lte:
      case tapi.ConditionCondition.gt:
      case tapi.ConditionCondition.gte:
      case tapi.ConditionCondition.eq:
      case tapi.ConditionCondition.neq:
      default:
        _showValue = true;
        break;
    }

    refresh();
  }

  bool _validateParameter(String data, String field) {
    if (isBlank(data)) {
      alert('Invalid Value', "$field can't be empty");
      return false;
    }

    switch (_selectedParameter!.parameterType) {
      case tapi.ParameterParameterType.yesno:
        if (!isBoolean(data)) {
          alert('Invalid Value', '$field ($data) should be true or false');
          return false;
        }
        break;
      case tapi.ParameterParameterType.numeric:
        if (int.tryParse(data) == null) {
          alert('Invalid Value', '$field ($data) should be a valid number');
          return false;
        }
        break;
      case tapi.ParameterParameterType.floating:
        if (double.tryParse(data) == null) {
          alert('Invalid Value', '$field ($data) should be a valid decimal');
          return false;
        }
        break;
      default:
        break;
    }
    return true;
  }

  Future _save({bool shouldPop = false}) async {
    List<String>? clientIds = super.isClientAdmin()
        ? await TwinnedSession.instance.getClientIds()
        : null;
    if (loading) return;
    loading = true;
    await execute(() async {
      if (isBlank(_nameController.text)) {
        alert('Missing Value', "Name can't be empty");
        return;
      }

      switch (_selectedCondition!) {
        case tapi.ConditionCondition.between:
        case tapi.ConditionCondition.nbetween:
          if (!_validateParameter(_lvalueController.text, 'Left Value')) return;
          if (!_validateParameter(_rvalueController.text, 'Right Value')) {
            return;
          }
          break;
        case tapi.ConditionCondition.contains:
        case tapi.ConditionCondition.ncontains:
          if (isBlank(_valuesController.text)) {
            alert('Invalid Value', "Values can't be empty");
            return;
          }
          var values = _valuesController.text.split('\n');
          for (var value in values) {
            value = value.trim();
            if (value.isEmpty) continue;
            if (!_validateParameter(value, 'Values')) return;
          }
          break;
        case tapi.ConditionCondition.lt:
        case tapi.ConditionCondition.lte:
        case tapi.ConditionCondition.gt:
        case tapi.ConditionCondition.gte:
        case tapi.ConditionCondition.eq:
        case tapi.ConditionCondition.neq:
        default:
          if (!_validateParameter(_valueController.text, 'Value')) return;
          break;
      }

      String value = _valueController.text;
      String lValue = _lvalueController.text;
      String rValue = _rvalueController.text;
      List<String> values = [];

      var cValues = _valuesController.text.split('\n');
      for (var value in cValues) {
        value = value.trim();
        if (value.isEmpty) continue;
        values.add(value);
      }

      values = values.toSet().toList();

      chopper.Response<tapi.ConditionEntityRes> res;

      if (null == widget.condition) {
        res = await TwinnedSession.instance.twin.createCondition(
            apikey: TwinnedSession.instance.authToken,
            body: tapi.ConditionInfo(
              name: _nameController.text,
              modelId: _selectedModel!.id,
              field: _selectedParameter!.name,
              condition: tapi.ConditionInfoCondition.values
                  .byName(_selectedCondition!.name),
              tags: _tagsController.text.split(' '),
              description: _descController.text,
              $value: value,
              leftValue: lValue,
              rightValue: rValue,
              values: values,
              clientIds: clientIds,
            ));
      } else {
        res = await TwinnedSession.instance.twin.updateCondition(
            apikey: TwinnedSession.instance.authToken,
            conditionId: widget.condition!.id,
            body: tapi.ConditionInfo(
              name: _nameController.text,
              modelId: _selectedModel!.id,
              field: _selectedParameter!.name,
              condition: tapi.ConditionInfoCondition.values
                  .byName(_selectedCondition!.name),
              tags: _tagsController.text.split(' '),
              description: _descController.text,
              $value: value,
              leftValue: lValue,
              rightValue: rValue,
              values: values,
              icon: widget.condition!.icon,
              clientIds: clientIds,
            ));
      }
      if (validateResponse(res)) {
        setState(() {
          widget.condition = res.body!.entity;
        });
        await alert('', 'Condition ${_nameController.text} saved successfully');
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

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
    _valueController.dispose();
    _nameController.dispose();
  }

  bool isBlank(String text) {
    return text.isEmpty;
  }

  bool isBoolean(String text) {
    return (text == 'true' || text == 'false');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 600,
        width: 600,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.getPrimaryColor(),
            width: 2.0,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            PageView(
              controller: _pageViewController,
              onPageChanged: _handlePageViewChanged,
              children: <Widget>[
                _buildFirstPage(),
                _buildSecondPage(),
                _buildThirdPage(),
              ],
            ),
            PageIndicator(
              tabController: _tabController,
              currentPageIndex: _currentPageIndex,
              onUpdateCurrentPageIndex: _updateCurrentPageIndex,
              onSave: _save,
              onCancel: _cancel,
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Select Device Library',
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 45,
                  color: theme.getPrimaryColor(),
                ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: 250,
              child: DeviceModelDropdown(
                  selectedItem: _selectedModel?.id,
                  onDeviceModelSelected: (dm) {
                    setState(() {
                      _selectedModel = dm;
                    });
                    _loadModels();
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'IF',
            style: theme.getStyle().copyWith(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: theme.getPrimaryColor(),
                ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: 250,
              child: DropdownButton<tapi.Parameter>(
                items: _parameterItems,
                value: _selectedParameter,
                isDense: false,
                iconSize: 0.0,
                isExpanded: true,
                alignment: AlignmentDirectional.center,
                onChanged: (tapi.Parameter? value) {
                  setState(() {
                    _changeParameter(value);
                  });
                },
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: 400,
              child: Center(
                child: DropdownButton<tapi.ConditionCondition>(
                  iconSize: 0.0,
                  isDense: false,
                  isExpanded: true,
                  alignment: AlignmentDirectional.center,
                  items: _conditionItems,
                  value: _selectedCondition,
                  onChanged: (tapi.ConditionCondition? value) {
                    setState(() {
                      _changeCondition(value);
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'Then',
            style: theme.getStyle().copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.getIntermediateColor(),
                ),
          ),
          const SizedBox(
            height: 15,
          ),
          if (_showValue)
            SizedBox(
              width: 150,
              child: LabelTextField(
                label: 'Enter Value',
                controller: _valueController,
              ),
            ),
          if (_showLRValues)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 200,
                  child: LabelTextField(
                    label: 'Enter Left Value',
                    controller: _lvalueController,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: LabelTextField(
                    label: 'Enter Right Value',
                    controller: _rvalueController,
                  ),
                ),
              ],
            ),
          if (_showTValues || _showNDValues)
            Expanded(
              child: SizedBox(
                width: 200,
                child: LabelTextField(
                  controller: _valuesController,
                  textAlign: TextAlign.center,
                  style: theme.getStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                  label: 'Values',
                  maxLines: 5,
                ),
              ),
            ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Condition Name',
                labelStyle: theme.getStyle().copyWith(
                      color: theme.getPrimaryColor(),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      5.0,
                    ),
                  ),
                  borderSide: BorderSide(
                    color: theme.getIntermediateColor(),
                    width: 5.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(
                    color: theme.getSecondaryColor(),
                    width: 3.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.onSave,
    required this.onCancel,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;
  final Future<void> Function({bool shouldPop}) onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 8.0,
        bottom: 50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SecondaryButton(
            labelKey: 'Cancel',
            onPressed: () => onCancel(),
          ),
          if (currentPageIndex > 0)
            SecondaryButton(
              labelKey: 'Previous',
              onPressed: _previousPage,
            ),
          if (currentPageIndex < 2)
            PrimaryButton(
              labelKey: 'Next',
              onPressed: _nextPage,
            ),
          if (currentPageIndex == 2)
            PrimaryButton(
              labelKey: 'Save',
              onPressed: () => onSave(shouldPop: true),
            ),
        ],
      ),
    );
  }

  void _previousPage() {
    onUpdateCurrentPageIndex(currentPageIndex - 1);
  }

  void _nextPage() {
    onUpdateCurrentPageIndex(currentPageIndex + 1);
  }
}
