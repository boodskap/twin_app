import 'dart:io' show Platform;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twin_app/auth.dart';
import 'package:twin_app/pages/admin/clients.dart';
import 'package:twin_app/pages/admin/current_plan.dart';
import 'package:twin_app/pages/admin/invoices.dart';
import 'package:twin_app/pages/admin/orders.dart';
import 'package:twin_app/pages/admin/users.dart';
import 'package:twin_app/pages/branding/fonts_colors.dart';
import 'package:twin_app/pages/dashboard.dart';
import 'package:twin_app/pages/branding/landing_page.dart';
import 'package:twin_app/pages/nocode_builder.dart';
import 'package:twin_app/pages/roles_page.dart';
import 'package:twin_app/pages/twin/components.dart';
import 'package:twin_app/router.dart';
import 'package:twin_app/widgets/client_snippet.dart';
import 'package:twin_app/widgets/notifications.dart';
import 'package:twin_app/widgets/profile_info_screen.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_app/foundation/logger/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_app/core/session_variables.dart' as session;

const List<Locale> locales = [Locale("en", "US"), Locale("ta", "IN")];

enum TwinAppMenu {
  dashboard,
  myNotifications,
  myEvents,
  myProfile,
  twin,
  admin,
  twinComponents,
  twinNoCodeBuilder,
  twinBranding,
  adminCurrentPlan,
  adminUsers,
  adminClients,
  adminRoles,
  adminInvoices,
  adminOrders,
  brandingFontsColors,
  brandingLanding,
}

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
    if (!kIsWeb) {
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget>? pages;

    if (null != session.buildLandingPages) {
      pages = session.buildLandingPages!(context);
    }

    if (null != pages) {
      session.landingPages.clear();
      session.landingPages.addAll(pages);
    }

    if (!kIsWeb &&
        (Platform.isAndroid ||
            Platform.isIOS ||
            MediaQuery.of(context).size.width <= 800)) {
      session.smallScreen = true;
    } else {
      session.smallScreen = false;
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
  final List<session.TwinMenuItem> menuItems = [];
  final List<Widget> _sideMenus = [];
  final List<tapi.Client> _clients = [];
  Widget? body;
  tapi.TwinUser? user;
  int _selectedClient = -1;
  bool firstTime = true;
  late StreamAuth auth;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
    menuItems.addAll(session.menuItems);
    menuItems.addAll(_menuItems);
    showScreen(session.selectedMenu);
  }

  ListTile? _createMenuItem(session.TwinMenuItem cci) {
    if (!cci.isMenuVisible()) {
      return null;
    }

    return ListTile(
      onTap: () {
        setState(() {
          session.selectedMenu = cci.id;
          session.selectedMenuTitle = cci.text;
        });
        cci.onPressed();
      },
      selected: session.selectedMenu == cci.id,
      selectedTileColor: session.theme.getIntermediateColor(),
      leading: (null == cci.icon)
          ? (null != cci.assetImage
              ? Image.asset(
                  cci.assetImage!,
                  width: 32,
                  height: 32,
                )
              : null)
          : Icon(
              cci.icon,
              color: session.selectedMenu == cci.id
                  ? Colors.white
                  : session.theme.getPrimaryColor(),
            ),
      title: Text(
        cci.text,
        style: session.theme.getStyle().copyWith(
            color: session.selectedMenu == cci.id ? Colors.white : null,
            fontWeight:
                session.selectedMenu == cci.id ? FontWeight.bold : null),
      ),
    );
  }

  ExpansionTile? _createMenu(session.TwinMenuItem item, int index) {
    if (!item.isMenuVisible()) {
      return null;
    }

    List<Widget> children = [];
    for (session.TwinMenuItem cci in item.subItems) {
      if (cci.subItems.isNotEmpty) {
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
      initiallyExpanded: item.expanded,
      title: Wrap(
        spacing: 5.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (null != item.icon)
            Icon(
              item.icon!,
              color: session.selectedMenu == item.id
                  ? Colors.white
                  : session.theme.getPrimaryColor(),
            ),
          if (null != item.assetImage)
            Image.asset(
              item.assetImage!,
              width: 24,
              height: 24,
            ),
          Text(
            item.text,
            style: session.theme.getStyle().copyWith(
                color: session.selectedMenu == item.id ? Colors.white : null,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
      children: children,
    );
  }

  void _initMenus() {
    _sideMenus.clear();
    if (null == user) return;
    for (session.TwinMenuItem ci in menuItems) {
      if (ci.subItems.isNotEmpty) {
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

  void closeDrawer() {
    if (null != _scaffoldKey.currentState &&
        _scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.closeDrawer();
    }
  }

  session.TwinMenuItem? _findMenuItem(
      List<session.TwinMenuItem> items, dynamic id) {
    for (session.TwinMenuItem mi in items) {
      if (mi.id == id) return mi;
      if (mi.subItems.isNotEmpty) {
        session.TwinMenuItem? item = _findMenuItem(mi.subItems, id);
        if (null != item) {
          return item;
        }
      }
    }
    return null;
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
                    color: session.theme.getPrimaryColor(),
                  )),
            ],
          ),
        ),
      );
    }

    auth = StreamAuthScope.of(context);

    _initMenus();

    if (null != user) {
      _sideMenus.add(Divider());
      _sideMenus.add(ListTile(
        leading: Icon(
          Icons.logout,
          color: session.theme.getPrimaryColor(),
        ),
        title: Text(
          'Sign Out',
          style: session.theme.getStyle(),
        ),
        onTap: () {
          setState(() {
            user = null;
          });
          _selectedClient = -1;
          session.selectedMenu = session.homeMenu;
          session.selectedMenuTitle = '';
          auth.signOut();
        },
      ));
    }

    _sideMenus.add(Divider(
      color: session.theme.getPrimaryColor(),
    ));

    debugPrint('BUILDING with ${session.pageBottomMenus.length} bottom menus');

    Widget widget = Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${session.selectedMenuTitle}',
          style: session.theme.getStyle().copyWith(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: session.theme.getPrimaryColor(),
        elevation: 5,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Text(
            user!.name,
            style: session.theme.getStyle().copyWith(color: Colors.white),
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
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              setState(() {
                user = null;
              });
              _selectedClient = -1;
              session.selectedMenu = session.homeMenu;
              session.selectedMenuTitle = '';
              auth.signOut();
            },
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      drawer: Drawer(
        key: Key(Uuid().v4()),
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
                  color: session.theme.getPrimaryColor(),
                ),
                child: Row(
                  children: [
                    if (_selectedClient == -1)
                      Text(
                        session.appTitle,
                        style: session.theme.getStyle().copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    if (_selectedClient != -1)
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5,
                        children: [
                          if (null != _clients[_selectedClient].icon &&
                              _clients[_selectedClient].icon!.isNotEmpty)
                            SizedBox(
                                //width: 280,
                                height: 64,
                                child: TwinImageHelper.getDomainImage(
                                    _clients[_selectedClient].icon!)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (null == _clients[_selectedClient].icon ||
                                  _clients[_selectedClient].icon!.isEmpty)
                                Text(
                                  '${_clients[_selectedClient].name}',
                                  style: session.theme.getStyle().copyWith(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              if (TwinnedSession.instance.isClientAdmin())
                                IconButton(
                                    onPressed: () {
                                      _editClient(
                                          client: _clients[_selectedClient]);
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    )),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 80,
              child: SingleChildScrollView(
                child: Column(
                  children: _sideMenus,
                ),
              ),
            ),
            //..._sideMenus,
            Expanded(
              flex: 10,
              child: SizedBox(width: 200, child: session.logo),
            ),
          ],
        ),
      ),
      body: body,
      bottomNavigationBar: (session.pageBottomMenus.isNotEmpty)
          ? CurvedNavigationBar(
              height: 50,
              backgroundColor: session.theme.getPrimaryColor(),
              buttonBackgroundColor: session.theme.getSecondaryColor(),
              //color: theme.getSecondaryColor(),
              items: session.pageBottomMenus,
              index: session.bottomMenuIndex,
              onTap: (index) {
                session.selectedMenuTitle =
                    session.pageBottomMenus[index].label;
                showScreen(session.pageBottomMenus[index].id);
              },
            )
          : null,
    );

    if (session.setDrawerOpen) {
      _openDrawer();
    }

    return widget;
  }

  void showScreen(dynamic id) {
    closeDrawer();

    session.pageBottomMenus.clear();
    session.bottomMenuIndex = 0;
    session.selectedMenu = id;

    debugPrint('MENU: $id');
    session.TwinMenuItem? mi = _findMenuItem(menuItems, id);
    if (null != mi) {
      body = mi.onMenuSelected(context);
      session.pageBottomMenus.addAll(mi.bottomMenus);
      session.bottomMenuIndex = 0;
      for (int i = 0; i < session.pageBottomMenus.length; i++) {
        if (session.pageBottomMenus[i].id == id) {
          session.bottomMenuIndex = i;
          break;
        }
      }
      if (null == body) {
        debugPrint('MENU: $id returned empty body');
      }
    } else {
      debugPrint('*** MENU: $id not found ***');
    }

    setState(() {});
  }

  List<session.TwinMenuItem> get _menuItems {
    return [
      session.TwinMenuItem(
        text: 'Dashboard',
        id: TwinAppMenu.dashboard,
        icon: Icons.dashboard,
        isMenuVisible: () {
          return true;
        },
        onMenuSelected: (ctx) {
          return const Dashboard();
        },
      ),
      session.TwinMenuItem(
        text: 'Digital Twin',
        id: TwinAppMenu.twin,
        expanded: true,
        assetImage: 'images/twin.png',
        subItems: _twinSubMenuItems,
        isMenuVisible: () {
          return !session.smallScreen && session.isAdmin();
        },
        onMenuSelected: (ctx) {
          return SizedBox.shrink();
        },
      ),
      session.TwinMenuItem(
        text: 'Admin',
        id: TwinAppMenu.admin,
        icon: Icons.shield,
        expanded: false,
        subItems: _adminSubMenuItems,
        isMenuVisible: () {
          return !session.smallScreen && session.isAdmin();
        },
        onMenuSelected: (ctx) {
          return SizedBox.shrink();
        },
      ),
      session.TwinMenuItem(
        text: 'My Notifications',
        id: TwinAppMenu.myNotifications,
        icon: Icons.notification_add,
        isMenuVisible: () {
          return null != user;
        },
        onMenuSelected: (ctx) {
          return AlarmsNotificationsGrid();
        },
      ),
      session.TwinMenuItem(
        text: 'My Events',
        id: TwinAppMenu.myEvents,
        icon: Icons.event_available,
        isMenuVisible: () {
          return null != user;
        },
        onMenuSelected: (ctx) {
          return ProfileInfoScreen(
            key: Key(Uuid().v4()),
            selectedTab: 2,
          );
        },
      ),
      session.TwinMenuItem(
        text: 'My Profile',
        id: TwinAppMenu.myProfile,
        icon: Icons.person,
        isMenuVisible: () {
          return null != user;
        },
        onMenuSelected: (ctx) {
          return ProfileInfoScreen(
            key: Key(Uuid().v4()),
            selectedTab: 0,
          );
        },
      ),
    ];
  }

  List<session.TwinMenuItem> get _twinSubMenuItems {
    return [
      session.TwinMenuItem(
        id: TwinAppMenu.twinComponents,
        text: 'Components',
        icon: Icons.menu,
        bottomMenus: _twinBottomMenus(),
        isMenuVisible: () {
          return true;
        },
        onMenuSelected: (BuildContext context) {
          return const Components();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.twinNoCodeBuilder,
        text: 'NoCode Builder',
        icon: Icons.menu,
        bottomMenus: _twinBottomMenus(),
        isMenuVisible: () {
          return true;
        },
        onMenuSelected: (BuildContext context) {
          return const NocodeBuilderPage();
        },
      ),
      session.TwinMenuItem(
        text: 'Branding',
        id: TwinAppMenu.twinBranding,
        icon: Icons.admin_panel_settings_rounded,
        expanded: false,
        subItems: _brandingSubMenuItems,
        bottomMenus: _twinBottomMenus(),
        isMenuVisible: () {
          return !session.smallScreen && session.isAdmin();
        },
        onMenuSelected: (ctx) {
          return SizedBox.shrink();
        },
      ),
    ];
  }

  List<session.TwinMenuItem> get _adminSubMenuItems {
    return [
      session.TwinMenuItem(
        id: TwinAppMenu.adminCurrentPlan,
        text: 'Current Plan',
        icon: Icons.account_balance_wallet,
        bottomMenus: _adminBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) {
          return const CurrentPlan();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.adminUsers,
        text: 'Users',
        icon: Icons.group,
        bottomMenus: _adminBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) {
          return const Users();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.adminClients,
        text: 'Clients',
        icon: Icons.perm_contact_cal_outlined,
        bottomMenus: _adminBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) {
          return const Clients();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.adminRoles,
        text: 'Roles',
        icon: Icons.key,
        bottomMenus: _adminBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) {
          return const RolesPage();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.adminInvoices,
        text: 'Invoices',
        icon: Icons.monetization_on,
        bottomMenus: _adminBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) {
          return const Invoices();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.adminOrders,
        text: 'Orders',
        icon: Icons.shopping_cart,
        bottomMenus: _adminBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) {
          return const Orders();
        },
      ),
    ];
  }

  List<session.TwinMenuItem> get _brandingSubMenuItems {
    return [
      session.TwinMenuItem(
        id: TwinAppMenu.adminCurrentPlan,
        text: 'Fonts & Colors',
        icon: Icons.font_download,
        bottomMenus: _twinBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) {
          return const FontsAndColors();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.adminUsers,
        text: 'Landing Page',
        icon: Icons.pages,
        bottomMenus: _twinBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) {
          return const LandingPage();
        },
      ),
    ];
  }

  List<BottomMenuItem> _adminBottomMenus() {
    return [
      const BottomMenuItem(
        id: TwinAppMenu.adminUsers,
        icon: Icon(Icons.person, size: 30),
        label: 'Users',
      ),
      const BottomMenuItem(
        id: TwinAppMenu.adminClients,
        icon: Icon(Icons.group, size: 30),
        label: 'Clients',
      ),
      const BottomMenuItem(
        id: TwinAppMenu.adminRoles,
        icon: Icon(Icons.key, size: 30),
        label: 'Roles',
      ),
    ];
  }

  List<BottomMenuItem> _twinBottomMenus() {
    return [
      const BottomMenuItem(
        id: TwinAppMenu.twinComponents,
        icon: Icon(Icons.menu, size: 30),
        label: 'Comps',
      ),
      const BottomMenuItem(
        id: TwinAppMenu.twinNoCodeBuilder,
        icon: Icon(Icons.menu, size: 30),
        label: 'Builder',
      ),
      const BottomMenuItem(
        id: TwinAppMenu.twinBranding,
        icon: Icon(Icons.menu, size: 30),
        label: 'Branding',
      ),
    ];
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _clients.clear();

    await execute(() async {
      user = await TwinnedSession.instance.getUser();
      var clients = await TwinnedSession.instance.getClients();
      _clients.addAll(clients);
      if (_clients.isNotEmpty) {
        _selectedClient = 0;
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() async {
    _load();
  }

  Future _openDrawer() async {
    if (!firstTime) return;
    await Future.delayed(Duration.zero);
    _scaffoldKey.currentState!.openDrawer();
    firstTime = false;
  }

  void _editClient({required tapi.Client client}) async {
    closeDrawer();
    ValueNotifier<tapi.Client> valueNotifier = ValueNotifier(client);
    valueNotifier.addListener(() {
      auth.signOut();
    });
    await super.alertDialog(
        title: 'Update ${client.name}',
        body: ClientSnippet(
          client: client,
          changeNotifier: valueNotifier,
        ),
        width: 750,
        height: MediaQuery.of(context).size.height - 150);
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
          style: session.theme.getStyle().copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
