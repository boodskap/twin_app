import 'package:flutter/material.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

typedef FcmTemplateSaved = void Function(FCMTemplate? fcmTemplate);

class FcmTemplateSnippet extends StatefulWidget {
  final FcmTemplateSaved onFcmTemplateSaved;
  FCMTemplate? fcmTemplate;

  FcmTemplateSnippet(
      {super.key, required this.onFcmTemplateSaved, this.fcmTemplate});

  @override
  State<FcmTemplateSnippet> createState() => _FcmTemplateSnippetState();
}

class _FcmTemplateSnippetState extends State<FcmTemplateSnippet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (null != widget.fcmTemplate) {
      _titleController.text = widget.fcmTemplate!.title;
      _contentController.text = widget.fcmTemplate!.content;
    }
  }

  void _validateAndFire() {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      widget.onFcmTemplateSaved(null);
    } else {
      widget.onFcmTemplateSaved(FCMTemplate(title: title, content: content));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              'FCM Template',
             
            ),
            const SizedBox(
              height: 8,
            ),
            TextFormField(
              onChanged: (value) {
                //setState(() {});
                _validateAndFire();
              },
              controller: _titleController,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: TextFormField(
                maxLines: null,
                expands: true,
                controller: _contentController,
                onChanged: (value) {
                  //setState(() {});
                  _validateAndFire();
                },
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
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
