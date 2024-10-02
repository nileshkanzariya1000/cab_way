import 'package:flutter/material.dart';

class RideHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Add back button functionality
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          rideHistoryItem(
            'aji dam, rajkot, gujarat',
            'Hill View Hotel',
            'Jan 8, 2022 - 3:33',
            200,
          ),
          rideHistoryItem(
            'thakardhani hotel, kalipat',
            'Hill View Hotel',
            'Jan 8, 2022 - 2:33',
            100,
          ),
          rideHistoryItem(
            'Rk university, Tramba',
            'Hill View Hotel',
            'Jan 8, 2022 - 6:33',
            200,
          ),
          rideHistoryItem(
            'greenland, rajkot, gujarat',
            'Hill View Hotel',
            'Jan 8, 2022 - 3:00',
            250,
          ),
        ],
      ),
    );
  }

  Widget rideHistoryItem(String start, String end, String dateTime, int price) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_pin, size: 20, color: Colors.black),
                        SizedBox(width: 5),
                        Text(
                          start,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.search, size: 20, color: Colors.black),
                        SizedBox(width: 5),
                        Text(
                          end,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'Rs $price',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              dateTime,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
