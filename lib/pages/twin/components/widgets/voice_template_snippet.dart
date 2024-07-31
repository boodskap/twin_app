import 'package:flutter/material.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_app/core/session_variables.dart';

typedef VoiceTemplateSaved = void Function(VoiceTemplate? voiceTemplate);

class VoiceTemplateSnippet extends StatefulWidget {
  final VoiceTemplateSaved onVoiceTemplateSaved;
  VoiceTemplate? voiceTemplate;

  VoiceTemplateSnippet(
      {super.key, this.voiceTemplate, required this.onVoiceTemplateSaved});

  @override
  State<VoiceTemplateSnippet> createState() => _VoiceTemplateSnippetState();
}

class _VoiceTemplateSnippetState extends BaseState<VoiceTemplateSnippet> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (null != widget.voiceTemplate) {
      _messageController.text = widget.voiceTemplate!.message;
    }
  }

  void _validateAndFire() {
    String message = _messageController.text.trim();
    if (message.isEmpty) {
      widget.onVoiceTemplateSaved(null);
    } else {
      widget.onVoiceTemplateSaved(VoiceTemplate(message: message));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Voice Template',
              style: theme.getStyle().copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            divider(),
            Expanded(
              child: TextFormField(
                controller: _messageController,
                onChanged: (value) {
                  //setState(() {});
                  _validateAndFire();
                },
                maxLines: null,
                expands: true,
                style: theme.getStyle(),
                decoration: InputDecoration(
                  labelText: 'Message',
                  labelStyle: theme.getStyle(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}
