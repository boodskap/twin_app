import 'dart:io' show Platform;

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twin_app/auth.dart';
import 'package:twin_app/core/theme_notifier.dart';
import 'package:twin_app/core/twin_helper.dart';
import 'package:twin_app/foundation/logger/logger.dart';
import 'package:twin_app/pages/admin/clients.dart';
import 'package:twin_app/pages/admin/current_plan.dart';
import 'package:twin_app/pages/admin/invoices.dart';
import 'package:twin_app/pages/admin/orders.dart';
import 'package:twin_app/pages/admin/users.dart';
import 'package:twin_app/pages/branding/fonts_colors.dart';
import 'package:twin_app/pages/branding/landing_page.dart';
import 'package:twin_app/pages/dashboard.dart';
import 'package:twin_app/pages/nocode_builder.dart';
import 'package:twin_app/pages/pulse/email_tab.dart';
import 'package:twin_app/pages/pulse/sms_tab.dart';
import 'package:twin_app/pages/pulse/template.dart';
import 'package:twin_app/pages/pulse/voice_tab.dart';
import 'package:twin_app/pages/query_console.dart';
import 'package:twin_app/pages/pulse/admin/manage_gateways.dart';
import 'package:twin_app/pages/pulse/email.dart';
import 'package:twin_app/pages/pulse/sms.dart';
import 'package:twin_app/pages/pulse/voice.dart';
import 'package:twin_app/pages/roles_page.dart';
import 'package:twin_app/pages/twin/components.dart';
import 'package:twin_app/pages/twin/components/asset_filters.dart';
import 'package:twin_app/pages/twin/components/asset_groups.dart';
import 'package:twin_app/pages/twin/components/report.dart';
import 'package:twin_app/pages/twin/organization_page.dart';
import 'package:twin_app/router.dart';
import 'package:twin_app/widgets/client_snippet.dart';
import 'package:twin_app/widgets/notifications.dart';
import 'package:twin_app/widgets/org_change_widget.dart';
import 'package:twin_app/widgets/profile_info_screen.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/twinned_dashboard_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:twin_commons/core/storage.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_app/core/session_variables.dart' as session;

const List<Locale> locales = [Locale("en", "US"), Locale("ta", "IN")];

enum TwinAppMenu {
  home,
  myNotifications,
  myEvents,
  myProfile,
  twin,
  admin,
  billing,
  pulse,
  twinComponents,
  twinNoCodeBuilder,
  twinFontsColors,
  twinLanding,
  twinOrganization,
  adminUsers,
  adminClients,
  adminRoles,
  adminQueryconsole,
  billingCurrentPlan,
  billingInvoices,
  billingOrders,
  customDashboard,
  pulseEmail,
  pulseSms,
  pulseVoice,
  pulseGateway,
  pulseTemplate,
  myGroups,
  myFilters,
  myReports,
  ;
}

