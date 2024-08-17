import 'package:flutter/material.dart';
import 'package:twin_app/app.dart';
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
int selectedOrg = 0;
final List<String> orgs = [];
final List<twin.DashboardScreen> screens = [];

bool isAdmin() {
  if (null != profile) return true;
  if (TwinnedSession.instance.isAdmin()) return true;
  return false;
}

bool isClient() {
  return TwinnedSession.instance.isClient();
}

bool isClientAdmin() {
  return TwinnedSession.instance.isClientAdmin();
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
