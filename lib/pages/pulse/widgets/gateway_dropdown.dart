import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;

typedef OnGatewaySelected = void Function(pulse.Gateway? gateway);

class GatewayDropdown extends StatefulWidget {
  final String? selectedItem;
  final OnGatewaySelected onGatewaySelected;

  const GatewayDropdown({
    super.key,
    required this.selectedItem,
    required this.onGatewaySelected,
  });

  @override
  State<GatewayDropdown> createState() => _GatewayDropdownState();
}

class _GatewayDropdownState extends BaseState<GatewayDropdown> {
  pulse.Gateway? _selectedItem;

  @override
  Widget build(BuildContext context) {
    var chipStyle = theme.getStyle().copyWith(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: theme.getPrimaryColor());

    return SearchChoices<pulse.Gateway>.single(
      value: _selectedItem,
      hint: 'Select Gateway',
      searchHint: 'Select Gateway',
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
        return Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              entity.name,
              style: theme
                  .getStyle()
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (entity.emailSupported ?? false)
              Chip(
                label: Text('Email', style: chipStyle),
                visualDensity: VisualDensity.compact,
                elevation: 0,
              ),
            if (entity.smsSupported ?? false)
              Chip(
                label: Text('SMS', style: chipStyle),
                visualDensity: VisualDensity.compact,
                elevation: 0,
              ),
            if (entity.voiceSupported ?? false)
              Chip(
                label: Text('Voice', style: chipStyle),
                visualDensity: VisualDensity.compact,
                elevation: 0,
              ),
            if (entity.fcmSupported ?? false)
              Chip(
                label: Text('FCM', style: chipStyle),
                visualDensity: VisualDensity.compact,
                elevation: 0,
              ),
            if (entity.whatsappSupported ?? false)
              Chip(
                label: Text('Whatsapp', style: chipStyle),
                visualDensity: VisualDensity.compact,
                elevation: 0,
              ),
            if (entity.webTrafficSupported ?? false)
              Chip(
                label: Text('Web Traffic', style: chipStyle),
                visualDensity: VisualDensity.compact,
                elevation: 0,
              ),
            if (entity.geocodingSupported ?? false)
              Chip(
                label: Text('Geocoding', style: chipStyle),
                visualDensity: VisualDensity.compact,
                elevation: 0,
              ),
            if (entity.reverseGeocodingSupported ?? false)
              Chip(
                label: Text('Reverse Geocoding', style: chipStyle),
                visualDensity: VisualDensity.compact,
                elevation: 0,
              ),
            if (entity.offlineNotificationSupported ?? false)
              Chip(
                label: Text('Digital Twin', style: chipStyle),
                visualDensity: VisualDensity.compact,
                elevation: 0,
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
    var chipStyle = theme.getStyle().copyWith(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: theme.getPrimaryColor());

    try {
      var pRes = await TwinnedSession.instance.pulseAdmin.searchGateway(
          apikey: TwinnedSession.instance.authToken,
          body: pulse.SearchReq(search: search, page: page ?? 0, size: 25));
      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedItem) {
            _selectedItem = entity;
          }
          items.add(DropdownMenuItem<pulse.Gateway>(
              value: entity,
              child: Wrap(
                spacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    entity.name,
                    style: theme
                        .getStyle()
                        .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (entity.emailSupported ?? false)
                    Chip(
                      label: Text('Email', style: chipStyle),
                      visualDensity: VisualDensity.compact,
                      elevation: 0,
                    ),
                  if (entity.smsSupported ?? false)
                    Chip(
                      label: Text('SMS', style: chipStyle),
                      visualDensity: VisualDensity.compact,
                      elevation: 0,
                    ),
                  if (entity.voiceSupported ?? false)
                    Chip(
                      label: Text('Voice', style: chipStyle),
                      visualDensity: VisualDensity.compact,
                      elevation: 0,
                    ),
                  if (entity.fcmSupported ?? false)
                    Chip(
                      label: Text('FCM', style: chipStyle),
                      visualDensity: VisualDensity.compact,
                      elevation: 0,
                    ),
                  if (entity.whatsappSupported ?? false)
                    Chip(
                      label: Text('Whatsapp', style: chipStyle),
                      visualDensity: VisualDensity.compact,
                      elevation: 0,
                    ),
                  if (entity.webTrafficSupported ?? false)
                    Chip(
                      label: Text('Web Traffic', style: chipStyle),
                      visualDensity: VisualDensity.compact,
                      elevation: 0,
                    ),
                  if (entity.geocodingSupported ?? false)
                    Chip(
                      label: Text('Geocoding', style: chipStyle),
                      visualDensity: VisualDensity.compact,
                      elevation: 0,
                    ),
                  if (entity.reverseGeocodingSupported ?? false)
                    Chip(
                      label: Text('Reverse Geocoding', style: chipStyle),
                      visualDensity: VisualDensity.compact,
                      elevation: 0,
                    ),
                  if (entity.offlineNotificationSupported ?? false)
                    Chip(
                      label: Text('Digital Twin', style: chipStyle),
                      visualDensity: VisualDensity.compact,
                      elevation: 0,
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
          _selectedItem = eRes.body!.entity;
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
