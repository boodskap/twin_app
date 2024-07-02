import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:io' show Platform;

import 'app.dart';
import 'flavors/flavor_config.dart';

void main() async {
  start();
}

void start() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  const flavor = String.fromEnvironment("flavor", defaultValue: "dev");
  final String envFile = getEnvFileName(flavor);

  debugPrint('ENV FILE: $envFile');

  await dotenv.load(
    fileName: envFile,
  );

  FlavorConfig.initialize(flavorString: flavor);

  config = FlavorConfig.values;

  if (kIsWeb) {
    smallScreen = false;
  }

  if (smallScreen) {
    smallScreen = Platform.isAndroid || Platform.isIOS;
  }

  startApp();
}

String getEnvFileName(String flavor) {
  switch (flavor) {
    case "prod":
      return ".env";
    case "qa":
      return ".env.qa";
    case "test":
      return ".env.test";
    case "dev":
    default:
      return ".env.dev";
  }
}
