import 'package:flutter/material.dart';
import 'package:twinned_widgets/core/top_bar.dart';

class RolesWidget extends StatefulWidget {
  final List<String> roles;
  const RolesWidget({Key? key, required this.roles}) : super(key: key);

  @override
  State<RolesWidget> createState() => _RolesWidgetState();
}

class _RolesWidgetState extends State<RolesWidget> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
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
                ElevatedButton(
                  onPressed: () {
                    final inputText = _textEditingController.text;
                    if (inputText.isNotEmpty) {
                      setState(() {
                        widget.roles.add(inputText);
                        _textEditingController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(140, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  child: Text(
                    'Add',
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.roles.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          widget.roles.removeAt(index);
                        });
                      },
                    ),
                    title: Text(widget.roles[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
