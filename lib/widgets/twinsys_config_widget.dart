import 'package:flutter/material.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/font_setting.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:twin_app/core/session_variables.dart';

typedef OnBannerUpload = Future<twinned.ImageFileEntityRes?> Function();
typedef OnImageUpload = Future<twinned.ImageFileEntityRes?> Function();
typedef OnIconUpload = Future<twinned.ImageFileEntityRes?> Function();

class TwinSysConfigWidget extends StatefulWidget {
  final OnBannerUpload onBannerUpload;
  final OnImageUpload onImageUpload;
  final OnIconUpload onIconUpload;

  const TwinSysConfigWidget(
      {super.key,
      required this.onBannerUpload,
      required this.onImageUpload,
      required this.onIconUpload});

  @override
  State<TwinSysConfigWidget> createState() => _TwinSysConfigWidgetState();
}

class _TwinSysConfigWidgetState extends BaseState<TwinSysConfigWidget> {
  twinned.TwinSysInfo info = twinned.TwinSysInfo(
    font: 'Open Sans',
    fontSize: 14,
    fontColor: Colors.black.value,
    headerFont: 'Open Sans',
    headerFontSize: 14,
    headerFontColor: Colors.black.value,
    subHeaderFont: 'Open Sans',
    subHeaderFontSize: 14,
    subHeaderFontColor: Colors.black.value,
    menuFont: 'Open Sans',
    menuFontSize: 14,
    menuFontColor: Colors.black.value,
    toolFont: 'Open Sans',
    toolFontSize: 14,
    toolFontColor: Colors.black.value,
    labelFont: 'Open Sans',
    labelFontSize: 14,
    labelFontColor: Colors.black.value,
    enforceRoles: false,
    autoApproveSelfRegistration: true,
    enableSelfRegistration: true,
    selfRegistrationDomain: '',
    labelIconColor: Colors.black.value,
    toolIconColor: Colors.black.value,
    bannerImage: '',
    logoImage: '',
    landingPages: [],
  );
  Widget? banner;
  Widget? logo;

  final TextEditingController _domainController = TextEditingController();

  @override
  void setup() async {
    await _load();
  }

  Future _load() async {
    if (loading) return;

    loading = true;

    await execute(() async {
      var res = await TwinnedSession.instance.twin
          .getTwinSysConfig(apikey: TwinnedSession.instance.authToken);
      if (validateResponse(res)) {
        info = res.body!.entity!;

        if (info.bannerImage!.isNotEmpty) {
          banner = TwinImageHelper.getCachedDomainImage(info.bannerImage!);
        }

        if (info.logoImage!.isNotEmpty) {
          logo = TwinImageHelper.getCachedDomainImage(info.logoImage!);
        }

        setState(() {});
      }
    });

    loading = false;
  }

