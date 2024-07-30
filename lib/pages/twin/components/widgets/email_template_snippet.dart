import 'package:flutter/material.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

typedef EmailTemplateSaved = void Function(EmailTemplate? emailTemplate);

class EmailTemplateSnippet extends StatefulWidget {
  final EmailTemplateSaved onEmailTemplateSaved;
  EmailTemplate? emailTemplate;

  EmailTemplateSnippet(
      {Key? key, required this.onEmailTemplateSaved, this.emailTemplate})
      : super(key: key);

  @override
  State<EmailTemplateSnippet> createState() => _EmailTemplateSnippetState();
}

class _EmailTemplateSnippetState extends State<EmailTemplateSnippet> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  @override
  void initState() {
    super.initState();

    if (null != widget.emailTemplate) {
      _subjectController.text = widget.emailTemplate!.subject;
      _contentController.text = widget.emailTemplate!.content;
    }
  }

  void _validateAndFire() {
    String subject = _subjectController.text.trim();
    String content = _contentController.text.trim();
    if (subject.isEmpty && content.isEmpty) {
      widget.onEmailTemplateSaved(null);
    } else {
      widget.onEmailTemplateSaved(
          EmailTemplate(subject: subject, content: content));
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
              'Email Template',
              
            ),
            const SizedBox(
              height: 8,
            ),
            TextFormField(
              controller: _subjectController,
              onChanged: (value) {
                //setState(() {});
                _validateAndFire();
              },
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: TextFormField(
                controller: _contentController,
                onChanged: (value) {
                  //setState(() {});
                  _validateAndFire();
                },
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  labelText: 'Content',
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
