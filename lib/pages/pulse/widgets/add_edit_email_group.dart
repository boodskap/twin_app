import 'package:flutter/material.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';

// ignore: must_be_immutable
class AddEditEmailGroup extends StatefulWidget {
  pulse.EmailGroup? emailGroup;
  final ValueChanged<String> onNameSaved;
  final ValueChanged<List<String>> onEmailSaved;

  AddEditEmailGroup({
    super.key,
    required this.onNameSaved,
    required this.onEmailSaved,
    this.emailGroup,
  });
  @override
  _AddEditEmailGroupState createState() => _AddEditEmailGroupState();
}

class _AddEditEmailGroupState extends BaseState<AddEditEmailGroup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<String> _emails = [];

  @override
  void initState() {
    super.initState();
    if (widget.emailGroup != null) {
      _emails = widget.emailGroup!.list;
      _nameController.text = widget.emailGroup!.name;
    }
  }

  void _addEmail() {
    final email = _emailController.text.trim();
    final emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regExp = RegExp(emailPattern);

    if (email.isNotEmpty && regExp.hasMatch(email)) {
      if (!_emails.contains(email)) {
        setState(() {
          _emails.add(email);
          widget.onEmailSaved(_emails);
        });
        _emailController.clear();
      } else {
        alert(
          'Warning',
          'This email is already added',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
      }
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
            onPressed: () => _saveEditedEmail(index),
          ),
        ],
      ),
    );
  }

  void _saveEditedEmail(int index) {
    final editedEmail = _emailController.text.trim();
    final emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regExp = RegExp(emailPattern);

    if (regExp.hasMatch(editedEmail)) {
      if (!_emails.contains(editedEmail) || _emails[index] == editedEmail) {
        setState(() {
          _emails[index] = editedEmail;
          widget.onEmailSaved(_emails);
        });
        _emailController.clear();
        Navigator.of(context).pop();
      } else {
        alert(
          'Warning',
          'This email is already in the list',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
      }
    }
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
          child: _emails.isNotEmpty
              ? ListView.builder(
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
                )
              : Center(
                  child: Text('No emails added'),
                ),
        ),
      ],
    );
  }

  @override
  void setup() {
  }
}
