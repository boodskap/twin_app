import 'package:eventify/eventify.dart' as event;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:twin_app/core/constants.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/device_data_simulator.dart';
import 'package:twin_app/pages/twin/components/widgets/map_alert.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twin_commons/core/twin_image_helper.dart';

class DeviceViewDefault extends StatefulWidget {
  final Device device;
  final DeviceModel deviceModel;
  final ValueNotifier<bool> location;
  const DeviceViewDefault(
      {super.key,
      required this.device,
      required this.deviceModel,
      required this.location});

  @override
  State<DeviceViewDefault> createState() => _DeviceViewDefaultState();
}

class _DeviceViewDefaultState extends BaseState<DeviceViewDefault> {
  bool includeGeoReverse = false;
  DeviceData? _data;
  final List<event.Listener> listeners = [];
  final List<Widget> _alarms = [];
  final List<Widget> _controls = [];
  final List<Widget> _displays = [];
  final List<Widget> _deviceInfo = [];
  final List<Widget> _deviceBody = [];

  double _topMenuHeight = 40;
  double _leftMenuWidth = 100;
  double _rightMenuWidth = 100;
  double _bottomMenuHeight = 40;
  double _width = 350;
  double _height = 350;

  @override
  void dispose() {
    for (event.Listener l in listeners) {
      BaseState.layoutEvents.off(l);
    }
    widget.location.removeListener(_hasLocationListener);
    super.dispose();
  }

