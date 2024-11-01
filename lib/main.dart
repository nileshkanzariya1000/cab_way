import 'package:cab_way/home_screen.dart';
import 'package:cab_way/login.dart';
import 'package:cab_way/profilepage.dart';
import 'package:cab_way/book_ride_screen.dart';
import 'package:cab_way/ratingscreen.dart';
import 'package:cab_way/sign_up.dart';
import 'package:cab_way/splashscreen.dart';
import 'package:cab_way/tripscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'ride_history.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}
