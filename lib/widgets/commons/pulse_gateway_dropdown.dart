import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;

typedef OnGatewaySelected = void Function(pulse.Gateway? gateway);

class PulseGatewayDropdown extends StatefulWidget {
  final String? selectedItem;
  final OnGatewaySelected onGatewaySelected;
  final bool? emailSupported;
  final bool? smsSupported;
  final bool? voiceSupported;
  final bool? webTrafficSupported;
  final bool? fcmSupported;
  final bool? offlineNotificationSupported;
  final bool? whatsappSupported;
  final bool? geocodingSupported;
  final bool? reverseGeocodingSupported;

  final TextStyle style;

  const PulseGatewayDropdown({
    super.key,
    required this.selectedItem,
    required this.onGatewaySelected,
    this.emailSupported,
    this.smsSupported,
    this.voiceSupported,
    this.webTrafficSupported,
    this.fcmSupported,
    this.offlineNotificationSupported,
    this.whatsappSupported,
    this.geocodingSupported,
    this.reverseGeocodingSupported,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<PulseGatewayDropdown> createState() => _PulseGatewayDropdownState();
}

class _PulseGatewayDropdownState extends BaseState<PulseGatewayDropdown> {
  pulse.Gateway? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<pulse.Gateway>.single(
      value: _selectedItem,
      hint: 'Select Gateway',
      searchHint: 'Search Gateways',
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
        widget.onGatewaySelected(_selectedItem);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<pulse.Gateway>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<pulse.Gateway>> items = [];
    int total = 0;
    try {
      var pRes = await TwinnedSession.instance.pulseAdmin.queryGateway(
          apikey: TwinnedSession.instance.authToken,
          body: pulse.EqlSearch(source: [], sort: {
            "namek": "asc"
          }, mustConditions: [
            if (null != widget.emailSupported)
              {
                "match": {'emailSupported': widget.emailSupported}
              },
            if (null != widget.smsSupported)
              {
                "match": {'smsSupported': widget.smsSupported}
              },
            if (null != widget.voiceSupported)
              {
                "match": {'voiceSupported': widget.voiceSupported}
              },
            if (null != widget.webTrafficSupported)
              {
                "match": {'webTrafficSupported': widget.webTrafficSupported}
              },
            if (null != widget.offlineNotificationSupported)
              {
                "match": {
                  'offlineNotificationSupported':
                      widget.offlineNotificationSupported
                }
              },
            if (null != widget.geocodingSupported)
              {
                "match": {'geocodingSupported': widget.geocodingSupported}
              },
            if (null != widget.reverseGeocodingSupported)
              {
                "match": {
                  'reverseGeocodingSupported': widget.reverseGeocodingSupported
                }
              },
            if ('*' != search)
              {
                "query_string": {
                  "query": '*$search*',
                  "fields": ["name", "description"]
                }
              },
          ]));

      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedItem) {
            _selectedItem = entity;
          }
          items.add(DropdownMenuItem<pulse.Gateway>(
              value: entity,
              child: Row(
                children: [
                  Text(
                    '${entity.name}, ${entity.description}',
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
      var eRes = await TwinnedSession.instance.pulseAdmin.getGateway(
        apikey: TwinnedSession.instance.authToken,
        gatewayId: widget.selectedItem,
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
