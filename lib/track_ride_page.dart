import 'dart:async';
import 'package:cab_way/ratingscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackRidePage extends StatefulWidget {
  @override
  _TrackRidePageState createState() => _TrackRidePageState();
}

class _TrackRidePageState extends State<TrackRidePage> {
  final LatLng _destinationLocation = LatLng(22.3039, 70.8022); // Rajkot, for example
  LatLng _carLocation = LatLng(22.4000, 70.9000); // Example car start location
  final MapController _mapController = MapController();
  List<LatLng> _polylinePoints = []; // Points for the polyline
  Timer? _timer;
  final Distance _distance = Distance();
  final double _averageSpeed = 50.0; // Speed in km/h

  // Calculate distance between two points
  double _calculateDistance(LatLng start, LatLng end) {
    return _distance.as(LengthUnit.Kilometer, start, end);
  }

  // Move car towards the destination
  void _moveCarToDestination() {
    const stepSize = 0.001; // Smaller step for smoother movement
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        double totalDistance = _calculateDistance(_carLocation, _destinationLocation);
        if (totalDistance < 0.05) {
          // Stop when car reaches near the destination
          timer.cancel();
        } else {
          // Move car step by step
          double step = stepSize / totalDistance;
          _carLocation = LatLng(
            _carLocation.latitude + (_destinationLocation.latitude - _carLocation.latitude) * step,
            _carLocation.longitude + (_destinationLocation.longitude - _carLocation.longitude) * step,
          );
          // Add the current car location to polyline points to show the path
          _polylinePoints.add(_carLocation);
        }
      });
    });
  }

  // Start trip: draw polyline and move car to destination
  void _startTrip() {
    _polylinePoints = [_carLocation, _destinationLocation]; // Draw polyline initially
    _moveCarToDestination();
  }

  // Navigate to Rating page after trip ends
  void _navigateToRatingPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RatingScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fullscreen Map as Background
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _carLocation,
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              // Polyline for direction path
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _polylinePoints,
                    color: Colors.blue,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              // Markers for car and destination
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _destinationLocation,
                    builder: (ctx) => Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40.0,
                    ),
                  ),
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
                ],
              ),
            ],
          ),
          // Ride Details Card at the Top
          Positioned(
            top: 40, // Position it below the status bar
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ride Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        'Driver: John Doe',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        'Car: Toyota Camry',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.local_activity, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        'License Plate: XYZ 1234',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        'Estimated Arrival: 5 minutes',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom Buttons
          Positioned(
            bottom: 40, // Positioned 40px above the bottom of the screen
            left: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add functionality to refresh location
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Full width and height of 50
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text('Refresh Location'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _startTrip, // Start the trip by moving the car and showing the path
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text('Start Trip'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _navigateToRatingPage(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text('End Trip'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
