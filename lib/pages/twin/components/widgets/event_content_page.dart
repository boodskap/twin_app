import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/email_template_snippet.dart';
import 'package:twin_app/pages/twin/components/widgets/fcm_template_snippet.dart';
import 'package:twin_app/pages/twin/components/widgets/match_group_widget.dart';
import 'package:twin_app/pages/twin/components/widgets/notification_template.dart';
import 'package:twin_app/pages/twin/components/widgets/roles_widget.dart';
import 'package:twin_app/pages/twin/components/widgets/sms_template_snippet.dart';
import 'package:twin_app/pages/twin/components/widgets/voice_template_snippet.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twinned_widgets/core/top_bar.dart';

class DigitalTwinEventContentPage extends StatefulWidget {
  final Event entity;
  final DeviceModel model;
  void valueChanged(Condition? selected) {}

  void onModelSelected(Condition? selected) {}
  const DigitalTwinEventContentPage(
      {super.key, required this.entity, required this.model});

  @override
  State<DigitalTwinEventContentPage> createState() =>
      _DigitalTwinEventContentPageState();
}

class _DigitalTwinEventContentPageState
    extends BaseState<DigitalTwinEventContentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool prequired = false;
  EmailTemplate? _emailTemplate;
  NotificationTemplate? _notificationTemplate;
  SMSTemplate? _smsTemplate;
  VoiceTemplate? _voiceTemplate;
  FCMTemplate? _fcmTemplate;

  @override
  void initState() {
    super.initState();

    if (widget.entity.conditions.isEmpty) {
      widget.entity.conditions.add(
          const MatchGroup(matchType: MatchGroupMatchType.any, conditions: []));
    }

    _emailTemplate = widget.entity.emailTemplate;
    _notificationTemplate = widget.entity.notificationTemplate;
    _smsTemplate = widget.entity.smsTemplate;
    _voiceTemplate = widget.entity.voiceTemplate;
    _fcmTemplate = widget.entity.fcmTemplate;
  }

  @override
  void setup() async {
    Event e = widget.entity;
    _nameController.text = e.name;
    _descController.text = e.description ?? '';
    _tagsController.text = null != e.tags ? e.tags!.join(' ') : '';
    refresh();
  }

  Future _save({bool shouldPop = false}) async {
    if (loading) return;
    loading = true;

    String name = _nameController.text.trim();
    String description = _descController.text.trim();
    String tags = _tagsController.text.trim();

    if (widget.entity.conditions[0].conditions.isEmpty) {
      alert('Missing', 'At least one condition is required');
      return;
    }

    if (null == _emailTemplate &&
        null == _notificationTemplate &&
        null == _smsTemplate &&
        null == _voiceTemplate &&
        null == _fcmTemplate) {
      alert('Missing',
          'One of Email, Notification, SMS, Voice or FCM template is required');
      return;
    }

    EventInfo body = EventInfo(
        name: name,
        description: description,
        tags: tags.split(' '),
        modelId: widget.entity.modelId,
        conditions: widget.entity.conditions,
        notificationTemplate: _notificationTemplate,
        emailTemplate: _emailTemplate,
        fcmTemplate: _fcmTemplate,
        roles: widget.entity.roles,
        smsTemplate: _smsTemplate,
        voiceTemplate: _voiceTemplate);

    await execute(() async {
      var res = await TwinnedSession.instance.twin.updateEvent(
        apikey: TwinnedSession.instance.authToken,
        eventId: widget.entity.id,
        body: body,
      );

      if (validateResponse(res)) {
        await alert('', 'Event ${_nameController.text} saved successfully');
        if (shouldPop) {
          _cancel();
        }
      }
    });

    loading = false;
    refresh();
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: ' Event - ${widget.entity.name}',
            style: theme.getStyle().copyWith(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          divider(),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.only(left: 8, bottom: 8, right: 8),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    divider(),
                    Row(
                      children: [
                        divider(horizontal: true),
                        Expanded(
                          flex: 20,
                          child: LabelTextField(
                            style: theme.getStyle(),
                            suffixIcon: Tooltip(
                              message: 'Copy event id',
                              preferBelow: false,
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: widget.entity.id,
                                    ),
                                  );
                                  // OverlayWidget.showOverlay(
                                  //   context: context,
                                  //   topPosition: 140,
                                  //   leftPosition: 250,
                                  //   message: 'Event id copied!',
                                  // );
                                },
                                child: const Icon(
                                  Icons.content_copy,
                                  size: 20,
                                ),
                              ),
                            ),
                            label: 'Event Name',
                            labelTextStyle: theme.getStyle(),
                            controller: _nameController,
                          ),
                        ),
                        divider(horizontal: true),
                        Expanded(
                            flex: 40,
                            child: LabelTextField(
                              style: theme.getStyle(),
                              labelTextStyle: theme.getStyle(),
                              label: 'Description',
                              controller: _descController,
                            )),
                        divider(horizontal: true),
                        Expanded(
                            flex: 40,
                            child: LabelTextField(
                              style: theme.getStyle(),
                              labelTextStyle: theme.getStyle(),
                              label: 'Tags',
                              controller: _tagsController,
                            )),
                      ],
                    ),
                    divider(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PrimaryButton(
                          labelKey: "Save",
                          onPressed: () {
                            _save(shouldPop: true);
                          },
                        ),
                        divider(horizontal: true),
                        SecondaryButton(
                          labelKey: "Close",
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        divider(horizontal: true),
                      ],
                    ),
                    divider(),
                    SizedBox(
                      height: 450,
                      child: Row(
                        children: [
                          SizedBox(
                            height: 425,
                            width: 350,
                            child: MatchGroupWidget(
                              deviceModel: widget.model,
                              event: widget.entity,
                              index: 0,
                              onDelete: (int index) {},
                              onSave: (MatchGroup group, int index) {
                                widget.entity.conditions[index] = group;
                              },
                            ),
                          ),
                          Expanded(
                            flex: 55,
                            child: EmailTemplateSnippet(
                              emailTemplate: widget.entity.emailTemplate,
                              onEmailTemplateSaved: (EmailTemplate? value) {
                                _emailTemplate = value;
                              },
                            ),
                          ),
                          divider(),
                          Expanded(
                            flex: 45,
                            child: SizedBox(
                              height: 425,
                              child: NotificationTemplateSnippet(
                                  notificationTemplate:
                                      widget.entity.notificationTemplate,
                                  onNotificationTemplateSaved:
                                      (NotificationTemplate? value) {
                                    _notificationTemplate = value;
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: Row(
                        children: [
                          Expanded(
                            child: SmsTemplateSnippet(
                                smsTemplate: widget.entity.smsTemplate,
                                onSmsTemplateSaved: (SMSTemplate? value) {
                                  _smsTemplate = value;
                                }),
                          ),
                          divider(horizontal: true),
                          Expanded(
                            child: VoiceTemplateSnippet(
                              voiceTemplate: widget.entity.voiceTemplate,
                              onVoiceTemplateSaved: (VoiceTemplate? value) {
                                _voiceTemplate = value;
                              },
                            ),
                          ),
                          divider(horizontal: true),
                          Expanded(
                              child: FcmTemplateSnippet(
                            fcmTemplate: widget.entity.fcmTemplate,
                            onFcmTemplateSaved: (FCMTemplate? value) {
                              _fcmTemplate = value;
                            },
                          )),
                          RolesWidget(roles: widget.entity.roles!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
