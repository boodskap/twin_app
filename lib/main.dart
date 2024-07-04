import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twin_app/core/session_variables.dart' as session;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'dart:io' show Platform;

import 'app.dart';
import 'flavors/flavor_config.dart';

void main() async {
  start(
      appTitle: 'My Twin App',
      menuItems: [],
      bottomMenus: {},
      homeMenu: 'HOME',
      homeMenuTitle: 'Home',
      onMenuSelected: (id) => Placeholder());
}

void start({
  required String appTitle,
  required dynamic homeMenu,
  required String homeMenuTitle,
  required List<session.TwinMenuItem> menuItems,
  required Map<dynamic, List<BottomMenuItem>> bottomMenus,
  required session.OnMenuSelected onMenuSelected,
}) async {
  session.appTitle = appTitle;
  session.selectedMenuTitle = homeMenuTitle;
  session.menuItems.addAll(menuItems);
  session.bottomMenus.addAll(bottomMenus);
  session.onMenuSelected = onMenuSelected;
  session.homeMenu = homeMenu;

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  const flavor = String.fromEnvironment("flavor", defaultValue: "");
  final String envFile = getEnvFileName(flavor);

  debugPrint('ENV FILE: $envFile');

  await dotenv.load(
    fileName: envFile,
  );

  FlavorConfig.initialize(flavorString: flavor);

  session.config = FlavorConfig.values;

  TwinnedSession.instance.init(
    debug: session.config.showLogs,
    domainKey: session.config.twinDomainKey ?? '',
    host: session.config.apiHost,
    authToken: '',
    noCodeAuthToken: '',
  );

  startApp();
}

String getEnvFileName(String flavor) {
  switch (flavor) {
    case "qa":
      return ".env.qa";
    case "test":
      return ".env.test";
    case "dev":
      return ".env.dev";
    case "prod":
    default:
      return ".env";
  }
}
