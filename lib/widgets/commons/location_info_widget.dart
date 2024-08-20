import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/widgets/default_deviceview.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;

class LocationInfoWidget extends StatefulWidget {
  final tapi.DeviceData deviceData;
  final OnClientTapped onClientTapped;
  final OnPremiseTapped onPremiseTapped;
  final OnFacilityTapped onFacilityTapped;
  final OnFloorTapped onFloorTapped;

  const LocationInfoWidget({
    super.key,
    required this.deviceData,
    required this.onClientTapped,
    required this.onPremiseTapped,
    required this.onFacilityTapped,
    required this.onFloorTapped,
  });

  @override
  State<LocationInfoWidget> createState() => _LocationInfoWidgetState();
}

class _LocationInfoWidgetState extends State<LocationInfoWidget> {
  @override
  Widget build(BuildContext context) {
    final tapi.DeviceData dd = widget.deviceData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dd.clientIds?.isNotEmpty ?? false)
              Tooltip(
                message: 'Client',
                child: InkWell(
                  onTap: () {
                    widget.onClientTapped(dd.clientIds!.first, dd);
                  },
                  child: Text(
                    dd.$client!,
                    style: theme.getStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.getPrimaryColor()),
                  ),
                ),
              ),
            if (dd.premiseId?.isNotEmpty ?? false) const SizedBox(height: 8),
            if (dd.premiseId?.isNotEmpty ?? false)
              Tooltip(
                message: 'Premise',
                child: InkWell(
                  onTap: () {
                    widget.onPremiseTapped(dd.premiseId!, dd);
                  },
                  child: Text(
                    dd.premise!,
                    style: theme.getStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.getPrimaryColor()),
                  ),
                ),
              ),
            if (dd.facilityId?.isNotEmpty ?? false) const SizedBox(height: 8),
            if (dd.facilityId?.isNotEmpty ?? false)
              Tooltip(
                message: 'Facility',
                child: InkWell(
                  onTap: () {
                    widget.onFacilityTapped(dd.facilityId!, dd);
                  },
                  child: Text(
                    dd.facility!,
                    style: theme.getStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: theme.getPrimaryColor()),
                  ),
                ),
              ),
            if (dd.floorId?.isNotEmpty ?? false) const SizedBox(height: 8),
            if (dd.floorId?.isNotEmpty ?? false)
              Tooltip(
                message: 'Floor',
                child: InkWell(
                  onTap: () {
                    widget.onFloorTapped(dd.floorId!, dd);
                  },
                  child: Text(
                    dd.floor!,
                    style: theme.getStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: theme.getPrimaryColor()),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
