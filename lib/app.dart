import 'dart:io';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/router.dart';
import 'package:twin_app/widgets/commons/theme_collapsible_sidebar.dart';
import '/foundation/logger/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:twin_commons/core/twinned_session.dart';

const List<Locale> locales = [Locale("en", "US"), Locale("ta", "IN")];
final GlobalKey<ThemeCollapsibleSidebarState> menu = GlobalKey();
final GlobalKey<HomeScreenState> application = GlobalKey();

void startApp() async {
  await initialiseApp();

  // Add fonts license
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(
    EasyLocalization(
      supportedLocales: locales,
      path: "assets/translations",
      fallbackLocale: const Locale("en", "US"),
      child: const TwinApp(),
    ),
  );
}

@visibleForTesting
Future initialiseApp({bool test = false}) async {
  final bindings = WidgetsFlutterBinding.ensureInitialized();

  bindings.deferFirstFrame();

  _initialiseGetIt();

  await Future.wait([
    _initSharedPreferences(),
    EasyLocalization.ensureInitialized(),
  ]);

  EasyLocalization.logger.printer = customEasyLogger;

  if (!kIsWeb && Platform.isAndroid) {
    try {
      FlutterDisplayMode.setHighRefreshRate();
    } on PlatformException catch (exception) {
      log.e(exception);
    }
  }

  bindings.allowFirstFrame();
}

Future _initSharedPreferences() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  GetIt.instance.registerSingleton(sharedPreferences);
}

void _initialiseGetIt() {
  log.d("Initializing dependencies...");
}

class TwinApp extends StatefulWidget {
  const TwinApp({super.key});

  @override
  State<TwinApp> createState() => _TwinAppState();
}

class _TwinAppState extends State<TwinApp> {
  final _loggedInStateInfo = LoggedInStateInfo();

  @override
  void dispose() {
    _loggedInStateInfo.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      smallScreen = false;
    }
    // if (!smallScreen) {
    //   smallScreen = Platform.isAndroid || Platform.isIOS;
    // }
    //
    if (!smallScreen) {
      smallScreen = MediaQuery.of(context).size.width <= 800;
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const HomeScreen({super.key, required this.loggedInState});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void showScreen(dynamic id) {
    selectedMenu = id;
    menu.currentState!.showScreen(id);
    pageBottomMenus.clear();
    setState(() {
      pageBottomMenus.addAll(bottomMenus[id] ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    //context.setLocale(const Locale('ta', 'IN'));
    //context.setLocale(const Locale('en', 'US'));
    return Scaffold(
      body: ThemeCollapsibleSidebar(
        key: menu,
        items: menuItems,
        title: appTitle,
      ),
      bottomNavigationBar: (pageBottomMenus.isNotEmpty)
          ? CurvedNavigationBar(
              height: 50,
              backgroundColor: theme.getSecondaryColor(),
              items: pageBottomMenus,
              index: bottomMenuIndex,
              onTap: (index) {
                menu.currentState!.showScreen(pageBottomMenus[index].id);
              },
            )
          : null,
    );
  }
}

class BottomMenuItem extends StatelessWidget {
  final dynamic id;
  final Widget icon;
  final String label;
  const BottomMenuItem(
      {super.key, required this.id, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        Text(
          label,
          style: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
