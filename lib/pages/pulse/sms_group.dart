import 'package:flutter/material.dart';
import 'package:pulse_admin_api/api/pulse_admin.swagger.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/pulse/widgets/add_edit_email_group.dart';
import 'package:twin_app/pages/pulse/widgets/add_edit_phone_group.dart';
import 'package:twin_app/pages/pulse/widgets/custom_badge.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;

class SmsGroupPage extends StatefulWidget {
  const SmsGroupPage({super.key});

  @override
  State<SmsGroupPage> createState() => _SmsGroupPageState();
}

class _SmsGroupPageState extends BaseState<SmsGroupPage> {
  String _search = '*';
  List<PhoneNumber> SMSList = [];
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
                  await _showSmsGroupDialog('Create', null);
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
                  hintText: "Search SMSs",
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

  bool canCreateOrUpdate(pulse.SmsGroup? entity) {
    if (entity != null) {
      return entity.name.isNotEmpty && entity.phoneList.isNotEmpty;
    } else {
      return name.isNotEmpty && SMSList.isNotEmpty;
    }
  }

  Widget _buildChild(pulse.SmsGroup entity) {
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
                          await _showSmsGroupDialog('Update', entity);
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
                text: entity.phoneList.length == 1 ? 'Member' : 'Members',
                hintText: entity.phoneList.length.toString(),
                badgeColor: theme.getPrimaryColor()),
          ],
        ),
      ),
    );
  }

  Future _delete(pulse.SmsGroup group) async {
    await confirm(
      title: 'Delete ${group.name}',
      message: 'Are you sure you want to delete this SMS group?',
      onPressed: () async {
        await execute(() async {
          var res = await TwinnedSession.instance.pulseAdmin.deleteSmsGroup(
              apikey: TwinnedSession.instance.authToken, groupId: group.id);

          if (validateResponse(res)) {
            alert('SMS Group ${group.name}', 'Deleted Successfully');
          }
        });
      },
    );
    Future.delayed(Duration(seconds: 1), () {
      _load();
    });
  }

  Future<void> _showSmsGroupDialog(String type, pulse.SmsGroup? entity) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '$type SMS Group',
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          scrollable: true,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.6,
            child: AddEditPhoneGroup(
              SmsGroup: entity,
              onNameSaved: (String value) {
                setState(() {
                  if (entity == null) {
                    name = value.trim();
                  } else {
                    entity = entity!.copyWith(name: value.trim());
                  }
                });
              },
              onSmsSaved: (List<PhoneNumber> SMS) {
                setState(() {
                  if (entity == null) {
                    SMSList = SMS;
                  } else {
                    entity = entity!.copyWith(phoneList: SMS);
                  }
                  SMSList = SMS;
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
      var res = await TwinnedSession.instance.pulseAdmin.searchSmsGroup(
          apikey: TwinnedSession.instance.authToken,
          body: pulse.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(res)) {
        for (pulse.SmsGroup entity in res.body?.values ?? []) {
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

  Future _save(pulse.SmsGroup? groupSMS) async {
    if (loading) return;
    loading = true;
    late pulse.SmsGroupInfo _config;

    if (null == groupSMS) {
      _config = pulse.SmsGroupInfo(
        name: name,
        phoneList: SMSList,
      );
    } else {
      _config = pulse.SmsGroupInfo(
          name: groupSMS.name, phoneList: groupSMS.phoneList);
    }
    await execute(() async {
      var uRes = await TwinnedSession.instance.pulseAdmin.upsertSmsGroup(
          apikey: TwinnedSession.instance.authToken,
          groupId: groupSMS != null ? groupSMS.id : null,
          body: _config);
      if (validateResponse(uRes)) {
        _close();
        if (groupSMS == null) {
          alert(
            'Success',
            'SMS Group ${_config.name} Created Successfully!',
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            contentStyle: theme.getStyle(),
          );
        } else {
          alert(
            'Success',
            'SMS Group ${_config.name} Updated Successfully!',
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
      SMSList = [];
    });
  }
}
