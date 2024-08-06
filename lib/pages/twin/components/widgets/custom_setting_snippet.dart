import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;

typedef OnSave = void Function(
    {required List<twin.ScrappingTableConfig> scrappingTableConfigs});

class CustomSettingsSnippet extends StatefulWidget {
  final List<twin.ScrappingTableConfig> scrappingTableConfigs;
  final OnSave onSave;
  const CustomSettingsSnippet(
      {super.key, required this.scrappingTableConfigs, required this.onSave});

  @override
  State<CustomSettingsSnippet> createState() => _CustomSettingsSnipperState();
}

class _CustomSettingsSnipperState extends BaseState<CustomSettingsSnippet> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _label = TextEditingController();
  final List<twin.ScrappingTable> _scrappingTables = [];
  final List<twin.ScrappingTable> _selectedScrappingTables = [];
  bool canAdd = false;
  String? selectedName;

  @override
  void initState() {
    _name.addListener(_changeListener);
    _label.addListener(_changeListener);
    super.initState();
  }

  void _changeListener() {
    final String name = _name.text.trim();
    final String label = _label.text.trim();
    bool enable = name.isNotEmpty && label.isNotEmpty;
    if (enable) {
      for (var cs in widget.scrappingTableConfigs) {
        if (cs.lookupName == name) {
          enable = false;
          break;
        }
      }
    }
    setState(() {
      canAdd = enable;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: LabelTextField(
                label: 'Lookup Name',
                controller: _name,
                style: theme.getStyle(),
                labelTextStyle: theme.getStyle(),
              ),
            ),
            divider(horizontal: true),
            Expanded(
              child: LabelTextField(
                label: 'Scrapping Table Name',
                controller: _label,
                style: theme.getStyle(),
                labelTextStyle: theme.getStyle(),
              ),
            ),
            divider(horizontal: true),
            IconButton(
                onPressed: !canAdd
                    ? null
                    : () {
                        setState(() {
                          widget.scrappingTableConfigs.add(
                              twin.ScrappingTableConfig(
                                  lookupName: _name.text,
                                  scrappingTableName: _label.text,
                                  scrappingTableIds: []));
                          _name.text = '';
                          _label.text = '';
                        });
                      },
                icon: const Icon(Icons.add)),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.scrappingTableConfigs.map((e) {
            return Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: InkWell(
                onTap: () {
                  _setSelected(e.lookupName);
                },
                child: Chip(
                  backgroundColor:
                      selectedName == e.lookupName ? Colors.blue : null,
                  label: Text(
                    '${e.scrappingTableName} (${e.lookupName})',
                    style:
                        theme.getStyle().copyWith(fontWeight: FontWeight.bold),
                  ),
                  onDeleted: () {
                    setState(() {
                      widget.scrappingTableConfigs.remove(e);
                      _setSelected(null);
                    });
                  },
                ),
              ),
            );
          }).toList(),
        ),
        divider(),
        if (null != selectedName && _scrappingTables.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Allowed  Tables',
              style: theme
                  .getStyle()
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        divider(),
        Expanded(
          child: ListView.builder(
              itemCount: (null == selectedName || _scrappingTables.isEmpty)
                  ? 0
                  : _scrappingTables.length,
              itemBuilder: (ctx, idx) {
                return CheckboxListTile(
                  title: Text(
                    _scrappingTables[idx].name,
                    style: theme
                        .getStyle()
                        .copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  value:
                      _selectedScrappingTables.contains(_scrappingTables[idx]),
                  onChanged: (selected) {
                    _setSetting(selected ?? false, _scrappingTables[idx]);
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                );
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SecondaryButton(
              labelKey: "Cancel",
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            divider(horizontal: true),
            PrimaryButton(
              labelKey: "Save",
              leading: Icon(
                Icons.save,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.onSave(
                    scrappingTableConfigs: widget.scrappingTableConfigs);
              },
            ),
          ],
        )
      ],
    );
  }

  void _setSelected(String? name) {
    selectedName = name;
    _selectedScrappingTables.clear();
    if (null != name) {
      for (var cs in widget.scrappingTableConfigs) {
        if (cs.lookupName == name) {
          for (var s in _scrappingTables) {
            if (cs.scrappingTableIds.contains(s.id)) {
              _selectedScrappingTables.add(s);
            }
          }
          break;
        }
      }
    }
    refresh();
  }

  void _setSetting(bool add, twin.ScrappingTable setting) {
    for (var cs in widget.scrappingTableConfigs) {
      if (cs.lookupName == selectedName) {
        if (add) {
          cs.scrappingTableIds.add(setting.id);
        } else {
          cs.scrappingTableIds.remove(setting.id);
        }
        break;
      }
    }
    refresh(sync: () {
      if (add) {
        _selectedScrappingTables.add(setting);
      } else {
        _selectedScrappingTables.remove(setting);
      }
    });
  }

  void _load() async {
    if (loading) return;
    loading = true;
    _scrappingTables.clear();

    execute(() async {
      var sRes = await TwinnedSession.instance.twin.listScrappingTables(
          apikey: TwinnedSession.instance.authToken,
          body: const twin.ListReq(page: 0, size: 10000));

      if (validateResponse(sRes)) {
        refresh(sync: () {
          _scrappingTables.addAll(sRes.body!.values!);
        });
      }
    });

    loading = false;
  }

  @override
  void setup() {
    _load();
  }
}
