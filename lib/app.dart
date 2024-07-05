import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twin_app/auth.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/router.dart';
import 'package:twin_app/widgets/profile_info_screen.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import '/foundation/logger/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

const List<Locale> locales = [Locale("en", "US"), Locale("ta", "IN")];

void startApp() async {
  await initialiseApp();

  // Add fonts license
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(
    StreamAuthScope(
      child: EasyLocalization(
        supportedLocales: locales,
        path: "assets/translations",
        fallbackLocale: const Locale("en", "US"),
        child: const TwinApp(),
      ),
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
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends BaseState<HomeScreen> {
  final List<Widget> _sideMenus = [];
  final List<tapi.Client> _clients = [];
  Widget? body;
  tapi.TwinUser? user;
  int _selectedClient = -1;

  @override
  initState() {
    super.initState();
    showScreen(selectedMenu);
  }

  ListTile? _createMenuItem(TwinMenuItem cci) {
    if (!isMenuVisible(cci.id)) {
      return null;
    }

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

  ExpansionTile? _createMenu(TwinMenuItem item, int index) {
    if (!isMenuVisible(item.id)) {
      return null;
    }

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
      initiallyExpanded: true,
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
    if (null == user) return;
    for (TwinMenuItem ci in menuItems) {
      if (null != ci.subItems && ci.subItems!.isNotEmpty) {
        var m = _createMenu(ci, 1);
        if (null != m) {
          _sideMenus.add(m);
        }
      } else {
        var mi = _createMenuItem(ci);
        if (null != mi) {
          _sideMenus.add(mi);
        }
      }
    }
  }

  void showScreen(dynamic id) {
    pageBottomMenus.clear();
    selectedMenu = id;
    body = onMenuSelected(id);
    pageBottomMenus.addAll(bottomMenus[id] ?? []);
    bottomMenuIndex = 0;
    for (int i = 0; i < pageBottomMenus.length; i++) {
      if (pageBottomMenus[i].id == id) {
        bottomMenuIndex = i;
        break;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //context.setLocale(const Locale('ta', 'IN'));
    //context.setLocale(const Locale('en', 'US'));
    if (null == user) {
      return Container(
        color: Colors.white,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    color: theme.getPrimaryColor(),
                  )),
            ],
          ),
        ),
      );
    }

    final StreamAuth auth = StreamAuthScope.of(context);

    _initMenus();

    if (null != user) {
      _sideMenus.add(ListTile(
        leading: Icon(Icons.person),
        title: Text(
          'My Profile',
          style: theme.getStyle(),
        ),
        onTap: () {
          setState(() {
            body = ProfileInfoScreen();
          });
        },
      ));

      _sideMenus.add(ListTile(
        leading: Icon(Icons.logout),
        title: Text(
          'Sign Out',
          style: theme.getStyle(),
        ),
        onTap: () {
          setState(() {
            user = null;
          });
          auth.signOut();
        },
      ));

      _sideMenus.add(Divider(
        color: theme.getPrimaryColor(),
      ));
    }

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
        actions: [
          Text(
            user!.name,
            style: theme.getStyle().copyWith(color: Colors.white),
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              setState(() {
                //TODO
                body = ProfileInfoScreen();
              });
            },
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 5,
        semanticLabel: 'Main menu',
        child: Column(
          //padding: EdgeInsets.zero,
          children: [
            Expanded(
              flex: 10,
              child: DrawerHeader(
                margin: const EdgeInsets.only(bottom: 0.0),
                decoration: BoxDecoration(
                  color: theme.getPrimaryColor(),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedClient == -1
                          ? appTitle
                          : '${_clients[_selectedClient].name}',
                      style: theme.getStyle().copyWith(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    if (_selectedClient >= 0 &&
                        null != _clients[_selectedClient].icon &&
                        _clients[_selectedClient].icon!.isNotEmpty)
                      SizedBox(
                          width: 185,
                          height: 100,
                          child: TwinImageHelper.getDomainImage(
                              _clients[_selectedClient].icon!)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 80,
              child: Column(
                children: _sideMenus,
              ),
            ),
            //..._sideMenus,
            Expanded(
              flex: 10,
              child: SizedBox(width: 200, child: logo),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (pageBottomMenus.isNotEmpty)
          ? CurvedNavigationBar(
              height: 50,
              backgroundColor: theme.getPrimaryColor(),
              buttonBackgroundColor: theme.getSecondaryColor(),
              //color: theme.getSecondaryColor(),
              items: pageBottomMenus,
              index: bottomMenuIndex,
              onTap: (index) {
                selectedMenuTitle = pageBottomMenus[index].label;
                showScreen(pageBottomMenus[index].id);
              },
            )
          : null,
      body: body,
    );
  }

  @override
  void setup() async {
    user = await TwinnedSession.instance.getUser();
    var clients = await TwinnedSession.instance.getClients();
    _clients.addAll(clients);
    if (_clients.isNotEmpty) {
      _selectedClient = 0;
    }
    refresh();
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
