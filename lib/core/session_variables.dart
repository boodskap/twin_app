import 'package:flutter/material.dart';
import 'package:twin_app/app.dart';
import 'package:twin_app/core/twin_helper.dart';
import 'package:twin_app/core/twin_theme.dart';
import 'package:twin_app/flavors/config_values.dart';
import 'package:twin_app/router.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:verification_api/api/verification.swagger.dart' as vapi;
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:nocode_api/api/nocode.swagger.dart' as nocode;

typedef OnMenuSelected = Future<Widget> Function(BuildContext context);
typedef IsMenuVisible = bool Function();
typedef BuildLandingPages = List<Widget>? Function(BuildContext context);
typedef PostLoginHook = Future Function();
typedef PostSignUpHook = Future Function(vapi.VerificationRes res);

TwinTheme theme = themes[0];

final Image logo = Image.asset(
  "assets/images/icon.png",
  //width: 150,
  fit: BoxFit.contain,
);

final Image poweredBy = Image.network(
  "https://static.boodskap.io/logos/logo.png",
  width: 100,
  fit: BoxFit.contain,
);

final Map<String, dynamic> localVariables = <String, dynamic>{};
final List<vapi.PlatformSession> sessions = [];
final List<Widget> landingPages = [];
late ConfigValues config;
twin.TwinSysInfo? twinSysInfo;
vapi.PlatformSession? session;
bool smallScreen = true;
double credScreenWidth = 450;
//Widget? homeScreen;
bool twinAppDisabled = false;
bool themeDisabled = true;
final String defaultFont = 'Open Sans';
final List<TwinMenuItem> menuItems = [];
String appTitle = 'My Digital Twin App';
final List<BottomMenuItem> pageBottomMenus = [];
int bottomMenuIndex = 0;
BuildLandingPages? buildLandingPages;
dynamic homeMenu = 'HOME';
dynamic selectedMenu = 'DASHBOARD';
String selectedMenuTitle = '';
String flavor = "prod";
bool setDrawerOpen = false;
PostLoginHook? postLoginHook;
PostSignUpHook? postSignUpHook;
nocode.Profile? profile;
nocode.OrgPlan? orgPlan;
int selectedOrg = 0;
final List<twin.OrgInfo> orgs = [];
final List<twin.DashboardScreen> screens = [];
final List<TwinMenuItem> screenMenus = [];

bool isAdmin() {
  if (null != profile) return true;
  if (TwinnedSession.instance.isAdmin()) return true;
  return false;
}

bool isClient() {
  return TwinnedSession.instance.isClient() || isClientAdmin();
}

bool isClientAdmin() {
  return TwinnedSession.instance.isClientAdmin();
}

bool isOrgOwner() {
  if (null != orgs[selectedOrg]) {
    return orgs[selectedOrg]!.profileId == orgs[selectedOrg]!.userProfileId;
  }
  return false;
}

Future<List<String>> getClientIds() async {
  return await TwinnedSession.instance.getClientIds();
}

Future<bool> hasDeviceLibrariesExhausted() async {
  bool exhausted = true;
  if (null != orgPlan) {
    await TwinHelper.execute(() async {
      var r = await TwinnedSession.instance.twin
          .countDeviceModels(apikey: TwinnedSession.instance.authToken);
      if (TwinHelper.validateResponse(r)) {
        debugPrint(
            'Utilized Models: ${r.body?.total} / ${orgPlan?.totalDeviceModelCount}');
        exhausted = r.body!.total >= (orgPlan?.totalDeviceModelCount ?? 0);
      }
    });
  }
  return exhausted;
}

bool hasDeviceParametersExhausted(int total) {
  bool exhausted = true;
  if (null != orgPlan) {
    exhausted = total >= (orgPlan?.totalModelParametersCount ?? 0);
  }
  return exhausted;
}

Future<bool> hasDevicesExhausted() async {
  bool exhausted = true;
  if (null != orgPlan) {
    await TwinHelper.execute(() async {
      var r = await TwinnedSession.instance.twin
          .countDevices(apikey: TwinnedSession.instance.authToken);
      if (TwinHelper.validateResponse(r)) {
        debugPrint(
            'Utilized Devices: ${r.body?.total} / ${orgPlan?.totalDevicesCount}');
        exhausted = r.body!.total >= (orgPlan?.totalDevicesCount ?? 0);
      }
    });
  }
  return exhausted;
}

Future<bool> hasDashboardsExhausted() async {
  bool exhausted = true;
  if (null != orgPlan) {
    await TwinHelper.execute(() async {
      var r = await TwinnedSession.instance.twin
          .countDashboards(apikey: TwinnedSession.instance.authToken);
      if (TwinHelper.validateResponse(r)) {
        debugPrint(
            'Utilized Dashboards: ${r.body?.total} / ${orgPlan?.totalDashboardCount}');
        exhausted = r.body!.total >= (orgPlan?.totalDashboardCount ?? 0);
      }
    });
  }
  return exhausted;
}

Future<bool> hasUsersExhausted() async {
  bool exhausted = true;
  if (null != orgPlan) {
    await TwinHelper.execute(() async {
      var r = await TwinnedSession.instance.twin
          .countTwinUsers(apikey: TwinnedSession.instance.authToken);
      if (TwinHelper.validateResponse(r)) {
        debugPrint(
            'Utilized Users: ${r.body?.total} / ${orgPlan?.totalUserCount}');
        exhausted = r.body!.total >= (orgPlan?.totalUserCount ?? 0);
      }
    });
  }
  return exhausted;
}

Future<bool> hasClientsExhausted() async {
  bool exhausted = true;
  if (null != orgPlan) {
    await TwinHelper.execute(() async {
      var r = await TwinnedSession.instance.twin
          .countClients(apikey: TwinnedSession.instance.authToken);
      if (TwinHelper.validateResponse(r)) {
        debugPrint(
            'Utilized Clients: ${r.body?.total} / ${orgPlan?.totalClientCount}');
        exhausted = r.body!.total >= (orgPlan?.totalClientCount ?? 0);
      }
    });
  }
  return exhausted;
}

bool canBuyArchivalPlan() {
  return orgPlan!.canBuyArchivalPlan ?? false;
}

bool canBuyDataPlan() {
  return orgPlan!.canBuyDataPlan ?? false;
}

bool canBuyClientPlan() {
  return orgPlan!.canBuyClientPlan ?? false;
}

class TwinMenuItem {
  TwinMenuItem({
    required this.id,
    required this.text,
    required this.onMenuSelected,
    required this.isMenuVisible,
    this.expanded = true,
    this.badgeCount,
    this.icon,
    this.assetImage,
    this.subItems = const [],
    this.bottomMenus = const [],
  });

  final dynamic id;
  final String text;
  final List<TwinMenuItem> subItems;
  final List<BottomMenuItem> bottomMenus;
  final IsMenuVisible isMenuVisible;
  final OnMenuSelected onMenuSelected;
  final bool expanded;
  int? badgeCount;
  IconData? icon;
  String? assetImage;

  void onPressed() {
    application.currentState!.showScreen(id);
  }
}
