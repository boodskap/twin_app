// import 'package:flutter/material.dart';
// import 'package:twin_commons/core/base_state.dart';
// import 'package:twinned_api/api/twinned.swagger.dart';
// import 'package:twin_commons/core/twinned_session.dart';
// import 'package:twin_app/core/session_variables.dart';

// class PreprocessorDropDown extends StatefulWidget {
//   final void Function(Preprocessor?) valueChanged;
//   final String? selected;
//   PreprocessorDropDown(
//       {Key? key, required this.valueChanged, required this.selected})
//       : super(key: key);

//   @override
//   State<PreprocessorDropDown> createState() => _PreprocessorDropDownState();
// }

// class _PreprocessorDropDownState extends BaseState<PreprocessorDropDown> {
//   final List<DropdownMenuItem<Preprocessor>> _entries = [];
//   Preprocessor? selected;

//   @override
//   void setup() async {
//     await _load();
//   }

//   Future<void> _load() async {
//     execute(() async {
//       var res = await TwinnedSession.instance.twin.searchPreprocessors(
//         apikey: TwinnedSession.instance.authToken,
//         body: const SearchReq(search: '*', page: 0, size: 10000),
//       );

//       if (validateResponse(res)) {
//         _entries.clear();

//         for (var element in res.body!.values!) {
//           DropdownMenuItem<Preprocessor> me = DropdownMenuItem(
//             value: element,
//             child: Container(
//               width: 142,
//               child: Text(
//                 element.name,
//                 style: theme.getStyle(),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           );
//           _entries.add(me);
//         }
//       }

//       if (null != selected) {
//         for (var val in _entries) {
//           if (val.value!.id == selected!.id) {
//             selected = val.value;
//             break;
//           }
//         }
//       } else if (null != widget.selected) {
//         for (var val in _entries) {
//           if (val.value!.id == widget.selected) {
//             selected = val.value;
//             break;
//           }
//         }
//       }

//       refresh();

//       widget.valueChanged(selected);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         width: 228,
//         decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(color: Colors.blueGrey),
//             borderRadius: BorderRadius.circular(5)),
//         child: Row(
//           children: [
//             Expanded(
//               child: DropdownButton<Preprocessor>(
//                 style: theme.getStyle(),
//                 padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
//                 dropdownColor: Colors.white,
//                 isDense: true,
//                 underline: Container(),
//                 hint: Text(
//                   "Select Preprocessor",
//                   style: theme.getStyle(),
//                 ),
//                 items: _entries,
//                 value: selected,
//                 onChanged: (Preprocessor? value) {
//                   setState(() {
//                     selected = value;
//                   });
//                   widget.valueChanged(value);
//                 },
//               ),
//             ),
//             if (selected != null)
//               IconButton(
//                 icon: Icon(Icons.clear, size: 18),
//                 onPressed: () {
//                   setState(() {
//                     selected = null;
//                   });
//                   widget.valueChanged(null);
//                 },
//               ),
//           ],
//         ));
//   }
// }

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart'; // Import the dropdown_button2 package
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_app/core/session_variables.dart';

class PreprocessorDropDown extends StatefulWidget {
  final void Function(Preprocessor?) valueChanged;
  final String? selected;

  PreprocessorDropDown({
    Key? key,
    required this.valueChanged,
    required this.selected,
  }) : super(key: key);

  @override
  State<PreprocessorDropDown> createState() => _PreprocessorDropDownState();
}

class _PreprocessorDropDownState extends BaseState<PreprocessorDropDown> {
  final List<DropdownMenuItem<Preprocessor>> _entries = [];
  Preprocessor? selected;

  @override
  void setup() async {
    await _load();
  }

  Future<void> _load() async {
    execute(() async {
      var res = await TwinnedSession.instance.twin.searchPreprocessors(
        apikey: TwinnedSession.instance.authToken,
        body: const SearchReq(search: '*', page: 0, size: 10000),
      );

      if (validateResponse(res)) {
        _entries.clear();

        for (var element in res.body!.values!) {
          DropdownMenuItem<Preprocessor> me = DropdownMenuItem(
            value: element,
            child: Container(
              width: 142,
              child: Text(
                element.name,
                style: theme.getStyle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
          _entries.add(me);
        }
      }

      if (null != selected) {
        for (var val in _entries) {
          if (val.value!.id == selected!.id) {
            selected = val.value;
            break;
          }
        }
      } else if (null != widget.selected) {
        for (var val in _entries) {
          if (val.value!.id == widget.selected) {
            selected = val.value;
            break;
          }
        }
      }

      refresh();
      widget.valueChanged(selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 228,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<Preprocessor>(
                isExpanded: true,
                hint: Text(
                  "Select Preprocessor",
                  style: theme.getStyle(),
                ),
                items: _entries.map((item) {
                  return DropdownMenuItem<Preprocessor>(
                    value: item.value,
                    child: item.child,
                  );
                }).toList(),
                value: selected,
                onChanged: (Preprocessor? value) {
                  setState(() {
                    selected = value;
                  });
                  widget.valueChanged(value);
                },
                buttonStyleData: ButtonStyleData(
             padding: const EdgeInsets.symmetric(horizontal: 8.0),
            
                ),
                dropdownStyleData: DropdownStyleData(
                  padding: EdgeInsets.all(0),
                  width: 228,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  offset: const Offset(0, 0),
                ),
                
              ),
            ),
          ),
          if (selected != null)
            IconButton(
              icon: Icon(Icons.clear, size: 18),
              onPressed: () {
                setState(() {
                  selected = null;
                });
                widget.valueChanged(null);
              },
            ),
        ],
      ),
    );
  }
}
