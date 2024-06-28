import 'package:flutter/material.dart';
import 'package:twin_app/core/twin_theme.dart';
import 'package:twin_app/flavors/config_values.dart';
import 'package:twin_app/router.dart';
import 'package:verification_api/api/verification.swagger.dart' as vapi;

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
vapi.PlatformSession? session;
bool smallSreen = true;
double credScreenWidth = 450;