class CustomMenu {
  final String screenId;
  const CustomMenu({required this.screenId});
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

GlobalKey appKey = GlobalKey();

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
    } else if (kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)) {
      session.smallScreen = true;
    } else {
      session.smallScreen = false;
    }

    if (session.smallScreen && MediaQuery.of(context).size.width >= 1600) {
      session.smallScreen = false;
    }

    if (!session.smallScreen && MediaQuery.of(context).size.width <= 800) {
      session.smallScreen = true;
    }

    return MaterialApp.router(
      key: appKey,
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
  final Map<dynamic, ExpansionTileController> _expControllers =
      Map<dynamic, ExpansionTileController>();
  Widget? body;
  tapi.TwinUser? user;
  int _selectedClient = -1;
  bool firstTime = true;
  late StreamAuth auth;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String fullName = '';

  @override
  initState() {
    super.initState();
    menuItems.addAll(session.menuItems);
    menuItems.addAll(session.twinAppDisabled ? [] : _menuItems);
    showScreen(session.selectedMenu);
     themeNotifier.addListener(() {
      setState(() {});
    });
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

    if (null == _expControllers[item.id]) {
      _expControllers[item.id] = ExpansionTileController();
    }

    return ExpansionTile(
      key: Key(item.id.toString()),
      initiallyExpanded: item.expanded,
      //controller: _expControllers[item.id],
      onExpansionChanged: (expanded) {
        //_expanded[item.id] = expanded;
      },
      //maintainState: true,
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
    if (session.orgs.length > 1)
      _sideMenus.add(SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
            color: session.theme.getPrimaryColor(),
            child: Align(
                alignment: Alignment.centerLeft,
                child: OrgChangeWidget(onSelected: _switchOrg))),
      ));
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
      onDrawerChanged: (opened) {},
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
          if (!session.smallScreen && session.orgs.length > 1)
            OrgChangeWidget(onSelected: _switchOrg),
          if (!session.smallScreen && session.orgs.length > 1)
           const SizedBox(width: 4),
          if (!session.themeDisabled)
            Switch(
              value: themeNotifier.isDarkTheme,
              onChanged: (value) {
                themeNotifier.toggleTheme(value);
              },
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return  Icon(Icons.nightlight_round,
                        color: session.theme.getPrimaryColor());
                  }
                  return  Icon(Icons.wb_sunny, color:session.theme.getPrimaryColor());
                },
              ),
              activeColor: Colors.white,
              activeTrackColor: Colors.grey,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: session.theme.getSecondaryColor(),
            ),
          const SizedBox(width: 4),
          if (!session.smallScreen)
            Text(
              toCamelCase(user!.name),
              style: session.theme.getStyle().copyWith(color: Colors.white),
            ),
          if (session.smallScreen)
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: Text(
                getInitials(user!.name),
                style: session.theme.getStyle().copyWith(
                      color: session.theme.getPrimaryColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              setState(() {
                //TODO
                body = ProfileInfoScreen(
                  auth: auth,
                );
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
              flex: 20,
              child: DrawerHeader(
                margin: const EdgeInsets.only(bottom: 0.0),
                decoration: BoxDecoration(
                  color: session.theme.getPrimaryColor(),
                ),
                child: Column(
                  children: [
                    Row(
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
                                    child: TwinImageHelper.getCachedDomainImage(
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
                                              client:
                                                  _clients[_selectedClient]);
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
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 70,
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
  
  @override
  void dispose() {
    themeNotifier.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }

  String toCamelCase(String text) {
    return text.split(' ').map((word) {
      return word.isNotEmpty
          ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
          : '';
    }).join(' ');
  }

  String getInitials(String fullName) {
    String firstLetter = fullName.isNotEmpty ? fullName[0].toUpperCase() : '';
    int spaceIndex = fullName.indexOf(' ');
    if (spaceIndex != -1) {
      String secondLetter = fullName[spaceIndex + 1].toUpperCase();
      return '$firstLetter$secondLetter';
    }
    return firstLetter;
  }

  Future _switchOrg(tapi.OrgInfo o) async {
    await execute(() async {
      session.selectedOrg = session.orgs.indexOf(o);
      Storage.putString('preferred.orgId', o.id);
      TwinnedSession ts = TwinnedSession.instance;
      TwinnedSession.instance.init(
        debug: ts.debug,
        host: ts.host,
        authToken: o.twinAuthToken,
        domainKey: o.twinDomainKey,
        orgId: o.id,
        noCodeAuthToken: ts.noCodeAuthToken,
      );

      var oRes = await TwinnedSession.instance.nocode.getOrgPlan(orgId: o.id);
      if (validateResponse(oRes)) {
        session.orgPlan = oRes.body?.entity;
      }

      await TwinnedSession.instance.getUser();
      await _load();
      showScreen(session.homeMenu);
    });
  }

  void showScreen(dynamic id) async {
    closeDrawer();

    session.pageBottomMenus.clear();
    session.bottomMenuIndex = 0;
    session.selectedMenu = id;

    debugPrint('MENU: $id');
    session.TwinMenuItem? mi = _findMenuItem(menuItems, id);
    if (null != mi) {
      session.selectedMenuTitle = mi.text;
      body = await mi.onMenuSelected(context);
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
    BaseState.emitPageEvent(PageEvent.eventRebuild);
  }

  List<session.TwinMenuItem> get _menuItems {
    return [
      if (session.homeMenu == TwinAppMenu.home)
        session.TwinMenuItem(
          text: 'Home',
          id: TwinAppMenu.home,
          icon: Icons.dashboard,
          isMenuVisible: () {
            return true;
          },
          onMenuSelected: (ctx) async {
            return const Dashboard();
          },
        ),
      session.TwinMenuItem(
        text: 'Dashboard',
        id: TwinAppMenu.customDashboard,
        expanded: true,
        assetImage: 'images/twin.png',
        subItems: session.screenMenus,
        isMenuVisible: () {
          return session.screens.isNotEmpty;
        },
        onMenuSelected: (ctx) async {
          return SizedBox.shrink();
        },
      ),
      session.TwinMenuItem(
        text: 'My Groups',
        id: TwinAppMenu.myGroups,
        icon: Icons.group_add,
        isMenuVisible: () {
          return null != user;
        },
        onMenuSelected: (ctx) async {
          return AssetGroupList(target: tapi.AssetGroupInfoTarget.user);
        },
      ),
      session.TwinMenuItem(
        text: 'My Filters',
        id: TwinAppMenu.myFilters,
        icon: Icons.filter_alt_sharp,
        isMenuVisible: () {
          return null != user;
        },
        onMenuSelected: (ctx) async {
          return AssetFilterList(target: tapi.DataFilterInfoTarget.user);
        },
      ),
      session.TwinMenuItem(
        text: 'My Reports',
        id: TwinAppMenu.myReports,
        icon: Icons.menu_book,
        isMenuVisible: () {
          return !session.smallScreen;
        },
        onMenuSelected: (ctx) async {
          return AssetReportList(target: tapi.ReportInfoTarget.user);
        },
      ),
      session.TwinMenuItem(
        text: 'My Notifications',
        id: TwinAppMenu.myNotifications,
        icon: Icons.notification_add,
        isMenuVisible: () {
          return null != user;
        },
        onMenuSelected: (ctx) async {
          return AlarmsNotificationsGrid();
        },
      ),
      session.TwinMenuItem(
        text: 'My Subscriptions',
        id: TwinAppMenu.myEvents,
        icon: Icons.event_available,
        isMenuVisible: () {
          return null != user;
        },
        onMenuSelected: (ctx) async {
          return ProfileInfoScreen(
            key: Key(Uuid().v4()),
            selectedTab: 2,
            auth: auth,
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
        onMenuSelected: (ctx) async {
          return ProfileInfoScreen(
            key: Key(Uuid().v4()),
            selectedTab: 0,
            auth: auth,
          );
        },
      ),
      session.TwinMenuItem(
        text: 'Digital Twin',
        id: TwinAppMenu.twin,
        expanded: false,
        assetImage: 'images/twin.png',
        subItems: _twinSubMenuItems,
        isMenuVisible: () {
          return !session.smallScreen &&
              (session.isClientAdmin() || session.isAdmin());
        },
        onMenuSelected: (ctx) async {
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
          return !session.smallScreen &&
              (session.isClientAdmin() || session.isAdmin());
        },
        onMenuSelected: (ctx) async {
          return SizedBox.shrink();
        },
      ),
      session.TwinMenuItem(
        text: 'Billing',
        id: TwinAppMenu.billing,
        icon: Icons.currency_exchange,
        expanded: false,
        subItems: _billingSubMenuItems,
        isMenuVisible: () {
          return !session.smallScreen && session.isAdmin();
        },
        onMenuSelected: (ctx) async {
          return SizedBox.shrink();
        },
      ),
      session.TwinMenuItem(
        text: 'Pulse',
        id: TwinAppMenu.pulse,
        icon: Icons.monitor_heart_rounded,
        expanded: false,
        subItems: _pulseSubMenuItems,
        isMenuVisible: () {
          return !session.smallScreen && session.isAdmin();
        },
        onMenuSelected: (ctx) async {
          return SizedBox.shrink();
        },
      ),
    ];
  }

  List<session.TwinMenuItem> get _twinSubMenuItems {
    return [
      session.TwinMenuItem(
        id: TwinAppMenu.twinComponents,
        text: 'Components',
        icon: Icons.settings_input_component,
        bottomMenus: _twinBottomMenus(),
        isMenuVisible: () {
          return true;
        },
        onMenuSelected: (BuildContext context) async {
          return const Components();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.twinNoCodeBuilder,
        text: 'NoCode Builder',
        icon: Icons.tablet,
        bottomMenus: _twinBottomMenus(),
        isMenuVisible: () {
          return true;
        },
        onMenuSelected: (BuildContext context) async {
          return const NocodeBuilderPage();
        },
      ),
      if (!session.isClient())
        session.TwinMenuItem(
          id: TwinAppMenu.twinFontsColors,
          text: 'Fonts & Colors',
          icon: Icons.font_download,
          bottomMenus: _twinBottomMenus(),
          isMenuVisible: () {
            return session.isAdmin();
          },
          onMenuSelected: (BuildContext context) async {
            return const FontsAndColorSettingPage();
          },
        ),
      if (!session.isClient())
        session.TwinMenuItem(
          id: TwinAppMenu.twinLanding,
          text: 'Landing Pages',
          icon: Icons.pages,
          bottomMenus: _twinBottomMenus(),
          isMenuVisible: () {
            return session.isAdmin();
          },
          onMenuSelected: (BuildContext context) async {
            return const LandingContentPage();
          },
        ),
      if (session.isOrgOwner())
        session.TwinMenuItem(
          id: TwinAppMenu.twinOrganization,
          text: 'My Organization',
          icon: Icons.business,
          bottomMenus: _twinBottomMenus(),
          isMenuVisible: () {
            return session.isAdmin() &&
                TwinnedSession.instance.noCodeAuthToken.isNotEmpty;
          },
          onMenuSelected: (BuildContext context) async {
            return OrganizationPage(
              orgInfo: session.orgs[session.selectedOrg],
            );
          },
        ),
    ];
  }

  List<session.TwinMenuItem> get _adminSubMenuItems {
    return [
      session.TwinMenuItem(
        id: TwinAppMenu.adminUsers,
        text: 'Users',
        icon: Icons.group,
        bottomMenus: _adminBottomMenus(),
        isMenuVisible: () {
          return (session.isAdmin() || session.isClientAdmin());
        },
        onMenuSelected: (BuildContext context) async {
          return const Users();
        },
      ),
      if (!session.isClient())
        session.TwinMenuItem(
          id: TwinAppMenu.adminClients,
          text: 'Clients',
          icon: Icons.perm_contact_cal_outlined,
          bottomMenus: _adminBottomMenus(),
          isMenuVisible: () {
            return session.isAdmin();
          },
          onMenuSelected: (BuildContext context) async {
            return const Clients();
          },
        ),
      if (!session.isClient())
        session.TwinMenuItem(
          id: TwinAppMenu.adminRoles,
          text: 'Roles',
          icon: Icons.key,
          bottomMenus: _adminBottomMenus(),
          isMenuVisible: () {
            return session.isAdmin();
          },
          onMenuSelected: (BuildContext context) async {
            return const RolesPage();
          },
        ),
      if (!session.isClient())
        session.TwinMenuItem(
          id: TwinAppMenu.adminQueryconsole,
          text: 'Query Console',
          icon: Icons.wysiwyg,
          bottomMenus: _adminBottomMenus(),
          isMenuVisible: () {
            return session.isAdmin();
          },
          onMenuSelected: (BuildContext context) async {
            return QueryConsole();
          },
        ),
    ];
  }

  List<session.TwinMenuItem> get _billingSubMenuItems {
    return [
      session.TwinMenuItem(
        id: TwinAppMenu.billingCurrentPlan,
        text: 'Current Plan',
        icon: Icons.account_balance_wallet,
        bottomMenus: _billingBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) async {
          return const CurrentPlan();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.billingInvoices,
        text: 'Invoices',
        icon: Icons.monetization_on,
        bottomMenus: _billingBottomMenus(),
        isMenuVisible: () {
          //return session.isAdmin();
          //TODO implement this
          return false;
        },
        onMenuSelected: (BuildContext context) async {
          return const Invoices();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.billingOrders,
        text: 'Orders',
        icon: Icons.shopping_cart,
        bottomMenus: _billingBottomMenus(),
        isMenuVisible: () {
          //TODO implement this
          //return session.isAdmin();
          return false;
        },
        onMenuSelected: (BuildContext context) async {
          return const Orders();
        },
      ),
    ];
  }

  List<session.TwinMenuItem> get _pulseSubMenuItems {
    return [
      session.TwinMenuItem(
        id: TwinAppMenu.pulseEmail,
        text: 'Email',
        icon: Icons.email,
        bottomMenus: _pulseBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) async {
          return const EmailTabPage();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.pulseSms,
        text: 'SMS',
        icon: Icons.sms,
        bottomMenus: _pulseBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) async {
          return const SMSTabPage();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.pulseVoice,
        text: 'Voice',
        icon: Icons.voicemail,
        bottomMenus: _pulseBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) async {
          return const VoiceTabPage();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.pulseTemplate,
        text: 'Templates',
        icon: Icons.event_note,
        bottomMenus: _pulseBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) async {
          return const TemplatePage();
        },
      ),
      session.TwinMenuItem(
        id: TwinAppMenu.pulseGateway,
        text: 'Gateways',
        icon: Icons.settings,
        bottomMenus: _pulseBottomMenus(),
        isMenuVisible: () {
          return session.isAdmin();
        },
        onMenuSelected: (BuildContext context) async {
          return const ManageGateways();
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
      if (!session.isClient())
        const BottomMenuItem(
          id: TwinAppMenu.adminClients,
          icon: Icon(Icons.group, size: 30),
          label: 'Clients',
        ),
      if (!session.isClient())
        const BottomMenuItem(
          id: TwinAppMenu.adminRoles,
          icon: Icon(Icons.key, size: 30),
          label: 'Roles',
        ),
      if (session.isAdmin())
        const BottomMenuItem(
          id: TwinAppMenu.adminQueryconsole,
          icon: Icon(Icons.wysiwyg, size: 30),
          label: 'Query',
        ),
    ];
  }

  List<BottomMenuItem> _billingBottomMenus() {
    return [
      const BottomMenuItem(
        id: TwinAppMenu.billingCurrentPlan,
        icon: Icon(Icons.account_balance_wallet, size: 30),
        label: 'Current Plan',
      ),
      const BottomMenuItem(
        id: TwinAppMenu.billingInvoices,
        icon: Icon(Icons.monetization_on, size: 30),
        label: 'Invoices',
      ),
      const BottomMenuItem(
        id: TwinAppMenu.billingOrders,
        icon: Icon(Icons.shopping_cart, size: 30),
        label: 'Orders',
      ),
    ];
  }

  List<BottomMenuItem> _twinBottomMenus() {
    return [
      const BottomMenuItem(
        id: TwinAppMenu.twinComponents,
        icon: Icon(Icons.settings_input_component, size: 30),
        label: 'Comps',
      ),
      const BottomMenuItem(
        id: TwinAppMenu.twinNoCodeBuilder,
        icon: Icon(Icons.tablet, size: 30),
        label: 'Builder',
      ),
      if (!session.isClient())
        const BottomMenuItem(
          id: TwinAppMenu.twinFontsColors,
          icon: Icon(Icons.font_download_sharp, size: 30),
          label: 'Fonts',
        ),
      if (!session.isClient())
        const BottomMenuItem(
          id: TwinAppMenu.twinLanding,
          icon: Icon(Icons.pages, size: 30),
          label: 'Landing',
        ),
      if (session.isOrgOwner())
        const BottomMenuItem(
          id: TwinAppMenu.twinOrganization,
          icon: Icon(Icons.business, size: 30),
          label: 'Organization',
        ),
    ];
  }

  List<BottomMenuItem> _pulseBottomMenus() {
    return [
      const BottomMenuItem(
        id: TwinAppMenu.pulseEmail,
        icon: Icon(Icons.email, size: 30),
        label: 'Email',
      ),
      const BottomMenuItem(
        id: TwinAppMenu.pulseSms,
        icon: Icon(Icons.sms, size: 30),
        label: 'SMS',
      ),
      const BottomMenuItem(
        id: TwinAppMenu.pulseVoice,
        icon: Icon(Icons.voicemail, size: 30),
        label: 'Voice',
      ),
      const BottomMenuItem(
        id: TwinAppMenu.pulseTemplate,
        icon: Icon(Icons.event_note, size: 30),
        label: 'Template',
      ),
      const BottomMenuItem(
        id: TwinAppMenu.pulseGateway,
        icon: Icon(Icons.settings, size: 30),
        label: 'Gateway',
      ),
    ];
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _selectedClient = -1;
    _clients.clear();

    await execute(() async {
      {
        user = await TwinnedSession.instance.getUser();
        var clients = await TwinnedSession.instance.getClients();
        _clients.addAll(clients);
        if (_clients.isNotEmpty) {
          _selectedClient = 0;
        }
      }

      {
        session.screens.clear();
        session.screenMenus.clear();

        var sRes = await TwinnedSession.instance.twin.searchDashboardScreens(
          apikey: session.orgs[session.selectedOrg].twinAuthToken,
          body: const tapi.SearchReq(search: '*', size: 25, page: 0),
        );
        if (TwinHelper.validateResponse(sRes)) {
          session.screens.addAll(sRes.body?.values ?? []);
          debugPrint('FOUND ${session.screens.length} dashboards');
        }

        for (tapi.DashboardScreen ds in session.screens) {
          session.screenMenus.add(session.TwinMenuItem(
            id: CustomMenu(screenId: ds.id),
            text: ds.name,
            icon: Icons.menu,
            isMenuVisible: () {
              return true;
            },
            onMenuSelected: (BuildContext context) async {
              return TwinnedDashboardWidget(
                screen: ds,
                screenId: ds.id,
              );
            },
          ));
        }
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
