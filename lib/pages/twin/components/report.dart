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
  final double cardWidth;
  final double cardHeight;
  const AssetReportList({
    super.key,
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
                  selectedItem: _selectedDeviceModel?.id,
                  onDeviceModelSelected: (e) {
                    setState(() {
                      _selectedDeviceModel = e;
                    });
                    _load();
                  }),
            ),
            divider(horizontal: true),
            if (null != _selectedDeviceModel!.id)
              PrimaryButton(
                leading: const Icon(
                  Icons.add_box,
                  color: Colors.white,
                ),
                labelKey: "Add New",
                onPressed: (_selectedDeviceModel != null)
                    ? () async {
                        await _addNew();
                      }
                    : null,
              ),
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
    Widget? image;
    if (null != report.icon && report.icon!.isNotEmpty) {
      image = TwinImageHelper.getImage(report.domainKey, report.icon!);
    }

    return InkWell(
      onDoubleTap: () async {
        await _edit(report);
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
                    message: 'Delete this report',
                    child: IconButton(
                      onPressed: () async {
                        await _delete(report);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: theme.getPrimaryColor(),
                      ),
                    ),
                  )),
              Positioned(
                right: 45,
                child: IconButton(
                  onPressed: () async {
                    await _edit(report);
                  },
                  icon: Icon(Icons.edit, color: theme.getPrimaryColor()),
                ),
              ),
              Positioned(
                  right: 8,
                  child: Tooltip(
                    message: 'Upload icon',
                    child: IconButton(
                        onPressed: () async {
                          await _upload(report);
                        },
                        icon: Icon(
                          Icons.upload,
                          color: theme.getPrimaryColor(),
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
      var deviceModelsRes = await TwinnedSession.instance.twin.listDeviceModels(
          apikey: TwinnedSession.instance.authToken,
          body: const twinned.ListReq(page: 0, size: 10000));

      if (validateResponse(deviceModelsRes)) {
        var deviceModels = deviceModelsRes.body?.values ?? [];
        if (deviceModels.isNotEmpty) {
          if (_selectedDeviceModel == null) {
            _selectedDeviceModel = deviceModels.first;
          }
        }
      }

      var res = await TwinnedSession.instance.twin.listReports(
          apikey: TwinnedSession.instance.authToken,
          modelId: _selectedDeviceModel!.id,
          body: const twinned.ListReq(page: 0, size: 10000));

      if (validateResponse(res)) {
        _reports.addAll(res.body!.values!);
        _cards.clear();
        for (int i = 0; i < _reports.length; i++) {
          _cards.add(buildCard(_reports[i]));
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
                    alert('Invalid',
                        'Name is required and should be minimum 3 characters');
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
        messageStyle: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
        onPressed: () async {
          await execute(() async {
            int index = _reports.indexWhere((element) => element.id == e.id);
            var res = await TwinnedSession.instance.twin.deleteReport(
                apikey: TwinnedSession.instance.authToken, reportId: e.id);
            if (validateResponse(res)) {
              await _load();
              _reports.removeAt(index);
              _cards.removeAt(index);
              alert("Success", "Report ${e.name} Deleted Successfully!");
            }
          });
        });
    loading = false;

    refresh();
  }

  Future _edit(twinned.Report report) async {
    await showDialog(
        context: context,
        useSafeArea: true,
        builder: (context) {
          return Center(
            child: AlertDialog(
              content: ReportContentWidget(
                report: report,
                deviceModel: _selectedDeviceModel!,
              ),
            ),
          );
        });
    await _load();
  }

  Future _upload(twinned.Report filter) async {
    if (loading) return;
    loading = true;
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
            ));

        if (validateResponse(rRes)) {
          await _load();
          alert('Filter ${rRes.body!.entity!.name} ', 'updated successfully');
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
              fields: widget.report.fields));
      if (validateResponse(res)) {
        await alert('Report - ${_name.text}', 'Saved successfully');
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
