import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:twin_app/core/session_variables.dart';

class CustomViewDropdown extends StatefulWidget {
  final void Function(MenuItem)? onChanged;

  const CustomViewDropdown({Key? key, this.onChanged}) : super(key: key);

  @override
  State<CustomViewDropdown> createState() => _CustomViewDropdownState();
}

class _CustomViewDropdownState extends State<CustomViewDropdown> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            customButton: const Icon(
              Icons.list,
              size: 32,
              color: Colors.black,
            ),
            items: [
              ...MenuItems.customItems.map(
                (item) => DropdownMenuItem<MenuItem>(
                  value: item,
                  child: MenuItems.buildItem(item),
                ),
              ),
              const DropdownMenuItem<Divider>(enabled: false, child: Text("")),
            ],
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value as MenuItem);
              }
            },
            dropdownStyleData: DropdownStyleData(
              width: 170,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                // color: Colors.white,
              ),
              offset: const Offset(0, 8),
            ),
            menuItemStyleData: MenuItemStyleData(
              customHeights: [
                ...List<double>.filled(MenuItems.customItems.length, 48),
                6,
              ],
              padding: const EdgeInsets.only(left: 16, right: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  const MenuItem({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;
}

abstract class MenuItems {
  static const List<MenuItem> customItems = [rectangle, circle];

  static const rectangle =
      MenuItem(text: 'Fillable Rectangle', icon: Icons.square);
  static const circle = MenuItem(text: 'Fillable Circle', icon: Icons.circle);

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.black, size: 16),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            item.text,
            style: theme.getStyle().copyWith(color: Colors.black, fontSize: 12),
          ),
        ),
      ],
    );
  }

  static String getItemType(MenuItem item) {
    if (item == rectangle) {
      return 'fillableRectangle';
    } else if (item == circle) {
      return 'fillableCircle';
    } else {
      return 'Unknown';
    }
  }
}
