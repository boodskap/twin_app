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

  const GoogleMapMultiWidget({
    super.key,
    required this.geoLocationList, required this.markerNameList,
  });

  @override
  State<GoogleMapMultiWidget> createState() => _GoogleMapMultiWidgetState();
}

class _GoogleMapMultiWidgetState extends State<GoogleMapMultiWidget> {
  GoogleMapController? mapController;
  late LatLng _center;
  Set<Marker> _markers = {};
  double zoomLevel = 5;

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
        infoWindow: InfoWindow(
          anchor: Offset(0, 0),
          title: widget.markerNameList[i],  // Access the corresponding name from markernamelist
          snippet:
            'Latitude: ${location.coordinates[1].toStringAsFixed(4)}, Longitude: ${location.coordinates[0].toStringAsFixed(4)}',
        ),
      ),
    );
  }
  
  zoomLevel = 2.5;
}

  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: zoomLevel,
      ),
      markers: _markers,
    );
  }
}