  Future _uploadBanner() async {
    if (loading) return;

    loading = true;

    await execute(() async {
      var res = await widget.onBannerUpload();
      if (null != res) {
        setState(() {
          info = info.copyWith(bannerImage: res.entity!.id);
          banner = TwinImageHelper.getCachedDomainImage(info.bannerImage!);
        });
        await alert(
          'Banner',
          'Updated successfully',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
      }
    });

    loading = false;
  }

  Future _uploadLogo() async {
    if (loading) return;

    loading = true;

    await execute(() async {
      var res = await widget.onImageUpload();
      if (null != res) {
        setState(() {
          info = info.copyWith(logoImage: res.entity!.id);
          logo = TwinImageHelper.getCachedDomainImage(info.logoImage!);
        });
        await alert(
          'Logo',
          'Updated successfully',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
      }
    });

    loading = false;
  }

  Future _save({bool close = false}) async {
    if (loading) return;

    loading = true;

    await execute(() async {
      var res = await TwinnedSession.instance.twin.upsertTwinConfig(
          apikey: TwinnedSession.instance.authToken, body: info);
      if (validateResponse(res)) {
        await alert(
          'Twin Settings',
          'Updated successfully',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
        if (close) {
          // _close();
        }
      }
    });

    loading = false;
    refresh();
  }

  void _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      FontSettingWidget(
          title: 'Header Font',
          font: info.headerFont!,
          fontSize: info.headerFontSize!,
          fontColor: info.headerFontColor!,
          onFontPicked: (String font) {
            setState(() {
              info = info.copyWith(headerFont: font);
            });
          },
          onFontSizePicked: (double fontSize) {
            setState(() {
              info = info.copyWith(headerFontSize: fontSize);
            });
          },
          onFontColorPicked: (int fontColor) {
            setState(() {
              info = info.copyWith(headerFontColor: fontColor);
            });
          }),
      FontSettingWidget(
          title: 'Sub Header Font',
          font: info.subHeaderFont!,
          fontSize: info.subHeaderFontSize!,
          fontColor: info.subHeaderFontColor!,
          onFontPicked: (String font) {
            setState(() {
              info = info.copyWith(subHeaderFont: font);
            });
          },
          onFontSizePicked: (double fontSize) {
            setState(() {
              info = info.copyWith(subHeaderFontSize: fontSize);
            });
          },
          onFontColorPicked: (int fontColor) {
            setState(() {
              info = info.copyWith(subHeaderFontColor: fontColor);
            });
          }),
      FontSettingWidget(
          title: 'General Font',
          font: info.font!,
          fontSize: info.fontSize!,
          fontColor: info.fontColor!,
          onFontPicked: (String font) {
            setState(() {
              info = info.copyWith(font: font);
            });
          },
          onFontSizePicked: (double fontSize) {
            setState(() {
              info = info.copyWith(fontSize: fontSize);
            });
          },
          onFontColorPicked: (int fontColor) {
            setState(() {
              info = info.copyWith(fontColor: fontColor);
            });
          }),
      FontSettingWidget(
          title: 'Menu Font',
          font: info.menuFont!,
          fontSize: info.menuFontSize!,
          fontColor: info.menuFontColor!,
          onFontPicked: (String font) {
            setState(() {
              info = info.copyWith(menuFont: font);
            });
          },
          onFontSizePicked: (double fontSize) {
            setState(() {
              info = info.copyWith(menuFontSize: fontSize);
            });
          },
          onFontColorPicked: (int fontColor) {
            setState(() {
              info = info.copyWith(menuFontColor: fontColor);
            });
          }),
      FontSettingWidget(
          title: 'Tool Menu Font',
          font: info.toolFont!,
          fontSize: info.toolFontSize!,
          fontColor: info.toolFontColor!,
          onFontPicked: (String font) {
            setState(() {
              info = info.copyWith(toolFont: font);
            });
          },
          onFontSizePicked: (double fontSize) {
            setState(() {
              info = info.copyWith(toolFontSize: fontSize);
            });
          },
          onFontColorPicked: (int fontColor) {
            setState(() {
              info = info.copyWith(toolFontColor: fontColor);
            });
          }),
      FontSettingWidget(
          title: 'Label Font',
          font: info.labelFont!,
          fontSize: info.labelFontSize!,
          fontColor: info.labelFontColor!,
          onFontPicked: (String font) {
            setState(() {
              info = info.copyWith(labelFont: font);
            });
          },
          onFontSizePicked: (double fontSize) {
            setState(() {
              info = info.copyWith(labelFontSize: fontSize);
            });
          },
          onFontColorPicked: (int fontColor) {
            setState(() {
              info = info.copyWith(labelFontColor: fontColor);
            });
          }),
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Fonts',
                style: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            divider(),
            SizedBox(
              height: 250,
              child: Center(
                child: ListView.builder(
                    itemCount: widgets.length,
                    itemBuilder: (BuildContext context, int index) {
                      return widgets[index];
                    }),
              ),
            ),
            divider(),
            Wrap(spacing: 5.0, children: [
              Tooltip(
                message:
                    'Once enabled, you can assign roles to assets, users belongs to that roles can see them',
                child: IntrinsicWidth(
                  child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        'Enforce Roles',
                        style: theme.getStyle(),
                      ),
                      value: info.enforceRoles ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          info = info.copyWith(enforceRoles: value ?? false);
                        });
                      }),
                ),
              ),
              Tooltip(
                message:
                    'Once enabled, you can partition the assets with different clients, users belongs to that client can see them',
                child: IntrinsicWidth(
                  child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        'Enforce Clients',
                        style: theme.getStyle(),
                      ),
                      value: info.enforceClient ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          info = info.copyWith(enforceClient: value ?? false);
                        });
                      }),
                ),
              ),
              Tooltip(
                message: 'Allow users to register to your application',
                child: IntrinsicWidth(
                  child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        'Self Registration',
                        style: theme.getStyle(),
                      ),
                      value: info.enableSelfRegistration ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          info = info.copyWith(
                              enableSelfRegistration: value ?? false);
                        });
                      }),
                ),
              ),
              Tooltip(
                message:
                    'Use my menu group\'s first menu as default landing page',
                child: IntrinsicWidth(
                  child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        'Menu as Landing',
                        style: theme.getStyle(),
                      ),
                      value: info.useMenuAsLanding ?? true,
                      onChanged: (bool? value) {
                        setState(() {
                          info =
                              info.copyWith(useMenuAsLanding: value ?? false);
                        });
                      }),
                ),
              ),
              Tooltip(
                message: 'Automatically approve self registrations',
                child: IntrinsicWidth(
                  child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        'Auto Approve',
                        style: theme.getStyle(),
                      ),
                      value: info.autoApproveSelfRegistration ?? true,
                      onChanged: (bool? value) {
                        setState(() {
                          setState(() {
                            info = info.copyWith(
                                autoApproveSelfRegistration: value ?? false);
                          });
                        });
                      }),
                ),
              ),
              Tooltip(
                message:
                    'Only allow users belongs to this domain to self register',
                child: IntrinsicWidth(
                  child: TextFormField(
                      controller: _domainController,
                      keyboardType: TextInputType.text,
                      style: theme.getStyle().copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                      decoration: InputDecoration(
                        hintStyle: theme.getStyle(),
                        hintText: 'Restrict Email Domain',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 5,
                        ),
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                      )),
                ),
              ),
            ]),
            divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Banner',
                style: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            divider(),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  if (null == banner)
                    Container(
                      color: Colors.grey,
                    ),
                  if (null != banner) banner!,
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () async {
                            await _uploadBanner();
                            if (info.bannerImage!.isNotEmpty) {
                              _save();
                            }
                          },
                          icon: const Icon(Icons.upload)))
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Logo',
                style: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 200,
                width: 200,
                child: Stack(
                  children: [
                    if (null == logo)
                      Container(
                        color: Colors.grey,
                      ),
                    if (null != logo) logo!,
                    Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () async {
                              await _uploadLogo();
                              if (info.logoImage!.isNotEmpty) {
                                _save();
                              }
                            },
                            icon: const Icon(Icons.upload)))
                  ],
                ),
              ),
            ),
            divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const BusyIndicator(),
                divider(horizontal: true),
                PrimaryButton(
                  labelKey: "Save",
                  onPressed: () async {
                    await _save(close: true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
