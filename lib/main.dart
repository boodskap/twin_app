import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twin_app/core/session_variables.dart';
import 'dart:io' show Platform;

import 'app.dart';
import 'flavors/flavor_config.dart';

void main() async {
  const flavor = String.fromEnvironment("flavor", defaultValue: "dev");

  await dotenv.load(
    fileName: getEnvFileName(flavor),
  );

  FlavorConfig.initialize(flavorString: flavor);

  config = FlavorConfig.values;

  if (kIsWeb) {
    smallSreen = false;
  }

  if (smallSreen) {
    smallSreen = Platform.isAndroid || Platform.isIOS;
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
