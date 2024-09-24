import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/asset_groups.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twinned_widgets/core/device_model_dropdown.dart';

class AssetReportList extends StatefulWidget {
  final twinned.ReportInfoTarget target;
  final double cardWidth;
  final double cardHeight;

  const AssetReportList({
    super.key,
    required this.target,
    this.cardWidth = 200,
    this.cardHeight = 200,
  });

  @override
  State<AssetReportList> createState() => _AssetReportListState();
}

class _AssetReportListState extends BaseState<AssetReportList> {
  final List<twinned.Report> _reports = [];
  final List<Widget> _cards = [];
  tapi.DeviceModel? _selectedDeviceModel;
  Map<String, bool> _editable = Map<String, bool>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const BusyIndicator(),
            IconButton(
                onPressed: () async {
                  await _load();
                },
                icon: const Icon(Icons.refresh)),
            divider(horizontal: true),
            SizedBox(
              width: 250,
              child: DeviceModelDropdown(
                  style: theme.getStyle(),
                  selectedItem: _selectedDeviceModel?.id,
                  onDeviceModelSelected: (e) {
                    setState(() {
                      _selectedDeviceModel = e;
                    });
                    _load();
                  }),
            ),
            divider(horizontal: true),
            // if (null != _selectedDeviceModel)
            PrimaryButton(
              leading: const Icon(
                Icons.add_box,
                color: Colors.white,
              ),
              labelKey: "Add New",
              onPressed: (canCreate() && _selectedDeviceModel != null)
                  ? () async {
                      await _addNew();
                    }
                  : null,
            ),
            divider(horizontal: true),
          ],
        ),
        if (_cards.isEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (loading) const BusyIndicator(),
              if (!loading) Text('No report found', style: theme.getStyle()),
            ],
          ),
        if (_cards.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: _cards,
            ),
          ),
      ],
    );
  }

  Widget buildCard(twinned.Report report) {
    bool editable = _editable[report.id] ?? false;
    Widget? image;
    if (null != report.icon && report.icon!.isNotEmpty) {
      image = TwinImageHelper.getCachedImage(report.domainKey, report.icon!);
    }

    return InkWell(
      onDoubleTap: () async {
        if (editable) {
          await _edit(report);
        }
      },
      child: Card(
        elevation: 10,
        child: Container(
          color: Colors.white,
          width: widget.cardWidth,
          height: widget.cardHeight,
          child: Stack(
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (null != image)
                      SizedBox(width: 48, height: 48, child: image),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        report.name,
                        style: theme.getStyle().copyWith(fontSize: 14),
                      ),
                    ),
                    Text(
                      '${report.fields.length} fields',
                      style: theme.getStyle().copyWith(
                            fontSize: 10,
                            color: Colors.blue,
                          ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  left: 8,
                  child: Tooltip(
                    message: editable ? "Delete" : "No Permission to Delete",
                    child: IconButton(
                      onPressed: editable
                          ? () {
                              _delete(report);
                            }
                          : null,
                      icon: Icon(
                        Icons.delete_forever,
                        color: editable ? theme.getPrimaryColor() : Colors.grey,
                      ),
                    ),
                  )),
              Positioned(
                right: 45,
                child: Tooltip(
                  message: editable ? "Update" : "No Permission to Edit",
                  child: IconButton(
                    onPressed: editable
                        ? () async {
                            await _edit(report);
                          }
                        : null,
                    icon: Icon(
                      Icons.edit,
                      color: editable ? theme.getPrimaryColor() : Colors.grey,
                    ),
                  ),
                ),
              ),
              Positioned(
                  right: 8,
                  child: Tooltip(
                    message: editable ? "Upload" : "No Permission to Upload",
                    child: IconButton(
                        onPressed: editable
                            ? () {
                                _upload(report);
                              }
                            : null,
                        icon: Icon(
                          Icons.upload,
                          color:
                              editable ? theme.getPrimaryColor() : Colors.grey,
                        )),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      _reports.clear();
      _cards.clear();

      String modelId = "";
      if (_selectedDeviceModel == null) {
        modelId = ""
            "";
      } else {
        modelId = _selectedDeviceModel!.id;
      }
      var res = await TwinnedSession.instance.twin.searchReports(
          apikey: TwinnedSession.instance.authToken,
          modelId: modelId,
          myReports: widget.target == twinned.ReportInfoTarget.user,
          body: const twinned.SearchReq(search: '*', page: 0, size: 10000));

      if (validateResponse(res)) {
        _reports.addAll(res.body!.values!);
        _cards.clear();

        for (tapi.Report e in _reports) {
          _editable[e.id] = await super.canEdit(clientIds: e.clientIds);

          _cards.add(buildCard(e));
        }
      }
    });
    loading = false;
    refresh();
  }

  Future _addNew() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      await _getBasicInfo(context, 'New Report',
          onPressed: (String name, String? description, String? tags) async {
        var res = await TwinnedSession.instance.twin.createReport(
            apikey: TwinnedSession.instance.authToken,
            body: twinned.ReportInfo(
              modelId: _selectedDeviceModel!.id,
              name: name,
              description: description,
              tags: (tags ?? '').split(' '),
              includePremise: false,
              includeFloor: false,
              includeFacility: false,
              includeDevice: false,
              includeAsset: true,
              fields: [],
              target: widget.target,
              clientIds: await getClientIds(),
            ));
        if (validateResponse(res)) {
          await _load();
        }
      });
    });
    loading = false;
    refresh();
  }

  Future<void> _getBasicInfo(BuildContext context, String title,
      {required BasicInfoCallback onPressed}) async {
    String? nameText = '';
    String? descText = '';
    String? tagsText = '';
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            contentTextStyle: theme.getStyle(),
            titleTextStyle: theme
                .getStyle()
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
            title: Text(title),
            content: SizedBox(
              width: 500,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        nameText = value;
                      });
                    },
                    style: theme.getStyle(),
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        descText = value;
                      });
                    },
                    style: theme.getStyle(),
                    decoration: InputDecoration(
                      hintText: 'Description',
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        tagsText = value;
                      });
                    },
                    style: theme.getStyle(),
                    decoration: InputDecoration(
                      hintText: 'Tags (space separated)',
                      hintStyle: theme.getStyle(),
                      labelStyle: theme.getStyle(),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              SecondaryButton(
                labelKey: "Cancel",
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              divider(horizontal: true),
              PrimaryButton(
                labelKey: "OK",
                onPressed: () {
                  if (nameText!.length < 3) {
                    alert(
                      'Invalid',
                      'Name is required and should be minimum 3 characters',
                      titleStyle: theme
                          .getStyle()
                          .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      contentStyle: theme.getStyle(),
                    );
                    return;
                  }
                  setState(() {
                    onPressed(nameText!, descText, tagsText);
                    Navigator.pop(context);
                  });
                },
              ),
              divider(horizontal: true),
            ],
          );
        });
  }

  Future _delete(tapi.Report e) async {
    if (loading) return;
    loading = true;
    await confirm(
        title: 'Warning',
        message:
            'Deleting is unrecoverable\nIt may also delete all the related models and components\n\nDo you want to proceed?',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle(),
        onPressed: () async {
          await execute(() async {
            int index = _reports.indexWhere((element) => element.id == e.id);
            var res = await TwinnedSession.instance.twin.deleteReport(
                apikey: TwinnedSession.instance.authToken, reportId: e.id);
            if (validateResponse(res)) {
              await _load();
              _reports.removeAt(index);
              _cards.removeAt(index);
              alert(
                "Report- ${e.name}",
                "Deleted successfully!",
                titleStyle: theme
                    .getStyle()
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                contentStyle: theme.getStyle(),
              );
            }
          });
        });
    loading = false;

    refresh();
  }

  Future _edit(twinned.Report report) async {
    var res = await TwinnedSession.instance.twin.getDeviceModel(
        modelId: report.modelId, apikey: TwinnedSession.instance.authToken);

    await showDialog(
        context: context,
        useSafeArea: true,
        builder: (context) {
          return Center(
            child: AlertDialog(
              contentTextStyle: theme.getStyle(),
              titleTextStyle: theme
                  .getStyle()
                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              content: ReportContentWidget(
                report: report,
                deviceModel: res.body!.entity!,
              ),
            ),
          );
        });
    await _load();
  }

  Future _upload(twinned.Report filter) async {
    if (loading) return;
    loading = true;
    List<String>? clientIds = super.isClientAdmin()
        ? await TwinnedSession.instance.getClientIds()
        : null;

    await execute(() async {
      var res = await TwinImageHelper.uploadDomainIcon();
      if (null != res && null != res.entity) {
        var rRes = await TwinnedSession.instance.twin.updateReport(
            apikey: TwinnedSession.instance.authToken,
            reportId: filter.id,
            body: twinned.ReportInfo(
              modelId: filter.modelId,
              name: filter.name,
              fields: filter.fields,
              icon: res.entity!.id,
              tags: filter.tags,
              description: filter.description,
              target: widget.target,
              clientIds: clientIds ?? filter.clientIds,
            ));

        if (validateResponse(rRes)) {
          await _load();
          alert(
            'Filter - ${rRes.body!.entity!.name} ',
            'Updated successfully!',
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

  @override
  void setup() async {
    _load();
  }
}

class ReportContentWidget extends StatefulWidget {
  final twinned.Report report;
  final twinned.DeviceModel deviceModel;

  const ReportContentWidget(
      {super.key, required this.report, required this.deviceModel});

  @override
  State<ReportContentWidget> createState() => _ReportContentWidgetState();
}

class _ReportContentWidgetState extends BaseState<ReportContentWidget> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _tags = TextEditingController();
  final TextEditingController _dateFormat = TextEditingController();
  bool includePremise = true;
  bool includeFacility = true;
  bool includeFloor = true;
  bool includeAsset = true;
  bool includeDevice = true;

  @override
  void initState() {
    _name.text = widget.report.name;
    _desc.text = widget.report.description ?? '';
    _tags.text = widget.report.tags?.join(' ') ?? '';
    _dateFormat.text = widget.report.dateFormat ?? 'yyyy/MM/dd HH:mm:ss';
    includePremise = widget.report.includePremise ?? true;
    includeFacility = widget.report.includeFacility ?? true;
    includeFloor = widget.report.includeFloor ?? true;
    includeAsset = widget.report.includeAsset ?? true;
    includeDevice = widget.report.includeDevice ?? true;
    super.initState();
  }

  Future _save() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      // var ires = await TwinImageHelper.uploadDomainIcon();

      var res = await TwinnedSession.instance.twin.updateReport(
          apikey: TwinnedSession.instance.authToken,
          reportId: widget.report.id,
          body: twinned.ReportInfo(
            modelId: widget.report.modelId,
            name: _name.text,
            description: _desc.text,
            tags: _tags.text.split(' '),
            icon: widget.report.icon,
            includeAsset: includeAsset,
            includeDevice: includeDevice,
            includeFacility: includeFacility,
            includeFloor: includeFloor,
            includePremise: includePremise,
            dateFormat: _dateFormat.text.trim(),
            tz: DateTime.now().timeZoneName,
            humanDateFormat: false,
            fields: widget.report.fields,
            target: widget.report.target == twinned.ReportTarget.app
                ? twinned.ReportInfoTarget.app
                : twinned.ReportInfoTarget.user,
            clientIds: await getClientIds(),
          ));
      if (validateResponse(res)) {
        await alert(
          'Report - ${_name.text}',
          'Saved successfully!',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
        _close();
      }
    });
    loading = false;
    refresh();
  }

  void _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (var parameter in widget.deviceModel.parameters) {
      children.add(CheckboxListTile(
        title: Text(
          '${parameter.name} ${parameter.unit ?? ''} (${parameter.label ?? parameter.name})',
          style: theme.getStyle(),
        ),
        value: widget.report.fields.contains(parameter.name),
        onChanged: (newValue) {
          setState(() {
            if (newValue ?? false) {
              widget.report.fields.add(parameter.name);
            } else {
              widget.report.fields.remove(parameter.name);
            }
          });
        },
        controlAffinity:
            ListTileControlAffinity.leading, //  <-- leading Checkbox
      ));
    }

    children.add(Container(
      height: 2,
      color: Colors.black,
    ));

    children.add(CheckboxListTile(
      title: Text(
        'Premise',
        style: theme.getStyle(),
      ),
      value: includePremise,
      onChanged: (bool? value) {
        setState(() {
          includePremise = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    ));

    children.add(CheckboxListTile(
      title: Text(
        'Facility',
        style: theme.getStyle(),
      ),
      value: includeFacility,
      onChanged: (bool? value) {
        setState(() {
          includeFacility = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    ));

    children.add(CheckboxListTile(
      title: Text(
        'Floor',
        style: theme.getStyle(),
      ),
      value: includeFloor,
      onChanged: (bool? value) {
        setState(() {
          includeFloor = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    ));

    children.add(CheckboxListTile(
      title: Text(
        'Asset',
        style: theme.getStyle(),
      ),
      value: includeAsset,
      onChanged: (bool? value) {
        setState(() {
          includeAsset = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    ));

    children.add(CheckboxListTile(
      title: Text(
        'Device',
        style: theme.getStyle(),
      ),
      value: includeDevice,
      onChanged: (bool? value) {
        setState(() {
          includeDevice = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    ));

    return SizedBox(
      width: MediaQuery.of(context).size.width / 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LabelTextField(
            label: 'Report Name',
            controller: _name,
            labelTextStyle: theme.getStyle(),
            decoration: InputDecoration(
              hintStyle: theme.getStyle(),
              errorStyle: theme.getStyle(),
            ),
            style: theme.getStyle(),
          ),
          divider(),
          LabelTextField(
            label: 'Description',
            controller: _desc,
            labelTextStyle: theme.getStyle(),
            style: theme.getStyle(),
          ),
          divider(),
          LabelTextField(
            label: 'Tags',
            controller: _tags,
            labelTextStyle: theme.getStyle(),
            style: theme.getStyle(),
          ),
          divider(),
          LabelTextField(
            label: 'Date Format',
            controller: _dateFormat,
            labelTextStyle: theme.getStyle(),
            style: theme.getStyle(),
          ),
          divider(),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, index) {
                  return children[index];
                }),
          ),
          divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              divider(horizontal: true),
              SecondaryButton(
                labelKey: "Cancel",
                onPressed: () {
                  _close();
                },
              ),
              divider(horizontal: true),
              PrimaryButton(
                labelKey: "Save",
                leading: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await _save();
                },
              ),
              divider(horizontal: true),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void setup() {}
}
