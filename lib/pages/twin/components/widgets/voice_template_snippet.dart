import 'package:flutter/material.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

typedef VoiceTemplateSaved = void Function(VoiceTemplate? voiceTemplate);

class VoiceTemplateSnippet extends StatefulWidget {
  final VoiceTemplateSaved onVoiceTemplateSaved;
  VoiceTemplate? voiceTemplate;

  VoiceTemplateSnippet(
      {super.key, this.voiceTemplate, required this.onVoiceTemplateSaved});

  @override
  State<VoiceTemplateSnippet> createState() => _VoiceTemplateSnippetState();
}

class _VoiceTemplateSnippetState extends State<VoiceTemplateSnippet> {
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
             
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: TextFormField(
                controller: _messageController,
                onChanged: (value) {
                  //setState(() {});
                  _validateAndFire();
                },
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  labelText: 'Message',
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
}
