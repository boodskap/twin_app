import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/pulse/widgets/add_edit_gateway.dart';
import 'package:twin_app/pages/twin/components/widgets/showoverlay_widget.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;

class ManageGateways extends StatefulWidget {
  const ManageGateways({super.key});

  @override
  State<ManageGateways> createState() => _ManageGatewaysState();
}

class _ManageGatewaysState extends BaseState<ManageGateways> {
  final TextEditingController _emailApiKey = TextEditingController();
  final TextEditingController _fromEmail = TextEditingController();
  String _search = '*';
  final List<Widget> _children = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const BusyIndicator(),
            divider(horizontal: true),
            IconButton(
                onPressed: () {
                  _load();
                },
                icon: const Icon(Icons.refresh)),
            divider(horizontal: true),
            PrimaryButton(
              leading: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              labelKey: 'Add New',
              onPressed: () {
                _addNew();
              },
            ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  leading: const Icon(Icons.search),
                  hintText: 'Search Gateways',
                  onChanged: (val) {
                    _search = val.trim().isEmpty ? '*' : val.trim();
                    _load();
                  },
                )),
          ],
        ),
        divider(),
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _children,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChild(pulse.GatewayConfig entity) {
    var chipStyle = theme.getStyle().copyWith(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: theme.getPrimaryColor());

    return SizedBox(
      width: 300,
      height: 200,
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                    message: 'Edit ${entity.name}',
                    child: IconButton(
                        onPressed: () {
                          _edit(entity);
                        },
                        icon: const Icon(Icons.edit))),
                Tooltip(
                    message: 'Delete ${entity.name}',
                    child: IconButton(
                        onPressed: () {
                          _delete(entity);
                        },
                        icon: const Icon(Icons.delete))),
              ],
            ),
            divider(),
            Text(
              entity.name,
              style: theme
                  .getStyle()
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            divider(),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: LabelTextField(
                readOnlyVal: true,
                suffixIcon: Tooltip(
                  message: 'Copy Pulse Key',
                  preferBelow: false,
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: entity.pulseKey),
                      );
                      OverlayWidget.showOverlay(
                        context: context,
                        topPosition: 140,
                        leftPosition: 250,
                        message: 'Pulse Key copied!',
                      );
                    },
                    child: const Icon(
                      Icons.content_copy,
                      size: 20,
                    ),
                  ),
                ),
                label: 'Pulse Key',
                controller: TextEditingController(text: '********************'),
              ),
            ),
            divider(),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
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
            ),
          ],
        ),
      ),
    );
  }

  Future _delete(pulse.GatewayConfig config) async {
    await super.confirm(
        title: 'Delete ${config.name}',
        message: 'Are you sure to delete this gateway configuration?',
        onPressed: () async {
          await execute(() async {
            var res = await TwinnedSession.instance.pulseAdmin.deleteConfig(
                apikey: TwinnedSession.instance.authToken, configId: config.id);
            if (validateResponse(res)) {
              alert('Gateway ${config.name}', 'Deleted successfully');
            }
          });
        });
    _load();
  }

  Future _edit(pulse.GatewayConfig config) async {
    await super.alertDialog(
        title: 'Edit ${config.name}', body: AddEditGateway(config: config));
    _load();
  }

  Future _addNew() async {
    await super.alertDialog(
        title: 'Configure New Gateway', body: const AddEditGateway());
    _load();
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    _children.clear();
    refresh();
    await execute(() async {
      var res = await TwinnedSession.instance.pulseAdmin.searchConfig(
          apikey: TwinnedSession.instance.authToken,
          body: pulse.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(res)) {
        for (pulse.GatewayConfig entity in res.body?.values ?? []) {
          _children.add(_buildChild(entity));
        }
      }
    });
    loading = false;
    debugPrint('** ${_children.length} Gateways **');
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}
