import 'package:flutter/Material.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/asset_library.dart';
import 'package:twin_app/pages/twin/components/condition_rules.dart';
import 'package:twin_app/pages/twin/components/device_library.dart';
import 'package:twin_app/pages/twin/components/installation_database.dart';
import 'package:twin_app/pages/twin/components/visual_alarms.dart';
import 'package:twin_app/pages/twin/components/visual_displays.dart';
import 'package:twin_commons/util/nocode_utils.dart';

class Components extends StatefulWidget {
  const Components({super.key});

  @override
  State<Components> createState() => _ComponentsState();
}

class _ComponentsState extends State<Components> {
  static const double iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 2;
    Color openColor = theme.getPrimaryColor();
    Color closedColor = Colors.black45;

    return Column(
      children: [
        Flexible(
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
                  headerPadding: const EdgeInsets.symmetric(
                      vertical: 3.5, horizontal: 7.5),
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
                        content:
                            SizedBox(height: height, child: DeviceLibrary())),
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
                        content: InstallationDatabase()),
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
                        content:
                            SizedBox(height: height, child: AssetLibrary())),
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
                        content:
                            SizedBox(height: height, child: ConditionRules())),
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
                        content:
                            SizedBox(height: height, child: VisualAlarms())),
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
                        content:
                            SizedBox(height: height, child: Placeholder())),
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
                        content:
                            SizedBox(height: height, child: Placeholder())),
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
                        content:
                            SizedBox(height: height, child: Placeholder())),
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
                        content:
                            SizedBox(height: height, child: Placeholder())),
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
                        content:
                            SizedBox(height: height, child: Placeholder())),
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
                        content:
                            SizedBox(height: height, child: Placeholder())),
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
                        content:
                            SizedBox(height: height, child: Placeholder())),
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
                            SizedBox(height: height, child: Placeholder())),
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
                            SizedBox(height: height, child: Placeholder())),
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
                            SizedBox(height: height, child: Placeholder())),
                  ],
                );
              }),
        ),
      ],
    );
  }
}
