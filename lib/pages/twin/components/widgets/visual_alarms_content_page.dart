import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/pages/twin/components/widgets/showoverlay_widget.dart';
import 'package:twin_app/pages/twin/components/widgets/utils.dart';
import 'package:twin_app/pages/twin/components/widgets/visual_alarm_state_page.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:uuid/uuid.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_app/core/session_variables.dart';

class VisualAlarmsContentPage extends StatefulWidget {
  final tapi.DeviceModel model;
  final tapi.Alarm alarm;

  const VisualAlarmsContentPage(
      {super.key, required this.model, required this.alarm});

  @override
  State<VisualAlarmsContentPage> createState() =>
      _VisualAlarmsContentPageState();
}

class _VisualAlarmsContentPageState extends BaseState<VisualAlarmsContentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  final List<Widget> _cards = [];

  @override
  void setup() {
    _nameController.text = widget.alarm.name;
    _descController.text = widget.alarm.description!;
    _tagsController.text = widget.alarm.tags!.join(" ");
    _load();
  }

  Future _add() async {
    await execute(() async {
      var group = tapi.AlarmMatchGroup(
          matchType: tapi.AlarmMatchGroupMatchType.all,
          conditions: [],
          alarmState: widget.alarm.conditions.length);
      widget.alarm.conditions.add(group);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisualAlarmStatePage(
              key: Key(Uuid().v4()),
              model: widget.model,
              alarm: widget.alarm,
              group: group),
        ),
      );
      _load();
    });
  }

  void _load() {
    final List<Widget> cards = [];
    for (var group in widget.alarm.conditions) {
      cards.add(_buildCard(group));
    }
    refresh(sync: () {
      _cards.clear();
      _cards.addAll(cards);
    });
  }

  void _delete(int group) async {
    await confirm(
        title: 'Warning',
        message: 'Are you sure to delete this alarm state?',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle(),
        onPressed: () async {
          await execute(() async {
            if (widget.alarm.stateIcons!.length > group) {
              TwinnedSession.instance.twin.deleteImage(
                  apikey: TwinnedSession.instance.authToken,
                  id: widget.alarm.stateIcons![group]);
              widget.alarm.stateIcons!.removeAt(group);
            }

            widget.alarm.conditions.removeAt(group);

            var res = await TwinnedSession.instance.twin.updateAlarm(
                apikey: TwinnedSession.instance.authToken,
                alarmId: widget.alarm.id,
                body: Utils.alarmInfo(widget.alarm));

            if (validateResponse(res)) {
              _load();
            }
          });
        });
  }

  Widget _buildCard(tapi.AlarmMatchGroup group) {
    Widget icon = const Icon(
      Icons.question_mark,
      size: 45,
    );
    if (widget.alarm.stateIcons!.length > group.alarmState) {
      icon = TwinImageHelper.getCachedImage(
          widget.alarm.domainKey, widget.alarm.stateIcons![group.alarmState]);
    }
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onDoubleTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisualAlarmStatePage(
                  key: Key(Uuid().v4()),
                  model: widget.model,
                  alarm: widget.alarm,
                  group: group),
            ),
          );
          _load();
        },
        child: SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'State ${group.alarmState}',
                    style: theme.getStyle().copyWith(
                        color: Colors.black, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () {
                        _delete(group.alarmState);
                      },
                      icon: const Icon(Icons.delete_forever))),
              Center(child: SizedBox(width: 65, height: 65, child: icon)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: 'Alarm - ${widget.alarm.name}',
            style: theme.getStyle().copyWith(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          divider(),
          Row(
            children: [
              divider(horizontal: true),
              Expanded(
                flex: 2,
                child: LabelTextField(
                  labelTextStyle: theme.getStyle(),
                  style: theme.getStyle(),
                  suffixIcon: Tooltip(
                    message: 'Copy alarm id',
                    preferBelow: false,
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: widget.alarm!.id),
                        );
                        OverlayWidget.showOverlay(
                          context: context,
                          topPosition: 130,
                          leftPosition: 250,
                          message: 'Alarm id copied!',
                        );
                      },
                      child: const Icon(
                        Icons.content_copy,
                        size: 20,
                      ),
                    ),
                  ),
                  label: 'Alarm Name',
                  controller: _nameController,
                ),
              ),
              divider(horizontal: true),
              Expanded(
                  flex: 4,
                  child: LabelTextField(
                    style: theme.getStyle(),
                    labelTextStyle: theme.getStyle(),
                    label: 'Description',
                    controller: _descController,
                  )),
              divider(horizontal: true),
              Expanded(
                flex: 1,
                child: LabelTextField(
                  style: theme.getStyle(),
                  labelTextStyle: theme.getStyle(),
                  textInputAction: TextInputAction.next,
                  label: 'Tags',
                  controller: _tagsController,
                ),
              ),
              BusyIndicator(),
              divider(horizontal: true),
            ],
          ),
          divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SecondaryButton(
                labelKey: 'Cancel',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              divider(
                horizontal: true,
              ),
              PrimaryButton(
                labelKey: 'Add New State',
                onPressed: () async {
                  await _add();
                },
              ),
              divider(horizontal: true),
            ],
          ),
          if (_cards.isNotEmpty)
            Expanded(
              flex: 1,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    itemCount: _cards.length,
                    itemBuilder: (ctx, index) {
                      return _cards[index];
                    },
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
