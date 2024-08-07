import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twin_app/core/session_variables.dart' as session;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:twin_app/core/twin_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:verification_api/api/verification.swagger.dart' as vapi;
import 'dart:io' show Platform;

import 'app.dart';
import 'flavors/flavor_config.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  session.flavor = 'jegan';

  start(
    appTitle: 'My Twin App',
    homeMenu: TwinAppMenu.dashboard,
    homeMenuTitle: 'Dashboard',
  );
}

void start({
  required String appTitle,
  required dynamic homeMenu,
  required String homeMenuTitle,
  List<session.TwinMenuItem> menuItems = const [],
  session.BuildLandingPages? buildLandingPages,
  bool setDrawerOpen = false,
  session.PostLoginHook? postLoginHook,
  session.PostSignUpHook? postSignUpHook = _createDefaultClient,
}) async {
  session.appTitle = appTitle;
  session.selectedMenuTitle = homeMenuTitle;
  session.menuItems.addAll(menuItems);
  session.homeMenu = homeMenu;
  session.selectedMenu = homeMenu;
  session.buildLandingPages = buildLandingPages;
  session.setDrawerOpen = setDrawerOpen;
  session.postLoginHook = postLoginHook;
  session.postSignUpHook = postSignUpHook;

  final String envFile = getEnvFileName(session.flavor);

  debugPrint('ENV FILE: $envFile');

  await dotenv.load(
    fileName: 'assets/$envFile',
  );

  FlavorConfig.initialize(flavorString: session.flavor);

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
      return ".env";
    default:
      return ".env.$flavor";
  }
}

Future _createDefaultClient(vapi.VerificationRes res) async {
  if (!session.config.signUpAsClient) return;

  await TwinHelper.execute(() async {
    var cRes = await TwinnedSession.instance.twin
        .makeMyselfAsNewClient(apikey: res.authToken);
    if (!TwinHelper.validateResponse(cRes)) {
      debugPrint(cRes.bodyString);
    }
  });
}
