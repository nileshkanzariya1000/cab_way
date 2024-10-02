import 'package:flutter/material.dart';

class RatingScreen extends StatefulWidget {
  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double rating = 3.0; // Default rating
  List<String> issues = [
    'Poor Route',
    'Too many Pickups',
    'Co-rider behavior',
    'Navigation',
    'Driving',
    'Other'
  ];
  Set<String> selectedIssues = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rating'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            StarRating(
              rating: rating,
              onRatingChanged: (newRating) {
                setState(() {
                  rating = newRating;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'What went wrong?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: issues.map((issue) {
                  return CheckboxListTile(
                    title: Text(issue),
                    value: selectedIssues.contains(issue),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedIssues.add(issue);
                        } else {
                          selectedIssues.remove(issue);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle submission
                print('Rating: $rating');
                print('Selected Issues: $selectedIssues');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;

  StarRating({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          onPressed: () {
            onRatingChanged(index + 1.0);
          },
        );
      }),
    );
  }
}
