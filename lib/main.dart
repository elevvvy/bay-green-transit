import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BayGreenTransit(),
    );
  }
}

class BayGreenTransit extends StatefulWidget {
  const BayGreenTransit({super.key});

  @override
  State<BayGreenTransit> createState() => _BayGreenTransitState();
}

class _BayGreenTransitState extends State<BayGreenTransit> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(37.7749, -122.4194);
  LatLng _currentPosition = const LatLng(37.7749, -122.4194);
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
  // Ask for both foreground and background
    var status = await Permission.locationWhenInUse.status;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      final alwaysStatus = await Permission.locationAlways.request();
      if (alwaysStatus.isGranted) {
        setState(() => _isPermissionGranted = true);
        _getCurrentLocation();
      }
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission permanently denied. '
              'Enable it in Settings > Privacy > Location Services.'),
        ),
      );
    }
  }


  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 15),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bay Green Transit')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _center, zoom: 13),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isPermissionGranted) {
            _getCurrentLocation();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission not granted. Enable it in Settings.'),
              ),
            );
          }
        },
  child: const Icon(Icons.my_location),
),
    );
  }
}
