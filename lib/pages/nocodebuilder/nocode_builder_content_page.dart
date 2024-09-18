import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/nocodebuilder/config_child_palatte.dart';
import 'package:twin_app/pages/nocodebuilder/config_dashboard_palette.dart';
import 'package:twin_app/pages/nocodebuilder/config_row_palatte.dart';
import 'package:twin_app/pages/nocodebuilder/widget_palatte.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:twinned_widgets/twinned_dashboard_widget.dart';
import 'package:twinned_widgets/twinned_widgets.dart';
import 'package:uuid/uuid.dart';

class NocodeBuilderContentPage extends StatefulWidget {
  final twinned.DashboardScreen entity;

  NocodeBuilderContentPage({super.key, required this.entity});

  @override
  State<NocodeBuilderContentPage> createState() =>
      _NocodeBuilderContentPageState();
}

class _NocodeBuilderContentPageState
    extends BaseState<NocodeBuilderContentPage> {
  bool editMode = true;
  int? selectedRow;
  int? selectedCol;
  final dashboard = GlobalKey<TwinnedDashboardWidgetState>();
  late twinned.DashboardScreen _entity;

  @override
  void initState() {
    _entity = widget.entity.copyWith();
    super.initState();
  }

  twinned.ScreenRow getSelectedRow() {
    return _entity.rows[selectedRow!];
  }

  twinned.ScreenChild getSelectedChild() {
    twinned.ScreenRow row = getSelectedRow();
    return row.children[selectedCol!];
  }

  @override
  Widget build(BuildContext context) {
    int bgColor = _entity.bgColor ?? Colors.white.value;

    if (bgColor <= 0) {
      bgColor = Colors.white.value;
    }

    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: 'Digital Twin - Dashboard - ${_entity.name}',
            style: theme.getStyle().copyWith(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const BusyIndicator(),
              divider(horizontal: true),
              if (editMode)
                PrimaryButton(
                  onPressed: () {
                    _save();
                  },
                  labelKey: 'Save',
                ),
              divider(horizontal: true),
              if (editMode)
                PrimaryButton(
                  onPressed: () {
                    _addNewRow();
                  },
                  labelKey: 'Add New Row',
                ),
              divider(horizontal: true),
              ToggleSwitch(
                minWidth: 90.0,
                initialLabelIndex: editMode ? 0 : 1,
                cornerRadius: 20.0,
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                totalSwitches: 2,
                icons: const [Icons.edit, Icons.remove_red_eye],
                activeBgColors: const [
                  [Colors.blue],
                  [Colors.pink]
                ],
                onToggle: (index) {
                  setState(() {
                    editMode = (index ?? 0) == 0;
                  });
                },
              ),
              divider(horizontal: true)
            ],
          ),
          divider(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: TwinnedDashboardWidget(
                    key: dashboard,
                    screen: _entity,
                    editMode: editMode,
                    selectedRow: selectedRow,
                    selectedCol: selectedCol,
                    onRowClicked: (selectedRow, row) {
                      setState(() {
                        this.selectedRow = selectedRow;
                        this.selectedCol = null;
                      });
                      debugPrint(
                          'CLICK Row:${this.selectedRow} Col:${this.selectedCol}');
                    },
                    onComponentClicked: (selectedRow, selectedCol, row, col) {
                      setState(() {
                        this.selectedRow = selectedRow;
                        this.selectedCol = selectedCol;
                      });
                      debugPrint(
                          'CLICK Row:${this.selectedRow} Col:${this.selectedCol}');
                    },
                  ),
                ),
                if (editMode)
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ConfigDashboardPalette(
                          screen: widget.entity,
                          onDashboardScreenSaved: (screen) {
                            _entity = screen;
                            refresh(sync: () {});
                            dashboard.currentState
                                ?.apply(_entity, selectedRow, selectedCol);
                          },
                        ),
                        if (null != selectedRow)
                          ConfigRowPalette(
                            key: Key(Uuid().v4()),
                            index: selectedRow!,
                            totalRows: _entity.rows.length,
                            row: getSelectedRow(),
                            onRowSaved: (rowIndex, row) {
                              _saveRow(rowIndex, row);
                            },
                            onRowDeleted: (rowIndex, row) {
                              _deleteRow(rowIndex);
                            },
                            onRowMovedUp: (rowIndex, row) {
                              _moveUp(rowIndex, row);
                            },
                            onRowMovedDown: (rowIndex, row) {
                              _moveDown(rowIndex, row);
                            },
                          ),
                        //divider(),
                        if (null != selectedRow && null != selectedCol)
                          ConfigChildPalette(
                            key: Key(Uuid().v4()),
                            rowIndex: selectedRow!,
                            columnIndex: selectedCol!,
                            totalColumns: getSelectedRow().children.length,
                            child: getSelectedChild(),
                            onChildDeleted: (rowIndex, columnIndex, child) {
                              _deleteWidget(rowIndex, columnIndex);
                            },
                            onChildSaved: (rowIndex, columnIndex, child) {
                              _updateWidget(rowIndex, columnIndex, child);
                            },
                            onMovedLeft: (row, col, child) {
                              _moveLeft(row, col, child);
                            },
                            onMovedRight: (row, col, child) {
                              _moveRight(row, col, child);
                            },
                          ),
                        divider(),
                        if (null != selectedRow)
                          Text(
                            'Widgets',
                            style: theme.getStyle().copyWith(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        divider(),
                        if (null != selectedRow)
                          WidgetPalette(
                            onPaletteWidgetPicked: (widgetId, builder) {
                              _addWidget(widgetId, builder);
                            },
                          ),
                      ],
                    ),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveRow(int rowIndex, twinned.ScreenRow row) {
    setState(() {
      _entity.rows[rowIndex] = row;
      _entity = _entity.copyWith();
    });
    dashboard.currentState?.apply(_entity, selectedRow, selectedCol);
  }

  void _moveUp(int rowIndex, twinned.ScreenRow row) {
    setState(() {
      var old = _entity.rows[rowIndex - 1];
      _entity.rows[rowIndex - 1] = row;
      _entity.rows[rowIndex] = old;
    });
    dashboard.currentState?.apply(_entity, selectedRow, selectedCol);
  }

  void _moveDown(int rowIndex, twinned.ScreenRow row) {
    setState(() {
      var old = _entity.rows[rowIndex + 1];
      _entity.rows[rowIndex + 1] = row;
      _entity.rows[rowIndex] = old;
    });
    dashboard.currentState?.apply(_entity, selectedRow, selectedCol);
  }

  void _deleteRow(int rowIndex) {
    super.confirm(
        title: 'Warning',
        message: 'Are you sure to delete this row?',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle(),
        onPressed: () {
          setState(() {
            selectedRow = null;
            selectedCol = null;
            _entity.rows.removeAt(rowIndex);
            _entity = _entity.copyWith();
            dashboard.currentState?.apply(_entity, selectedRow, selectedCol);
          });
        });
  }

  void _deleteWidget(int rowIndex, int columnIndex) {
    super.confirm(
        title: 'Warning',
        message: 'Are you sure to delete this widget?',
        titleStyle: theme
            .getStyle()
            .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
        messageStyle: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
        onPressed: () {
          setState(() {
            selectedCol = null;
            _entity.rows[rowIndex].children.removeAt(columnIndex);
            _entity = _entity.copyWith();
          });
          dashboard.currentState?.apply(_entity, selectedRow, selectedCol);
        });
  }

  void _updateWidget(int rowIndex, int columnIndex, twinned.ScreenChild child) {
    setState(() {
      _entity.rows[rowIndex].children[columnIndex] = child;
      _entity = _entity.copyWith();
    });
    dashboard.currentState?.apply(_entity, selectedRow, selectedCol);
  }

  void _moveLeft(int rowIndex, int columnIndex, twinned.ScreenChild child) {
    setState(() {
      var old = _entity.rows[rowIndex].children[columnIndex - 1];
      _entity.rows[rowIndex].children[columnIndex - 1] = child;
      _entity.rows[rowIndex].children[columnIndex] = old;
      _entity = _entity.copyWith();
    });
    dashboard.currentState?.apply(_entity, selectedRow, selectedCol);
  }

  void _moveRight(int rowIndex, int columnIndex, twinned.ScreenChild child) {
    setState(() {
      var old = _entity.rows[rowIndex].children[columnIndex + 1];
      _entity.rows[rowIndex].children[columnIndex + 1] = child;
      _entity.rows[rowIndex].children[columnIndex] = old;
      _entity = _entity.copyWith();
    });
    dashboard.currentState?.apply(_entity, selectedRow, selectedCol);
  }

  void _addWidget(String widgetId, TwinnedWidgetBuilder builder) {
    int row = selectedRow!;
    int? col = selectedCol;
    bool insert;
    if (null != col) {
      col = col + 1;
      insert = true;
    } else {
      insert = false;
      col = _entity.rows[row].children.length;
    }
    setState(() {
      twinned.ScreenChild child = twinned.ScreenChild(
          width: 400,
          height: 400,
          widgetId: widgetId,
          config: builder.getDefaultConfig().toJson());
      if (insert) {
        _entity.rows[row].children.insert(col!, child);
        _entity = _entity.copyWith();
      } else {
        _entity.rows[row].children.add(child);
        _entity = _entity.copyWith();
      }
      dashboard.currentState?.apply(_entity, selectedRow, selectedCol);
    });
  }

  Future _save() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.updateDashboardScreen(
          apikey: TwinnedSession.instance.authToken,
          screenId: widget.entity.id,
          body: twinned.DashboardScreenInfo(
            name: _entity.name,
            titleConfig: _entity.titleConfig,
            scrollDirection: _entity.scrollDirection,
            mainAxisAlignment: _entity.mainAxisAlignment,
            spacing: _entity.spacing,
            crossAxisAlignment: _entity.crossAxisAlignment,
            bgColor: _entity.bgColor,
            mainAxisSize: _entity.mainAxisSize,
            description: _entity.description,
            tags: _entity.tags,
            bannerImage: _entity.bannerImage,
            bgImage: _entity.bgImage,
            screenBorderConfig: _entity.screenBorderConfig,
            bgImageFit: _entity.bgImageFit,
            rows: _entity.rows,
            clientIds: _entity.clientIds,
            marginConfig: _entity.marginConfig,
            priority: _entity.priority,
            bannerImageFit: _entity.bannerImageFit,
            bannerHeight: _entity.bannerHeight,
            roles: _entity.roles,
            paddingConfig: _entity.paddingConfig,
          ));
      if (validateResponse(sRes)) {
        alert(
          'Dashboard - ${_entity.name}',
          'saved successfully',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
      } else {
        alert(
          'Error',
          'Unable to save, unknown failure',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
      }
    });

    loading = false;
    refresh();
  }

  void _addNewRow() {
    setState(() {
      List<twinned.ScreenChild> children = [];
      _entity.rows.add(
          twinned.ScreenRow(height: 400.0, spacing: 10.0, children: children));
      _entity = _entity.copyWith();
      selectedCol = null;
      selectedRow = _entity.rows.length - 1;
      //dashboard.currentState?.apply(_entity);
    });
    dashboard.currentState?.apply(_entity, selectedRow, selectedCol);
  }

  Future load() async {}

  @override
  void setup() {
    load();
  }
}
