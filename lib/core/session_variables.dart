import 'package:flutter/material.dart';
import 'package:twin_app/core/twin_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twin_app/flavors/config_values.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:verification_api/api/verification.swagger.dart' as vapi;
import 'package:nocode_api/api/nocode.swagger.dart' as ncapi;

TwinTheme theme = const PurpleTheme();

final Image poweredBy = Image.asset(
  "assets/images/poweredby.png",
  width: 150,
);

late ConfigValues config;
vapi.PlatformSession? session;
bool smallSreen = true;
