import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Ensure you add the flutter_map package
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart' as latlong;

class TripScreen extends StatefulWidget {
  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final LatLng _pickupLocation = LatLng(22.2558, 70.8050); // RK University
  final LatLng _dropoffLocation = LatLng(22.3072, 70.8022); // Greenland chokdi

  // Initial car location (starting at RK University)
  LatLng _carLocation = LatLng(22.2558, 70.8050);

  // Timer for car movement
  Timer? _timer;
  bool _isTripStarted = false;

  // Speed and distance calculations
  final double _averageSpeed = 50.0; // km/h
  final Distance _distance = Distance();

  // Calculate distance between two LatLng points
  double _calculateDistance(LatLng start, LatLng end) {
    return _distance.as(LengthUnit.Kilometer, start, end);
  }

  // Move the car dynamically from the pickup to the dropoff location
  void _startTrip() {
    if (!_isTripStarted) {
      _isTripStarted = true;
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {
          double totalDistance = _calculateDistance(_carLocation, _dropoffLocation);

          if (totalDistance < 0.1) {
            // Stop the timer once the car reaches the destination
            timer.cancel();
          } else {
            // Move the car towards the dropoff location in small steps
            double step = 0.001;
            LatLng direction = LatLng(
              _dropoffLocation.latitude - _carLocation.latitude,
              _dropoffLocation.longitude - _carLocation.longitude,
            );

            // Calculate the new car location
            _carLocation = LatLng(
              _carLocation.latitude + (direction.latitude * step / totalDistance),
              _carLocation.longitude + (direction.longitude * step / totalDistance),
            );
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ongoing Trip'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: _carLocation, // Center the map on the car location
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    // Marker for the car
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _carLocation,
                      builder: (ctx) => Icon(
                        Icons.directions_car,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                    // Marker for the dropoff location
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _dropoffLocation,
                      builder: (ctx) => Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ram', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Pickup Location: RK University, Tramba', style: TextStyle(fontSize: 16)),
                SizedBox(height: 5),
                Text('Drop-off Location: Greenland chokdi, Rajkot', style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _startTrip(); // Start the trip when button is pressed
                    print('Trip Started');
                  },
                  child: Text('START TRIP'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
