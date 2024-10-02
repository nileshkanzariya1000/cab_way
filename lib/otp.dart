import 'package:cab_way/home_screen.dart';
import 'package:cab_way/sign_up.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(Otp());
}

class Otp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OtpVerificationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OtpVerificationScreen extends StatefulWidget {
  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();
  final FocusNode _focusNode6 = FocusNode();

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    _controllers.forEach((controller) => controller.dispose());
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    _focusNode5.dispose();
    _focusNode6.dispose();
    super.dispose();
  }

  void _nextField(String value, FocusNode currentFocus, FocusNode nextFocus) {
    if (value.length == 1) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),

              // Instruction text
              Text(
                "Enter the 4-digit code sent to you at +977 98400316099",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),

              // OTP input fields using Wrap to avoid overflow
              Wrap(
                spacing: 8, // Space between OTP fields
                children: [
                  _otpTextField(_controllers[0], _focusNode1, _focusNode2),
                  _otpTextField(_controllers[1], _focusNode2, _focusNode3),
                  _otpTextField(_controllers[2], _focusNode3, _focusNode4),
                  _otpTextField(_controllers[3], _focusNode4, _focusNode5),
                  _otpTextField(_controllers[4], _focusNode5, _focusNode6),
                  _otpTextField(_controllers[5], _focusNode6, null),
                ],
              ),

              SizedBox(height: 20),

              // Resend code and login with password buttons
              Column(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "I didn't receive a code",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Login with password action
                    },
                    child: Text(
                      "Login with password",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),

              Spacer(), // Pushes the navigation buttons to the bottom

              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      // Back action
                    },
                  ),
// Next button
ElevatedButton.icon(
  onPressed: _controllers.every((controller) => controller.text.isNotEmpty)
      ? () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      : null, // Disables button if OTP isn't complete
  icon: Icon(Icons.arrow_forward),
  label: Text("Next"),
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white, backgroundColor: _controllers.every((controller) => controller.text.isNotEmpty)
        ? Colors.black // Background color when enabled
        : Colors.grey, // Text color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
),

                ],
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for creating individual OTP input field
  Widget _otpTextField(TextEditingController controller, FocusNode currentFocus,
      FocusNode? nextFocus) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: 8), // Add horizontal margin between OTP fields
      padding: EdgeInsets.all(4), // Add padding inside the container
      decoration: BoxDecoration(
        color: Colors.grey[200], // Background color for padding effect
        borderRadius:
            BorderRadius.circular(8), // Rounded corners for the outer container
      ),
      child: Container(
        width: 50,
        height: 50,
        child: TextField(
          controller: controller,
          focusNode: currentFocus,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(fontSize: 20),
          decoration: InputDecoration(
            counterText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            if (nextFocus != null) {
              _nextField(value, currentFocus, nextFocus);
            }
          },
        ),
      ),
    );
  }
}
