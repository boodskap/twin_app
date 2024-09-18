import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/pulse/widgets/add_edit_email_group.dart';
import 'package:twin_app/pages/pulse/widgets/custom_badge.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;

class EmailGroupPage extends StatefulWidget {
  const EmailGroupPage({super.key});

  @override
  State<EmailGroupPage> createState() => _EmailGroupPageState();
}

class _EmailGroupPageState extends BaseState<EmailGroupPage> {
  String _search = '*';
  List<String> emailList = [];
  String name = "";
  final List<Widget> _children = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              divider(),
              Tooltip(
                message: "Refresh",
                child: IconButton(
                  onPressed: () async {
                    _search = "*";
                    await _load();
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ),
              divider(horizontal: true),
              PrimaryButton(
                leading: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                labelKey: 'Add New',
                onPressed: () async {
                  _reset();
                  await _showEmailGroupDialog('Create', null);
                },
              ),
              divider(horizontal: true),
              SizedBox(
                width: 250,
                height: 40,
                child: SearchBar(
                  leading: const Icon(Icons.search),
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintText: "Search Emails",
                  onChanged: (value) async {
                    _search = value.trim().isNotEmpty ? value.trim() : '*';
                    await _load();
                  },
                ),
              ),
            ],
          ),
          divider(),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool canCreateOrUpdate(pulse.EmailGroup? entity) {
    if (entity != null) {
      return entity.name.isNotEmpty && entity.list.isNotEmpty;
    } else {
      return name.isNotEmpty && emailList.isNotEmpty;
    }
  }

  Widget _buildChild(pulse.EmailGroup entity) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                    message: 'Edit ${entity.name}',
                    child: IconButton(
                        onPressed: () async {
                          await _showEmailGroupDialog('Update', entity);
                        },
                        icon: const Icon(Icons.edit))),
                Tooltip(
                    message: 'Delete ${entity.name}',
                    child: IconButton(
                        onPressed: () {
                          _delete(entity);
                        },
                        icon: const Icon(Icons.delete))),
              ],
            ),
            divider(),
            Text(
              entity.name,
              style: theme
                  .getStyle()
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            divider(),
            CustomBadge(
                text: entity.list.length == 1 ? 'Member' : 'Members',
                hintText: entity.list.length.toString(),
                badgeColor: theme.getPrimaryColor()),
          ],
        ),
      ),
    );
  }

  Future _delete(pulse.EmailGroup group) async {
    await confirm(
      title: 'Delete ${group.name}',
      message: 'Are you sure you want to delete this email group?',
      onPressed: () async {
        await execute(() async {
          var res = await TwinnedSession.instance.pulseAdmin.deleteEmailGroup(
              apikey: TwinnedSession.instance.authToken, groupId: group.id);

          if (validateResponse(res)) {
            alert('Email Group ${group.name}', 'Deleted Successfully');
          }
        });
      },
    );
    Future.delayed(Duration(seconds: 1), () {
      _load();
    });
  }

  Future<void> _showEmailGroupDialog(
      String type, pulse.EmailGroup? entity) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '$type Email Group',
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          scrollable: true,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.6,
            child: AddEditEmailGroup(
              emailGroup: entity,
              onNameSaved: (String value) {
                setState(() {
                  if (entity == null) {
                    name = value.trim();
                  } else {
                    entity = entity!.copyWith(name: value.trim());
                  }
                });
              },
              onEmailSaved: (List<String> email) {
                setState(() {
                  if (entity == null) {
                    emailList = email;
                  } else {
                    entity = entity!.copyWith(list: email);
                  }
                  emailList = email;
                });
              },
            ),
          ),
          actions: [
             Divider(
              color: theme.getPrimaryColor(),
              thickness: 1.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(
                  labelKey: 'Cancel',
                  onPressed: () {
                    _close();
                  },
                ),
                divider(horizontal: true),
                PrimaryButton(
                  labelKey: type,
                  onPressed: () async {
                    if (canCreateOrUpdate(entity)) {
                      await _save(entity); 
                    } else {
                      alert('Warning', 'Please fill in all fields.');
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
    _load();
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    _children.clear();
    refresh();
    await execute(() async {
      var res = await TwinnedSession.instance.pulseAdmin.searchEmailGroup(
          apikey: TwinnedSession.instance.authToken,
          body: pulse.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(res)) {
        for (pulse.EmailGroup entity in res.body?.values ?? []) {
          _children.add(_buildChild(entity));
        }
      }
    });
    loading = false;
    refresh();
  }

  @override
  void setup() {
    _load();
  }

  Future _save(pulse.EmailGroup? groupEmail) async {
    if (loading) return;
    loading = true;
  late pulse.EmailGroupInfo _config;
   
     if (null == groupEmail) {
      _config =  pulse.EmailGroupInfo(
        name: name,
        list: emailList,
      );
    } else {
      _config = pulse.EmailGroupInfo(
        name: groupEmail.name,
        list:groupEmail.list
      );
    }
    await execute(() async {
      var uRes = await TwinnedSession.instance.pulseAdmin.upsertEmailGroup(
          apikey: TwinnedSession.instance.authToken,
          groupId: groupEmail != null ? groupEmail.id : null,
          body: _config);
      if (validateResponse(uRes)) {
        _close();
        if (groupEmail == null) {
          alert(
            'Success',
            'Email Group ${_config.name} Created Successfully!',
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            contentStyle: theme.getStyle(),
          );
        } else {
          alert(
            'Success',
            'Email Group ${_config.name} Updated Successfully!',
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            contentStyle: theme.getStyle(),
          );
        }
      }
    });

    loading = false;
    refresh();
  }

  void _close() {
    Navigator.of(context).pop();
  }

   void _reset() {
   setState(() {
     name = "";
     emailList = [];
   });
  }
}
