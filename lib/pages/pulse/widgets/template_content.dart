import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/card_layout.dart';
import 'package:twin_app/pages/twin/components/widgets/showoverlay_widget.dart';
import 'package:twin_app/widgets/commons/email_template.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_widgets/core/top_bar.dart';

class TemplateContentPage extends StatefulWidget {
  pulse.ContentTemplate? template;
  final String title;
  TemplateContentPage({super.key, this.template, required this.title});

  @override
  State<TemplateContentPage> createState() => _TemplateContentPageState();
}

class _TemplateContentPageState extends BaseState<TemplateContentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  pulse.ContentTemplateContentType templateContentType =
      pulse.ContentTemplateContentType.html;
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();

    if (null != widget.template) {
      _nameController.text = widget.template!.name;
      _subjectController.text = widget.template!.subject!;
      _contentController.text = widget.template!.content;
      templateContentType = widget.template!.contentType;
    } else {
      _contentController.text = emailTemplateHtml;
    }
    final RegExp regExp = RegExp(r'{{');
    final Match? match = regExp.firstMatch(_contentController.text);
    if (match != null) {
      Future.delayed(Duration(seconds: 1), () {
        FocusScope.of(context).requestFocus(_focusNode);
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: (match.start + 2)),
        );
      });
    }
    _nameController.addListener(_onFieldChanged);
    _contentController.addListener(_onFieldChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TopBar(
            title: widget.title,
            style: theme.getStyle().copyWith(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          divider(),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                        PrimaryButton(
                          labelKey:
                              (null == widget.template) ? 'Create' : 'Update',
                          onPressed: !_canCreateOrUpdate()
                              ? null
                              : () {
                                  _save();
                                },
                        ),
                      ],
                    ),
                    divider(),
                    CardLayoutSection(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 30,
                                  child: LabelTextField(
                                    style: theme.getStyle(),
                                    suffixIcon: (null != widget.template)
                                        ? Tooltip(
                                            message: 'Copy template id',
                                            preferBelow: false,
                                            child: InkWell(
                                              onTap: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: widget.template!.id,
                                                  ),
                                                );
                                                OverlayWidget.showOverlay(
                                                  context: context,
                                                  topPosition: 140,
                                                  leftPosition: 250,
                                                  message:
                                                      'Template id copied!',
                                                );
                                              },
                                              child: const Icon(
                                                Icons.content_copy,
                                                size: 20,
                                              ),
                                            ),
                                          )
                                        : null,
                                    label: 'Template Name',
                                    labelTextStyle: theme.getStyle(),
                                    controller: _nameController,
                                  ),
                                ),
                                divider(horizontal: true),
                                Expanded(
                                    flex: 60,
                                    child: LabelTextField(
                                      style: theme.getStyle(),
                                      labelTextStyle: theme.getStyle(),
                                      label: 'Subject',
                                      controller: _subjectController,
                                    )),
                                divider(horizontal: true),
                                Expanded(
                                  flex: 10,
                                  child: DropdownButtonFormField2<
                                      pulse.ContentTemplateContentType>(
                                    value: templateContentType,
                                    isExpanded: true,
                                    onChanged: (newValue) {
                                      setState(() {
                                        templateContentType = newValue ??
                                            pulse.ContentTemplateContentType
                                                .html;

                                        if (templateContentType ==
                                            pulse.ContentTemplateContentType
                                                .plain) {
                                          _contentController.text =
                                              (widget.template != null)
                                                  ? widget.template!.content
                                                  : "";

                                          if (isHtml(
                                              widget.template!.content)) {
                                            _contentController.text = "";
                                          }
                                        } else {
                                          _contentController.text =
                                              (widget.template != null)
                                                  ? widget.template!.content
                                                  : emailTemplateHtml;

                                          if (!isHtml(
                                              widget.template!.content)) {
                                            _contentController.text =
                                                emailTemplateHtml;
                                            
                                          }
                                        }
                                      });
                                    },
                                    items: <pulse.ContentTemplateContentType>[
                                      pulse.ContentTemplateContentType.html,
                                      pulse.ContentTemplateContentType.plain,
                                    ].map((pulse.ContentTemplateContentType
                                        value) {
                                      return DropdownMenuItem<
                                              pulse.ContentTemplateContentType>(
                                          value: value,
                                          child:
                                              Text(value.value ?? value.name));
                                    }).toList(),
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        border: OutlineInputBorder()),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                      ),
                                      offset: const Offset(0, 0),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(40),
                                      ),
                                    ),
                                    validator: (value) => value == null
                                        ? 'Please select a type'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            divider(),
                            divider(),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.73,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  TextField(
                                    controller: _contentController,
                                    onChanged: (value) {},
                                    focusNode: _focusNode,
                                    maxLines: null,
                                    expands: true,
                                    textAlignVertical: TextAlignVertical.top,
                                    style: theme.getStyle(),
                                    decoration: InputDecoration(
                                      labelText: 'Content',
                                      labelStyle: theme.getStyle(),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            color: Colors.blue),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 8.0),
                                    ),
                                  ),
                                  if(templateContentType == pulse.ContentTemplateContentType.html)
                                  Positioned(
                                    top: 8, // Position the icon at the top
                                    right: 8,
                                    child: InkWell(
                                      onTap: () {
                                        previewEmailTemplate(
                                            context, _contentController.text);
                                      },
                                      child: Tooltip(
                                          message: 'Preview Template',
                                          child: Icon(Icons.remove_red_eye)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
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

  void _onFieldChanged() {
    setState(() {});
  }

  bool _canCreateOrUpdate() {
    final name = _nameController.text.trim();
    final content = _contentController.text.trim();
    bool isValidHtml = true;
    if (templateContentType == pulse.ContentTemplateContentType.html) {
      isValidHtml = true;
    } else {
      isValidHtml = false;
    }
    return name.isNotEmpty &&
        content.isNotEmpty &&
        (isHtml(content) == isValidHtml);
  }

  void _close() {
    Navigator.of(context).pop();
  }

  void previewEmailTemplate(BuildContext context, emailContent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Preview Template'),
          content: SingleChildScrollView(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 400,
                  child: HtmlWidget(emailContent))),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future _save({bool silent = false}) async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var uRes = await TwinnedSession.instance.pulseAdmin.upsertContentTemplate(
          apikey: TwinnedSession.instance.authToken,
          templateId: widget.template?.id != null ? widget.template!.id : null,
          body: pulse.ContentTemplateInfo(
              name: _nameController.text,
              subject: _subjectController.text,
              content: _contentController.text,
              contentType: _getContentType(templateContentType)));
      if (validateResponse(uRes)) {
        if (!silent) {
          _close();
          if ((null != widget.template)) {
            alert('Success',
                'Template ${_nameController.text} updated successfully!');
          } else {
            alert('Success',
                'Template ${_nameController.text} created successfully!');
          }
        }
      }
    });

    loading = false;
    refresh();
  }

  bool isHtml(String text) {
    // Regular expression to check for HTML tags
    final htmlTagRegExp = RegExp(r'<[^>]+>');
    return htmlTagRegExp.hasMatch(text);
  }

  pulse.ContentTemplateInfoContentType _getContentType(
      pulse.ContentTemplateContentType type) {
    switch (type) {
      case pulse.ContentTemplateContentType.plain:
        return pulse.ContentTemplateInfoContentType.plain;
      default:
        return pulse.ContentTemplateInfoContentType.html;
    }
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}
