import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_app/core/session_variables.dart';

class PreprocessorDropDown extends StatefulWidget {
  final void Function(Preprocessor?) valueChanged;
  final String? selected;
  PreprocessorDropDown(
      {Key? key, required this.valueChanged, required this.selected})
      : super(key: key);

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
            child: Text(
              element.name,
              style: theme.getStyle(),
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
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey),
          borderRadius: BorderRadius.circular(5)),
      child: DropdownButton<Preprocessor>(
        style: theme.getStyle(),
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        dropdownColor: Colors.white,
        isDense: true,
        underline: Container(),
        hint: Text(
          "Select Preprocessor",
          style: theme.getStyle(),
        ),
        items: _entries,
        value: selected,
        onChanged: (Preprocessor? value) {
          setState(() {
            selected = value;
          });
          widget.valueChanged(value);
          //widget.onModelSelected(value);
        },
      ),
    );
  }
}
