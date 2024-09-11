import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;

typedef OnVoiceGroupSelected = void Function(pulse.VoiceGroup? group);

class PulseVoiceGroupDropdown extends StatefulWidget {
  final String? selectedItem;
  final OnVoiceGroupSelected onVoiceGroupSelected;
  final TextStyle style;

  const PulseVoiceGroupDropdown({
    super.key,
    required this.selectedItem,
    required this.onVoiceGroupSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<PulseVoiceGroupDropdown> createState() =>
      _PulseVoiceGroupDropdownState();
}

class _PulseVoiceGroupDropdownState extends BaseState<PulseVoiceGroupDropdown> {
  pulse.VoiceGroup? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<pulse.VoiceGroup>.single(
      value: _selectedItem,
      hint: 'Select Email Group',
      searchHint: 'Search Email Groups',
      isExpanded: true,
      futureSearchFn: (String? keyword, String? orderBy, bool? orderAsc,
          List<Tuple2<String, String>>? filters, int? pageNb) async {
        pageNb = pageNb ?? 1;
        --pageNb;
        var result = await _search(search: keyword ?? '*', page: pageNb);
        return result;
      },
      dialogBox: true,
      dropDownDialogPadding: const EdgeInsets.fromLTRB(250, 50, 250, 50),
      selectedValueWidgetFn: (value) {
        pulse.Gateway entity = value;
        return Row(
          children: [
            Text(
              entity.name,
              style: widget.style,
            ),
          ],
        );
      },
      onChanged: (selected) {
        setState(() {
          _selectedItem = selected;
        });
        widget.onVoiceGroupSelected(_selectedItem);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<pulse.VoiceGroup>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<pulse.VoiceGroup>> items = [];
    int total = 0;
    try {
      var pRes = await TwinnedSession.instance.pulseAdmin.searchVoiceGroup(
          apikey: TwinnedSession.instance.authToken,
          body: pulse.SearchReq(search: search, page: page, size: 10));

      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedItem) {
            _selectedItem = entity;
          }
          items.add(DropdownMenuItem<pulse.VoiceGroup>(
              value: entity,
              child: Row(
                children: [
                  Text(
                    entity.name,
                    style: widget.style,
                  ),
                ],
              )));
        }

        total = pRes.body?.total ?? 0;
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    loading = false;

    return Tuple2(items, total);
  }

  Future _load() async {
    if (widget.selectedItem?.isEmpty ?? true) {
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.pulseAdmin.getVoiceGroup(
        apikey: TwinnedSession.instance.authToken,
        groupId: widget.selectedItem,
      );
      if (eRes != null && eRes.body != null) {
        setState(() {
          _selectedItem = eRes.body?.entity;
        });
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  @override
  void setup() {
    _load();
  }
}
