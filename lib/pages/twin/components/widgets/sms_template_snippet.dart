import 'package:flutter/material.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

typedef SmsTemplateSaved = void Function(SMSTemplate? notificationTemplate);

class SmsTemplateSnippet extends StatefulWidget {
  final SmsTemplateSaved onSmsTemplateSaved;
  SMSTemplate? smsTemplate;

  SmsTemplateSnippet(
      {super.key, this.smsTemplate, required this.onSmsTemplateSaved});

  @override
  State<SmsTemplateSnippet> createState() => _SmsTemplateSnippetState();
}

class _SmsTemplateSnippetState extends State<SmsTemplateSnippet> {
  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (null != widget.smsTemplate) {
      _messageController.text = widget.smsTemplate!.message;
    }
  }

  void _validateAndFire() {
    String message = _messageController.text.trim();
    if (message.isEmpty) {
      widget.onSmsTemplateSaved(null);
    } else {
      widget.onSmsTemplateSaved(SMSTemplate(message: message));
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
              'SMS Template',
            
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
