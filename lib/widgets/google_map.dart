import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;

class GoogleMapWidget extends StatefulWidget {
  final double longitude;
  final double latitude;
  final void Function(LatLng)? saveLocation;
  final bool viewMode;

  const GoogleMapWidget({
    super.key,
    required this.longitude,
    required this.latitude,
    this.saveLocation,
    required this.viewMode,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? mapController;
  late LatLng _center;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.latitude, widget.longitude);
    _markers.add(
      Marker(
        markerId: const MarkerId('center_marker'),
        position: _center,
      ),
    );
  }

  @override
  void didUpdateWidget(GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _center = LatLng(widget.latitude, widget.longitude);
      _updateMarkers(_center);
      _moveCamera(_center);
    }
  }

  void _updateMarkers(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('center_marker'),
          position: position,
        ),
      );
    });
  }

  void _moveCamera(LatLng position) {
    mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapToolbarEnabled: widget.viewMode ? true : false,
      zoomControlsEnabled: widget.viewMode ? true : false,
      zoomGesturesEnabled: widget.viewMode ? true : false,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        _moveCamera(_center);
      },
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 5.0,
      ),
      markers: _markers,
      onTap: (LatLng tappedPosition) {
        if (widget.viewMode) {
          _updateMarkers(tappedPosition);
          widget.saveLocation?.call(tappedPosition);
        }
      },
    );
  }
}



class GoogleMapMultiWidget extends StatefulWidget {
  final List<tapi.GeoLocation> geoLocationList;
  final List<String> markerNameList;
  final List<String> hardwareDeviceIdList;
  final List<String> reportedTimeList;
  final List<String> levelList;
  final bool isTwin;

  const GoogleMapMultiWidget({
    super.key,
    required this.geoLocationList,
    required this.markerNameList,
    required this.hardwareDeviceIdList,
    required this.reportedTimeList,
    required this.levelList,
    required this.isTwin,
  });

  @override
  State<GoogleMapMultiWidget> createState() => _GoogleMapMultiWidgetState();
}

class _GoogleMapMultiWidgetState extends State<GoogleMapMultiWidget> {
  GoogleMapController? mapController;
  late LatLng _center;
  Set<Marker> _markers = {};
  double zoomLevel = 5;
  Offset? customInfoWindowPosition;
  String? selectedMarkerTitle;
  // String? selectedMarkerSnippet;
  String? selectedMarkerHardwareDeviceId;
  String selectedMarkerDataLevel = '-';
  String? selectedMarkerReportedTime;

  @override
  void initState() {
    super.initState();

    _center = LatLng(0, 0);
    bool firstLocationAssigned = false;
    for (int i = 0; i < widget.geoLocationList.length; i++) {
      tapi.GeoLocation location = widget.geoLocationList[i];

      if (location.coordinates.isNotEmpty) {
        if (!firstLocationAssigned) {
          _center = LatLng(
            location.coordinates[1],
            location.coordinates[0],
          );
          firstLocationAssigned = true;
        }

        _markers.add(
          Marker(
            markerId: MarkerId(location.coordinates[0].toString()),
            position: LatLng(location.coordinates[1], location.coordinates[0]),
            onTap: () {
              _showCustomInfoWindow(context, i, location);
            },
          ),
        );
      }
      zoomLevel = 2.5;
    }
  }

  void _showCustomInfoWindow(
      BuildContext context, int index, tapi.GeoLocation location) {
    setState(() {
      selectedMarkerTitle = widget.markerNameList[index];
      selectedMarkerHardwareDeviceId = widget.hardwareDeviceIdList[index];
      if (!widget.isTwin) {
        selectedMarkerDataLevel = widget.levelList[index];
      }
      selectedMarkerReportedTime = widget.reportedTimeList[index];
     

      final screenSize = MediaQuery.of(context).size;
      customInfoWindowPosition = Offset(
        screenSize.width<=650 ? 10 : screenSize.width / 2.3,
        10,
      );
    });
  }

  void _closeCustomInfoWindow() {
    setState(() {
      customInfoWindowPosition = null;
      selectedMarkerTitle = null;
      selectedMarkerHardwareDeviceId = null;
      selectedMarkerDataLevel = "";
      selectedMarkerReportedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: zoomLevel,
          ),
          markers: _markers,
        ),
        if (customInfoWindowPosition != null && selectedMarkerTitle != null)
          CustomInfoWindow(
            title: selectedMarkerTitle!,
            position: customInfoWindowPosition!,
            onClose: _closeCustomInfoWindow,
            hardwareDeviceId: selectedMarkerHardwareDeviceId!,
            level: selectedMarkerDataLevel,
            reportedtime: selectedMarkerReportedTime!,
            isTwinPage: widget.isTwin,
          ),
      ],
    );
  }
}

class CustomInfoWindow extends StatelessWidget {
  final String title;
  final Offset position;
  final String hardwareDeviceId;
  final String level;
  final String reportedtime;
  final VoidCallback onClose;
  final bool isTwinPage;
  const CustomInfoWindow(
      {Key? key,
      required this.title,
      required this.position,
      required this.onClose,
      required this.hardwareDeviceId,
      required this.level,
      required this.reportedtime,
      required this.isTwinPage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 310,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    iconSize: 22.0,
                  ),
                ],
              ),
              SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hardware Device Id",
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    hardwareDeviceId,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (!isTwinPage)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Level",
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      level,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Reported Time",
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    reportedtime,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
