import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:provider/provider.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:string_validator/string_validator.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';

class BooleanStateProvider with ChangeNotifier {
  bool _isTrue = false;
  bool get isTrue => _isTrue;

  void check(bool val) {
    _isTrue = val;
    notifyListeners();
  }
}

class DeviceDataSimulator extends StatefulWidget {
  final String hardwareDeviceId;
  final String apiKey;
  final DeviceModel deviceModel;
  const DeviceDataSimulator(
      {super.key,
      required this.hardwareDeviceId,
      required this.apiKey,
      required this.deviceModel});

  @override
  State<DeviceDataSimulator> createState() => _DeviceDataSimulatorState();
}

class _DeviceDataSimulatorState extends BaseState<DeviceDataSimulator> {
  final List<TextEditingController> _controllers = [];
  final Map<String, Parameter> _parameters = {};
  final Map<String, dynamic> _data = {};
  final Map<String, Widget> _fields = {};
  final Map<String, String> _labels = {};
  final List<Widget> _children = [];

  @override
  void initState() {
    super.initState();

    for (Parameter p in widget.deviceModel.parameters) {
      _parameters[p.name] = p;

      switch (p.parameterType) {
        case ParameterParameterType.yesno:
          _fields[p.name] = _buildBooleanField(p.name);
          break;
        case ParameterParameterType.numeric:
          _fields[p.name] = _buildNumericField(p.name);
          break;
        case ParameterParameterType.floating:
          _fields[p.name] = _buildDecimalField(p.name);
          break;
        case ParameterParameterType.text:
          _fields[p.name] = _buildTextField(p.name);
          break;
        default:
          debugPrint('** UNIMPLEMENTED PARAMETER TYPE ${p.parameterType} **');
          continue;
      }

      _labels[p.name] =
          ((p.label != null && p.label!.isNotEmpty) ? p.label! : p.name);
    }

    _fields.forEach((key, value) {
      _children.add(Row(
        children: [
          Expanded(
              flex: 30,
              child: Text(
                _labels[key] ?? key,
                style: theme.getStyle(),
              )),
          const SizedBox(
            width: 8,
          ),
          Expanded(flex: 70, child: value),
        ],
      ));
      _children.add(const SizedBox(
        height: 4,
      ));
    });

    _children.add(Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const BusyIndicator(),
        const SizedBox(
          width: 8,
        ),
        SecondaryButton(
          minimumSize: Size(100, 40),
          labelKey: "Cancel",
          onPressed: () {
            _close();
          },
        ),
        divider(horizontal: true),
        PrimaryButton(
          minimumSize: Size(100, 40),
          labelKey: "Send",
          onPressed: () {
            _send();
          },
        ),
      ],
    ));
  }

  @override
  void dispose() {
    for (TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void setup() {}

  void _send() async {
    busy();
    try {
      _data.removeWhere((key, value) {
        if (null == value) return true;
        if (value is String) {
          String s = value;
          return s.isEmpty;
        }
        return false;
      });

      for (Parameter p in _parameters.values) {
        if (p.required && !_data.containsKey(p.name)) {
          alert('Missing', '${_labels[p.name]} is required');
          return;
        }
      }

      var res = await TwinnedSession.instance.twin.sendDeviceData(
          apikey: widget.apiKey,
          hardwareDeviceId: widget.hardwareDeviceId,
          body: _data);

      if (validateResponse(res)) {
        _close();
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    } finally {
      busy(busy: false);
    }
  }

  void _close() {
    Navigator.pop(context);
  }

  Widget _buildNumericField(String name) {
    TextEditingController controller = TextEditingController();
    _controllers.add(controller);
    controller.addListener(() {
      _data[name] = toInt(controller.text);
    });

    controller.text = _parameters[name]!.defaultValue ?? '';

    return TextField(
      style: theme.getStyle(),
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Numbers',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
    );
  }

  Widget _buildDecimalField(String name) {
    TextEditingController controller = TextEditingController();
    _controllers.add(controller);
    controller.addListener(() {
      _data[name] = toDouble(controller.text);
    });

    controller.text = _parameters[name]!.defaultValue ?? '';

    return TextField(style: theme.getStyle(),
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Decimal',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }

  Widget _buildBooleanField(String name) {
    _data[name] = (_parameters[name]!.defaultValue == 'true');

    return Align(
      alignment: Alignment.centerLeft,
      child: Transform.scale(
        scale: 0.7,
        child: Consumer<BooleanStateProvider>(
          builder: (BuildContext context, values, child) => Switch(
            value: _data[name],
            activeColor: Colors.blue,
            onChanged: (bool value) {
              values.check(value);
              _data[name] = value;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String name) {
    TextEditingController controller = TextEditingController();
    _controllers.add(controller);
    controller.addListener(() {
      _data[name] = controller.text;
    });

    controller.text = _parameters[name]!.defaultValue ?? '';

    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Text',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BooleanStateProvider())
      ],
      child: SizedBox(
        width: 600,
        child: Column(mainAxisSize: MainAxisSize.min, children: _children),
      ),
    );
  }

  void _showSimulatorDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Device Simulated Data'),
            content: Container(
              color: const Color(0xffffffff),
              child:
                  Column(mainAxisSize: MainAxisSize.min, children: _children),
            ),
          );
        });
  }
}
