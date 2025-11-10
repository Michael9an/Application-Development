import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_init.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/events_screen.dart';
import 'screens/clubs_screen.dart';  
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'utils/theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Start Firebase initialization in background. use service in lib/services/firebase_init.dart
  safeInitializeFirebase().catchError((e) => print('safeInitializeFirebase error: $e'));

  // Launch app immediately without waiting; code that needs Firebase should
  // call ensureFirebaseInitialized() to wait for init to complete.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            
            // Error handling for the entire app. Use a safe builder: child may be null
            builder: (context, child) {
              ErrorWidget.builder = (FlutterErrorDetails details) {
                return Material(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'An error occurred',
                          style: Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                          child: const Text('Return to Home'),
                        ),
                      ],
                    ),
                  ),
                );
              };

              // Add error boundary for input widgets; child may be null on first build
              final safeChild = child ?? const SizedBox.shrink();
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0, // Prevent text scaling issues
                ),
                child: safeChild,
              );
            },
            
            // Routes configuration
            routes: {
              '/': (context) => appProvider.isLoggedIn ? const HomeScreen() : const LoginScreen(),
              '/home_screen': (context) => const HomeScreen(),
              '/events_screen': (context) => const EventsScreen(),
              '/clubs_screen': (context) => const ClubsScreen(),
              '/profile_screen': (context) => const ProfileScreen(),
              '/login_screen': (context) => const LoginScreen(),
            },
            
            // Handle unknown routes
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => appProvider.isLoggedIn 
                  ? const HomeScreen() 
                  : const LoginScreen(),
              );
            },
            
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}