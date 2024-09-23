import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:uuid/uuid.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';

class VisualAlarmStatePage extends StatefulWidget {
  final tapi.DeviceModel model;
  final tapi.Alarm alarm;
  final tapi.AlarmMatchGroup group;
  const VisualAlarmStatePage({
    super.key,
    required this.model,
    required this.alarm,
    required this.group,
  });

  @override
  State<VisualAlarmStatePage> createState() => _VisualAlarmStatePageState();
}

class _VisualAlarmStatePageState extends BaseState<VisualAlarmStatePage> {
  // final Image _banner = Image.asset(
  //   'images/banner.png',
  //   fit: BoxFit.contain,
  // );

  final TextEditingController _tooltipController = TextEditingController();
  tapi.AlarmMatchGroupMatchType matchType = tapi.AlarmMatchGroupMatchType.all;
  Widget stateIcon = const Icon(Icons.cloud_upload);
  Widget deviceImage = const Icon(
    Icons.question_mark,
    size: 100,
  );
  int selectedDeviceImage = 0;
  bool hasStateIcon = false;
  final List<tapi.Condition> _conditions = [];
  final List<tapi.Condition> _selected = [];
  final List<DropdownMenuItem<tapi.Condition>> _entries = [];

  @override
  void initState() {
    _tooltipController.text = widget.group.tooltip ?? '';
    matchType = widget.group.matchType;
    selectedDeviceImage = widget.model.selectedImage ?? 0;
    if (selectedDeviceImage < 0) {
      selectedDeviceImage = 0;
    }

    super.initState();
  }

  @override
  void setup() async {
    var res = await TwinnedSession.instance.twin.listConditions(
      apikey: TwinnedSession.instance.authToken,
      modelId: widget.alarm.modelId,
      body: const tapi.ListReq(page: 0, size: 10000),
    );

    if (validateResponse(res)) {
      _conditions.addAll(res.body!.values!);
    }

    for (var cond in _conditions) {
      if (widget.group.conditions.contains(cond.id)) {
        _selected.add(cond);
      }
    }
    refresh();
  }

