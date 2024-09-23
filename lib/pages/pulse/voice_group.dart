import 'package:flutter/material.dart';
import 'package:pulse_admin_api/api/pulse_admin.swagger.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/pulse/widgets/add_edit_phone_group.dart';
import 'package:twin_app/pages/pulse/widgets/custom_badge.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;

class VoiceGroupPage extends StatefulWidget {
  const VoiceGroupPage({super.key});

  @override
  State<VoiceGroupPage> createState() => _VoiceGroupPageState();
}

class _VoiceGroupPageState extends BaseState<VoiceGroupPage> {
  String _search = '*';
  List<PhoneNumber> VoiceList = [];
  String name = "";
  final List<Widget> _children = [];
   final TextEditingController _searchTextController = TextEditingController();
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
                    _searchTextController.text = "";
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
                  await _showVoiceGroupDialog('Create', null);
                },
              ),
              divider(horizontal: true),
              SizedBox(
                width: 250,
                height: 40,
                child: SearchBar(
                  controller: _searchTextController,
                  leading: const Icon(Icons.search),
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintText: "Search Voices",
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

  bool canCreateOrUpdate(pulse.VoiceGroup? entity) {
    if (entity != null) {
      return entity.name.isNotEmpty && entity.phoneList.isNotEmpty;
    } else {
      return name.isNotEmpty && VoiceList.isNotEmpty;
    }
  }

  Widget _buildChild(pulse.VoiceGroup entity) {
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
                          await _showVoiceGroupDialog('Update', entity);
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

  Future _delete(pulse.VoiceGroup group) async {
    await confirm(
      title: 'Delete ${group.name}',
      message: 'Are you sure you want to delete this Voice group?',
      onPressed: () async {
        await execute(() async {
          var res = await TwinnedSession.instance.pulseAdmin.deleteVoiceGroup(
              apikey: TwinnedSession.instance.authToken, groupId: group.id);

          if (validateResponse(res)) {
            alert('Voice Group ${group.name}', 'Deleted Successfully');
          }
        });
      },
    );
    Future.delayed(Duration(seconds: 1), () {
      _load();
    });
  }

  Future<void> _showVoiceGroupDialog(String type, pulse.VoiceGroup? entity) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '$type Voice Group',
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
              VoiceGroup: entity,
              onNameSaved: (String value) {
                setState(() {
                  if (entity == null) {
                    name = value.trim();
                  } else {
                    entity = entity!.copyWith(name: value.trim());
                  }
                });
              },
              onPhoneNumberSaved: (List<PhoneNumber> Voice) {
                setState(() {
                  if (entity == null) {
                    VoiceList = Voice;
                  } else {
                    entity = entity!.copyWith(phoneList: Voice);
                  }
                  VoiceList = Voice;
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
      var res = await TwinnedSession.instance.pulseAdmin.searchVoiceGroup(
          apikey: TwinnedSession.instance.authToken,
          body: pulse.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(res)) {
        for (pulse.VoiceGroup entity in res.body?.values ?? []) {
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

  Future _save(pulse.VoiceGroup? groupVoice) async {
    if (loading) return;
    loading = true;
    late pulse.VoiceGroupInfo _config;

    if (null == groupVoice) {
      _config = pulse.VoiceGroupInfo(
        name: name,
        phoneList: VoiceList,
      );
    } else {
      _config = pulse.VoiceGroupInfo(
          name: groupVoice.name, phoneList: groupVoice.phoneList);
    }
    await execute(() async {
      var uRes = await TwinnedSession.instance.pulseAdmin.upsertVoiceGroup(
          apikey: TwinnedSession.instance.authToken,
          groupId: groupVoice != null ? groupVoice.id : null,
          body: _config);
      if (validateResponse(uRes)) {
        _close();
        if (groupVoice == null) {
          alert(
            'Success',
            'Voice Group ${_config.name} Created Successfully!',
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            contentStyle: theme.getStyle(),
          );
        } else {
          alert(
            'Success',
            'Voice Group ${_config.name} Updated Successfully!',
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
      VoiceList = [];
    });
  }

  
}
