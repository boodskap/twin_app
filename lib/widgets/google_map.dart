import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;
import 'package:twin_commons/widgets/default_deviceview.dart';
import 'package:uuid/uuid.dart';

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
  final bool isTwin;
  final List<tapi.DeviceData> deviceDataList;
  final OnAssetTapped onAssetTapped;
  final OnDeviceTapped onDeviceTapped;

  const GoogleMapMultiWidget({
    super.key,
    required this.geoLocationList,
    required this.isTwin,
    required this.deviceDataList,
    required this.onAssetTapped,
    required this.onDeviceTapped,
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
  tapi.DeviceData? selectedDeviceData;
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
      selectedDeviceData = widget.deviceDataList[index];
      final screenSize = MediaQuery.of(context).size;
      customInfoWindowPosition = Offset(
        screenSize.width <= 650 ? 10 : screenSize.width / 2.3,
        10,
      );
    });
  }

  void _closeCustomInfoWindow() {
    setState(() {
      customInfoWindowPosition = null;
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
        if (customInfoWindowPosition != null)
          CustomInfoWindow(
              position: customInfoWindowPosition!,
              onClose: _closeCustomInfoWindow,
              isTwinPage: widget.isTwin,
              deviceData: selectedDeviceData!,
              onAssetTapped: widget.onAssetTapped,
              onDeviceTapped: widget.onDeviceTapped),
      ],
    );
  }
}

