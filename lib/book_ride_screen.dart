import 'dart:async';
import 'package:cab_way/track_ride_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BookRideScreen extends StatefulWidget {
  @override
  _BookRideScreenState createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();

  String _rideType = 'Select Ride Type';
  List<String> _rideTypes = ['Select Ride Type', 'Economy', 'Premium', 'Luxury'];

  // Map and car movement logic
  final LatLng _rajkotLocation = LatLng(22.3039, 70.8022);
  LatLng _carLocation = LatLng(22.4000, 70.9000);
  final MapController _mapController = MapController();
  Timer? _timer;
  final Distance _distance = Distance();
  final double _averageSpeed = 60.0;

  double _calculateDistance(LatLng start, LatLng end) {
    return _distance.as(LengthUnit.Kilometer, start, end);
  }

  String _calculateTime(double distance) {
    double timeInHours = distance / _averageSpeed;
    int hours = timeInHours.floor();
    int minutes = ((timeInHours - hours) * 60).round();
    return "${hours > 0 ? '$hours hr ' : ''}${minutes} min";
  }

  void _moveCarDynamically() {
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        double totalDistance = _calculateDistance(_carLocation, _rajkotLocation);
        if (totalDistance < 0.1) {
          timer.cancel();
        } else {
          double step = 0.01;
          LatLng direction = LatLng(
            _rajkotLocation.latitude - _carLocation.latitude,
            _rajkotLocation.longitude - _carLocation.longitude,
          );
          _carLocation = LatLng(
            _carLocation.latitude + (direction.latitude * step / totalDistance),
            _carLocation.longitude + (direction.longitude * step / totalDistance),
          );
        }
      });
    });
  }

  void _cancelRide() {
    _timer?.cancel();
    setState(() {
      _carLocation = LatLng(22.4000, 70.9000);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double distance = _calculateDistance(_rajkotLocation, _carLocation);
    String travelTime = _calculateTime(distance);

    return Scaffold(
      appBar: AppBar(
        title: Text('Book a Ride'),
        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: _moveCarDynamically,
          ),
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: _cancelRide,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Section
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _rajkotLocation,
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _rajkotLocation,
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
          // Foreground content: Booking section
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pick-up location input
                TextField(
                  controller: _pickupController,
                  decoration: InputDecoration(
                    labelText: 'Pick-up Location',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 16.0),
                // Destination input
                TextField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: 'Destination',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 16.0),
                // Ride Type Dropdown
                DropdownButton<String>(
                  value: _rideType,
                  isExpanded: true,
                  items: _rideTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _rideType = newValue!;
                    });
                  },
                ),
                SizedBox(height: 24.0),
                // Book Ride button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      String pickup = _pickupController.text;
                      String destination = _destinationController.text;

                      if (pickup.isNotEmpty &&
                          destination.isNotEmpty &&
                          _rideType != 'Select Ride Type') {
                        showRideBottomSheet(context, pickup, destination, _rideType);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Error'),
                            content: Text('Please fill all fields and select a ride type.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text('Book Ride'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showRideBottomSheet(BuildContext context, String pickup, String destination, String rideType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '25% promotion applied',
                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_taxi, color: Colors.white),
                      SizedBox(width: 8.0),
                      Text(
                        'Go Intercity - $rideType',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Text(
                    '₹330.76',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹370.76',
                    style: TextStyle(
                      color: Colors.white54,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    '1:50pm • 10 min away',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrackRidePage(),
                      ),
                    );
                  },
                  child: Text('Confirm Ride'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
