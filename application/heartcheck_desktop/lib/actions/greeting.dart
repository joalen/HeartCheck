import 'package:flutter/material.dart';

class TimeBasedGreeting extends StatelessWidget {
  const TimeBasedGreeting({super.key});

  // Function to determine the time of day and return a suitable greeting
  static String getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;  // Get the current hour

    // Return the appropriate greeting based on the hour
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good afternoon';
    } else if (hour >= 18 && hour < 22) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Time-Based Greeting')),
      body: Center(
        child: Text(
          '${getTimeBasedGreeting()}, Alen!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}