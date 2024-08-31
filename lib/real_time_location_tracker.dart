import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class RealTimeLocationTracker extends StatefulWidget {
  @override
  _RealTimeLocationTrackerState createState() => _RealTimeLocationTrackerState();
}

class _RealTimeLocationTrackerState extends State<RealTimeLocationTracker> {
  GoogleMapController? _googlemapController;
  Position? _currentPosition;
  Set<Marker> _marker = {};
  List<LatLng> _polylinePoints = [];
  Set<Polyline> _polyline = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  Future<void> _getCurrentLocation() async {
    // check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Permission granted
      final bool isEnable = await Geolocator.isLocationServiceEnabled();
      if (isEnable) {
        // get location
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 10,
            timeLimit: Duration(seconds: 10),
          ),
        );
        if (mounted) {
          setState(() {});
        }
        _updateLocation(position);
      } else {
        // ON gps service
        Geolocator.openLocationSettings();
      }

    } else {
      // Permission denied
      if (permission == LocationPermission.deniedForever) {
        Geolocator.openAppSettings();
        return;
      }
      LocationPermission requestPermission =
      await Geolocator.requestPermission();
      if (requestPermission == LocationPermission.always ||
          requestPermission == LocationPermission.whileInUse) {
        _getCurrentLocation();
      }
    }
  }

  void _startLocationUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
          ));
      _updateLocation(position);
    });
  }

  void _updateLocation(Position position) {
    LatLng latLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = position;

      // Update marker
      _marker.clear();
      _marker.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: latLng,
          infoWindow: InfoWindow(
            title: 'My current location',
            snippet: '${position.latitude}, ${position.longitude}',
          ),
        ),
      );

      // Add polyline coordinates
      _polylinePoints.add(latLng);

      // Update polylines
      _polyline.clear();
      _polyline.add(Polyline(
        polylineId: PolylineId('route'),
        visible: true,
        points: _polylinePoints,
        width: 5,
        color: Colors.blue,
      ));

      // Animate camera to the new location
      _googlemapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Location Tracker'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentPosition!.latitude,
              _currentPosition!.longitude),
          zoom: 16,
        ),
        markers: _marker,
        polylines: _polyline,
        onMapCreated: (GoogleMapController controller) {
          _googlemapController = controller;
        },
      ),
    );
  }
}
