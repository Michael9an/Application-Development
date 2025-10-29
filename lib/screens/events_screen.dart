import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class EventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("EventsScreen loaded successfully!"); // Debug print
    
    return Scaffold(
      appBar: AppBar(title: Text('Events')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Events Screen Content'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/home_screen', (route) => false);
              },
              child: Text('Go to Home'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(selectedIndex: 1),
    );
  }
}