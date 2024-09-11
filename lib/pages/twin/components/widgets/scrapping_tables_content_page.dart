import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/card_layout_section.dart';
import 'package:twin_app/pages/twin/components/widgets/parameter_upsert_dialog.dart';
import 'package:twin_app/pages/twin/components/widgets/showoverlay_widget.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twinned_widgets/core/top_bar.dart';

class ScrappingTablesContentPage extends StatefulWidget {
  tapi.ScrappingTable? model;

  ScrappingTablesContentPage({super.key, this.model});

  @override
  State<ScrappingTablesContentPage> createState() =>
      _ScrappingTablesContentPageState();
}

class _ScrappingTablesContentPageState
    extends BaseState<ScrappingTablesContentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  int editIndex = -1;
  final TextEditingController paramName = TextEditingController();
  final TextEditingController paramDesc = TextEditingController();
  final TextEditingController paramLabel = TextEditingController();
  final TextEditingController paramValue = TextEditingController();
  ValueNotifier<tapi.AttributeAttributeType> paramType = ValueNotifier(
    tapi.AttributeAttributeType.numeric,
  );
  ValueNotifier<bool> paramEditable = ValueNotifier(true);
  List<TableRow> rows = [];
  List<TableRow> paramHeaders = [];

  List<tapi.Attribute> paramList = [
    const tapi.Attribute(
        name: 'dummy',
        description: 'auto generated, change this',
        label: "",
        attributeType: tapi.AttributeAttributeType.numeric,
        $value: '',
        editable: true),
  ];

  @override
  void initState() {
    super.initState();
    if (null != widget.model) {
      paramList.clear();
      paramList.addAll(widget.model!.attributes as Iterable<tapi.Attribute>);
    }
    paramHeaders.add(TableRow(children: [
      Center(
        child: Text(
          'Name',
          style: theme.getStyle().copyWith(
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Description',
          style: theme.getStyle().copyWith(
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Label',
          style: theme.getStyle().copyWith(
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Type',
          style: theme.getStyle().copyWith(
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Value',
          style: theme.getStyle().copyWith(
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Editable',
          style: theme.getStyle().copyWith(
                fontSize: 16,
              ),
        ),
      ),
      Center(
        child: Text(
          'Action',
          style: theme.getStyle().copyWith(
                fontSize: 16,
              ),
        ),
      ),
    ]));
    rows.add(paramHeaders.first);
    _rebuild();
  }

  @override
  void setup() {
    tapi.ScrappingTable e = widget.model!;
    _nameController.text = e.name;
    _descController.text = e.description ?? '';
    _tagsController.text = null != e.tags ? e.tags!.join(' ') : '';
    ;
  }

  void _rebuild() {
    rows.clear();
    rows.add(paramHeaders.first);
    for (var p in paramList) {
      _buildRow(p);
    }
    setState(() {});
  }

  void _buildRow(var param) {
    TableRow row = TableRow(children: [
      Align(
          alignment: Alignment.center,
          child: Text(
            param.name,
            style: theme.getStyle(),
          )),
      Align(
        alignment: Alignment.center,
        child: Text(param.description ?? '', style: theme.getStyle()),
      ),
      Align(
          alignment: Alignment.center,
          child: Text(param.label ?? '', style: theme.getStyle())),
      Align(
        alignment: Alignment.center,
        child: Text(param.attributeType.value!, style: theme.getStyle()),
      ),
      Align(
        alignment: Alignment.center,
        child: Text(param.$value ?? '', style: theme.getStyle()),
      ),
      Checkbox(
        value: param.editable,
        onChanged: null,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              _editParameter(param, paramList.indexOf(param));
            },
            icon: const Icon(
              Icons.edit,
              size: 18,
            ),
          ),
          IconButton(
            onPressed: () {
              _removeRow(param);
            },
            icon: const Icon(
              Icons.delete,
              size: 18,
            ),
          ),
        ],
      ),
    ]);
    rows.add(row);
  }

  void _removeRow(var param) {
    setState(() {
      paramList.remove(param);
    });
    _rebuild();
  }

  void _addParameter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ParameterUpsertDialogSettings(
          paramName: paramName,
          paramDesc: paramDesc,
          paramLabel: paramLabel,
          paramValue: paramValue,
          isEdit: false,
          addRow: _addNewRow,
          paramType: paramType,
          paramEditable: paramEditable,
        );
      },
    );
  }

  void _editParameter(tapi.Attribute param, int index) {
    setState(() {
      paramName.text = param.name;
      paramDesc.text = param.description ?? '';
      paramLabel.text = param.label ?? '';
      paramValue.text = param.$value ?? '';
      paramType = ValueNotifier(param.attributeType);
      editIndex = index;
      paramEditable = ValueNotifier(param.editable ?? false);
    });

    showDialog(
      context: context,
      builder: (context) {
        return ParameterUpsertDialogSettings(
            addRow: _updateRow,
            paramName: paramName,
            paramDesc: paramDesc,
            paramLabel: paramLabel,
            paramType: paramType,
            paramValue: paramValue,
            isEdit: true,
            paramEditable: paramEditable);
      },
    );
  }

  void _updateRow() {
    var param = tapi.Attribute(
      name: paramName.text,
      description: paramDesc.text,
      label: paramLabel.text,
      attributeType: paramType.value,
      $value: paramValue.text,
      editable: paramEditable.value,
    );

    setState(() {
      paramList[editIndex] = param;
    });
    _rebuild();
  }

  void _addNewRow() {
    var param = tapi.Attribute(
      name: paramName.text,
      description: paramDesc.text,
      label: paramLabel.text,
      attributeType: paramType.value,
      $value: paramValue.text,
      editable: paramEditable.value,
    );

    setState(() {
      paramList.add(param);
    });
    _rebuild();
  }

  void _save() async {
    busy();

    tapi.ScrappingTableInfo info = tapi.ScrappingTableInfo(
      name: _nameController.text,
      attributes: paramList,
      description: _descController.text,
      tags: _tagsController.text.split(','),
    );

    try {
      var res;

      if (null == widget.model) {
        res = await TwinnedSession.instance.twin.createScrappingTable(
          apikey: TwinnedSession.instance.authToken,
          body: info,
        );
      } else {
        res = await TwinnedSession.instance.twin.updateScrappingTable(
          apikey: TwinnedSession.instance.authToken,
          scrappingTableId: widget.model!.id,
          body: info,
        );
      }

      if (validateResponse(res)) {
        setState(() {
          widget.model = res.body!.entity;
        });
        await alert(
            'Scrapping Table - ${_nameController.text}', 'Saved successfully!',
            contentStyle: theme.getStyle(),
            titleStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold));
        Navigator.pop(context);
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    busy(busy: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: 'Digital Twin - Setting - ${widget.model?.name}',
            style: theme.getStyle().copyWith(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          divider(),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    divider(),
                    Row(
                      children: [
                        divider(horizontal: true),
                        Expanded(
                          flex: 25,
                          child: LabelTextField(
                            style: theme.getStyle(),
                            labelTextStyle: theme.getStyle(),
                            suffixIcon: Tooltip(
                              message: 'Copy Scrapping Table id',
                              preferBelow: false,
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: widget.model!.id),
                                  );
                                  OverlayWidget.showOverlay(
                                    context: context,
                                    topPosition: 140,
                                    leftPosition: 280,
                                    message: 'Scrapping Table id copied!',
                                  );
                                },
                                child: const Icon(
                                  Icons.content_copy,
                                  size: 20,
                                ),
                              ),
                            ),
                            label: 'Scrapping Table Name',
                            controller: _nameController,
                          ),
                        ),
                        divider(horizontal: true),
                        Expanded(
                            flex: 50,
                            child: LabelTextField(
                              style: theme.getStyle(),
                              labelTextStyle: theme.getStyle(),
                              label: 'Description',
                              controller: _descController,
                            )),
                        divider(horizontal: true),
                        Expanded(
                            flex: 30,
                            child: LabelTextField(
                              style: theme.getStyle(),
                              labelTextStyle: theme.getStyle(),
                              label: 'Tags',
                              controller: _tagsController,
                            )),
                        divider(horizontal: true),
                      ],
                    ),
                    divider(),
                    CardLayoutSection(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Parameter Info",
                                style: theme.getStyle().copyWith(fontSize: 24),
                              ),
                            ],
                          ),
                          divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              PrimaryButton(
                                labelKey: 'Add Parameter',
                                onPressed: _addParameter,
                              ),
                            ],
                          ),
                          divider(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Table(
                              border: TableBorder.all(),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              columnWidths: {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(2),
                                3: FlexColumnWidth(1),
                                4: FlexColumnWidth(2),
                                5: FlexColumnWidth(1),
                              },
                              children: rows,
                            ),
                          ),
                          divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              PrimaryButton(
                                labelKey: 'Save',
                                onPressed: () {
                                  _save();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
