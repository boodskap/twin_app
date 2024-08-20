import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/default_deviceview.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;
import 'package:timeago/timeago.dart' as timeago;

class AssetInfoWidget extends StatefulWidget {
  final tapi.DeviceData deviceData;
  final OnAssetTapped onAssetTapped;
  final OnDeviceTapped onDeviceTapped;
  final OnClientTapped onClientTapped;
  final OnPremiseTapped onPremiseTapped;
  final OnFacilityTapped onFacilityTapped;
  final OnFloorTapped onFloorTapped;

  const AssetInfoWidget({
    super.key,
    required this.deviceData,
    required this.onAssetTapped,
    required this.onDeviceTapped,
    required this.onClientTapped,
    required this.onPremiseTapped,
    required this.onFacilityTapped,
    required this.onFloorTapped,
  });

  @override
  State<AssetInfoWidget> createState() => _AssetInfoWidgetState();
}

class _AssetInfoWidgetState extends State<AssetInfoWidget> {
  @override
  Widget build(BuildContext context) {
    final tapi.DeviceData dd = widget.deviceData;
    var dT = DateTime.fromMillisecondsSinceEpoch(dd.updatedStamp);
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dd.assetId?.isNotEmpty ?? false)
              Tooltip(
                message: 'Asset',
                child: InkWell(
                  onTap: () {
                    widget.onAssetTapped(dd.assetId!, dd);
                  },
                  child: Text(
                    dd.asset!,
                    style: theme.getStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: theme.getPrimaryColor()),
                  ),
                ),
              ),
            if (dd.asset?.isEmpty ?? true)
              Tooltip(
                message: 'Device',
                child: InkWell(
                  onTap: () {
                    widget.onDeviceTapped(dd.deviceId, dd);
                  },
                  child: Text(
                    dd.deviceName ?? dd.hardwareDeviceId,
                    style: theme.getStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: theme.getPrimaryColor()),
                  ),
                ),
              ),
            const SizedBox(
              height: 8,
            ),
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
            Tooltip(
              message: 'Last reported',
              child: Text(
                timeago.format(dT, locale: 'en'),
                style: theme
                    .getStyle()
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Tooltip(
              message: 'Last reported timestamp',
              child: Text(
                dT.toString(),
                style: theme
                    .getStyle()
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
