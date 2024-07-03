import 'package:collapsible_sidebar/collapsible_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/app.dart';
import 'package:twin_app/core/twin_theme.dart';
import 'package:twin_app/flavors/config_values.dart';
import 'package:twin_app/router.dart';
import 'package:verification_api/api/verification.swagger.dart' as vapi;
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;

typedef OnMenuSelected = Widget Function(dynamic id);

TwinTheme theme = themes[2];

final Image logo = Image.asset(
  "assets/images/icon.png",
  width: 150,
  fit: BoxFit.contain,
);

final Image poweredBy = Image.asset(
  "assets/images/poweredby.png",
  width: 150,
);

final Map<String, dynamic> localVariables = <String, dynamic>{};
final LoggedInStateInfo loggedInState = LoggedInStateInfo();
final List<vapi.PlatformSession> sessions = [];
final List<Widget> landingPages = [];
late ConfigValues config;
tapi.TwinSysInfo? twinSysInfo;
vapi.PlatformSession? session;
bool smallScreen = true;
double credScreenWidth = 450;
//Widget? homeScreen;
final String defaultFont = 'Open Sans';
final List<CollapsibleItem> menuItems = [];
String appTitle = 'My Digital Twin App';
final Map<dynamic, List<BottomMenuItem>> bottomMenus =
    <dynamic, List<BottomMenuItem>>{};
final List<BottomMenuItem> pageBottomMenus = [];
late OnMenuSelected onMenuSelected;
dynamic homeMenu = 'HOME';
dynamic selectedMenu = homeMenu;
