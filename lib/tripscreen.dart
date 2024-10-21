import 'package:flutter/material.dart';

void main() {
  runApp(BookRideApp());
}

class BookRideApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Ride',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RideBookingScreen(),
    );
  }
}

class RideBookingScreen extends StatefulWidget {
  @override
  _RideBookingScreenState createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _confirmRide();
  }

  void _confirmRide() {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _isConfirmed = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Ride'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _isConfirmed ? _buildConfirmedRideDetails() : _buildWaitingForDriver(),
        ),
      ),
    );
  }

  Widget _buildWaitingForDriver() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.local_taxi,
          size: 100,
          color: Colors.white,
        ),
        SizedBox(height: 20),
        Text(
          'Waiting for Driver Confirmation...',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            // Add your cancellation logic here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Booking Canceled')),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Cancel Booking',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedRideDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.check_circle,
          size: 100,
          color: Colors.green,
        ),
        SizedBox(height: 20),
        Text(
          'Ride Confirmed!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Text(
          'Driver: John Doe',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Text(
          'Vehicle: Toyota Camry',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Text(
          'License Plate: ABC-1234',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            // Logic for ride completion or further actions
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'View Ride Details',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
