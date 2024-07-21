import 'package:flutter/material.dart';
import 'package:twin_app/app.dart';
import 'package:twin_app/core/twin_theme.dart';
import 'package:twin_app/flavors/config_values.dart';
import 'package:twin_app/router.dart';
import 'package:verification_api/api/verification.swagger.dart' as vapi;
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;

typedef OnMenuSelected = Widget Function(BuildContext context);
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
  width: 150,
  fit: BoxFit.contain,
);

final Map<String, dynamic> localVariables = <String, dynamic>{};
final List<vapi.PlatformSession> sessions = [];
final List<Widget> landingPages = [];
late ConfigValues config;
tapi.TwinSysInfo? twinSysInfo;
vapi.PlatformSession? session;
bool smallScreen = true;
double credScreenWidth = 450;
//Widget? homeScreen;
final String defaultFont = 'Open Sans';
final List<TwinMenuItem> menuItems = [];
String appTitle = 'My Digital Twin App';
final List<BottomMenuItem> pageBottomMenus = [];
BuildLandingPages? buildLandingPages;
dynamic homeMenu = 'HOME';
dynamic selectedMenu = homeMenu;
String selectedMenuTitle = '';
int bottomMenuIndex = 0;
String flavor = "prod";
bool setDrawerOpen = false;
PostLoginHook? postLoginHook;
PostSignUpHook? postSignUpHook;

class TwinMenuItem {
  TwinMenuItem({
    required this.id,
    required this.text,
    required this.isMenuVisible,
    required this.onMenuSelected,
    this.badgeCount,
    this.icon,
    this.iconImage,
    this.subItems = const [],
    this.bottomMenus = const [],
  });

  final dynamic id;
  final String text;
  final List<TwinMenuItem> subItems;
  final List<BottomMenuItem> bottomMenus;
  final IsMenuVisible isMenuVisible;
  final OnMenuSelected onMenuSelected;
  int? badgeCount;
  IconData? icon;
  ImageProvider? iconImage;

  void onPressed() {
    if (bottomMenus.isEmpty) {
      application.currentState!.showScreen(id);
    }
  }
}
