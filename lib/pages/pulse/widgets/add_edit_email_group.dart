import 'package:flutter/material.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;
import 'package:twin_app/core/session_variables.dart';
// ignore: must_be_immutable
class AddEditEmailGroup extends StatefulWidget {
  pulse.EmailGroup? emailGroup; 
  final ValueChanged<String> onNameSaved;
  final ValueChanged<List<String>> onEmailSaved;

   AddEditEmailGroup(
      {super.key, required this.onNameSaved, required this.onEmailSaved, this.emailGroup,});
  @override
  _AddEditEmailGroupState createState() => _AddEditEmailGroupState();
}

class _AddEditEmailGroupState extends State<AddEditEmailGroup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<String> _emails = [];

 @override
  void initState() {
    super.initState();
    if(widget.emailGroup!=null){
      _emails = widget.emailGroup!.list;
      _nameController.text = widget.emailGroup!.name;
    }
  }

  void _addEmail() {
    final email = _emailController.text;
    final emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regExp = RegExp(emailPattern);

    if (email.isNotEmpty && regExp.hasMatch(email)) {
      setState(() {
        _emails.add(email);
        widget.onEmailSaved(_emails);
      });
      _emailController.clear();
    }
  }

  void _editEmail(int index) {
    _emailController.text = _emails[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Email'),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.2,
          height: 100,
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(hintText: "Edit email"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              setState(() {
                _emails[index] = _emailController.text;
                widget.onEmailSaved(_emails);
              });

              _emailController.clear();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _removeEmail(int index) {
    setState(() {
      _emails.removeAt(index);
      widget.onEmailSaved(_emails);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameController,
          onChanged: (value) {
            widget.onNameSaved(_nameController.text);
          },
          decoration: InputDecoration(
            labelText: 'Name',
          ),
        ),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: _addEmail,
            ),
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _emails.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_emails[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editEmail(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeEmail(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}