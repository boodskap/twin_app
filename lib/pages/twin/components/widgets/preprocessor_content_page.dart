import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:code_editor/code_editor.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/groovy.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_app/core/session_variables.dart';

class PreprocessorContentPage extends StatefulWidget {
  final Preprocessor? preprocessor;

  const PreprocessorContentPage({
    super.key,
    this.preprocessor,
  });

  @override
  State<PreprocessorContentPage> createState() =>
      _PreprocessorContentPageState();
}

class _PreprocessorContentPageState extends BaseState<PreprocessorContentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final CodeController _controller = CodeController(language: groovy);
  late EditorModel model;

  @override
  void initState() {
    _nameController.text = widget.preprocessor!.name;
    _classController.text = widget.preprocessor!.className;
    _descController.text = widget.preprocessor!.description ?? '';
    _tagsController.text = null != widget.preprocessor!.tags
        ? widget.preprocessor!.tags!.join(' ')
        : '';
    _controller.text = widget.preprocessor!.code ?? '';

    model = EditorModel(
      files: [
        FileEditor(
          name: "editor",
          language: "groovy",
          code: _controller.fullText,
        )
      ],
      styleOptions: EditorModelStyleOptions(
        heightOfContainer: 400,
        fontSize: 12,
        textStyleOfTextField: const TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.normal,
        ),
        toolbarOptions: const ToolbarOptions(
          selectAll: true,
          copy: true,
          cut: true,
          paste: true,
        ),
      ),
    );

    super.initState();
  }

  @override
  void setup() async {
    if (_controller.text.trim().isEmpty ||
        _controller.text.trim() == 'return args;') {
      String content = await DefaultAssetBundle.of(context)
          .loadString('preprocessor.groovy');
      refresh(sync: () {
        _controller.text = content;
      });
    }
  }

  Future _save({bool shouldPop = false}) async {
    execute(() async {
      var res = await TwinnedSession.instance.twin.updatePreprocessor(
        apikey: TwinnedSession.instance.authToken,
        preprocessorId: widget.preprocessor!.id,
        body: PreprocessorInfo(
          name: _nameController.text.trim(),
          className: _classController.text.trim(),
          description: _descController.text.trim(),
          tags: _tagsController.text.trim().split(' '),
          code: _controller.text.trim(),
        ),
      );

      if (validateResponse(res)) {
        await alert(
            '', 'Preprocessor ${_nameController.text} saved successfully!');
      } else {
        await alert('', res.body!.msg!);
      }
      if (shouldPop) {
        _cancel();
      }
    });
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
            title: 'Digital Twin Preprocessor - ${widget.preprocessor!.name}',
            style: theme.getStyle().copyWith(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          divider(),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Row(
                  children: [
                    divider(horizontal: true),
                    Expanded(
                      flex: 15,
                      child: LabelTextField(
                        labelTextStyle: theme.getStyle(),
                        style: theme.getStyle(),
                        label: 'Preprocessor Name',
                        controller: _nameController,
                      ),
                    ),
                    divider(horizontal: true),
                    Expanded(
                      flex: 15,
                      child: LabelTextField(
                        labelTextStyle: theme.getStyle(),
                        style: theme.getStyle(),
                        label: 'Class Name',
                        controller: _classController,
                      ),
                    ),
                    divider(horizontal: true),
                    Expanded(
                      flex: 35,
                      child: LabelTextField(
                        labelTextStyle: theme.getStyle(),
                        style: theme.getStyle(),
                        label: 'Description',
                        controller: _descController,
                      ),
                    ),
                    divider(horizontal: true),
                    Expanded(
                      flex: 35,
                      child: LabelTextField(
                        labelTextStyle: theme.getStyle(),
                        style: theme.getStyle(),
                        label: 'Tags',
                        controller: _tagsController,
                      ),
                    ),
                    divider(horizontal: true),
                  ],
                ),
                divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const BusyIndicator(padding: 4.0),
                    divider(horizontal: true),
                    PrimaryButton(
                      labelKey: 'Save',
                      onPressed: () {
                        _save(shouldPop: true);
                      },
                    ),
                    divider(horizontal: true),
                    SecondaryButton(
                      labelKey: 'Close',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    divider(horizontal: true),
                  ],
                ),
                divider(),
                CodeEditor(
                  model: model,
                  formatters: const ["groovy"],
                  disableNavigationbar: true,
                  onSubmit: (language, value) {
                    _controller.fullText = value;
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
