import 'package:flutter/material.dart';
import 'package:twin_commons/core/twinned_session.dart';

import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class RolesInfrastructeWidget extends StatefulWidget {
  final List<String> currentRoles;
  final void Function(List<String>) valueChanged;
  final void Function(List<String>) saveConfirm;
  bool isSave;

  double iconSize;
  RolesInfrastructeWidget(
      {Key? key,
      required this.valueChanged,
      required this.currentRoles,
      this.iconSize = 28,
      required this.saveConfirm,
      this.isSave = false})
      : super(key: key);

  @override
  State<RolesInfrastructeWidget> createState() =>
      _RolesInfrastructeWidgetState();
}

class _RolesInfrastructeWidgetState extends BaseState<RolesInfrastructeWidget> {
  List<String> selectedOptions = [];
  List<String> options = [];
  final List<Role> _entities = [];

  @override
  void setup() async {
    await _loadroles();
  }

  Future<void> _loadroles() async {
    try {
      var res = await TwinnedSession.instance.twin.listRoles(
        apikey: TwinnedSession.instance.authToken,
        body: const ListReq(page: 0, size: 10000),
      );

      if (validateResponse(res)) {
        for (Role r in res.body!.values!) {
          _entities.add(r);
          options.add(r.name);
        }
      }
    } catch (e, x) {
      debugPrint('$e\n$x');
    }
  }

  @override
  Widget build(BuildContext context) {
    selectedOptions = widget.currentRoles;
    return IconButton(
      icon: Icon(Icons.manage_accounts),
      onPressed: () {
        _showOptionsDialog(context);
      },
      iconSize: widget.iconSize,
      color: Colors.black,
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _entities.isNotEmpty
            ? AlertDialog(
                title: Text('Select Roles'),
                content: SingleChildScrollView(
                  child: Column(
                    children: _entities.map((option) {
                      bool isSelected = widget.currentRoles.contains(option.id);
                      return OptionCheckbox(
                        option: option.name,
                        isSelected: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value) {
                              selectedOptions.add(option.id);
                            } else {
                              selectedOptions.remove(option.id);
                            }
                          });
                          widget.valueChanged(selectedOptions);
                        },
                      );
                    }).toList(),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                  if (widget.isSave) ...[
                    SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        widget.saveConfirm(selectedOptions);
                      },
                      child: const Text('Save'),
                    ),
                  ]
                ],
              )
            : AlertDialog(
                content: const SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Center(child: Text("No Roles Found")),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
      },
    );
  }
}

class OptionCheckbox extends StatefulWidget {
  final String option;
  final bool isSelected;
  final ValueChanged<bool>? onChanged;

  const OptionCheckbox({
    required this.option,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  _OptionCheckboxState createState() => _OptionCheckboxState();
}

class _OptionCheckboxState extends State<OptionCheckbox> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.option),
      value: _isSelected,
      onChanged: (value) {
        setState(() {
          _isSelected = value!;
        });
        widget.onChanged!(value!);
      },
    );
  }
}
