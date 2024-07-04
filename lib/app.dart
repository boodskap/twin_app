import 'dart:io';
import 'dart:js_interop';
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
  final List<Widget> _sideMenus = [];
  Widget? body;

  @override
  initState() {
    super.initState();
    showScreen(homeMenu);
  }

  ListTile _createMenuItem(TwinMenuItem cci) {
    return ListTile(
      onTap: () {
        cci.onPressed();
        setState(() {
          selectedMenu = cci.id;
          selectedMenuTitle = cci.text;
        });
      },
      selected: selectedMenu == cci.id,
      selectedTileColor: theme.getIntermediateColor(),
      leading: (null == cci.icon)
          ? null
          : Icon(
              cci.icon,
              color: selectedMenu == cci.id
                  ? Colors.white
                  : theme.getPrimaryColor(),
            ),
      title: Text(
        cci.text,
        style: theme.getStyle().copyWith(
            color: selectedMenu == cci.id ? Colors.white : null,
            fontWeight: selectedMenu == cci.id ? FontWeight.bold : null),
      ),
    );
  }

  ExpansionTile _createMenu(TwinMenuItem item, int index) {
    List<Widget> children = [];
    for (TwinMenuItem cci in item.subItems!) {
      if (null != cci.subItems && cci.subItems!.isNotEmpty) {
        children.add(Padding(
          padding: EdgeInsets.only(left: 8.0 * index.toDouble()),
          child: _createMenu(cci, ++index),
        ));
      } else {
        children.add(Padding(
          padding: EdgeInsets.only(left: 16.0 * index.toDouble()),
          child: _createMenuItem(cci),
        ));
      }
    }
    return ExpansionTile(
      title: Wrap(
        spacing: 5.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (null != item.icon)
            Icon(
              item.icon!,
              color: selectedMenu == item.id
                  ? Colors.white
                  : theme.getPrimaryColor(),
            ),
          Text(
            item.text,
            style: theme.getStyle().copyWith(
                color: selectedMenu == item.id ? Colors.white : null,
                fontWeight: selectedMenu == item.id ? FontWeight.bold : null),
          ),
        ],
      ),
      children: children,
    );
  }

  void _initMenus() {
    _sideMenus.clear();

    for (TwinMenuItem ci in menuItems) {
      if (null != ci.subItems && ci.subItems!.isNotEmpty) {
        _sideMenus.add(_createMenu(ci, 1));
      } else {
        _sideMenus.add(_createMenuItem(ci));
      }
    }
  }

  void showScreen(dynamic id) {
    pageBottomMenus.clear();
    selectedMenu = id;
    body = onMenuSelected(id);
    pageBottomMenus.addAll(bottomMenus[id] ?? []);
    for (BottomMenuItem bmi in pageBottomMenus) {
      if (bmi.id == id) {
        selectedMenuTitle = bmi.label;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //context.setLocale(const Locale('ta', 'IN'));
    //context.setLocale(const Locale('en', 'US'));
    _initMenus();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '$selectedMenuTitle',
          style: theme.getStyle().copyWith(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.getPrimaryColor(),
        elevation: 5,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: body,
      drawer: Drawer(
        elevation: 5,
        semanticLabel: 'Main menu',
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: const EdgeInsets.only(bottom: 0.0),
              decoration: BoxDecoration(
                color: theme.getPrimaryColor(),
              ),
              child: Text(
                appTitle,
                style: theme.getStyle().copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ..._sideMenus,
          ],
        ),
      ),
      bottomNavigationBar: (pageBottomMenus.isNotEmpty)
          ? CurvedNavigationBar(
              height: 50,
              backgroundColor: theme.getSecondaryColor(),
              items: pageBottomMenus,
              index: bottomMenuIndex,
              onTap: (index) {
                showScreen(pageBottomMenus[index].id);
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
