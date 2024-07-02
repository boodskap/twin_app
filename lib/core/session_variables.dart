import 'package:flutter/material.dart';
import 'package:twin_app/core/twin_theme.dart';
import 'package:twin_app/flavors/config_values.dart';
import 'package:twin_app/router.dart';
import 'package:verification_api/api/verification.swagger.dart' as vapi;
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;

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
late ConfigValues config;
tapi.TwinSysInfo? sysInfo;
vapi.PlatformSession? session;
bool smallScreen = true;
double credScreenWidth = 450;
Widget? homeScreen;
