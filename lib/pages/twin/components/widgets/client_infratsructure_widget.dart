import 'package:flutter/material.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class ClientInfrastructeWidget extends StatefulWidget {
  final List<String> currentClients;
  final void Function(List<String>) valueChanged;
  final void Function(List<String>) saveConfirm;
  bool isSave;

  double iconSize;
  ClientInfrastructeWidget(
      {Key? key,
      required this.valueChanged,
      required this.currentClients,
      this.iconSize = 28,
      required this.saveConfirm,
      this.isSave = false})
      : super(key: key);

  @override
  State<ClientInfrastructeWidget> createState() =>
      _ClientInfrastructeWidgetState();
}

class _ClientInfrastructeWidgetState
    extends BaseState<ClientInfrastructeWidget> {
  List<String> selectedOptions = [];
  List<String> options = [];
  final List<Client> _entities = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void setup() async {
    await _loadclients();
  }

  Future<void> _loadclients() async {
    try {
      var res = await TwinnedSession.instance.twin.searchClients(
        apikey: TwinnedSession.instance.authToken,
        body: const SearchReq(search: '*', page: 0, size: 10000),
      );

      if (validateResponse(res)) {
        setState(() {
          for (Client r in res.body!.values!) {
            _entities.add(r);
            options.add(r.name);
          }
        });
      }
    } catch (e, x) {
      debugPrint('$e\n$x');
    }
  }

  @override
  Widget build(BuildContext context) {
    selectedOptions = widget.currentClients;
    return IconButton(
      icon: Icon(Icons.business),
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
        return StatefulBuilder(
          builder: (context, setState) {
            return _entities.isNotEmpty
                ? AlertDialog(
                    titleTextStyle: theme.getStyle().copyWith(fontSize: 20),
                    title: Text('Select Clients'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          style: theme.getStyle(),
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintStyle: theme.getStyle(),
                            labelStyle: theme.getStyle(),
                            hintText: 'Search',
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: _buildOptions(),
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close', style: theme.getStyle()),
                      ),
                      if (widget.isSave) ...[
                        SizedBox(width: 4),
                        TextButton(
                          onPressed: () {
                            widget.saveConfirm(selectedOptions);
                          },
                          child: Text('Save', style: theme.getStyle()),
                        ),
                      ]
                    ],
                  )
                : AlertDialog(
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Center(
                              child: Text("No Clients Found",
                                  style: theme.getStyle())),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close', style: theme.getStyle()),
                      ),
                    ],
                  );
          },
        );
      },
    );
  }

  List<Widget> _buildOptions() {
    final searchTerm = _searchController.text.toLowerCase().trim();

    if (searchTerm.isEmpty) {
      final firstFiveOptions = _entities.take(5).toList();
      return firstFiveOptions.map((option) {
        bool isSelected = widget.currentClients.contains(option.id);
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
      }).toList();
    } else {
      final filteredOptions = _entities.where((client) {
        return client.name.toLowerCase().contains(searchTerm);
      }).toList();

      if (filteredOptions.isEmpty) {
        return [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No clients found', style: theme.getStyle()),
          ),
        ];
      }

      return filteredOptions.map((option) {
        bool isSelected = widget.currentClients.contains(option.id);
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
      }).toList();
    }
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
      title: Text(widget.option, style: theme.getStyle()),
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