  Future _save() async {
    List<String>? clientIds = super.isClientAdmin()
        ? await TwinnedSession.instance.getClientIds()
        : null;

    busy();
    try {
      tapi.AlarmMatchGroup g = tapi.AlarmMatchGroup(
          tooltip: _tooltipController.text,
          deviceState: selectedDeviceImage,
          matchType: matchType,
          conditions: widget.group.conditions,
          alarmState: widget.group.alarmState);

      widget.alarm.conditions[widget.group.alarmState] = g;

      var res = await TwinnedSession.instance.twin.updateAlarm(
          apikey: TwinnedSession.instance.authToken,
          alarmId: widget.alarm.id,
          body: tapi.AlarmInfo(
            name: widget.alarm.name,
            description: widget.alarm.description,
            label: widget.alarm.label,
            tags: widget.alarm.tags,
            stateIcons: widget.alarm.stateIcons,
            showOnlyIfMatched: true,
            modelId: widget.alarm.modelId,
            state: widget.alarm.state,
            conditions: widget.alarm.conditions,
            clientIds: clientIds ?? widget.alarm.clientIds,
            deviceId: widget.alarm.deviceId,
          ));
      if (validateResponse(res)) {
        await alert('Alarm - ${widget.alarm.name}', 'Saved successfully!',
            contentStyle: theme.getStyle(),
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
        _close();
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    busy(busy: false);
  }

  void _close() {
    Navigator.pop(context);
  }

  Future _uploadIcon() async {
    var res = await TwinImageHelper.uploadAlarmIcon(alarmId: widget.alarm.id);
    if (null != res) {
      if ((widget.alarm.stateIcons?.length ?? 0) > widget.group.alarmState) {
        widget.alarm.stateIcons![widget.group.alarmState] = res.entity!.id;
      } else {
        widget.alarm.stateIcons!.add(res.entity!.id);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.alarm.stateIcons?.length ?? 0) > widget.group.alarmState) {
      hasStateIcon = true;
      stateIcon = TwinImageHelper.getCachedImage(widget.alarm.domainKey,
          widget.alarm.stateIcons![widget.group.alarmState]);
    } else {
      hasStateIcon = false;
    }

    if ((widget.model.images?.length ?? 0) > selectedDeviceImage) {
      deviceImage = TwinImageHelper.getCachedImage(
          widget.model.domainKey, widget.model.images![selectedDeviceImage]);
    }
    _entries.clear();
    for (var cond in _conditions) {
      if (widget.group.conditions.contains(cond.id)) continue;
      _entries.add(DropdownMenuItem(
        value: cond,
        child: Text(
          cond.name,
          style: theme.getStyle(),
        ),
      ));
    }

    return Scaffold(
        body: Column(
      children: [
        TopBar(
          title:
              '${widget.alarm.name} Alarm State - ${widget.group.alarmState}',
          style: theme.getStyle().copyWith(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        divider(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SecondaryButton(
              labelKey: 'Cancel',
              onPressed: () {
                _close();
              },
            ),
            divider(horizontal: true),
            if (hasStateIcon && widget.group.conditions.isNotEmpty)
              PrimaryButton(
                labelKey: 'Save',
                onPressed: () async {
                  await _save();
                },
              ),
            divider(horizontal: true),
          ],
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'IF',
                  style: theme
                      .getStyle()
                      .copyWith(fontSize: 24, color: Colors.blue),
                ),
                divider(horizontal: true, width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(5)),
                      child: DropdownButton<tapi.Condition>(
                        style: theme.getStyle(),
                        key: Key(Uuid().v4()),
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        dropdownColor: Colors.white,
                        isDense: true,
                        underline: Container(),
                        hint: Text(
                          "Choose Condition",
                          style: theme.getStyle(),
                        ),
                        items: _entries,
                        onChanged: (tapi.Condition? value) {
                          if (null != value) {
                            setState(() {
                              _selected.add(value);
                              widget.group.conditions.add(value.id);
                            });
                          }
                        },
                      ),
                    ),
                    divider(),
                    SizedBox(
                      width: 200,
                      height: _selected.length * 50,
                      child: ListView.builder(
                          key: Key(const Uuid().v4()),
                          itemCount: _selected.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 200,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Chip(
                                  labelStyle: theme.getStyle(),
                                  label: Text(_selected[index].name),
                                  onDeleted: () {
                                    setState(() {
                                      var cond = _selected.removeAt(index);
                                      widget.group.conditions.remove(cond.id);
                                    });
                                  },
                                ),
                              ),
                            );
                          }),
                    )
                  ],
                ),
                divider(horizontal: true, width: 8),
                if (widget.group.conditions.isNotEmpty)
                  Text(
                    'MATCHES',
                    style: theme
                        .getStyle()
                        .copyWith(fontSize: 24, color: Colors.green),
                  ),
                divider(horizontal: true, width: 16),
                if (widget.group.conditions.isNotEmpty)
                  AlarmMatchTypeDropDown(
                    selected: matchType,
                    selectionChanged: (tapi.AlarmMatchGroupMatchType selected) {
                      setState(() {
                        matchType = selected;
                      });
                    },
                  ),
                divider(horizontal: true, width: 16),
                if (widget.group.conditions.isNotEmpty)
                  Text(
                    'THEN',
                    style: theme
                        .getStyle()
                        .copyWith(fontSize: 24, color: Colors.red),
                  ),
                divider(horizontal: true, width: 16),
                if (widget.group.conditions.isNotEmpty)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasStateIcon)
                        SizedBox(
                            width: 45,
                            height: 45,
                            child: InkWell(
                              onTap: () async {
                                await _uploadIcon();
                              },
                              child: Tooltip(
                                  message: 'Change icon', child: stateIcon),
                            )),
                      if (!hasStateIcon)
                        PrimaryButton(
                          labelKey: 'Upload',
                          onPressed: () async {
                            await _uploadIcon();
                          },
                          leading: Icon(Icons.cloud_upload,
                              color: Colors.white, size: 15),
                        ),
                      divider(height: 8),
                      SizedBox(
                        width: 150,
                        child: LabelTextField(
                          style: theme.getStyle(),
                          labelTextStyle: theme.getStyle(),
                          label: 'Tooltip',
                          controller: _tooltipController,
                        ),
                      ),
                    ],
                  ),
                divider(horizontal: true, width: 16),
                // if (widget.group.conditions.isNotEmpty &&
                //     ((widget.model.images?.length ?? 0) > 0))
                //   Text(
                //     'DEVICE',
                //     style: theme
                //         .getStyle()
                //         .copyWith(fontSize: 24, color: Colors.orange),
                //   ),
                // divider(horizontal: true, width: 16),
                // if (widget.group.conditions.isNotEmpty &&
                //     ((widget.model.images?.length ?? 0) > 0))
                //   NumberDropDown(
                //       max: widget.model.images?.length ?? 0,
                //       selected: selectedDeviceImage,
                //       selectionChanged: (index) {
                //         setState(() {
                //           selectedDeviceImage = index;
                //         });
                //       }),
                // divider(horizontal: true, width: 16),
                // if (widget.group.conditions.isNotEmpty &&
                //     ((widget.model.images?.length ?? 0) > 0))
                //   SizedBox(width: 250, height: 250, child: deviceImage),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class AlarmMatchTypeDropDown extends StatefulWidget {
  tapi.AlarmMatchGroupMatchType selected;
  final void Function(tapi.AlarmMatchGroupMatchType) selectionChanged;
  AlarmMatchTypeDropDown(
      {super.key, required this.selected, required this.selectionChanged});

  @override
  State<AlarmMatchTypeDropDown> createState() => _AlarmMatchTypeDropDownState();
}