  void _mqttdialog() async {
    try {
      String connectionInfo =
          getDeviceConnectionInfo(widget.device.deviceId, widget.device.apiKey);

      return showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController textEditingController = TextEditingController();
          textEditingController.text = connectionInfo;

          return AlertDialog(
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Mqtt / Http settings",
                          style: theme.getStyle().copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff000000),
                              ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: theme.getStyle(),
                            controller: textEditingController,
                            readOnly: true,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              // Add additional styling if needed
                            ),
                          ),
                        ),
                      ],
                    ),
                    divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: "Copy",
                          child: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: textEditingController.text),
                              );
                            },
                          ),
                        ),
                        SecondaryButton(
                          labelKey: 'Cancel',
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Handle error
      debugPrint('Error fetching MQTT connection info: $e');
    }
  }

  Future<void> _showMapDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return MapAlert(device: widget.device, deviceModel: widget.deviceModel);
      },
    );
  }

  @override
  void initState() {
    super.initState();

    listeners.add(BaseState.layoutEvents
        .on(PageEvent.twinMessageReceived.name, this, (e, o) {
      if (widget.device.deviceId == e.eventData) {
        debugPrint('*** REFRESHING ***');
        setup();
      }
    }));
    _buildDeviceInfo(widget.location.value);

    widget.location.addListener(_hasLocationListener);
  }

  void _hasLocationListener() {
    _deviceInfo.clear();
    _buildDeviceInfo(widget.location.value);
  }

  void _buildDeviceInfo(bool hasLocation) {
    Widget newCard = Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: "Device Connection Settings",
            child: IconButton(
              onPressed: () async {
                _mqttdialog();
              },
              icon: const Icon(Icons.power),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Visibility(
            visible: hasLocation,
            child: Tooltip(
              message: "Send mock location data",
              child: IconButton(
                onPressed: () async {
                  _showMapDialog(context);
                },
                icon: const Icon(Icons.location_on_outlined),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Tooltip(
            message: 'Send mock data',
            child: IconButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Simulate Device Data',
                          style: theme.getStyle(),
                        ),
                        content: SingleChildScrollView(
                          child: DeviceDataSimulator(
                            apiKey: widget.device.apiKey,
                            deviceModel: widget.deviceModel,
                            hardwareDeviceId: widget.device.deviceId,
                          ),
                        ),
                      );
                    });
                setup();
              },
              icon: const FaIcon(FontAwesomeIcons.solidPaperPlane),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Tooltip(
            message: 'Refresh',
            child: IconButton(
              onPressed: () {
                setup();
              },
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
            ),
          ),
        ],
      ),
    );

    setState(() {
      _deviceInfo.add(newCard);
    });
  }

  Future<void> _reload() async {
    _alarms.clear();
    _controls.clear();
    _displays.clear();
    //_deviceInfo.clear();
    _deviceBody.clear();

    try {
      var res = await TwinnedSession.instance.twin.getDeviceData(
          apikey: TwinnedSession.instance.authToken,
          isHardwareDevice: false,
          deviceId: widget.device.id);
      if (validateResponse(res)) {
        _data = res.body!.data;
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    await _loadMain();
    await _loadAlarms();
    await _loadControls();
    await _loadDisplays();

    setState(() {});
  }

  @override
  void setup() async {
    execute(() async {
      await _reload();
    });
  }

  Future<void> _loadMain() async {
    if (widget.deviceModel.selectedImage! >= 0 &&
        widget.deviceModel.selectedImage! < widget.deviceModel.images!.length) {
      // var image = Image.network(
      //   UserSession.twinImageUrl(baseUrl(), widget.deviceModel.domainKey,
      //       widget.deviceModel.images![widget.deviceModel.selectedImage!]),
      //   fit: BoxFit.cover,
      // );
      var image = TwinImageHelper.getCachedImage(widget.deviceModel.domainKey,
          widget.deviceModel.images![widget.deviceModel.selectedImage!],
          fit: BoxFit.cover);
      _deviceBody.add(Center(child: image));
    }
  }

  void _getAlarmState(Alarm alarm, Map<String, dynamic> params) {
    params['state'] = 0;
    params['tooltip'] = '';

    if (null != _data) {
      for (var a in _data!.alarms) {
        if (a.alarmId == alarm.id) {
          if (alarm.stateIcons!.length < a.state) {
            params['state'] = 0;
          } else {
            params['state'] = a.state;
          }
        }
      }
    }

    params['tooltip'] = alarm.conditions[params['state']].tooltip ?? alarm.name;
  }

  Future<void> _loadAlarms() async {
    var res = await TwinnedSession.instance.twin.listAlarms(
        apikey: TwinnedSession.instance.authToken,
        modelId: widget.deviceModel.id,
        body: const ListReq(page: 0, size: 10000));
    if (validateResponse(res)) {
      for (var alarm in res.body!.values!) {
        Map<String, dynamic> params = {};
        _getAlarmState(alarm, params);
        Widget image;
        if (params['state'] < 0) {
          image = Image.asset('images/new-alarm-icon.png', fit: BoxFit.cover);
        } else {
          // image = Image.network(
          //   UserSession.twinImageUrl(baseUrl(), widget.deviceModel.domainKey,
          //     alarm.stateIcons![params['state']]),
          // fit: BoxFit.cover,
          // );
          image = TwinImageHelper.getCachedImage(
            widget.deviceModel.domainKey,
            alarm.stateIcons![params['state']],
            fit: BoxFit.cover,
          );
        }
        _alarms.add(SizedBox(
          width: _topMenuHeight,
          height: _topMenuHeight,
          child: Tooltip(message: params['tooltip'] ?? '', child: image),
        ));
      }
    }
  }

  EvaluatedDisplay? _getEvaluatedDisplay(String displayId) {
    if (null != _data) {
      for (var d in _data!.displays) {
        if (d.displayId == displayId) {
          return d;
        }
      }
    }

    return null;
  }

  List<String> _getDisplayValues(String displayId, DisplayMatchGroup display) {
    if (null != _data) {
      for (var d in _data!.displays) {
        if (d.displayId == displayId) {
          return [d.prefix, d.$value, d.suffix];
        }
      }
    }

    return [
      display.prefixText ?? '',
      display.$value ?? '',
      display.suffixText ?? ''
    ];
  }

  Future<void> _loadDisplays() async {
    var res = await TwinnedSession.instance.twin.listDisplays(
        apikey: TwinnedSession.instance.authToken,
        modelId: widget.deviceModel.id,
        body: const ListReq(page: 0, size: 10000));
    if (validateResponse(res)) {
      for (var display in res.body!.values!) {
        EvaluatedDisplay? edisp = _getEvaluatedDisplay(display.id);
        var cond = display.conditions[edisp != null ? edisp.conditionIndex : 0];
        List<String> values = [];
        if (null != edisp) {
          values.add(edisp.prefix);
          values.add(edisp.$value);
          values.add(edisp.suffix);
        } else {
          values.add(cond.prefixText ?? '');
          values.add(cond.$value ?? '');
          values.add(cond.suffixText ?? '');
        }
        BoxDecoration? decoration;

        switch (cond.borderType) {
          case DisplayMatchGroupBorderType.box:
            decoration = BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.zero),
                color: Color(cond.bgColor!),
                border: Border.all(
                    style: BorderStyle.solid, color: Color(cond.bordorColor!)));
            break;
          case DisplayMatchGroupBorderType.rounded:
            decoration = BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.elliptical(_width, _height)),
                color: Color(cond.bgColor!),
                border: Border.all(
                    style: BorderStyle.solid, color: Color(cond.bordorColor!)));
            break;
          case DisplayMatchGroupBorderType.circle:
            decoration = BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(_width)),
                color: Color(cond.bgColor!),
                border: Border.all(
                    style: BorderStyle.solid, color: Color(cond.bordorColor!)));
            break;
          default:
            decoration = BoxDecoration(color: Color(cond.bgColor!));
        }

        var widget = RichText(
          text: TextSpan(children: [
            TextSpan(
              text: values[0],
              style: TextStyle(
                  fontFamily: cond.prefixFont!,
                  fontSize: cond.prefixFontSize!,
                  color: Color(cond.prefixFontColor!)),
            ),
            WidgetSpan(
                child: SizedBox(
              width: cond.prefixPadding,
            )),
            TextSpan(
              text: values[1],
              style: TextStyle(
                  fontFamily: cond.font,
                  fontSize: cond.fontSize,
                  color: Color(cond.fontColor)),
            ),
            WidgetSpan(
                child: SizedBox(
              width: cond.suffixPadding,
            )),
            TextSpan(
              text: values[2],
              style: TextStyle(
                  fontFamily: cond.suffixFont!,
                  fontSize: cond.suffixFontSize!,
                  color: Color(cond.suffixFontColor!)),
            ),
          ]),
        );

        _displays.add(SizedBox(
            width: cond.width,
            height: cond.height + 10,
            child: Container(
                decoration: decoration,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Tooltip(
                        message: cond.tooltip ?? display.name, child: widget),
                  ],
                ))));
      }
    }
  }

  Future<void> _loadControls() async {}

  @override
  Widget build(BuildContext context) {
    double width = _width;
    double height = _height;

    if (_controls.isNotEmpty) {
      width += _leftMenuWidth;
    }
    if (_displays.isNotEmpty) {
      width += _rightMenuWidth;
    }
    if (_alarms.isNotEmpty) {
      height += _topMenuHeight;
    }
    if (_deviceInfo.isNotEmpty) {
      height += _bottomMenuHeight;
    }

    return Card(
      color: const Color(0xffffffff),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: const Color(0xffffffff),
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              children: [
                if (_alarms.isNotEmpty)
                  SizedBox(
                    height: _topMenuHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _alarms,
                    ),
                  ),
                Row(
                  children: [
                    if (_controls.isNotEmpty)
                      SizedBox(
                        width: _leftMenuWidth,
                        height: _height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _controls,
                        ),
                      ),
                    SizedBox(
                      width: _width,
                      height: _height,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                alignment: Alignment.topLeft,
                                children: _deviceBody,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    if (_displays.isNotEmpty)
                      SizedBox(
                        width: _rightMenuWidth,
                        height: _height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _displays,
                        ),
                      ),
                  ],
                ),
                if (_deviceInfo.isNotEmpty)
                  SizedBox(
                    height: _bottomMenuHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _deviceInfo,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
