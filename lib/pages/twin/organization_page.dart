import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/custom_settings_dropdown.dart';
import 'package:twin_app/pages/twin/components/widgets/showoverlay_widget.dart';
import 'package:twin_app/pages/twin/components/widgets/single_value_input.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_app/widgets/purchase_change_addon_widget.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;
import 'package:nocode_api/api/nocode.swagger.dart' as nocode;

class OrganizationPage extends StatefulWidget {
  final tapi.OrgInfo orgInfo;

  const OrganizationPage({
    super.key,
    required this.orgInfo,
  });

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends BaseState<OrganizationPage> {
  nocode.Organization? _organization;
  tapi.TwinSysInfo? _twinSysInfo;

  @override
  Widget build(BuildContext context) {
    if (null == _organization || null == _twinSysInfo) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Loading...',
              style: theme.getStyle(),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Card(
                  elevation: 5,
                  child: Stack(
                    children: [
                      if (_organization?.icon?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 30, 10, 10),
                          child: TwinImageHelper.getDomainImage(
                              _organization!.icon!),
                        ),
                      Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              onPressed: () {}, icon: Icon(Icons.upload))),
                    ],
                  ),
                ),
              ),
            ),
            divider(horizontal: true),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _organization!.name,
                      style: theme
                          .getStyle()
                          .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(onPressed: _editName, icon: Icon(Icons.edit)),
                  ],
                ),
                divider(),
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _organization!.description ?? '',
                      style: theme
                          .getStyle()
                          .copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: _editDescription, icon: Icon(Icons.edit)),
                  ],
                ),
              ],
            ),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const BusyIndicator(),
            divider(horizontal: true),
            PrimaryButton(
              labelKey: 'Email API',
              leading: Icon(Icons.email, color: Colors.white),
              onPressed: _editEmailApi,
            ),
            divider(horizontal: true),
            PrimaryButton(
              labelKey: 'Sms API',
              leading: Icon(Icons.sms, color: Colors.white),
              onPressed: _editSmsApi,
            ),
            divider(horizontal: true),
            PrimaryButton(
              labelKey: 'Voicemail API',
              leading: Icon(Icons.voicemail, color: Colors.white),
              onPressed: _editVoiceApi,
            ),
            divider(horizontal: true),
          ],
        ),
        divider(height: 50),
        Flexible(
            child: SingleChildScrollView(
                child: Wrap(
          spacing: 15,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Card(
                color: Colors.white,
                elevation: 10,
                child: InkWell(
                  onDoubleTap: () {},
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: FaIcon(FontAwesomeIcons.appStoreIos),
                      ),
                      Center(
                        child: Text(
                          'IoS App',
                          style: theme.getStyle().copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: Card(
                color: Colors.white,
                elevation: 10,
                child: InkWell(
                  onDoubleTap: () {},
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: FaIcon(FontAwesomeIcons.android),
                      ),
                      Center(
                        child: Text(
                          'Android App',
                          style: theme.getStyle().copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: Card(
                color: Colors.white,
                elevation: 10,
                child: InkWell(
                  onDoubleTap: () {},
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: FaIcon(FontAwesomeIcons.apple),
                      ),
                      Center(
                        child: Text(
                          'MacOS App',
                          style: theme.getStyle().copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: Card(
                color: Colors.white,
                elevation: 10,
                child: InkWell(
                  onDoubleTap: () {},
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: FaIcon(FontAwesomeIcons.microsoft),
                      ),
                      Center(
                        child: Text(
                          'Windows App',
                          style: theme.getStyle().copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: Card(
                color: Colors.white,
                elevation: 10,
                child: InkWell(
                  onDoubleTap: () {},
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: FaIcon(FontAwesomeIcons.linux),
                      ),
                      Center(
                        child: Text(
                          'Linux App',
                          style: theme.getStyle().copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: Card(
                color: Colors.white,
                elevation: 10,
                child: InkWell(
                  onDoubleTap: () {},
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: FaIcon(FontAwesomeIcons.chrome),
                      ),
                      Center(
                        child: Text(
                          'Browser App',
                          style: theme.getStyle().copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ))),
      ],
    );
  }

  nocode.OrganizationInfo getInfo() {
    nocode.Organization o = _organization!;
    return nocode.OrganizationInfo(
      name: o.name,
      currency: o.currency,
      address: o.address,
      email: o.email,
      phone: o.phone,
      icon: o.icon,
      description: o.description,
      landscapeBanner: o.landscapeBanner,
      logo: o.logo,
      portraitBanner: o.portraitBanner,
      settings: o.settings,
      website: o.website,
    );
  }

  Future _editName() async {
    super.alertDialog(
        height: 150,
        title: 'Edit Organization',
        body: SingleValueInput(
            value: _organization!.name,
            label: 'Name',
            onChanged: (value) async {
              await execute(() async {
                var res =
                    await TwinnedSession.instance.nocode.updateOrganization(
                  token: TwinnedSession.instance.noCodeAuthToken,
                  orgId: _organization!.id,
                  body: getInfo().copyWith(name: value),
                );
                if (validateResponse(res)) {
                  alert('Organization', 'Updated successfully');
                  _load();
                }
              });
            }));
  }

  Future _editDescription() async {
    super.alertDialog(
        height: 150,
        title: 'Edit Organization',
        body: SingleValueInput(
            value: _organization!.description,
            label: 'Description',
            onChanged: (value) async {
              await execute(() async {
                var res =
                    await TwinnedSession.instance.nocode.updateOrganization(
                  token: TwinnedSession.instance.noCodeAuthToken,
                  orgId: _organization!.id,
                  body: getInfo().copyWith(description: value),
                );
                if (validateResponse(res)) {
                  alert('Organization', 'Updated successfully');
                  _load();
                }
              });
            }));
  }

  Future _editEmailApi() async {
    super.alertDialog(
        height: 150,
        title: 'Email Api',
        body: SingleValueInput(
            value: _twinSysInfo!.pulseEmailKey,
            label: 'Pulse Key',
            onChanged: (value) async {
              await execute(() async {
                var res = await TwinnedSession.instance.twin.upsertTwinConfig(
                    apikey: widget.orgInfo.twinAuthToken,
                    body: _twinSysInfo!.copyWith(pulseEmailKey: value));
                if (validateResponse(res)) {
                  alert('Email Api', 'Updated successfully');
                  _load();
                }
              });
            }));
  }

  Future _editSmsApi() async {
    super.alertDialog(
        height: 150,
        title: 'SMS Api',
        body: SingleValueInput(
            value: _twinSysInfo!.pulseSmsKey,
            label: 'Pulse Key',
            onChanged: (value) async {
              await execute(() async {
                var res = await TwinnedSession.instance.twin.upsertTwinConfig(
                    apikey: widget.orgInfo.twinAuthToken,
                    body: _twinSysInfo!.copyWith(pulseSmsKey: value));
                if (validateResponse(res)) {
                  alert('SMS Api', 'Updated successfully');
                  _load();
                }
              });
            }));
  }

  Future _editVoiceApi() async {
    super.alertDialog(
        height: 150,
        title: 'Voicemail Api',
        body: SingleValueInput(
            value: _twinSysInfo!.pulseVoiceKey,
            label: 'Pulse Key',
            onChanged: (value) async {
              await execute(() async {
                var res = await TwinnedSession.instance.twin.upsertTwinConfig(
                    apikey: widget.orgInfo.twinAuthToken,
                    body: _twinSysInfo!.copyWith(pulseVoiceKey: value));
                if (validateResponse(res)) {
                  alert('Voicemail Api', 'Updated successfully');
                  _load();
                }
              });
            }));
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      var res = await TwinnedSession.instance.nocode.getOrganization(
          token: TwinnedSession.instance.noCodeAuthToken,
          orgId: widget.orgInfo.id);
      if (validateResponse(res)) {
        refresh(sync: () {
          _organization = res.body!.entity;
        });
      }

      var cRes = await TwinnedSession.instance.twin
          .getTwinSysConfig(apikey: widget.orgInfo.twinAuthToken);
      if (validateResponse(cRes)) {
        refresh(sync: () {
          _twinSysInfo = cRes.body!.entity;
        });
      }
    });
    loading = false;
  }

  @override
  void setup() {
    _load();
  }
}
