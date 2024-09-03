import 'package:flutter/material.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';

class SingleValueInput extends StatefulWidget {
  final String? value;
  final String label;
  final ValueChanged<String> onChanged;
  final String? buttonLabel;
  const SingleValueInput(
      {super.key,
      required this.value,
      required this.label,
      required this.onChanged,
      this.buttonLabel});

  @override
  State<SingleValueInput> createState() => _SingleValueInputState();
}

class _SingleValueInputState extends State<SingleValueInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.value ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          LabelTextField(
            label: widget.label,
            controller: _controller,
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SecondaryButton(
                  labelKey: 'cancel',
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              SizedBox(
                width: 8,
              ),
              PrimaryButton(
                labelKey: widget.buttonLabel ?? 'Ok',
                onPressed: () {
                  Navigator.pop(context);
                  widget.onChanged(_controller.text);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
