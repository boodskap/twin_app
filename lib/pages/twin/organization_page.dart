import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/custom_settings_dropdown.dart';
import 'package:twin_app/pages/twin/components/widgets/showoverlay_widget.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_app/widgets/purchase_change_addon_widget.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;
import 'package:nocode_api/api/nocode.swagger.dart' as nocode;

class OrganizationPage extends StatefulWidget {
  OrganizationPage({
    super.key,
  });

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends BaseState<OrganizationPage> {
  nocode.AppProfile? appProfile;

  String customerId = "";

  final TextEditingController _appNameController = TextEditingController();
  final TextEditingController _appDescController = TextEditingController();
  final TextEditingController controller = TextEditingController();

  final TextEditingController orgFont =
      TextEditingController(text: 'Open Sans');
  final TextEditingController orgFontSize = TextEditingController(text: '0');
  final TextEditingController orgFontColor =
      TextEditingController(text: '0xFF3A3A3A');

  final TextEditingController _apikeyController = TextEditingController();
  String apikeyConfig = '';

  tapi.TwinSysInfo info = tapi.TwinSysInfo(
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

  nocode.Organization orgInfo = nocode.Organization(
    profileId: '',
    organizationState: nocode.OrganizationOrganizationState.active,
    name: '',
    id: '',
    rtype: '',
    createdBy: '',
    createdStamp: 0,
    updatedBy: '',
    updatedStamp: 0,
    domainKey: '',
  );

  @override
  void initState() {
    super.initState();
    _customerProfile();
  }

  @override
  void setup() async {
    _loadOrganizations();
    _customerProfile();
  }

  void _loadOrganizations() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var res = await TwinnedSession.instance.nocode.getOrganization(
        orgId: TwinnedSession.instance.orgId,
        token: TwinnedSession.instance.noCodeAuthToken,
      );
      if (validateResponse(res)) {
        orgInfo = res.body!.entity!;
      }
    });

