import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/twinned_session.dart';

const hdivider = SizedBox(width: 5);

class QueryConsole extends StatefulWidget {
  const QueryConsole({super.key});

  @override
  State<QueryConsole> createState() => _QueryConsoleState();
}

class _QueryConsoleState extends BaseState<QueryConsole> {
  bool isMsgSelected = false;
  String protocolType = 'POST';
  String extraPathType = '/_search';
  Object queryObject = {};
  String jsonStringData = '{}';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                    onTap: () {
                      // _load();
                    },
                    child: Icon(Icons.refresh,
                        color: loading ? theme.getPrimaryColor() : null)),
                QueryHeaderSection(
                  onMessageCheckedChanged: (bool value) {
                    setState(() {
                      isMsgSelected = value;
                    });
                  },
                  onProtocolChanged: (String value) {
                    setState(() {
                      protocolType = value;
                    });
                  },
                  onSearchTextChanged: (String value) {
                    setState(() {
                      extraPathType = value;
                    });
                  },
                ),
                hdivider,
                PrimaryButton(
                  labelKey: "Execute",
                  onPressed: () {
                    _executeQuery();
                  },
                ),
              ],
            ),
            Expanded(child: QueryContentSection(
              onQueryChanged: (Object value) {
                setState(() {
                  queryObject = value;
                });
              }, jsonStringData: jsonStringData,
            ))
          ],
        ),
      ),
    );
  }

  Future _executeQuery() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      var cRes = await TwinnedSession.instance.twin.queryGeneric(
          apikey: TwinnedSession.instance.authToken,
          eql: GenericQueryReq(eql: {},isMessage: isMsgSelected,extraPath: extraPathType));
      if (validateResponse(cRes)) {
        var result = cRes.body!.result;
         jsonStringData = jsonEncode(result);
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {

  }
}

class QueryHeaderSection extends StatefulWidget {
  final ValueChanged<bool> onMessageCheckedChanged;
  final ValueChanged<String> onProtocolChanged;
  final ValueChanged<String> onSearchTextChanged;

  QueryHeaderSection({
    required this.onMessageCheckedChanged,
    required this.onProtocolChanged,
    required this.onSearchTextChanged,
  });
  @override
  _QueryHeaderSectionState createState() => _QueryHeaderSectionState();
}

class _QueryHeaderSectionState extends State<QueryHeaderSection> {
  bool _isMsgChecked = false;
  String _seletedProtocol = 'POST';
  TextEditingController _searchController =
      TextEditingController(text: '/_search');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: _isMsgChecked,
          onChanged: (bool? value) {
            setState(() {
              _isMsgChecked = value!;
            });
            widget.onMessageCheckedChanged(_isMsgChecked);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 1, right: 2),
          child: Text("Message"),
        ),
        hdivider,
        SizedBox(
          width: 120,
          child: DropdownButtonFormField2<String>(
            value: _seletedProtocol,
            isExpanded: true,
            onChanged: (newValue) {
              setState(() {
                _seletedProtocol = newValue!;
              });
              widget.onProtocolChanged(_seletedProtocol);
            },
            items: <String>['POST', 'GET', 'DELETE'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder()),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              offset: const Offset(0, 0),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please select a type' : null,
          ),
        ),
        hdivider,
        SizedBox(
          width: 150,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: '',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              widget.onSearchTextChanged(value);
            },
          ),
        ),
      ],
    );
  }
}

class QueryContentSection extends StatefulWidget {
  final ValueChanged<Object> onQueryChanged;
  final String jsonStringData;

  QueryContentSection({
    required this.onQueryChanged, required this.jsonStringData,
  });
  @override
  QueryContentSectionState createState() => QueryContentSectionState();
}

class QueryContentSectionState extends BaseState<QueryContentSection> {
  late TextEditingController _controller;
  double jsonTextFontSize = 13;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: '{}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Edit JSON',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                widget.onQueryChanged(_controller.text);
              },
            ),
            divider(),
           
            JsonView.string(
              widget.jsonStringData,
              theme: JsonViewTheme(
                  keyStyle: TextStyle(
                      color: Colors.white, fontSize: jsonTextFontSize),
                  doubleStyle:
                      TextStyle(color: Colors.red, fontSize: jsonTextFontSize),
                  intStyle:
                      TextStyle(color: Colors.red, fontSize: jsonTextFontSize),
                  boolStyle: TextStyle(
                      color: Colors.orange, fontSize: jsonTextFontSize),
                  stringStyle: TextStyle(
                      color: Colors.green, fontSize: jsonTextFontSize),
                  viewType: JsonViewType.collapsible),
            ),
          ],
        ),
      ),
    );
  }

 

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void setup() {
  }
}
