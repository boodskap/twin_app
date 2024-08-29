import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:twin_app/core/session_variables.dart';

class CustomSettingsDropdown extends StatefulWidget {
  final void Function(MenuDataItem)? onChanged;

  const CustomSettingsDropdown({Key? key, this.onChanged}) : super(key: key);

  @override
  State<CustomSettingsDropdown> createState() => _CustomSettingsDropdownState();
}

class _CustomSettingsDropdownState extends State<CustomSettingsDropdown> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            customButton: const Icon(
              Icons.settings_suggest,
              color: Colors.black,
            ),
            items: MenuDataItems.customItems
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final addBorder = index == MenuDataItems.customItems.indexOf(MenuDataItems.purge);
                  return DropdownMenuItem<MenuDataItem>(
                    value: item,
                    child: Container(
                      decoration: addBorder
                          ? const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.black,width:1.5),
                              ),
                            )
                          : null,
                      child: Padding(
                        padding: addBorder? EdgeInsets.only(top:7) : EdgeInsets.zero,
                        child: MenuDataItems.buildItem(item),
                      ),
                    ),
                  );
                })
                .toList(),
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value as MenuDataItem);
              }
            },
            dropdownStyleData: DropdownStyleData(
              width: 170,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              offset: const Offset(0, 8),
            ),
            menuItemStyleData: MenuItemStyleData(
              customHeights: [
                ...List<double>.filled(MenuDataItems.customItems.length, 48),
              ],
              padding: const EdgeInsets.only(left: 16, right: 16),
            ),
          ),
        ),
      ),
    );
  }
}


class MenuDataItem {
  const MenuDataItem({
    required this.text,
  });

  final String text;
}

class MenuDataItems {
  static const elasticEmail = MenuDataItem(text: 'Elastic Email config');
  static const twillio = MenuDataItem(text: 'Twillio Config');
  static const textLocal = MenuDataItem(text: 'Text Local Config');
  static const geoAPI = MenuDataItem(text: 'Geo API Config');
  static const purge = MenuDataItem(text: 'Purge All Data');
  static const wipe = MenuDataItem(text: 'Wipe All Data');

  static const List<MenuDataItem> customItems = [
    elasticEmail,
    twillio,
    textLocal,
    geoAPI,
    purge,
    wipe
  ];

  static Widget buildItem(MenuDataItem item,) {
    Color backgroundColor = Colors.white;
    if (item == purge) {
      backgroundColor = Colors.orange;
    } else if (item == wipe) {
      backgroundColor = const Color(0XFFfd4f5c);
    } else if (item == elasticEmail) {
      backgroundColor = Colors.blue;
    } else if (item == twillio) {
      backgroundColor = const Color(0XFF2f6555);
    } else if (item == textLocal) {
      backgroundColor = Colors.grey;
    } else {
      backgroundColor =  const Color(0XFFf2c2c8);
    }


    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Text(item.text,
              style: theme.getStyle()
                  .copyWith(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  static String getItemType(MenuDataItem item) {
    if (item == purge) {
      return 'purge';
    } else if (item == wipe) {
      return 'wipe';
    } else if (item == elasticEmail) {
      return 'elasticEmail';
    } else if (item == twillio) {
      return 'twillio';
    } else if (item == textLocal) {
      return 'textLocal';
    } else if (item == geoAPI) {
      return 'geoAPI';
    } else {
      return 'Unknown';
    }
  }
}
