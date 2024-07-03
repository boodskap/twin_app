import 'package:collapsible_sidebar/collapsible_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';

class ThemeCollapsibleSidebar extends StatefulWidget {
  final String title;
  final List<CollapsibleItem> items;
  final Widget? avatarImg;
  final Widget? body;
  const ThemeCollapsibleSidebar({
    super.key,
    required this.title,
    required this.items,
    this.avatarImg,
    this.body,
  });

  @override
  State<ThemeCollapsibleSidebar> createState() =>
      ThemeCollapsibleSidebarState();
}

class ThemeCollapsibleSidebarState extends BaseState<ThemeCollapsibleSidebar> {
  bool _isSidebarOpen = !smallScreen;
  Widget? body;

  @override
  void initState() {
    super.initState();
    body = onMenuSelected(homeMenu);
  }

  void showScreen(dynamic id) {
    setState(() {
      body = onMenuSelected(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isSidebarOpen)
          Column(
            children: [
              SizedBox(
                height: 0,
              ),
              Expanded(
                child: CollapsibleSidebar(
                  showToggleButton: true,
                  toggleButtonIcon: Icons.toggle_off,
                  isCollapsed: true,
                  items: widget.items,
                  avatarImg: widget.avatarImg,
                  title: widget.title,
                  showTitle: false,
                  topPadding: 15,
                  onTitleTap: () {},
                  body: body ?? Placeholder(),
                  selectedIconBox: Colors.transparent,
                  unselectedTextColor: theme.menuColor,
                  unselectedIconColor: theme.menuColor,
                  backgroundColor: theme.getPrimaryColor(),
                  selectedTextColor: theme.selectedMenuColor,
                  selectedIconColor: theme.selectedMenuColor,
                  textStyle: theme.getStyle().copyWith(fontSize: 15),
                  titleStyle: theme
                      .getStyle()
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  toggleTitle: widget.title,
                  iconSize: 25,
                  toggleTitleStyle: theme
                      .getStyle()
                      .copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                  sidebarBoxShadow: [
                    BoxShadow(
                      color: theme.getPrimaryColor(),
                      blurRadius: 20,
                      spreadRadius: 0.01,
                      offset: Offset(3, 3),
                    ),
                    BoxShadow(
                      color: theme.getIntermediateColor(),
                      blurRadius: 50,
                      spreadRadius: 0.01,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        if (!_isSidebarOpen) body ?? Placeholder(),
        Positioned(
          top: -5,
          left: 10,
          child: IconButton(
            icon: Icon(Icons.menu, color: Colors.black54, size: 30),
            onPressed: () {
              setState(() {
                _isSidebarOpen = !_isSidebarOpen;
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  void setup() {}
}