class CustomInfoWindow extends StatelessWidget {
  final Offset position;
  final VoidCallback onClose;
  final bool isTwinPage;
  final tapi.DeviceData deviceData;
  final OnAssetTapped onAssetTapped;
  final OnDeviceTapped onDeviceTapped;
  const CustomInfoWindow(
      {Key? key,
      required this.position,
      required this.onClose,
      required this.isTwinPage,
      required this.deviceData,
      required this.onAssetTapped,
      required this.onDeviceTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dynamicLevelData = deviceData.data as Map<String, dynamic> ?? {};
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
                    child: InkWell(
                      onTap: () {
                        if (deviceData.asset != "") {
                          onAssetTapped(deviceData.assetId!, deviceData);
                        } else if (deviceData.deviceName != "") {
                          onDeviceTapped(deviceData.deviceId, deviceData);
                        }
                      },
                      child: Text(
                        deviceData.asset != ""
                            ? deviceData.asset.toString()
                            : deviceData.deviceName.toString(),
                        style: theme.getStyle().copyWith(
                            color: theme.getPrimaryColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                    style: theme.getStyle(),
                  ),
                  Text(
                    deviceData.hardwareDeviceId.toString(),
                    style:
                        theme.getStyle().copyWith(fontWeight: FontWeight.bold),
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
                      style: theme.getStyle(),
                    ),
                    Text(
                      dynamicLevelData['level'].toString() + " %",
                      style: theme
                          .getStyle()
                          .copyWith(fontWeight: FontWeight.bold),
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
                    style: theme.getStyle(),
                  ),
                  Text(
                    deviceData.updatedStamp != 0
                        ? DateTime.fromMillisecondsSinceEpoch(
                                deviceData.updatedStamp)
                            .toString()
                        : '-',
                    style:
                        theme.getStyle().copyWith(fontWeight: FontWeight.bold),
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

class LocationPoint {
  final tapi.GeoLocation geoPoint;
  final String type;
  final String name;

  LocationPoint(
      {required this.geoPoint, required this.type, required this.name});
}

// ignore: must_be_immutable
class GoogleMapRoutePlan extends StatefulWidget {
  final LocationPoint startLocation;
  final LocationPoint endLocation;
  List<LocationPoint> deliveryLocations;
  GoogleMapRoutePlan(
      {super.key,
      required this.startLocation,
      required this.endLocation,
      required this.deliveryLocations});

  @override
  State<GoogleMapRoutePlan> createState() => _GoogleMapRoutePlanState();
}

class _GoogleMapRoutePlanState extends State<GoogleMapRoutePlan> {
  GoogleMapController? _mapController;
  List<Marker> _markers = [];
  List<LatLng> _polylineCoordinates = [];
  Polyline _polyline = const Polyline(polylineId: PolylineId('route'));

  @override
  void initState() {
    super.initState();

    _addMarkers();
  }

  void _addMarkers() async {
    final startIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/images/begin-flag.png',
    );
    final flagIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(35, 35)),
      'assets/images/end-flag.png',
    );
    var uuid = Uuid();
    if (widget.startLocation.type != "") {
      String uniqueStartId = uuid.v4();
      _markers.add(
        Marker(
          markerId: MarkerId('marker_$uniqueStartId'),
          position: LatLng(widget.startLocation.geoPoint.coordinates[0], widget.startLocation.geoPoint.coordinates[1]),
          infoWindow: InfoWindow(title: 'Start'),
          icon: startIcon,
        ),
      );

      _polylineCoordinates.add(LatLng(widget.startLocation.geoPoint.coordinates[0], widget.startLocation.geoPoint.coordinates[1]));
    }

    if (widget.endLocation.type != "") {
      String uniqueEndId = uuid.v4();
      _markers.add(
        Marker(
          markerId: MarkerId('marker_$uniqueEndId'),
          position: LatLng(widget.endLocation.geoPoint.coordinates[0], widget.endLocation.geoPoint.coordinates[1]),
          infoWindow: InfoWindow(title: 'End'),
          icon: flagIcon,
        ),
      );

      _polylineCoordinates.add(LatLng(widget.endLocation.geoPoint.coordinates[0], widget.endLocation.geoPoint.coordinates[1]));
    }

    if (widget.deliveryLocations.isNotEmpty) {
      for (int i = 0; i < widget.deliveryLocations.length; i++) {
        String uniqueMidId = uuid.v4();
        LatLng point = LatLng(widget.deliveryLocations[i].geoPoint.coordinates[0], widget.deliveryLocations[i].geoPoint.coordinates[1]);

        BitmapDescriptor markerIcon;

        markerIcon = await createCustomMarkerBitmap(
            i, 'assets/images/marker.png', i + 1);
        _markers.add(
          Marker(
            markerId: MarkerId('marker_$uniqueMidId'),
            position: point,
            infoWindow: InfoWindow(title: widget.deliveryLocations[i].name),
            icon: markerIcon,
          ),
        );

        _polylineCoordinates.add(point);
      }
    }

    _updatePolyline();
    setState(() {});
  }

  void _updatePolyline() {
    _polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: _polylineCoordinates,
      color: Colors.blue.withOpacity(0.6),
      width: 5,
      patterns: [PatternItem.dot, PatternItem.gap(10)],
      jointType: JointType.round,
      endCap: Cap.roundCap,
      startCap: Cap.roundCap,
    );
  }

  Future<BitmapDescriptor> createCustomMarkerBitmap(
      int markerNumber, String imageURL, int indicator) async {
    int markerWidth = 40;
    PictureRecorder recorder = new PictureRecorder();
    Canvas c = Canvas(recorder);

    final data1 = await rootBundle.load(imageURL);
    var markerImage = await decodeImageFromList(data1.buffer.asUint8List());
    c.drawImageRect(
      markerImage,
      Rect.fromLTRB(0.0, 0.0, markerImage.width.toDouble(),
          markerImage.height.toDouble()),
      Rect.fromLTRB(0.0, 0.0, markerWidth.toDouble(), markerWidth.toDouble()),
      Paint(),
    );

    TextSpan span = TextSpan(
      style: TextStyle(
          color: Colors.black,
          fontSize: markerWidth / 3,
          fontWeight: FontWeight.bold),
      text: indicator.toString(),
    );
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        c,
        Offset(markerNumber > 9 ? markerWidth / 3.5 : markerWidth / 2.5,
            markerWidth / 5.5));

    var p = recorder.endRecording();
    ByteData? pngBytes = await (await p.toImage(markerWidth, markerWidth))
        .toByteData(format: ImageByteFormat.png);
    Uint8List data = Uint8List.view(pngBytes!.buffer);
    return BitmapDescriptor.bytes(data);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.startLocation.geoPoint.coordinates[0], widget.startLocation.geoPoint.coordinates[1]),
        zoom: 12,
      ),
      markers: Set<Marker>.of(_markers),
      polylines: Set<Polyline>.of([_polyline]),
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }
}

