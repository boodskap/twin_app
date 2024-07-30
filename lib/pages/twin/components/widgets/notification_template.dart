import 'package:flutter/material.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

typedef NotificationTemplateSaved = void Function(
    NotificationTemplate? notificationTemplate);

class NotificationTemplateSnippet extends StatefulWidget {
  final NotificationTemplateSaved onNotificationTemplateSaved;
  NotificationTemplate? notificationTemplate;

  NotificationTemplateSnippet(
      {super.key,
      this.notificationTemplate,
      required this.onNotificationTemplateSaved});

  @override
  State<NotificationTemplateSnippet> createState() =>
      _NotificationTemplateSnippetState();
}

class _NotificationTemplateSnippetState
    extends State<NotificationTemplateSnippet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (null != widget.notificationTemplate) {
      _titleController.text = widget.notificationTemplate!.title;
      _contentController.text = widget.notificationTemplate!.content;
    }
  }

  void _validateAndFire() {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      widget.onNotificationTemplateSaved(null);
    } else {
      widget.onNotificationTemplateSaved(
          NotificationTemplate(title: title, content: content));
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
        width: 300,
        height: 300,
        child: Column(
          children: [
            Text(
              'Notification Template',
            ),
            const SizedBox(
              height: 8,
            ),
            TextFormField(
              controller: _titleController,
              onChanged: (value) {
                //setState(() {});
                _validateAndFire();
              },
              decoration: InputDecoration(
                labelText: 'Title',
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