    loading = false;
    refresh();
  }

  @override
  void dispose() {
    _apikeyController.dispose();
    super.dispose();
  }

  void _customerProfile() async {
    try {
      var res = await TwinnedSession.instance.nocode.getAppProfile(
        token: TwinnedSession.instance.noCodeAuthToken,
      );
      if (validateResponse(res)) {
        customerId = res.body!.profile!.settings!.stripeCustomerId!;
      }
    } catch (e) {}
  }

  Widget buildAppDetails(BuildContext context) {
    DateTime created =
        DateTime.fromMillisecondsSinceEpoch(orgInfo.createdStamp);
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 350,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Card(
                    child: Container(
                      width: 250,
                      height: 250,
                      child: Stack(
                        children: [
                          if (orgInfo.logo!.isNotEmpty)
                            Positioned.fill(
                              child: TwinImageHelper.getCachedDomainImage(
                                orgInfo.logo!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (orgInfo.logo!.isEmpty)
                            const Center(
                              child: Icon(
                                Icons.image,
                                size: 100,
                              ),
                            ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Tooltip(
                              message: "Upload Image",
                              child: IconButton(
                                icon: const Icon(Icons.upload),
                                onPressed: () {
                                  _uploadImage();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              divider(),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    divider(),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Created By: ',
                              style: theme.getStyle().copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            divider(),
                            Text(
                              orgInfo.createdBy,
                              style: theme.getStyle(),
                            ),
                            divider(
                              horizontal: true,
                            ),
                            Text(
                              'Created On: ',
                              style: theme.getStyle().copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            divider(),
                            Text(
                              DateFormat('yyyy/MM/dd hh:mm:ss a')
                                  .format(created),
                              style: theme.getStyle(),
                            ),
                            divider(
                              horizontal: true,
                            ),
                            Visibility(
                              child: Row(
                                children: [
                                  Text(
                                    'Domain Key: ',
                                    style: theme.getStyle().copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  divider(),
                                  Text(
                                    orgInfo.settings!.twinDomainKey ?? '',
                                    style: theme.getStyle(),
                                  ),
                                  divider(),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              orgInfo.settings!.twinDomainKey ??
                                                  '',
                                        ),
                                      );

                                      OverlayWidget.showOverlay(
                                          context: context,
                                          topPosition: 170,
                                          rightPosition: 300,
                                          message: " Domain Key copied!");
                                    },
                                    child: const Tooltip(
                                      message: "Copy domain key",
                                      child: Icon(
                                        Icons.copy,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            divider(
                              horizontal: true,
                            ),
                            Text(
                              "Customer Id:",
                              style: theme.getStyle().copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            divider(),
                            Text(
                              customerId,
                              style: theme.getStyle(),
                            ),
                            divider(
                              horizontal: true,
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: customerId));

                                OverlayWidget.showOverlay(
                                    context: context,
                                    topPosition: 170,
                                    rightPosition: 120,
                                    message: " CustomerId  copied!");
                              },
                              child: const Tooltip(
                                message: "Copy CustomerId",
                                child: Icon(
                                  Icons.copy,
                                  size: 20,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                  text: TwinnedSession.instance.authToken,
                                ));

                                OverlayWidget.showOverlay(
                                    context: context,
                                    topPosition: 170,
                                    rightPosition: 120,
                                    message: " API Key  copied!");
                              },
                              child: const Tooltip(
                                message: "Copy API Key",
                                child: Icon(
                                  Icons.key,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        buildAppEdit(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> updateOrg() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      nocode.Organization org = orgInfo;

      var res = await TwinnedSession.instance.nocode.updateOrganization(
        token: TwinnedSession.instance.noCodeAuthToken,
        body: nocode.OrganizationInfo(
          name: _appNameController.text,
          description: _appDescController.text,
          website: org.website,
          icon: org.icon,
          landscapeBanner: org.landscapeBanner,
          logo: org.logo,
          portraitBanner: org.portraitBanner,
          settings: org.settings,
        ),
        orgId: orgInfo.id,
      );

      if (validateResponse(res)) {
        refresh(sync: () {
          orgInfo = res.body!.entity!;
        });
        await alert('Organization ${org.name}', 'Updated Successfully');
      }
    });
    loading = false;
    refresh();
  }

  Widget buildAppEdit(BuildContext context) {
    _appNameController.text = orgInfo.name;
    _appDescController.text = orgInfo.description!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          child: TextField(
              controller: _appNameController,
              style: theme.getStyle(),
              decoration: InputDecoration(
                hintText: 'Organization Name',
                suffix: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: orgInfo.id));

                    OverlayWidget.showOverlay(
                        context: context,
                        topPosition: 220,
                        leftPosition: 350,
                        message: " OrganizationId copied!");
                  },
                  child: const Tooltip(
                    message: "Copy OrganizationId",
                    child: Icon(
                      Icons.copy,
                      size: 20,
                    ),
                  ),
                ),
                isDense: true,
                prefixIcon: Icon(
                  Icons.edit,
                  size: 20,
                ),
              )),
        ),
        divider(
          horizontal: true,
        ),
        SizedBox(
          width: 250,
          child: TextField(
              controller: _appDescController,
              style: theme.getStyle(),
              decoration: InputDecoration(
                hintText: "Description",
                isDense: true,
                prefixIcon: Icon(
                  Icons.description,
                  size: 20,
                ),
              )),
        ),
        divider(
          horizontal: true,
        ),
        Visibility(
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: orgInfo.settings!.twinAccountId!,
                    ),
                  );
                  OverlayWidget.showOverlay(
                    context: context,
                    topPosition: 220,
                    leftPosition: 600,
                    message: " Account id copied!",
                  );
                },
                child: const Tooltip(
                  message: "Copy account id",
                  child: Icon(
                    Icons.copy,
                    size: 24,
                    color: Color(
                      0xff008080,
                    ),
                  ),
                ),
              ),
              divider(
                horizontal: true,
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: orgInfo.settings!.twinPlanId!,
                    ),
                  );
                  OverlayWidget.showOverlay(
                    context: context,
                    topPosition: 220,
                    leftPosition: 650,
                    message: " Plan id copied!",
                  );
                },
                child: const Tooltip(
                  message: "Copy plan id",
                  child: Icon(
                    Icons.copy,
                    size: 24,
                    color: Color(
                      0xffADD8E6,
                    ),
                  ),
                ),
              ),
              divider(
                horizontal: true,
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: appProfile!
                              .profile!.settings!.stripeNoCodeSubscriptionId ??
                          '',
                    ),
                  );
                  OverlayWidget.showOverlay(
                    context: context,
                    topPosition: 220,
                    leftPosition: 700,
                    message: "Subscription id copied!",
                  );
                },
                child: const Tooltip(
                  message: "Copy subscription id",
                  child: Icon(
                    Icons.copy,
                    size: 24,
                    color: Color(
                      0xff8B0000,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        divider(
          horizontal: true,
        ),
        PrimaryButton(
          labelKey: 'Update',
          onPressed: () {
            updateOrg();
          },
        ),
        divider(),
      ],
    );
  }

//Purge All Data
  void purgeRemoveData() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var res = await TwinnedSession.instance.twin
          .cleanup(apikey: orgInfo.settings!.twinApiKey);
      if (validateResponse(res)) {
        Navigator.pop(context);
        alert("Success", "All Data wiped successfully!");
      }
    });
    loading = false;
    refresh();
  }

  void confirmPurgeAllData() {
    Widget cancelButton = SecondaryButton(
      labelKey: 'Cancel',
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = PrimaryButton(
      labelKey: 'Delete',
      onPressed: () {
        purgeRemoveData();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: theme.getStyle(),
      ),
      content: Text(
        "Are you sure you want to purge all the data? \nThis will delete all the model elements like Devices,Device Models,Alarms, Conditions etc., This action can't be undone.",
        style: theme.getStyle(),
        maxLines: 10,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //wipe all data
  Future<void> wipeRemoveData() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var res = await TwinnedSession.instance.twin.cleanup(
        apikey: orgInfo.settings!.twinApiKey,
        dropIndexes: true,
      );
      if (validateResponse(res)) {
        Navigator.pop(context);
        alert("Success", "All Data wiped successfully!");
      }
    });
    loading = false;
    refresh();
  }

  void confirmWipeAllData() {
    Widget cancelButton = SecondaryButton(
      labelKey: 'Cancel',
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = PrimaryButton(
      labelKey: 'Delete',
      onPressed: () {
        wipeRemoveData();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: theme.getStyle(),
      ),
      content: Text(
        "Are you sure you want to wipe all the data? \nThis will delete all the model elements like Devices,Device Models,Alarms, Conditions etc., This action can't be undone.",
        style: theme.getStyle(),
        maxLines: 10,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  divider(
                    horizontal: true,
                  ),
                  buildAppDetails(context),
                ],
              ),
              divider(
                horizontal: true,
              ),
              Container(
                color: const Color(0xFF000000).withOpacity(0.2),
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: 'Purchase AddOns',
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  content: PurchaseChangeAddonWidget(
                                    orgId: TwinnedSession.instance.orgId,
                                    purchase: true,
                                  ),
                                );
                              });
                        },
                        child: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Visibility(
                      child: Tooltip(
                        message: 'Settings',
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CustomSettingsDropdown(
                            onChanged: (item) {
                              String customDataType =
                                  MenuDataItems.getItemType(item);
                              if (customDataType == "purge") {
                                confirmPurgeAllData();
                              } else if (customDataType == "wipe") {
                                confirmWipeAllData();
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return configPopup(
                                      onSave: (apikeyValue) {
                                        if (customDataType == "elasticEmail") {
                                          info = info.copyWith(
                                              elasticEmailConfig:
                                                  tapi.ElasticEmailConfig(
                                                      apiKey: apikeyValue,
                                                      fromEmail: ''));
                                        } else if (customDataType ==
                                            "twillio") {
                                          info = info.copyWith(
                                              twilioConfig: tapi.TwilioConfig(
                                                  accountSid: '',
                                                  authToken: '',
                                                  phoneNumber: ''));
                                        } else if (customDataType ==
                                            "textLocal") {
                                          info = info.copyWith(
                                              textLocalConfig:
                                                  tapi.TextLocalConfig(
                                                      apiKey: apikeyValue));
                                        } else if (customDataType == "geoAPI") {
                                          info = info.copyWith(
                                              geoapifyConfig:
                                                  tapi.GeoapifyConfig(
                                                      apiKey: apikeyValue));
                                        }
                                        _updateConfig(close: true);
                                      },
                                      type: customDataType,
                                      configInfo: info,
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              divider(
                horizontal: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _uploadImage() async {
    if (loading) return;
    loading = true;

    bool imageUploaded = false;

    await execute(() async {
      var uRes = await TwinImageHelper.uploadDomainImage();
      if (null != uRes && null != uRes.entity) {
        imageUploaded = true;
        orgInfo = orgInfo.copyWith(logo: [uRes.entity!.id].first);
      }
    });

    loading = false;
    refresh();

    if (imageUploaded && null != orgInfo.logo) {
      // await alert('Organization Image', 'Uploaded Successfully!');
    }
  }

  Future _updateConfig({bool close = false}) async {
    if (loading) return;

    loading = true;

    await execute(() async {
      var res = await TwinnedSession.instance.twin.upsertTwinConfig(
          apikey: TwinnedSession.instance.authToken, body: info);
      if (validateResponse(res)) {
        await alert('Twin Settings', 'Updated successfully');
        if (close) {
          _close();
        }
      }
    });

    loading = false;
  }

  void _close() {
    Navigator.pop(context);
  }
}

class configPopup extends StatefulWidget {
  final String type;
  final Function(String) onSave;
  final tapi.TwinSysInfo configInfo;

  configPopup({
    Key? key,
    required this.onSave,
    required this.type,
    required this.configInfo,
  }) : super(key: key);

  @override
  _configPopupState createState() => _configPopupState();
}

class _configPopupState extends State<configPopup> {
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String popupText = "";

  @override
  void initState() {
    super.initState();
    if (widget.type == "elasticEmail") {
      popupText = 'Elastic Email config';
      _textEditingController.text =
          widget.configInfo.elasticEmailConfig?.apiKey ?? '';
    } else if (widget.type == "twillio") {
      popupText = 'Twillio Config';
      _textEditingController.text =
          widget.configInfo.twilioConfig?.authToken ?? '';
    } else if (widget.type == "textLocal") {
      popupText = 'Text Local Config';
      _textEditingController.text =
          widget.configInfo.textLocalConfig?.apiKey ?? '';
    } else if (widget.type == "geoAPI") {
      popupText = 'Geo API Config';
      _textEditingController.text =
          widget.configInfo.geoapifyConfig?.apiKey ?? '';
    }
    setState(() {});
  }

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      String apikeyVal = _textEditingController.text;
      widget.onSave(apikeyVal);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(popupText.toString(), style: theme.getStyle()),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.26,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _textEditingController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'API key is required';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter API key',
              suffixIcon: InkWell(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: _textEditingController.text));
                  OverlayWidget.showOverlay(
                    context: context,
                    topPosition: (MediaQuery.of(context).size.height / 2) - 15,
                    leftPosition: MediaQuery.of(context).size.width / 2,
                    message: " API Key copied!",
                  );
                },
                child: const Tooltip(
                  message: "Copy API Key",
                  child: Icon(
                    Icons.key,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SecondaryButton(
              labelKey: 'Cancel',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 10),
            PrimaryButton(
              labelKey: "Save",
              onPressed: _saveData,
            ),
          ],
        ),
      ],
    );
  }
}
