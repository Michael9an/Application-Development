import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;

  const BottomNav({required this.selectedIndex});
  void _navigateToScreen(BuildContext context, int index) {
  if (index == selectedIndex) return;

  switch (index) {
    case 0:
      Navigator.pushNamedAndRemoveUntil(context, '/home_screen', (route) => false);
      break;
    case 1:
      Navigator.pushNamedAndRemoveUntil(context, '/events_screen', (route) => false);
      break;
    case 2:
      Navigator.pushNamedAndRemoveUntil(context, '/clubs_screen', (route) => false);
      break;
    case 3:
      Navigator.pushNamedAndRemoveUntil(context, '/profile_screen', (route) => false);
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed, // For more than 3 items
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: const Color.fromARGB(255, 83, 82, 82),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clubs'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) => _navigateToScreen(context, index),
    );
  }
}
