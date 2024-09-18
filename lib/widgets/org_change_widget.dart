import 'package:flutter/material.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:twin_app/core/session_variables.dart' as session;

class OrgChangeWidget extends StatefulWidget {
  final ValueChanged<tapi.OrgInfo> onSelected;
  const OrgChangeWidget({super.key, required this.onSelected});

  @override
  State<OrgChangeWidget> createState() => _OrgChangeWidgetState();
}

class _OrgChangeWidgetState extends State<OrgChangeWidget> {
  @override
  Widget build(BuildContext context) {
    return DropdownMenu<tapi.OrgInfo>(
      initialSelection: session.orgs[session.selectedOrg],
      leadingIcon: Icon(
        Icons.bungalow_sharp,
        color: Colors.white,
      ),
      textStyle: session.theme.getStyle().copyWith(color: Colors.white),
      dropdownMenuEntries: session.orgs.map((o) {
        return DropdownMenuEntry(
            value: o,
            label: o.name,
            labelWidget: Text(
              o.name,
              style: session.theme.getStyle(),
            ));
      }).toList(),
      onSelected: (o) async {
        if (null != o) {
          widget.onSelected(o!);
        }
      },
    );
  }
}
