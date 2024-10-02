import 'package:cab_way/book_ride_screen.dart';
import 'package:cab_way/track_ride_page.dart';
import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Services',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Go anywhere, get anything',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildServiceCard(
                    context: context,
                    title: 'Ride',
                    imagePath: 'assets/image/car.png',
                    promo: true,
                  ),
                  buildServiceCard(
                    context: context,
                    title: 'Auto',
                    imagePath: 'assets/image/auto.png',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildServiceCard(
                    context: context,
                    title: 'Intercity',
                    imagePath: 'assets/image/texi.png',
                  ),
                  buildServiceCard(
                    context: context,
                    title: 'Moto',
                    imagePath: 'assets/image/bike.png',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildServiceCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    bool promo = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookRideScreen()),
        );
      },
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (promo)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Promo',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            const SizedBox(height: 5),
            Image.asset(
              imagePath,
              width: 40,
              height: 40,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}