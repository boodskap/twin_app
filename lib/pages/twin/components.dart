import 'package:flutter/Material.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
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
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';

class Components extends StatefulWidget {
  const Components({super.key});

  @override
  State<Components> createState() => _ComponentsState();
}

class _ComponentsState extends BaseState<Components> {
  static const double iconSize = 20.0;
  Widget? _screen;

  @override
  Widget build(BuildContext context) {
    if (null == _screen) return BusyIndicator();

    return Column(
      children: [_screen!],
    );
  }

  Future _load() async {
    execute(() async {
      double height = MediaQuery.of(context).size.width / 8 + 100;
      Color openColor = theme.getPrimaryColor();
      Color closedColor = Colors.black45;
      _screen = Flexible(
        child: ListView.builder(
            itemCount: 1,
            itemBuilder: (index, context) {
              return Accordion(
                contentBorderColor: Color(0xFF333333),
                contentBackgroundColor: Colors.white,
                contentBorderWidth: 1,
                scaleWhenAnimating: true,
                openAndCloseAnimation: true,
                maxOpenSections: 1,
                headerPadding:
                    const EdgeInsets.symmetric(vertical: 3.5, horizontal: 7.5),
                sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                sectionClosingHapticFeedback: SectionHapticFeedback.light,
                children: [
                  AccordionSection(
                      isOpen: true,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.developer_board_rounded,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Device Library',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: SingleChildScrollView(child: DeviceLibrary())),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.memory_rounded,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Installation Database',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content:
                          SingleChildScrollView(child: InstallationDatabase())),
                  AccordionSection(
                      isOpen: true,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.departure_board_rounded,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Asset Library',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: SingleChildScrollView(child: AssetLibrary())),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.settings_display_sharp,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Condition Rules',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: SingleChildScrollView(child: ConditionRules())),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.doorbell_outlined,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Visual Alarms',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: SizedBox(height: height, child: VisualAlarms())),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.display_settings,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Visual Displays',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content:
                          SizedBox(height: height, child: VisualDisplays())),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.event_rounded,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Events & Notification',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: SizedBox(height: height, child: Placeholder())),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.settings_suggest,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Preprocessors',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: SizedBox(
                          height: height,
                          child:
                              SingleChildScrollView(child: Preprocessors()))),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.settings_suggest,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Scrapping Tables',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: SizedBox(
                          height: height,
                          child:
                              SingleChildScrollView(child: ScrappingTables()))),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.home,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Premises',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: SizedBox(
                          height: height,
                          child: SingleChildScrollView(child: Premises()))),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.business,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Facilities',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: SizedBox(
                          height: height,
                          child: SingleChildScrollView(child: Facilities()))),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.cabin,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Floors',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: SizedBox(
                          height: height,
                          child: SingleChildScrollView(child: Floors()))),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.view_comfy,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Assets',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: SizedBox(
                          height: height,
                          child: SingleChildScrollView(child: Assets()))),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.group_add,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Asset Groups',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content:
                          SizedBox(height: height, child: AssetGroupList())),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.filter_alt_sharp,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Asset Filters',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content:
                          SizedBox(height: height, child: AssetFilterList())),
                  AccordionSection(
                      isOpen: false,
                      headerBackgroundColorOpened: openColor,
                      headerBackgroundColor: closedColor,
                      leftIcon: Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      header: Text('Custom Reports',
                          style: theme.getStyle().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content:
                          SizedBox(height: height, child: AssetReportList())),
                ],
              );
            }),
      );
      refresh();
    });
  }

  @override
  Future setup() async {
    _load();
  }
}
