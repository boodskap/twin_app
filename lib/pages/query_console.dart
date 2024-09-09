import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  TextEditingController _queryController = TextEditingController(text: '');
  TextEditingController _searchController =
      TextEditingController(text: '/_search');
  bool apiLoadingStatus = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Column(
          children: [
            divider(),
            Padding(
              padding: const EdgeInsets.only(right: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap: () {
                        _resetFields();
                      },
                      child: Icon(Icons.refresh,
                          color: loading ? theme.getPrimaryColor() : null)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: isMsgSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            isMsgSelected = value!;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 1, right: 2),
                        child: Text("Message"),
                      ),
                      hdivider,
                      SizedBox(
                        width: 120,
                        height: 42,
                        child: DropdownButtonFormField2<String>(
                          value: protocolType,
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              protocolType = newValue!;
                            });
                          },
                          items: <String>['POST', 'GET', 'DELETE']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
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
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a type'
                              : null,
                        ),
                      ),
                      hdivider,
                      SizedBox(
                        width: 150,
                        height: 42,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: '',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value.trim() != "") {
                                extraPathType = value;
                              } else {
                                extraPathType = '/_search';
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  hdivider,
                  PrimaryButton(
                    labelKey: apiLoadingStatus ? "Executing..." : "Execute",
                    onPressed: apiLoadingStatus
                        ? null
                        : () {
                            if (queryObject is! Map<String, dynamic> ||
                                queryObject is String ||
                                queryObject == "") {
                              alert('Warning', 'Invalid JSON format');
                            } else {
                              setState(() {
                                apiLoadingStatus = true;
                              });
                              _executeQuery();
                            }
                          },
                  ),
                ],
              ),
            ),
            Expanded(
                child: QueryContentSection(
              onQueryChanged: (String value) {
                setState(() {
                  queryObject = jsonDecode(value) as Map<String, dynamic>;
                });
              },
              jsonStringData: jsonStringData,
              queryController: _queryController,
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
          eql: GenericQueryReq(
              eql: queryObject,
              isMessage: isMsgSelected,
              extraPath: extraPathType));
      if (validateResponse(cRes)) {
        var result = cRes.body!.result;
        jsonStringData = jsonEncode(result);
      }
    });

    loading = false;
    apiLoadingStatus = false;
    refresh();
  }

  void _resetFields() {
    setState(() {
      _queryController.text = '';
      jsonStringData = '{}';
      isMsgSelected = false;
      protocolType = 'POST';
      _searchController.text = '/_search';
      queryObject = '';
    });
  }

  @override
  void setup() {}

  @override
  void dispose() {
    _queryController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class QueryContentSection extends StatefulWidget {
  final ValueChanged<String> onQueryChanged;
  final String jsonStringData;
  final TextEditingController queryController;

  QueryContentSection({
    required this.onQueryChanged,
    required this.jsonStringData,
    required this.queryController,
  });
  @override
  QueryContentSectionState createState() => QueryContentSectionState();
}

// class QueryContentSectionState extends BaseState<QueryContentSection> {
//   late TextEditingController _controller;
//   double jsonTextFontSize = 13;
//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(
//       text: '{}',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 5),
//             TextField(
//               controller: widget.queryController,
//               maxLines: null,
//               minLines: 4,
//               keyboardType: TextInputType.multiline,
//               decoration: InputDecoration(
//                 labelText: 'Query',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (String value) {
//                 widget.onQueryChanged(value);
//               },
//             ),
//             divider(),
//             JsonView.string(
//               widget.jsonStringData,
//               theme: JsonViewTheme(
//                   keyStyle: TextStyle(
//                       color: Colors.white, fontSize: jsonTextFontSize),
//                   doubleStyle:
//                       TextStyle(color: Colors.red, fontSize: jsonTextFontSize),
//                   intStyle:
//                       TextStyle(color: Colors.red, fontSize: jsonTextFontSize),
//                   boolStyle: TextStyle(
//                       color: Colors.orange, fontSize: jsonTextFontSize),
//                   stringStyle: TextStyle(
//                       color: Colors.green, fontSize: jsonTextFontSize),
//                   viewType: JsonViewType.collapsible),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   void setup() {}
// }

//////////-
// class QueryContentSectionState extends BaseState<QueryContentSection> {
//   late TextEditingController _controller;
//   double jsonTextFontSize = 13;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(
//       text: '{}',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 5),
//             TextField(
//               controller: widget.queryController,
//               maxLines: null,
//               minLines: 4,
//               keyboardType: TextInputType.multiline,
//               decoration: InputDecoration(
//                 labelText: 'Query',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (String value) {
//                 widget.onQueryChanged(value);
//               },
//             ),
//             divider(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'JSON Result',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.copy),
//                   onPressed: () {
//                     Clipboard.setData(ClipboardData(text: widget.jsonStringData));
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Copied to clipboard')),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             JsonView.string(
//               widget.jsonStringData,
//               theme: JsonViewTheme(
//                 keyStyle: TextStyle(
//                     color: Colors.white, fontSize: jsonTextFontSize),
//                 doubleStyle: TextStyle(
//                     color: Colors.red, fontSize: jsonTextFontSize),
//                 intStyle: TextStyle(
//                     color: Colors.red, fontSize: jsonTextFontSize),
//                 boolStyle: TextStyle(
//                     color: Colors.orange, fontSize: jsonTextFontSize),
//                 stringStyle: TextStyle(
//                     color: Colors.green, fontSize: jsonTextFontSize),
//                 viewType: JsonViewType.collapsible,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   void setup() {}
// }

// class QueryContentSectionState extends BaseState<QueryContentSection> {
//   late TextEditingController _controller;
//   double jsonTextFontSize = 13;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(
//       text: '{}',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 5),
//             TextField(
//               controller: widget.queryController,
//               maxLines: null,
//               minLines: 4,
//               keyboardType: TextInputType.multiline,
//               decoration: InputDecoration(
//                 labelText: 'Query',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (String value) {
//                 widget.onQueryChanged(value);
//               },
//             ),
//             divider(),
//             Stack(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(top: 35), // adjust padding to avoid overlap with the button
//                   child: JsonView.string(
//                     widget.jsonStringData,
//                     theme: JsonViewTheme(
//                       keyStyle: TextStyle(
//                           color: Colors.white, fontSize: jsonTextFontSize),
//                       doubleStyle: TextStyle(
//                           color: Colors.red, fontSize: jsonTextFontSize),
//                       intStyle: TextStyle(
//                           color: Colors.red, fontSize: jsonTextFontSize),
//                       boolStyle: TextStyle(
//                           color: Colors.orange, fontSize: jsonTextFontSize),
//                       stringStyle: TextStyle(
//                           color: Colors.green, fontSize: jsonTextFontSize),
//                       viewType: JsonViewType.collapsible,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 20,
//                   right: 0,
//                   child: IconButton(
//                     icon: Icon(Icons.copy, color: Colors.blue),
//                     onPressed: () {
//                       Clipboard.setData(ClipboardData(text: widget.jsonStringData));
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Copied to clipboard')),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   void setup() {}
// }

class QueryContentSectionState extends BaseState<QueryContentSection> {
  late TextEditingController _controller;
  double jsonTextFontSize = 13;
  bool _showCopiedText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: '{}',
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.jsonStringData));
    setState(() {
      _showCopiedText = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showCopiedText = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            TextField(
              controller: widget.queryController,
              maxLines: null,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Query',
                border: OutlineInputBorder(),
              ),
              onChanged: (String value) {
                widget.onQueryChanged(value);
              },
            ),
            divider(),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height*0.6,
                    ),
                    child: JsonView.string(
                      widget.jsonStringData,
                      theme: JsonViewTheme(
                        keyStyle: TextStyle(
                            color: Colors.white, fontSize: jsonTextFontSize),
                        doubleStyle: TextStyle(
                            color: Colors.red, fontSize: jsonTextFontSize),
                        intStyle: TextStyle(
                            color: Colors.red, fontSize: jsonTextFontSize),
                        boolStyle: TextStyle(
                            color: Colors.orange, fontSize: jsonTextFontSize),
                        stringStyle: TextStyle(
                            color: Colors.green, fontSize: jsonTextFontSize),
                        viewType: JsonViewType.collapsible,
                      ),
                    ),
                  ),
                ),
                if(widget.jsonStringData!=""&&widget.jsonStringData!='{}'&& widget.jsonStringData.isNotEmpty)
                
                Positioned(
                  top: 10,
                  right: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: 'Copy Result',
                        child: IconButton(
                          icon: Icon(Icons.copy, color: Colors.white),
                          onPressed: _copyToClipboard,
                        ),
                      ),
                      if (_showCopiedText)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Copied',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
  void setup() {}
}
