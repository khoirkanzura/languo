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
  // ===============================
  // VARIABLE
  // ===============================
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng pusatAbsensi = LatLng(-7.98455, 112.62085);

  LatLng? userPosition;
  double distanceInMeters = 0.0;
  bool isWithinRadius = false;

  // ===============================
  // INIT
  // ===============================
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  // ===============================
  // CEK IZIN LOKASI
  // ===============================
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

  // ===============================
  // AMBIL LOKASI USER
  // ===============================
  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userPosition = LatLng(position.latitude, position.longitude);
    });

    _calculateDistance();
  }

  // ===============================
  // HITUNG JARAK USER KE PUSAT ABSENSI
  // ===============================
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
  }

  // ===============================
  // BUILD UI MAPS
  // ===============================
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
                // =======================
                // GOOGLE MAP
                // =======================
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: userPosition!,
                    zoom: 17,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: {
                    Marker(
                      markerId: const MarkerId("pusat_absensi"),
                      position: pusatAbsensi,
                      infoWindow: const InfoWindow(title: "Pusat Absensi"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
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

                // =======================
                // PANEL INFO ATAS
                // =======================
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
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isWithinRadius
                                ? "Lokasi Anda berada di dalam radius 100 meter"
                                : "Anda berada di luar radius 100 meter",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isWithinRadius
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // =======================
                // PANEL INFO BAWAH
                // =======================
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Jarak ke pusat absensi:",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${distanceInMeters.toStringAsFixed(1)} meter",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isWithinRadius ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isWithinRadius
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isWithinRadius
                                ? "Anda berada dalam radius, silakan melakukan absensi."
                                : "Anda berada di luar radius 100 meter.\nTidak bisa check-in atau check-out.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isWithinRadius
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
