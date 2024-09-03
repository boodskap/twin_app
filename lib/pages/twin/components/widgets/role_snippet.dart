import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/twinned_api.dart' as twinned;

class RolesSnippet extends StatefulWidget {
  final twinned.Role? roles;
  final ValueNotifier<twinned.Role>? changeNotifier;
  const RolesSnippet({super.key, this.roles, this.changeNotifier});

  @override
  State<RolesSnippet> createState() => _RolesSnippetState();
}

class _RolesSnippetState extends BaseState<RolesSnippet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  Future<List<String>>? clientIds =
      isClientAdmin() ? TwinnedSession.instance.getClientIds() : null;
  twinned.RoleInfo _role =
      const twinned.RoleInfo(name: '', description: '', clientIds: []);

  @override
  void initState() {
    super.initState();
    if (null != widget.roles) {
      twinned.Role c = widget.roles!;
      _role = _role.copyWith(
        description: c.description,
        name: c.name,
        clientIds: c.clientIds,
      );
    }

    nameController.text = _role.name;
    descController.text = _role.description ?? '';

    nameController.addListener(_onNameChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        height: MediaQuery.of(context).size.height / 1.1,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.getPrimaryColor(),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Name',
                          labelTextStyle: theme.getStyle(),
                          style: theme.getStyle(),
                          controller: nameController,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.getPrimaryColor()),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Description',
                          labelTextStyle: theme.getStyle(),
                          style: theme.getStyle(),
                          controller: descController,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.getPrimaryColor()),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: theme.getPrimaryColor(),
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 10),
              child: Row(
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
                    labelKey: (null == widget.roles) ? 'Create' : 'Update',
                    onPressed: !_canCreateOrUpdate()
                        ? null
                        : () {
                            _save();
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.removeListener(_onNameChanged);

    nameController.dispose();
    descController.dispose();

    super.dispose();
  }

  void _onNameChanged() {
    setState(() {});
  }

  bool _canCreateOrUpdate() {
    final text = nameController.text.trim();

    return text.isNotEmpty && text.length >= 3;
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Future _save({bool silent = false}) async {
    if (loading) return;
    loading = true;
    List<String>? clientIds = super.isClientAdmin()
        ? await TwinnedSession.instance.getClientIds()
        : null;
    _role = _role.copyWith(
      name: nameController.text.trim(),
      description: descController.text.trim(),
      clientIds: clientIds ?? _role.clientIds,
      tags: [],
    );

    await execute(() async {
      if (null == widget.roles) {
        var cRes = await TwinnedSession.instance.twin
            .createRole(apikey: TwinnedSession.instance.authToken, body: _role);
        if (validateResponse(cRes)) {
          _close();
          alert('Success', 'Role ${_role.name} created');
        }
      } else {
        var uRes = await TwinnedSession.instance.twin.updateRole(
            apikey: TwinnedSession.instance.authToken,
            roleId: widget.roles!.id,
            body: _role);
        if (validateResponse(uRes)) {
          if (!silent) {
            _close();
            alert('Success', 'Role ${_role.name} updated successfully');
          }
          if (null != widget.changeNotifier) {
            widget.changeNotifier!.value = uRes.body!.entity!;
          }
        }
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {}
}
