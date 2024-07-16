import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';

class CreateEditConditionSnippet extends StatefulWidget {
  const CreateEditConditionSnippet({super.key});

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
  List<String> deviceModelList = <String>[
    'Genset',
    'Tank Monitor',
    'AC',
    'Chiller',
    'Boiler'
  ];
  late String deviceModelValue;
  List<String> operatorsList = <String>[
    '==',
    '>',
    '>=',
    '<',
    '<=',
    '!=',
    'BETWEEN',
    'NOT BETWEEN',
    'CONTAINS',
    'NOT CONTAINS',
  ];
  late String operatorValue;
  List<String> paramList = <String>[
    'rpm',
    'fuel',
    'temperature',
    'pressure',
    'power_level',
  ];
  late String paramValue;
  TextEditingController _valueController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _leftValueController = TextEditingController();
  TextEditingController _rightValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    deviceModelValue = deviceModelList.first;
    operatorValue = operatorsList.first;
    paramValue = paramList.first;
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
    _valueController.dispose();
    _nameController.dispose();
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
            child: DropdownMenu<String>(
              initialSelection: deviceModelList.first,
              onSelected: (String? value) {
                setState(() {
                  deviceModelValue = value!;
                });
              },
              dropdownMenuEntries: deviceModelList
                  .map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
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
            child: DropdownMenu<String>(
              initialSelection: paramList.first,
              onSelected: (String? value) {
                setState(() {
                  paramValue = value!;
                });
              },
              dropdownMenuEntries:
                  paramList.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: DropdownMenu<String>(
              initialSelection: operatorsList.first,
              onSelected: (String? value) {
                setState(() {
                  operatorValue = value!;
                });
              },
              dropdownMenuEntries:
                  operatorsList.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
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
          if (!(operatorValue == 'BETWEEN' ||
              operatorValue == 'NOT BETWEEN' ||
              operatorValue == 'CONTAINS' ||
              operatorValue == 'NOT CONTAINS'))
            SizedBox(
              width: 150,
              child: LabelTextField(
                label: 'Enter Value',
                controller: _valueController,
              ),
            ),
          if (operatorValue == 'BETWEEN' ||
              operatorValue == 'NOT BETWEEN' ||
              operatorValue == 'CONTAINS' ||
              operatorValue == 'NOT CONTAINS')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: LabelTextField(
                    label: 'Enter Left Value',
                    controller: _leftValueController,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: LabelTextField(
                    label: 'Enter Right Value',
                    controller: _rightValueController,
                  ),
                ),
              ],
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

  @override
  void setup() {
    // TODO: implement setup
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;

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
            onPressed: _cancel,
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
              onPressed: _save,
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

  void _cancel() {
    // Implement cancel logic
  }

  void _save() {
    // Implement save logic
  }
}
