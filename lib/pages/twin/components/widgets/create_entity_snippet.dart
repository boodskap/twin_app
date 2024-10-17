import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

typedef NameCallback = void Function(String name);

class CreateEntitySnippet extends StatefulWidget {
  CreateEntitySnippet({
    super.key,
  });

  @override
  State<CreateEntitySnippet> createState() => _CreateEntitySnippetState();
}

class _CreateEntitySnippetState extends BaseState<CreateEntitySnippet> {
  TextEditingController nameController = TextEditingController();
  bool strictCheck = true;
  tapi.CustomEntityMappingInfo _entity =
      const tapi.CustomEntityMappingInfo(name: '', relaxed: false, fields: [
    tapi.CustomEntityField(
        name: 'id', type: tapi.CustomEntityFieldType.keyword),
  ]);

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Name',
                          style: theme.getStyle(),
                          labelTextStyle: theme.getStyle(),
                          controller: nameController,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.getPrimaryColor(),
                            ),
                          ),
                        ),
                      ),
                      divider(),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Checkbox(
                              value: strictCheck,
                              onChanged: (value) {
                                setState(() {
                                  strictCheck = value ?? false;
                                });
                              }),
                          Text(
                            'Strict field check',
                            style: theme.getStyle(),
                          )
                        ],
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
                    labelKey: 'Create',
                    onPressed: () {
                      if (_canCreateOrUpdate()) {
                        _save();
                      } else {
                        alert("Please check", "Name can't be empty",
                            contentStyle: theme.getStyle(),
                            titleStyle: theme.getStyle().copyWith(
                                fontSize: 18, fontWeight: FontWeight.bold));
                      }
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

  bool _canCreateOrUpdate() {
    final text = nameController.text.trim();

    return text.isNotEmpty;
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Future _save() async {
    if (loading) return;
    loading = true;

    _entity = _entity.copyWith(
      name: nameController.text.trim(),
      relaxed: !strictCheck,
    );

    await execute(() async {
      var cRes = await TwinnedSession.instance.twin.upsertCustomEntityMapping(
          apikey: TwinnedSession.instance.authToken, body: _entity);
      if (validateResponse(cRes)) {
        _close();
        alert(
          'Custom Entity - ${_entity.name}',
          'Created successfully!',
          titleStyle: theme.getStyle().copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
          contentStyle: theme.getStyle(),
        );
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {}
}
