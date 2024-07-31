import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';

class RolesWidget extends StatefulWidget {
  final List<String> roles;
  const RolesWidget({Key? key, required this.roles}) : super(key: key);

  @override
  State<RolesWidget> createState() => _RolesWidgetState();
}

class _RolesWidgetState extends BaseState<RolesWidget> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Container(
        height: 300,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Roles',
                style: theme
                    .getStyle()
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, top: 5),
                      child: TextFormField(
                        style: theme.getStyle(),
                        controller: _textEditingController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black45),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                PrimaryButton(
                  labelKey: "Add",
                  onPressed: () {
                    final inputText = _textEditingController.text;
                    if (inputText.isNotEmpty) {
                      setState(() {
                        widget.roles.add(inputText);
                        _textEditingController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.roles.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.roles.removeAt(index);
                        });
                      },
                    ),
                    title: Text(
                      widget.roles[index],
                      style: theme.getStyle(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void setup() {}
}
