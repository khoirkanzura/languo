import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng pusatAbsensi = LatLng(-7.98455, 112.62085);

  LatLng? userPosition;
  double distanceInMeters = 0.0;
  bool isWithinRadius = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userPosition = LatLng(position.latitude, position.longitude);
    });

    _calculateDistance();
  }

  void _calculateDistance() {
    if (userPosition == null) return;

    distanceInMeters = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      pusatAbsensi.latitude,
      pusatAbsensi.longitude,
    );

    isWithinRadius = distanceInMeters <= 100;
    setState(() {});

    // KIRIM RESULT OTOMATIS
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context, isWithinRadius);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lokasi Anda",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // ← memastikan judul di tengah
        backgroundColor: const Color(0xFF36546C),
        iconTheme: const IconThemeData(
          color: Colors.white, // ← panah back putih
        ),
      ),
      body: userPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: userPosition!,
                    zoom: 17,
                  ),
                  myLocationEnabled: true,
                  markers: {
                    Marker(
                      markerId: const MarkerId("pusat_absensi"),
                      position: pusatAbsensi,
                      infoWindow: const InfoWindow(title: "Pusat Absensi"),
                    ),
                    Marker(
                      markerId: const MarkerId("user"),
                      position: userPosition!,
                      infoWindow: const InfoWindow(title: "Lokasi Anda"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure,
                      ),
                    ),
                  },
                  circles: {
                    Circle(
                      circleId: const CircleId("radius_absensi"),
                      center: pusatAbsensi,
                      radius: 100,
                      strokeWidth: 2,
                      strokeColor: Colors.blue,
                      fillColor: Colors.blue.withOpacity(0.1),
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isWithinRadius
                                ? "Lokasi valid — dalam radius 100 meter"
                                : "Lokasi tidak valid — di luar radius",
                            style: TextStyle(
                                color:
                                    isWithinRadius ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