class _AlarmMatchTypeDropDownState extends State<AlarmMatchTypeDropDown> {
  final List<DropdownMenuItem<tapi.AlarmMatchGroupMatchType>> _items = [];

  @override
  void initState() {
    _items.add(DropdownMenuItem<tapi.AlarmMatchGroupMatchType>(
        value: tapi.AlarmMatchGroupMatchType.any,
        child: Text(
          'Any',
          style: theme.getStyle(),
        )));
    _items.add(DropdownMenuItem<tapi.AlarmMatchGroupMatchType>(
        value: tapi.AlarmMatchGroupMatchType.all,
        child: Text(
          'All',
          style: theme.getStyle(),
        )));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<tapi.AlarmMatchGroupMatchType>(
        style: theme.getStyle(),
        value: widget.selected,
        items: _items,
        onChanged: (value) {
          setState(() {
            widget.selected = value ?? tapi.AlarmMatchGroupMatchType.all;
            widget.selectionChanged(widget.selected);
          });
        });
  }
}

class NumberDropDown extends StatefulWidget {
  final int min;
  final int max;
  int selected;
  final void Function(int) selectionChanged;
  NumberDropDown(
      {super.key,
      this.min = 0,
      required this.max,
      required this.selected,
      required this.selectionChanged});

  @override
  State<NumberDropDown> createState() => _NumberDropDownState();
}

class _NumberDropDownState extends State<NumberDropDown> {
  final List<DropdownMenuItem<int>> _items = [];

  @override
  void initState() {
    for (int i = widget.min; i < widget.max; i++) {
      _items.add(DropdownMenuItem<int>(
          value: i,
          child: Text(
            'State $i',
            style: theme.getStyle(),
          )));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
        style: theme.getStyle(),
        value: widget.selected,
        items: _items,
        onChanged: (value) {
          setState(() {
            widget.selected = value ?? widget.min;
            widget.selectionChanged(widget.selected);
          });
        });
  }
}
