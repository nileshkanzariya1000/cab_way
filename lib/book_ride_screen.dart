import 'package:cab_way/tripscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

class PolylineMap1 extends StatefulWidget {
  @override
  _PolylineMap1State createState() => _PolylineMap1State();
}

class _PolylineMap1State extends State<PolylineMap1> {
  final MapController mapController = MapController();
  List<LatLng> polylineCoordinates = [];
  String graphhopperApiKey ='graphhopperApiKey'; // Replace with your GraphHopper API key
  String openRouteServiceApiKey='openRouteServiceApiKey'; // Replace with your OpenRouteService API key
    final String mapboxApiKey = 'mapboxApiKey';
  final String mapboxStyle = 'mapbox/outdoors-v12';

bool showBookingWrapper = false; // New variable

  double? distance;
  String? duration;
  bool isLoading = true;
  bool isLoadingCurrentLocation = false;

  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();

  LatLng? fromLocation;
  LatLng? toLocation;

  List<String> suggestions = [];
  bool _showSuggestions = false;
  String activeSearchBox = '';

  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> getPolylinePoints() async {
    if (fromLocation == null || toLocation == null) {
      print('From or To location is missing');
      return;
    }

    setState(() {
      isLoading = true;
    });

    String url =
        'https://graphhopper.com/api/1/route?point=${fromLocation!.latitude},${fromLocation!.longitude}&point=${toLocation!.latitude},${toLocation!.longitude}&profile=car&locale=en&points_encoded=true&key=$graphhopperApiKey';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['paths'] != null && data['paths'].length > 0) {
          double distanceInMeters = data['paths'][0]['distance'];
          int durationInMilliseconds = data['paths'][0]['time'];

          distance = distanceInMeters / 1000;

          int totalMinutes = (durationInMilliseconds / 60000).round();
          int hours = totalMinutes ~/ 60;
          int minutes = totalMinutes % 60;
          duration = '${hours}h ${minutes}m';

          String encodedPolyline = data['paths'][0]['points'];
          PolylinePoints polylinePoints = PolylinePoints();
          List<PointLatLng> result = polylinePoints.decodePolyline(encodedPolyline);

          polylineCoordinates = result.map((point) => LatLng(point.latitude, point.longitude)).toList();
          updateMarkers();

          if (polylineCoordinates.isNotEmpty) {
            double latSum = 0;
            double lngSum = 0;

            for (LatLng point in polylineCoordinates) {
              latSum += point.latitude;
              lngSum += point.longitude;
            }

            double centerLat = latSum / polylineCoordinates.length;
            double centerLng = lngSum / polylineCoordinates.length;
            mapController.move(LatLng(centerLat, centerLng), 10.0);

            setState(() {});
          }
        } else {
          print('No paths found in the response');
        }
      } else {
        print('Failed to fetch polyline. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching polyline: $error');
    } finally {
      setState(() {
        isLoading = false;
        showBookingWrapper = true; // Show the booking wrapper

      });
    }
  }

  void updateMarkers() {
    markers.clear();

    if (fromLocation != null) {
      markers.add(
        Marker(
          point: fromLocation!,
          width: 30,
          height: 30,
          child: Container(
            child: Icon(Icons.location_on, color: Colors.red, size: 30),
          ),
        ),
      );
    }

    if (toLocation != null) {
      markers.add(
        Marker(
          point: toLocation!,
          width: 30,
          height: 30,
          child: Container(
            child: Icon(Icons.flag, color: Colors.green, size: 30),
          ),
        ),
      );
    }

    setState(() {});
  }

  Future<LatLng?> getCoordinates(String location) async {
    String url = 'https://photon.komoot.io/api/?q=$location&limit=1';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['features'] != null && data['features'].length > 0) {
        double longitude = data['features'][0]['geometry']['coordinates'][0];
        double latitude = data['features'][0]['geometry']['coordinates'][1];
        return LatLng(latitude, longitude);
      }
    } else {
      print('Failed to fetch coordinates');
    }
    return null;
  }

  Future<List<String>> getSuggestions(String query) async {
    String url =
        'https://api.openrouteservice.org/geocode/search?api_key=$openRouteServiceApiKey&text=$query';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<String> suggestions = [];
      if (data['features'] != null) {
        for (var feature in data['features']) {
          suggestions.add(feature['properties']['label']);
        }
      }
      return suggestions;
    }
    return [];
  }

  void _onSearchChanged(String query, {bool isFrom = true}) async {
    if (query.isNotEmpty) {
      final results = await getSuggestions(query);
      setState(() {
        suggestions = results;
        _showSuggestions = true;
        activeSearchBox = isFrom ? 'from' : 'to';
      });
    } else {
      setState(() {
        suggestions.clear();
        _showSuggestions = false;
      });
    }
  }

  void _onSuggestionSelected(String suggestion) async {
    if (activeSearchBox == 'from') {
      fromController.text = suggestion;
      fromLocation = await getCoordinates(suggestion);
    } else if (activeSearchBox == 'to') {
      toController.text = suggestion;
      toLocation = await getCoordinates(suggestion);
    }
    setState(() {
      suggestions.clear();
      _showSuggestions = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingCurrentLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      fromLocation = LatLng(position.latitude, position.longitude);
      fromController.text = 'Current Location';
      updateMarkers();
    } catch (e) {
      print('Error getting current location: $e');
    } finally {
      setState(() {
        isLoadingCurrentLocation = false;
      });
    }
  }

  double calculatePrice(double distance) {
    return distance * 10 + 100; // Price calculation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Search for Route',
        style: TextStyle( color: Colors.white),),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(32.5776, 74.0713),
              initialZoom: 10.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/$mapboxStyle/tiles/{z}/{x}/{y}?access_token=$mapboxApiKey',
                additionalOptions: {
                  'accessToken': mapboxApiKey,
                },
              ),
              if (polylineCoordinates.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylineCoordinates,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),
          if (isLoading || isLoadingCurrentLocation)
            Center(
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fromController,
                        decoration: InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.my_location),
                            onPressed: _getCurrentLocation,
                            tooltip: 'Use Current Location',
                          ),
                        ),
                        onChanged: (value) => _onSearchChanged(value, isFrom: true),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: toController,
                  decoration: InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                  onChanged: (value) => _onSearchChanged(value, isFrom: false),
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: getPolylinePoints,
                  child: Text('Get Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                ),
              
              ],
            ),
          ),
          if (_showSuggestions)
            Positioned(
              top: 130,
              left: 16,
              right: 16,
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(suggestions[index]),
                      onTap: () => _onSuggestionSelected(suggestions[index]),
                    );
                  },
                ),
              ),
            ),
          // Book Ride Wrapper
     // Book Ride Wrapper
if (showBookingWrapper) // Conditionally show the wrapper
  Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2), // Shadow below the container
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row: From and To Locations with Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Side: From and To Locations
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (fromLocation != null) ...[
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red),
                        SizedBox(width: 4.0),
                        Text(
                          ' ${fromController.text}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (toLocation != null) ...[
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.flag, color: Colors.green),
                        SizedBox(width: 4.0),
                        Text(
                          '${toController.text}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              // Right Side: Price
              if (distance != null)
                Text(
                  'Price: ₹${calculatePrice(distance!).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.0), // Space between rows
          // Second Row: Distance and Duration
          if (distance != null && duration != null) ...[
            Text(
              'Distance: ${distance!.toStringAsFixed(2)} km',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'Duration: $duration',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
          SizedBox(height: 8.0),
          // Book Ride Button
          ElevatedButton(
            onPressed: () {
              // Add your booking logic here
              print("Ride booked from ${fromController.text} to ${toController.text}!");
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RideBookingScreen()),
                  );
            },
            child: Text('Book Ride'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5, // Add elevation for depth
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
