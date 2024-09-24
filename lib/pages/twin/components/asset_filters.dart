import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/asset_groups.dart';
import 'package:twin_app/pages/twin/components/widgets/field_filter_snippet.dart';
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
import 'package:twinned_widgets/core/top_bar.dart';

class AssetFilterList extends StatefulWidget {
  final twinned.DataFilterInfoTarget target;
  final double cardWidth;
  final double cardHeight;

  const AssetFilterList({
    super.key,
    required this.target,
    this.cardWidth = 200,
    this.cardHeight = 200,
  });

  @override
  State<AssetFilterList> createState() => _AssetFilterListState();
}

class _AssetFilterListState extends BaseState<AssetFilterList> {
  final List<twinned.DataFilter> _dataFilters = [];
  final List<twinned.FieldFilter> _fieldFilters = [];
  tapi.DeviceModel? _selectedDeviceModel;
  Map<String, bool> _editable = Map<String, bool>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = [];

    for (var group in _fieldFilters) {
      bool editable = _editable[group.id] ?? false;
      Widget? image;
      if (null != group.icon && group.icon!.isNotEmpty) {
        image = TwinImageHelper.getCachedImage(group.domainKey, group.icon!);
      }
      cards.add(InkWell(
          onDoubleTap: () async {
            if (editable) {
              await alertDialog(
                titleStyle: theme.getStyle().copyWith(fontSize: 20),
                title: 'Generic Filter - ${group.name}',
                body: FieldFilterSnippet(
                  fieldFilter: group,
                ),
              );
              await _load();
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
                            group.name,
                            style: theme.getStyle().copyWith(
                                  fontSize: 14,
                                ),
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
                            ? () async {
                                await _deleteField(group);
                              }
                            : null,
                        icon: Icon(
                          Icons.delete_forever,
                          color:
                              editable ? theme.getPrimaryColor() : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 45,
                    child: Tooltip(
                      message: editable ? "Update" : "No Permission to Edit",
                      child: IconButton(
                        onPressed: editable
                            ? () async {
                                await alertDialog(
                                  titleStyle: theme.getStyle().copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                  title: 'Generic Filter - ${group.name}',
                                  body: FieldFilterSnippet(
                                    fieldFilter: group,
                                  ),
                                );
                                await _load();
                              }
                            : null,
                        icon: Icon(
                          Icons.edit,
                          color:
                              editable ? theme.getPrimaryColor() : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      right: 8,
                      child: Tooltip(
                        message:
                            editable ? "Upload" : "No Permission to Upload",
                        child: IconButton(
                            onPressed: editable
                                ? () async {
                                    await _uploadField(group);
                                  }
                                : null,
                            icon: Icon(
                              Icons.upload,
                              color: editable
                                  ? theme.getPrimaryColor()
                                  : Colors.grey,
                            )),
                      )),
                ],
              ),
            ),
          )));
    }

    for (var group in _dataFilters) {
      Widget? image;
      if (null != group.icon && group.icon!.isNotEmpty) {
        image = TwinImageHelper.getCachedImage(group.domainKey, group.icon!);
      }
      bool editable = _editable[group.id] ?? false;
      cards.add(InkWell(
          onDoubleTap: () async {
            if (editable) {
              await _editGroup(group);
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
                            group.name,
                            style: theme.getStyle().copyWith(
                                  fontSize: 14,
                                ),
                          ),
                        ),
                        Text(
                          '${group.matchGroups.length} conditions',
                          style: theme.getStyle().copyWith(
                              fontSize: 10,
                              color: Colors.blue,
                              overflow: TextOverflow.ellipsis),
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
                            ? () async {
                                await _delete(group);
                              }
                            : null,
                        icon: Icon(
                          Icons.delete_forever,
                          color:
                              editable ? theme.getPrimaryColor() : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 45,
                    child: Tooltip(
                      message: editable ? "Update" : "No Permission to Edit",
                      child: IconButton(
                        onPressed: editable
                            ? () async {
                                await _editGroup(group);
                              }
                            : null,
                        icon: Icon(
                          Icons.edit,
                          color:
                              editable ? theme.getPrimaryColor() : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      right: 8,
                      child: Tooltip(
                        message:
                            editable ? "Upload" : "No Permission to Upload",
                        child: IconButton(
                          onPressed: editable
                              ? () async {
                                  await _upload(group);
                                }
                              : null,
                          icon: Icon(
                            Icons.upload,
                            color: editable
                                ? theme.getPrimaryColor()
                                : Colors.grey,
                          ),
                        ),
                      )),
                ],
              ),
            ),
          )));
    }

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
            PrimaryButton(
              labelKey: "Add New",
              onPressed: (_selectedDeviceModel != null)
                  ? () async {
                      await _addNew();
                    }
                  : null,
            ),
            divider(horizontal: true),
            PrimaryButton(
                labelKey: "Add Generic",
                onPressed: () async {
                  await _addNewField();
                }),
            divider(horizontal: true),
          ],
        ),
        if (cards.isEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (loading) const BusyIndicator(),
              if (!loading)
                Text(
                  'No filter found',
                  style: theme.getStyle(),
                ),
            ],
          ),
        if (cards.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: cards,
            ),
          ),
      ],
    );
  }

  Future _load() async {
    await _loadFieldFilters();
    await _loadDataFilters();
  }

  Future _loadDataFilters() async {
    if (loading) return;
    loading = true;

    _dataFilters.clear();
    await execute(() async {
      var res = await TwinnedSession.instance.twin.searchDataFilters(
          apikey: TwinnedSession.instance.authToken,
          modelId: _selectedDeviceModel?.id,
          body: const twinned.SearchReq(search: '*', page: 0, size: 10000));
      if (validateResponse(res)) {
        _dataFilters.addAll(res.body!.values!);
        for (var g in _dataFilters) {
          _editable[g.id] = await canEdit(clientIds: g.clientIds);
        }
      }
    });

    loading = false;
    refresh();
  }

  Future _loadFieldFilters() async {
    if (loading) return;
    loading = true;

    _fieldFilters.clear();
    await execute(() async {
      var res = await TwinnedSession.instance.twin.searchFieldFilters(
          apikey: TwinnedSession.instance.authToken,
          body: const twinned.SearchReq(search: '*', page: 0, size: 10000));
      if (validateResponse(res)) {
        _fieldFilters.addAll(res.body!.values!);
        for (var g in _fieldFilters) {
          _editable[g.id] = await canEdit(clientIds: g.clientIds);
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
      await _getBasicInfo(context, 'New Asset Filter',
          onPressed: (String name, String? description, String? tags) async {
        var res = await TwinnedSession.instance.twin.createDataFilter(
            apikey: TwinnedSession.instance.authToken,
            body: twinned.DataFilterInfo(
              modelId: _selectedDeviceModel!.id,
              name: name,
              label: name,
              target: widget.target,
              description: description,
              tags: (tags ?? '').split(' '),
              matchGroups: [],
              clientIds: await getClientIds(),
            ));
        if (validateResponse(res)) {
          await _load();
          alert(
            'DataFilter - ${res.body!.entity!.name} ',
            'Created successfully!',
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

  Future<void> _addNewField() async {
    await alertDialog(
        titleStyle: theme
            .getStyle()
            .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        title: 'New Generic Filter',
        body: const FieldFilterSnippet());
    _loadFieldFilters();
  }

  Future _delete(tapi.DataFilter e) async {
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
            int index =
                _dataFilters.indexWhere((element) => element.id == e.id);
            var res = await TwinnedSession.instance.twin.deleteDataFilter(
                apikey: TwinnedSession.instance.authToken, dataFilterId: e.id);
            if (validateResponse(res)) {
              await _load();
              _dataFilters.removeAt(index);

              alert(
                "DataFilter - ${e.name}",
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

  Future _deleteField(tapi.FieldFilter e) async {
    if (loading) return;
    loading = true;
    await confirm(
        title: 'Warning',
        message:
            'Deleting is unrecoverable\nIt may also delete all the related models  and components\n\nDo you want to proceed?',
        titleStyle: theme.getStyle().copyWith(color: Colors.red),
        messageStyle: theme.getStyle(),
        onPressed: () async {
          await execute(() async {
            int index =
                _fieldFilters.indexWhere((element) => element.id == e.id);
            var res = await TwinnedSession.instance.twin.deleteFieldFilter(
                apikey: TwinnedSession.instance.authToken, fieldFilterId: e.id);
            if (validateResponse(res)) {
              await _load();
              _fieldFilters.removeAt(index);

              alert(
                "Field Filter - ${e.name}",
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

  Future _editGroup(twinned.DataFilter filter) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetFilterContent(
          filter: filter,
        ),
      ),
    );
    await _load();
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
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        nameText = value;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: 'Name',
                        labelStyle: theme.getStyle(),
                        hintStyle: theme.getStyle()),
                  ),
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        descText = value;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: 'Description',
                        labelStyle: theme.getStyle(),
                        hintStyle: theme.getStyle()),
                  ),
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        tagsText = value;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: 'Tags (space separated)',
                        labelStyle: theme.getStyle(),
                        hintStyle: theme.getStyle()),
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
              )
            ],
          );
        });
  }

  Future _upload(twinned.DataFilter filter) async {
    if (loading) return;
    loading = true;
    await execute(() async {
      var res = await TwinImageHelper.uploadDomainIcon();
      if (null != res && null != res.entity) {
        var rRes = await TwinnedSession.instance.twin.updateDataFilter(
            apikey: TwinnedSession.instance.authToken,
            dataFilterId: filter.id,
            body: twinned.DataFilterInfo(
              modelId: filter.modelId,
              name: filter.name,
              label: filter.label,
              target: widget.target,
              matchGroups: filter.matchGroups,
              icon: res.entity!.id,
              tags: filter.tags,
              description: filter.description,
              clientIds: await getClientIds(),
            ));

        if (validateResponse(rRes)) {
          await _loadDataFilters();
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

  Future _uploadField(twinned.FieldFilter filter) async {
    if (loading) return;
    loading = true;
    await execute(() async {
      var res = await TwinImageHelper.uploadDomainIcon();
      if (null != res && null != res.entity) {
        var rRes = await TwinnedSession.instance.twin.updateFieldFilter(
            apikey: TwinnedSession.instance.authToken,
            fieldFilterId: filter.id,
            body: twinned.FieldFilterInfo(
              name: filter.name,
              description: filter.description,
              target: twinned.FieldFilterInfoTarget.values
                  .byName(filter.target.name),
              tags: filter.tags,
              icon: res.entity!.id,
              fieldType: twinned.FieldFilterInfoFieldType.values
                  .byName(filter.fieldType.name),
              field: filter.field,
              condition: twinned.FieldFilterInfoCondition.values
                  .byName(filter.condition.name),
              values: filter.values,
              rightValue: filter.rightValue,
              leftValue: filter.leftValue,
              $value: filter.$value,
              clientIds: await getClientIds(),
            ));

        if (validateResponse(rRes)) {
          await _loadFieldFilters();
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
    await _load();
  }
}

class AssetFilterContent extends StatefulWidget {
  final twinned.DataFilter filter;
  const AssetFilterContent({super.key, required this.filter});

  @override
  State<AssetFilterContent> createState() => _AssetFilterContentState();
}

class _AssetFilterContentState extends BaseState<AssetFilterContent> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _tags = TextEditingController();

  @override
  void initState() {
    _name.text = widget.filter.name;
    _desc.text = widget.filter.description ?? '';
    _tags.text = widget.filter.tags?.join(' ') ?? '';
    super.initState();
  }

  void _addNew() {
    setState(() {
      widget.filter.matchGroups.add(const twinned.FilterMatchGroup(
          matchType: twinned.FilterMatchGroupMatchType.any, conditionIds: []));
    });
  }

  bool _validate() {
    if (widget.filter.matchGroups.isEmpty) {
      alert(
        'Invalid',
        'You should have at least one filter group',
        titleStyle: theme
            .getStyle()
            .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        contentStyle: theme.getStyle(),
      );
      return false;
    }
    for (int i = 0; i < widget.filter.matchGroups.length; i++) {
      if (widget.filter.matchGroups[i].conditionIds?.isEmpty ?? true) {
        alert(
          'Invalid',
          'You should have at least condition in filter group ${i + 1}',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
        return false;
      }
    }
    return true;
  }

  Future _save() async {
    if (!_validate()) {
      return;
    }
    await execute(() async {
      var res = await TwinnedSession.instance.twin.updateDataFilter(
          apikey: TwinnedSession.instance.authToken,
          dataFilterId: widget.filter.id,
          body: twinned.DataFilterInfo(
            modelId: widget.filter.modelId,
            name: _name.text,
            label: _name.text,
            target: twinned.DataFilterInfoTarget.values
                .byName(widget.filter.target.name),
            matchGroups: widget.filter.matchGroups,
            icon: widget.filter.icon,
            tags: _tags.text.split(' '),
            description: _desc.text,
            clientIds: await getClientIds(),
          ));
      if (validateResponse(res)) {
        await alert(
          'Data Filter - ${widget.filter.name}',
          'Saved successfully!',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
        _close();
      }
    });
  }

  void _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: 'Asset Filter - ${widget.filter.name}',
            style: theme.getStyle().copyWith(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          divider(),
          Row(
            children: [
              divider(horizontal: true),
              Expanded(
                flex: 1,
                child: LabelTextField(
                  label: 'Asset Filter Name',
                  controller: _name,
                  style: theme.getStyle(),
                  labelTextStyle: theme.getStyle(),
                ),
              ),
              divider(horizontal: true),
              Expanded(
                flex: 2,
                child: LabelTextField(
                  label: 'Description',
                  controller: _desc,
                  style: theme.getStyle(),
                  labelTextStyle: theme.getStyle(),
                ),
              ),
              divider(horizontal: true),
              Expanded(
                flex: 2,
                child: LabelTextField(
                  label: 'Tags',
                  controller: _tags,
                  style: theme.getStyle(),
                  labelTextStyle: theme.getStyle(),
                ),
              ),
              divider(horizontal: true),
            ],
          ),
          divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const BusyIndicator(),
              divider(horizontal: true),
              SecondaryButton(
                labelKey: "Cancel",
                onPressed: () {
                  _close();
                },
              ),
              divider(horizontal: true),
              PrimaryButton(
                leading: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                labelKey: "Save",
                onPressed: () async {
                  await _save();
                },
              ),
              divider(horizontal: true),
              PrimaryButton(
                labelKey: "Add New",
                onPressed: () {
                  _addNew();
                },
                leading: const Icon(
                  Icons.add_box,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _buildGroups(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroups(BuildContext context) {
    List<Widget> children = [];

    for (int i = 0; i < widget.filter.matchGroups.length; i++) {
      children.add(_MatchGroupFilterWidget(
          parent: this, filter: widget.filter, index: i));
      children.add(divider());
    }

    return children;
  }

  @override
  void setup() {}
}

class _MatchGroupFilterWidget extends StatefulWidget {
  final _AssetFilterContentState parent;
  final twinned.DataFilter filter;
  final int index;
  _MatchGroupFilterWidget({
    required this.parent,
    required this.filter,
    required this.index,
  });

  @override
  State<_MatchGroupFilterWidget> createState() =>
      _MatchGroupFilterWidgetState();
}

class _MatchGroupFilterWidgetState extends BaseState<_MatchGroupFilterWidget> {
  List<DropdownMenuEntry<twinned.Condition>> _conditions = [];
  twinned.Condition? selectedCondition;
  Map<String, Widget> _selected = {};

  void _addCondition() {
    setState(() {
      String id = selectedCondition!.id;
      List<String> ids = [];
      ids.addAll(widget.filter.matchGroups[widget.index].conditionIds!);
      ids.add(id);
      widget.filter.matchGroups[widget.index] =
          widget.filter.matchGroups[widget.index].copyWith(conditionIds: ids);
      _selected[id] = Chip(
        label: Text(
          selectedCondition!.name,
          style: theme.getStyle(),
        ),
        onDeleted: () {
          setState(() {
            _selected.remove(id);
            widget.filter.matchGroups[widget.index].conditionIds!.remove(id);
          });
        },
      );
    });
  }

  Future _removeGroup() async {
    await confirm(
        title: 'Confirm',
        message:
            'Deleting is non recoverable, are you sure you want to proceed?',
        titleStyle: theme.getStyle().copyWith(
            color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
        messageStyle: theme.getStyle(),
        onPressed: () async {
          widget.parent.setState(() {
            widget.filter.matchGroups.removeAt(widget.index);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> selected = [];
    selected.addAll(_selected.values);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('IF',
            style: theme.getStyle().copyWith(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
        divider(horizontal: true),
        SizedBox(
          width: 400,
          height: 200,
          child: Stack(
            children: [
              Card(
                elevation: 10,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            divider(),
                            if (_conditions.isNotEmpty)
                              DropdownMenu<twinned.Condition>(
                                initialSelection: selectedCondition,
                                dropdownMenuEntries: _conditions,
                                enableSearch: true,
                                onSelected: (condition) {
                                  setState(() {
                                    selectedCondition = condition;
                                  });
                                },
                              ),
                            if (_conditions.isEmpty)
                              Text('No condition found',
                                  style: theme.getStyle()),
                            divider(horizontal: true),
                            if (_conditions.isNotEmpty &&
                                null != selectedCondition &&
                                !widget.filter.matchGroups[widget.index]
                                    .conditionIds!
                                    .contains(selectedCondition!.id))
                              IconButton(
                                  onPressed: () {
                                    _addCondition();
                                  },
                                  icon: const Icon(Icons.add_box)),
                          ],
                        ),
                      ),
                      divider(),
                      Wrap(
                        spacing: 8,
                        clipBehavior: Clip.hardEdge,
                        children: selected,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () async {
                      await _removeGroup();
                    },
                    icon: Icon(Icons.delete, color: theme.getPrimaryColor()),
                  )),
            ],
          ),
        ),
        divider(horizontal: true),
        if (widget.filter.matchGroups[widget.index].conditionIds?.isNotEmpty ??
            false)
          Text('MATCHES',
              style: theme.getStyle().copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),
        divider(horizontal: true),
        if (widget.filter.matchGroups[widget.index].conditionIds?.isNotEmpty ??
            false)
          DropdownMenu<twinned.FilterMatchGroupMatchType>(
            initialSelection: widget.filter.matchGroups[widget.index].matchType,
            enableSearch: true,
            dropdownMenuEntries: const [
              DropdownMenuEntry<twinned.FilterMatchGroupMatchType>(
                  value: twinned.FilterMatchGroupMatchType.any, label: 'ANY'),
              DropdownMenuEntry<twinned.FilterMatchGroupMatchType>(
                  value: twinned.FilterMatchGroupMatchType.all, label: 'ALL'),
            ],
            onSelected: (group) {
              setState(() {
                widget.filter.matchGroups[widget.index] = widget
                    .filter.matchGroups[widget.index]
                    .copyWith(matchType: group);
              });
            },
          ),
      ],
    );
  }

  @override
  void setup() async {
    await execute(() async {
      var res = await TwinnedSession.instance.twin.searchConditions(
          apikey: TwinnedSession.instance.authToken,
          modelId: widget.filter.modelId,
          body: const twinned.SearchReq(search: '*', page: 0, size: 10000));
      if (validateResponse(res)) {
        List<DropdownMenuEntry<twinned.Condition>> conditions = [];
        for (var condition in res.body!.values!) {
          conditions.add(DropdownMenuEntry<twinned.Condition>(
              value: condition, label: condition.name));
          if (widget.filter.matchGroups[widget.index].conditionIds!
              .contains(condition.id)) {
            _selected[condition.id] = Chip(
              label: Text(
                condition.name,
                style: theme.getStyle(),
              ),
              onDeleted: () {
                setState(() {
                  _selected.remove(condition.id);
                  widget.filter.matchGroups[widget.index].conditionIds!
                      .remove(condition.id);
                });
              },
            );
          }
        }
        if (conditions.isNotEmpty) {
          selectedCondition = conditions.first.value;
        }
        setState(() {
          _conditions.clear();
          _conditions.addAll(conditions);
        });
      }
    });
  }
}
