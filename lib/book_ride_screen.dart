import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cab_way/track_ride_page.dart';

class BookRideScreen extends StatefulWidget {
  @override
  _BookRideScreenState createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  List<Map<String, dynamic>> _searchSuggestions = [];
  List<Marker> _markers = [];
  final MapController _mapController = MapController();
  bool _showSuggestions = false;

  String _rideType = 'Select Ride Type';
  List<String> _rideTypes = ['Select Ride Type', 'Economy', 'Premium', 'Luxury'];

  LatLng? _currentLocation;

  double _routeDistance = 0.0;
  double _routeDuration = 0.0; // In minutes

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _pickupController.text = 'Current Location'; // Set initial pickup to current location
       _markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: _currentLocation!,
        builder: (ctx) => Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 40.0,
        ),
      ),
    );
      _mapController.move(_currentLocation!, 13.0);
    });
  }

  Future<List<Map<String, dynamic>>> fetchPlaceSuggestions(String query) async {
    final url = Uri.parse('https://photon.komoot.io/api/?lang=en&q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['features'] as List)
          .map((place) => {
                'name': place['properties']['name'],
                'lat': place['geometry']['coordinates'][1],
                'lon': place['geometry']['coordinates'][0],
              })
          .toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  void _onSearchChanged(String query) async {
    if (query.isNotEmpty) {
      final results = await fetchPlaceSuggestions(query);
      setState(() {
        _searchSuggestions = results;
        _showSuggestions = true;
      });
    } else {
      setState(() {
        _showSuggestions = false;
        _searchSuggestions = [];
      });
    }
  }

  void _onSuggestionSelected(Map<String, dynamic> place) async {
    setState(() {
      _markers = [
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(place['lat'], place['lon']),
          builder: (ctx) => Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40.0,
          ),
        )
      ];

      _mapController.move(LatLng(place['lat'], place['lon']), 13.0);
      _showSuggestions = false;
      _destinationController.text = place['name'];
    });

    // Fetch distance and duration using Mapbox API after selecting a destination
    await _fetchRouteDetails();
  }

  Future<void> _fetchRouteDetails() async {
    if (_currentLocation == null || _markers.isEmpty) return;

    final destination = _markers.first.point;
    final url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/${_currentLocation!.longitude},${_currentLocation!.latitude};${destination.longitude},${destination.latitude}?access_token=sk.eyJ1IjoibmtwYXRlbDEyIiwiYSI6ImNtMXB2Zms4NjA3NmMycHFyaXAyc3phZWMifQ.6e3hwpp0_Nll-nsQB_KbCQ');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        _routeDistance = data['routes'][0]['distance'] / 1000; // Convert meters to km
        _routeDuration = data['routes'][0]['duration'] / 60;   // Convert seconds to minutes
      });
    } else {
      throw Exception('Failed to load route details');
    }
  }

  double _calculatePrice(double distance) {
    return (distance * 20) + 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book a Ride'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation ?? LatLng(51.5, -0.09), // Default center if current location not available
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pick-up location (Current location)
                TextField(
                  controller: _pickupController,
                  decoration: InputDecoration(
                    labelText: 'Pick-up Location',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                  enabled: false, // Disable input since it's fixed to current location
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
                  onChanged: _onSearchChanged,
                ),
                // Show suggestions for destination
                if (_showSuggestions)
                  Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, index) {
                        final place = _searchSuggestions[index];
                        return ListTile(
                          title: Text(place['name'] ?? 'Unnamed Place'),
                          onTap: () => _onSuggestionSelected(place),
                        );
                      },
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
                // Distance and Duration display
                if (_routeDistance > 0 && _routeDuration > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distance: ${_routeDistance.toStringAsFixed(2)} km'),
                      Text('Duration: ${_routeDuration.toStringAsFixed(2)} minutes'),
                    ],
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
                    child: Text('Search'),
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
    double price = _calculatePrice(_routeDistance);  // Calculate the ride price based on the distance

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
                    '₹${price.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${(price * 1.1).toStringAsFixed(2)}', // Displaying the original price with 10% higher for promotion effect
                    style: TextStyle(
                      color: Colors.white54,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    '${_routeDuration.toStringAsFixed(0)} min away', // Displaying the travel duration
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
