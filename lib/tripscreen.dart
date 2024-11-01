import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';



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
    Razorpay _razorpay=Razorpay();

  @override
  void initState() {
    super.initState();
    _confirmRide();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _confirmRide() {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _isConfirmed = true;
      });
    });
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_Lrcnvh6GWwPg9S',  // Replace with your Razorpay key
      'amount': 50000,  // Amount in paise (50000 paise = INR 500)
      'name': 'Ride Booking',
      'description': 'Ride Confirmation Payment',
      'prefill': {
        'contact': '1234567890', // Replace with user contact
        'email': 'user@example.com' // Replace with user email
      },
      'theme': {
        'color': '#F37254'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Success: ${response.paymentId}")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.code} - ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
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
          child: _isConfirmed 
            ? _buildConfirmedRideDetails() 
            : _buildWaitingForDriver(),
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
          onPressed: _openCheckout,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Pay Now',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
