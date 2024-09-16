import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/pulse/widgets/gateway_dropdown.dart';
import 'package:twin_app/widgets/commons/pulse_email_group_dropdown.dart';
import 'package:twin_app/widgets/commons/pulse_gateway_dropdown.dart';
import 'package:twin_app/widgets/commons/pulse_sms_group_dropdown.dart';
import 'package:twin_app/widgets/commons/pulse_voice_group_dropdown.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:timezone_dropdown/timezone_dropdown.dart';

class AddEditGateway extends StatefulWidget {
  final pulse.GatewayConfig? config;
  const AddEditGateway({super.key, this.config});

  @override
  State<AddEditGateway> createState() => _AddEditGatewayState();
}

class _AddEditGatewayState extends BaseState<AddEditGateway> {
  static final TextInputFormatter digitsOnly =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
  static final TextInputFormatter decimalOnly =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'));

  static final TextInputFormatter emailOnly = FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-Z0-9@._]'),
  );

  late pulse.GatewayConfigInfo _config;
  pulse.Gateway? _gateway;
  final List<Widget> _children = [];
  final List<TextEditingController> _controllers = [];
  final Map<String, pulse.GatewayParam> _params =
      <String, pulse.GatewayParam>{};

  String countryCode = 'US';

  @override
  void initState() {
    super.initState();
    if (null == widget.config) {
      _config = const pulse.GatewayConfigInfo(
        gatewayId: '',
        parameters: [],
      );
    } else {
      _config = pulse.GatewayConfigInfo(
        gatewayId: widget.config!.gatewayId,
        parameters: widget.config!.parameters,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (TextEditingController c in _controllers) {
      c.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            divider(),
            if (null == widget.config)
              GatewayDropdown(
                selectedItem:
                    _config.gatewayId.isEmpty ? null : _config.gatewayId,
                onGatewaySelected: (e) async {
                  _gateway = e;
                  if (null == e) {
                    _config = _config.copyWith(gatewayId: '');
                  } else {
                    _config = _config.copyWith(gatewayId: e!.id);
                  }
                  await _load();
                },
              ),
            divider(),
            SingleChildScrollView(child: Column(children: _children)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const BusyIndicator(),
                divider(horizontal: true),
                PrimaryButton(
                  labelKey: null == widget.config ? 'Create' : 'Save',
                  onPressed: _canSave()
                      ? () async {
                          await _save();
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameter(pulse.GatewayParam param) {
    TextEditingController c = TextEditingController();
    if (isClient()) {
      getClientIds().then((clientIds) {
        if (clientIds.isNotEmpty) {
          c.text = clientIds.first;

          setState(() {});
        }
      });
    } else {
      c.text = '';
    }

    _controllers.add(c);

    c.addListener(() {
      setState(() {
        param = param.copyWith($value: c.text.trim());
        _params[param.name] = param;
      });
    });
    c.text = param.$value;

    switch (param.type) {
      case pulse.GatewayParamType.swaggerGeneratedUnknown:
      case pulse.GatewayParamType.string:
        return LabelTextField(
          label: (param.description?.isNotEmpty ?? false)
              ? param.description!
              : param.name,
          controller: c,
          readOnlyVal: !param.editable,
        );
      case pulse.GatewayParamType.number:
        return LabelTextField(
          label: (param.description?.isNotEmpty ?? false)
              ? param.description!
              : param.name,
          controller: c,
          readOnlyVal: !param.editable,
          inputFormatters: [digitsOnly],
          keyboardType: const TextInputType.numberWithOptions(
              signed: true, decimal: true),
        );
      case pulse.GatewayParamType.decimal:
        return LabelTextField(
          label: (param.description?.isNotEmpty ?? false)
              ? param.description!
              : param.name,
          controller: c,
          readOnlyVal: !param.editable,
          inputFormatters: [decimalOnly],
          keyboardType: const TextInputType.numberWithOptions(
              signed: true, decimal: true),
        );
      case pulse.GatewayParamType.boolean:
        return Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Checkbox(
                value: param.$value.toLowerCase() == 'true',
                // value: bool.parse(param.$value),
                onChanged: (v) {
                  if (!param.editable) return;
                  setState(() {
                    param =
                        param.copyWith($value: (v ?? false) ? 'true' : 'false');
                    _params[param.name] = param;
                  });
                }),
            Text(
              (param.description?.isNotEmpty ?? false)
                  ? param.description!
                  : param.name,
              style: theme.getStyle(),
            ),
          ],
        );
      case pulse.GatewayParamType.email:
        return LabelTextField(
          label: (param.description?.isNotEmpty ?? false)
              ? param.description!
              : param.name,
          controller: c,
          readOnlyVal: !param.editable,
          inputFormatters: [emailOnly],
          keyboardType: TextInputType.emailAddress,
        );
      case pulse.GatewayParamType.phoneNumber:
        return SizedBox(
          width: MediaQuery.of(context).size.width / 2.5,
          child: IntlPhoneField(
            controller: c,
            keyboardType: TextInputType.phone,
            initialCountryCode: countryCode,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: 'Phone Number',
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: theme.getPrimaryColor(),
                ),
              ),
            ),
            validator: (phone) {
              if (phone == null || phone.number.isEmpty) {
                return 'Enter a valid phone number';
              }
              return null;
            },
            onChanged: (phone) {
              setState(() {
                countryCode = phone.countryISOCode;
              });
            },
            onCountryChanged: (country) {
              setState(() {
                countryCode = country.code;
              });
            },
          ),
        );
      case pulse.GatewayParamType.timezone:
        return TimezoneDropdown(
          hintText: 'Select Time Zone',
          onTimezoneSelected: (selectedTimezone) {
            setState(() {});
          },
        );
      case pulse.GatewayParamType.twinDomainKey:
        return LabelTextField(
          label: (param.description?.isNotEmpty ?? false)
              ? param.description!
              : param.name,
          controller: c..text = orgs[selectedOrg].twinDomainKey,
          readOnlyVal: true,
        );
      case pulse.GatewayParamType.twinApiKey:
        return LabelTextField(
          label: (param.description?.isNotEmpty ?? false)
              ? param.description!
              : param.name,
          controller: c..text = orgs[selectedOrg].twinAuthToken,
          readOnlyVal: true,
        );
      case pulse.GatewayParamType.clientId:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: LabelTextField(
            style: theme.getStyle(),
            labelTextStyle: theme.getStyle(),
            label: 'Value',
            controller: c,
            readOnlyVal: !isClient(),
            onChanged: (value) {
              setState(() {});
            },
          ),
        );
      case pulse.GatewayParamType.pulseEmailKey:
        return PulseGatewayDropdown(
          onGatewaySelected: (pulse.GatewayConfig? gateway) {
            if (gateway != null) {
              setState(() {
                _params[param.name] = param.copyWith($value: gateway.id);
              });
            }
          },
          selectedItem: _params[param.name]?.$value,
          style: theme.getStyle(),
        );
      case pulse.GatewayParamType.pulseSmsKey:
        return PulseGatewayDropdown(
          onGatewaySelected: (pulse.GatewayConfig? gateway) {
            if (gateway != null) {
              setState(() {
                _params[param.name] = param.copyWith($value: gateway.id);
              });
            }
          },
          selectedItem: _params[param.name]?.$value,
          style: theme.getStyle(),
        );
      case pulse.GatewayParamType.pulseVoiceKey:
        return PulseGatewayDropdown(
          onGatewaySelected: (pulse.GatewayConfig? gateway) {
            if (gateway != null) {
              setState(() {
                _params[param.name] = param.copyWith($value: gateway.id);
              });
            }
          },
          selectedItem: _params[param.name]?.$value,
          style: theme.getStyle(),
        );
      case pulse.GatewayParamType.pulseEmailGroupId:
        return PulseEmailGroupDropdown(
          onEmailGroupSelected: (pulse.EmailGroup? group) {
            if (group != null) {
              setState(() {
                _params[param.name] = param.copyWith($value: group.id);
              });
            }
          },
          selectedItem: _params[param.name]?.$value,
          style: theme.getStyle(),
        );
      case pulse.GatewayParamType.pulseSmsGroupId:
        return PulseSmsGroupDropdown(
          onSmsGroupSelected: (pulse.SmsGroup? group) {
            if (group != null) {
              setState(() {
                _params[param.name] = param.copyWith($value: group.id);
              });
            }
          },
          selectedItem: _params[param.name]?.$value,
          style: theme.getStyle(),
        );
      case pulse.GatewayParamType.pulseVoiceGroupId:
        return PulseVoiceGroupDropdown(
          onVoiceGroupSelected: (pulse.VoiceGroup? group) {
            if (group != null) {
              setState(() {
                _params[param.name] = param.copyWith($value: group.id);
              });
            }
          },
          selectedItem: _params[param.name]?.$value,
          style: theme.getStyle(),
        );
    }
  }

  bool _canSave() {
    for (pulse.GatewayParam p in _params.values) {
      if (p.$value.trim().isEmpty) return false;
    }
    return _params.isNotEmpty;
  }

  Future _save() async {
    if (loading) return;

    loading = true;

    await execute(() async {
      List<pulse.GatewayParam> params = [];
      for (pulse.GatewayParam p in _params.values) {
        params.add(p);
      }
      _config = _config.copyWith(parameters: params);

      var res = await TwinnedSession.instance.pulseAdmin.upsertConfig(
          apikey: TwinnedSession.instance.authToken,
          configId: widget.config?.id,
          body: _config);
      if (validateResponse(res)) {
        _close();
        alert(
            'Gateway ${widget.config?.name ?? ''}',
            null == widget.config
                ? 'Created successfully'
                : 'Updated Successfully');
      }
    });

    loading = false;
  }

  void _close() {
    Navigator.pop(context);
  }

  Future _load() async {
    _children.clear();
    _params.clear();
    refresh();

    if (null != widget.config) {
      for (pulse.GatewayParam p in widget.config!.parameters) {
        _params[p.name] = p;
        if (p.displayable) {
          _children.add(_buildParameter(p));
          _children.add(divider());
        }
      }

      var res = await TwinnedSession.instance.pulseAdmin.getGateway(
          apikey: TwinnedSession.instance.authToken,
          gatewayId: widget.config!.gatewayId);
      if (validateResponse(res)) {
        for (pulse.GatewayParam p in res.body?.entity?.parameters ?? []) {
          if (!_params.containsKey(p.name)) {
            _params[p.name] = p;
            if (p.displayable) {
              _children.add(_buildParameter(p));
              _children.add(divider());
            }
          }
        }
      }
      return;
    }

    if (loading) return;

    loading = true;

    await execute(() async {
      if (null == _gateway && (_config.gatewayId.isNotEmpty ?? false)) {
        var res = await TwinnedSession.instance.pulseAdmin.getGateway(
            apikey: TwinnedSession.instance.authToken,
            gatewayId: _config!.gatewayId);
        if (validateResponse(res)) {
          _gateway = res.body?.entity;
        }
      }
    });

    if (null != _gateway) {
      for (pulse.GatewayParam p in _gateway!.parameters) {
        _params[p.name] = p;
        if (p.displayable) {
          _children.add(_buildParameter(p));
          _children.add(divider());
        }
      }
    }

    loading = false;

    if (_children.isNotEmpty) {
      refresh();
    }
  }

  @override
  void setup() {
    _load();
  }
}
