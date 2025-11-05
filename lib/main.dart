import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/events_screen.dart';
import 'screens/clubs_screen.dart';  
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/report_event_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'Club Events',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            
            // Remove 'home' property and use routes only
            routes: {
              '/': (context) => appProvider.isLoggedIn ? HomeScreen() : LoginScreen(),
              '/home_screen': (context) => HomeScreen(), // Match your bottom_nav route name
              '/events_screen': (context) => EventsScreen(),
              '/clubs_screen': (context) => ClubsScreen(),
              '/profile_screen': (context) => ProfileScreen(),
              '/report_event': (context) => const ReportEventScreen(),
              '/login_screen': (context) => LoginScreen(),
            },
            
            // Handle unknown routes
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => appProvider.isLoggedIn ? HomeScreen() : LoginScreen(),
              );
            },
            
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}