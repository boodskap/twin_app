import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/osm_location_picker.dart';

class MapAlert extends StatefulWidget {
  final Device device;
  final DeviceModel deviceModel;
  const MapAlert({super.key, required this.device, required this.deviceModel});

  @override
  State<MapAlert> createState() => _MapAlertState();
}

class _MapAlertState extends BaseState<MapAlert> {
  bool includeGeoReverse = false;
  @override
  void setup() {}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titleTextStyle: theme.getStyle(),
      contentTextStyle: theme.getStyle(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Checkbox(
                value: includeGeoReverse,
                onChanged: (value) {
                  setState(() {
                    includeGeoReverse = !includeGeoReverse;
                  });
                },
              ),
              Text(
                ' Geo-Reverse Mapping',
                style: theme.getStyle(),
              ),
            ],
          ),
          SizedBox(
            height: 400,
            width: 600,
            child: OSMLocationPicker(
              onPicked: (pickedData) async {
                try {
                  var res = await TwinnedSession.instance.twin
                      .sendDeviceLocationData(
                          lon: pickedData.longitude,
                          lat: pickedData.latitude,
                          apikey: widget.device.apiKey,
                          hardwareDeviceId: widget.device.deviceId,
                          geocode: includeGeoReverse);

                  if (validateResponse(res)) {}
                } catch (e, s) {
                  debugPrint('$e\n$s');
                }
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
