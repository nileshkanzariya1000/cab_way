import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Notification'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Today'),
          _buildNotificationItem(
            icon: Icons.payment,
            title: 'Payment Successfully!',
            description: 'Lorem ipsum dolor sit amet consectetur.',
          ),
          _buildNotificationItem(
            icon: Icons.discount,
            title: '30% Special Discount!',
            description: 'Lorem ipsum dolor sit amet consectetur.',
          ),
          _buildSectionHeader('Yesterday'),
          _buildNotificationItem(
            icon: Icons.payment,
            title: 'Payment Successfully!',
            description: 'Lorem ipsum dolor sit amet consectetur.',
          ),
          _buildNotificationItem(
            icon: Icons.credit_card,
            title: 'Credit Card added!',
            description: 'Lorem ipsum dolor sit amet consectetur.',
          ),
          _buildNotificationItem(
            icon: Icons.account_balance_wallet,
            title: 'Added Money wallet Successfully!',
            description: 'Lorem ipsum dolor sit amet consectetur.',
          ),
          _buildNotificationItem(
            icon: Icons.discount,
            title: '5% Special Discount!',
            description: 'Lorem ipsum dolor sit amet consectetur.',
          ),
          _buildSectionHeader('May 27, 2023'),
          _buildNotificationItem(
            icon: Icons.payment,
            title: 'Payment Successfully!',
            description: 'Lorem ipsum dolor sit amet consectetur.',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.black,
          child: Icon(
            icon,
            color: Colors.amber,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
      ),
    );
  }
}

