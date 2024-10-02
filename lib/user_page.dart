import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  MapboxMapController? mapController;
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLocation();
  }

  // Request necessary permissions and get the current location
  Future<void> _requestPermissionsAndLocation() async {
    if (await _handlePermissions()) {
      _getCurrentLocation();
    } else {
      // Handle the case where permissions are denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission denied')),
      );
    }
  }

  // Handle permission requests
  Future<bool> _handlePermissions() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Get the current device location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    // Animate to the current location on the map
    if (mapController != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLng(currentLocation!),
      );
    }
  }

  // Initialize the Mapbox controller
  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    if (currentLocation != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLng(currentLocation!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Welcome, NISHIL!',
          style: TextStyle(color: Colors.black),
        ),
        leading: Icon(Icons.menu, color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      MapboxMap(
                        accessToken: 'pk.eyJ1IjoibmtwYXRlbDEyIiwiYSI6ImNsemY0dGR1cDB4aHEya3M4dGEwNXlqdGUifQ.zEcnlCb6Ur4QHRHmUZtOuQ',
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: currentLocation!,
                          zoom: 14.0,
                        ),
                        myLocationEnabled: true,
                        myLocationTrackingMode: MyLocationTrackingMode.Tracking,
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your current location',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.purple),
                                  SizedBox(width: 5),
                                  FutureBuilder<String>(
                                    future: _getAddressFromLatLng(
                                      currentLocation!.latitude,
                                      currentLocation!.longitude,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text('Loading...');
                                      } else if (snapshot.hasError) {
                                        return Text('Error getting location');
                                      } else {
                                        return Text(snapshot.data ??
                                            'Bouddha, Kathmandu');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Where do you wanna go?',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ListTile(
                        leading: Icon(Icons.star_border, color: Colors.black),
                        title: Text('Choose a saved place'),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                      ListTile(
                        leading: Icon(Icons.map, color: Colors.black),
                        title: Text('Set destination on map'),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New on the town',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'on the market, beat the Market',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }

  // Method to get an address from coordinates (optional)
  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    // You can use Geocoding API or any reverse geocoding service here
    return 'Bouddha, Kathmandu'; // Replace with actual reverse geocoding logic
  }
}
