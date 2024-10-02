import 'package:flutter/material.dart';

class SupportingDocumentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Supporting Documents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload your license photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter license number',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            SizedBox(height: 16),
            _buildResponsiveRow(screenWidth, [
              _buildUploadButton('Front', screenWidth),
              _buildUploadButton('Back', screenWidth),
            ]),
            SizedBox(height: 24),
            Divider(thickness: 1),
            SizedBox(height: 16),
            Text(
              'Upload your billbook photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            _buildResponsiveGrid(screenWidth),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Handle request for verification
                },
                child: Text('Request for verification'),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(String label, double screenWidth) {
    // Adjust size based on screen width
    double size = screenWidth > 600 ? 150 : 100;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Implement upload functionality here
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, size: 50, color: Colors.black),
          ),
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildResponsiveRow(double screenWidth, List<Widget> children) {
    return screenWidth > 600
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: children,
          )
        : Column(
            children: children,
          );
  }

  Widget _buildResponsiveGrid(double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = screenWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildUploadButton('Page 1', screenWidth),
            _buildUploadButton('Page 2', screenWidth),
            _buildUploadButton('Page 3', screenWidth),
            _buildUploadButton('Page 4', screenWidth),
          ],
        );
      },
    );
  }
}
