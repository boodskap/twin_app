import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnRolesSelected = void Function(List<twin.Role> items);

class MultiRoleDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnRolesSelected onRolesSelected;
  final TextStyle style;

  const MultiRoleDropdown({
    super.key,
    required this.selectedItems,
    required this.onRolesSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<MultiRoleDropdown> createState() => _MultiRoleDropdownState();
}

class _MultiRoleDropdownState extends BaseState<MultiRoleDropdown> {
  final List<twin.Role> _allItems = [];
  final List<twin.Role> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Role>(
      // key: Key(Uuid().v4()),
      allowDuplicates: false,
      hint: 'Select Roles',
      searchHint: 'Search roles',
      selectedItems: _selectedItems,
      onItemsSelected: (selectedItems) {
        setState(() {
          _selectedItems.clear();
          _selectedItems.addAll(selectedItems as List<twin.Role>);
        });
        widget.onRolesSelected(_selectedItems);
      },
      itemSearchFunc: _search,
      itemLabelFunc: (item) {
        return Text(
          item.name,
          style: widget.style,
        );
      },
      itemIdFunc: (item) => item.name,
    );
  }

  Future<List<twin.Role>> _search(String keyword, int page) async {
    return _allItems
        .where(
            (role) => role.name.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  Future<void> _load() async {
    try {
      var eRes = await TwinnedSession.instance.twin.listRoles(
        apikey: TwinnedSession.instance.authToken,
        body: const twin.ListReq(page: 0, size: 10000),
      );
      if (eRes.body?.values != null) {
        setState(() {
          _allItems.addAll(eRes.body!.values!);
          _selectedItems.addAll(
            _allItems.where((role) => widget.selectedItems.contains(role.name)),
          );
        });
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  @override
  void setup() {
    // _load();
  }
}
