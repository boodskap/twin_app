import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/asset_filters.dart';
import 'package:twin_app/pages/twin/components/asset_groups.dart';
import 'package:twin_app/pages/twin/components/asset_library.dart';
import 'package:twin_app/pages/twin/components/assets.dart';
import 'package:twin_app/pages/twin/components/condition_rules.dart';
import 'package:twin_app/pages/twin/components/device_library.dart';
import 'package:twin_app/pages/twin/components/events.dart';
import 'package:twin_app/pages/twin/components/facilities.dart';
import 'package:twin_app/pages/twin/components/floors.dart';
import 'package:twin_app/pages/twin/components/installation_database.dart';
import 'package:twin_app/pages/twin/components/premises.dart';
import 'package:twin_app/pages/twin/components/preprocessors.dart';
import 'package:twin_app/pages/twin/components/report.dart';
import 'package:twin_app/pages/twin/components/scrapping_tables.dart';
import 'package:twin_app/pages/twin/components/visual_alarms.dart';
import 'package:twin_app/pages/twin/components/visual_displays.dart';
import 'package:twin_app/pages/wrapper_page.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

class Components extends StatefulWidget {
  const Components({super.key});

  @override
  State<Components> createState() => _ComponentsState();
}

class _ComponentsState extends BaseState<Components> {
  final List<Widget> _list = [];
  final List<Widget> _children = [];

  @override
  void initState() {
    super.initState();

    _list.add(_createChild(
        icon: Icons.developer_board_rounded,
        title: 'Device Library',
        page: DeviceLibrary()));
    _list.add(_createChild(
        icon: Icons.memory_rounded,
        title: 'Installation Database',
        page: InstallationDatabase()));
    _list.add(_createChild(
        icon: Icons.departure_board_rounded,
        title: 'Asset Library',
        page: AssetLibrary()));
    _list.add(_createChild(
        icon: Icons.settings_display_sharp,
        title: 'Condition Rules',
        page: ConditionRules()));
    _list.add(_createChild(
        icon: Icons.doorbell_outlined,
        title: 'Visual Alarms',
        page: VisualAlarms()));
    _list.add(_createChild(
        icon: Icons.display_settings,
        title: 'Visual Displays',
        page: VisualDisplays()));
    _list.add(_createChild(
        icon: Icons.event_rounded,
        title: 'Events & Notifications',
        page: Events()));
    _list.add(_createChild(
        icon: Icons.settings_suggest,
        title: 'Preprocessors',
        page: Preprocessors()));
    _list.add(_createChild(
        icon: Icons.settings_suggest,
        title: 'Scrapping Tables',
        page: ScrappingTables()));
    _list.add(
        _createChild(icon: Icons.home, title: 'Premises', page: Premises()));
    _list.add(_createChild(
        icon: Icons.business, title: 'Facilities', page: Facilities()));
    _list.add(_createChild(icon: Icons.cabin, title: 'Floors', page: Floors()));
    _list.add(
        _createChild(icon: Icons.view_comfy, title: 'Assets', page: Assets()));
    _list.add(_createChild(
        icon: Icons.group_add, title: 'Asset Groups', page: AssetGroupList()));
    _list.add(_createChild(
        icon: Icons.filter_alt_sharp,
        title: 'Asset Filters',
        page: AssetFilterList(
          target: tapi.DataFilterInfoTarget.app,
        )));
    _list.add(_createChild(
        icon: Icons.menu_book,
        title: 'Custom Reports',
        page: AssetReportList()));

    _children.addAll(_list);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Flexible(
          child: SingleChildScrollView(
            child: Center(
              child: Wrap(
                spacing: 15,
                children: _children,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _createChild(
      {required IconData icon, required String title, required Widget page}) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Scaffold(
                      body: WrapperPage(
                        title: title,
                        child: page,
                      ),
                    )));
      },
      child: SizedBox(
        width: 250,
        height: 250,
        child: Card(
          elevation: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: theme.getPrimaryColor(),
                size: 48,
              ),
              divider(),
              Text(
                title,
                style: theme.getStyle().copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    overflow: TextOverflow.visible),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future setup() async {}
}
