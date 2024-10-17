import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

typedef NameCallback = void Function(String name);

class CreateFieldSnippet extends StatefulWidget {
  final tapi.CustomEntityMapping mapping;

  CreateFieldSnippet({
    super.key,
    required this.mapping,
  });

  @override
  State<CreateFieldSnippet> createState() => _CreateFieldSnippetState();
}

class _CreateFieldSnippetState extends BaseState<CreateFieldSnippet> {
  static final List<tapi.CustomEntityFieldType> fields = [
    tapi.CustomEntityFieldType.text,
    tapi.CustomEntityFieldType.keyword,
    tapi.CustomEntityFieldType.long,
    tapi.CustomEntityFieldType.integer,
    tapi.CustomEntityFieldType.short,
    tapi.CustomEntityFieldType.byte,
    tapi.CustomEntityFieldType.double,
    tapi.CustomEntityFieldType.float,
    tapi.CustomEntityFieldType.boolean,
    tapi.CustomEntityFieldType.date,
    tapi.CustomEntityFieldType.unsignedLong,
    tapi.CustomEntityFieldType.halfFloat,
    tapi.CustomEntityFieldType.geoPoint,
    tapi.CustomEntityFieldType.geoShape,
    tapi.CustomEntityFieldType.point,
    tapi.CustomEntityFieldType.shape,
    tapi.CustomEntityFieldType.object,
    tapi.CustomEntityFieldType.binary,
    tapi.CustomEntityFieldType.wildcard,
    tapi.CustomEntityFieldType.constantKeyword,
    tapi.CustomEntityFieldType.dateNanos,
    tapi.CustomEntityFieldType.flattened,
    tapi.CustomEntityFieldType.nested,
    tapi.CustomEntityFieldType.longRange,
    tapi.CustomEntityFieldType.doubleRange,
    tapi.CustomEntityFieldType.dateRange,
    tapi.CustomEntityFieldType.ipRange,
    tapi.CustomEntityFieldType.ip,
    tapi.CustomEntityFieldType.version,
    tapi.CustomEntityFieldType.murmur3,
    tapi.CustomEntityFieldType.aggregateMetricDouble,
    tapi.CustomEntityFieldType.histogram,
    tapi.CustomEntityFieldType.matchOnlyText,
    tapi.CustomEntityFieldType.completion,
    tapi.CustomEntityFieldType.searchAsYouType,
    tapi.CustomEntityFieldType.semanticText,
    tapi.CustomEntityFieldType.tokenCount,
    tapi.CustomEntityFieldType.denseVector,
    tapi.CustomEntityFieldType.sparseVector,
    tapi.CustomEntityFieldType.rankFeature,
    tapi.CustomEntityFieldType.rankFeatures,
  ];

  TextEditingController nameController = TextEditingController();
  tapi.CustomEntityFieldType? fieldType;

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
                      Card(
                        elevation: 1,
                        margin: EdgeInsets.only(bottom: 3),
                        child: ListTile(
                          title: Text("Data Type"),
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          trailing: DropdownButtonHideUnderline(
                            child: DropdownButton<tapi.CustomEntityFieldType>(
                              isExpanded: false,
                              value: fieldType,
                              items: fields.map((item) {
                                return new DropdownMenuItem(
                                  child: Container(
                                    width: 150, //expand here
                                    child: new Text(
                                      item.name,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  value: item,
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  fieldType = value;
                                });
                              },
                              hint: Container(
                                width: 150, //and here
                                child: Text(
                                  "Select Data Type",
                                  style: theme
                                      .getStyle()
                                      .copyWith(color: Colors.grey),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              style: TextStyle(
                                  color: Colors.black,
                                  decorationColor: Colors.red),
                            ),
                          ),
                        ),
                      ),
                      divider(),
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
                        alert("Please check", "Name and type can't be empty",
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

    return text.isNotEmpty && null != fieldType;
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Future _save() async {
    if (loading) return;
    loading = true;

    List<tapi.CustomEntityField> fields = [];
    fields.addAll(widget.mapping.fields);

    tapi.CustomEntityMappingInfo entity = tapi.CustomEntityMappingInfo(
        name: widget.mapping.name,
        relaxed: widget.mapping.relaxed,
        fields: fields);

    await execute(() async {
      var cRes = await TwinnedSession.instance.twin.upsertCustomEntityMapping(
          apikey: TwinnedSession.instance.authToken, body: entity);
      if (validateResponse(cRes)) {
        _close();
        alert(
          entity.name,
          'Updated successfully!',
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
