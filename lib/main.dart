import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/events_screen.dart';
import 'screens/clubs_screen.dart';  
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'utils/theme.dart';

Future<void> initializeFirebase() async {
  try {
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, 
    );
    print('Firebase initialized successfully');
    
    // Configure Firebase Storage with shorter timeouts to prevent ANR
    FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 15));
    FirebaseStorage.instance.setMaxOperationRetryTime(const Duration(seconds: 15));
    print('Firebase Storage configured successfully');
    
    // Initialize Firestore settings with smaller cache
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 10485760, // 10 MB cache
    );
    
    // Quick connection checks with timeouts
    await Future.wait([
      FirebaseFirestore.instance.collection('test').doc('test').get()
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Firestore connection timeout'),
        )
        .then((_) => print('Firestore connection verified'))
        .catchError((e) => print('Firestore check failed: $e')),
        
      FirebaseStorage.instance.ref().child('test').getMetadata()
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Storage connection timeout'),
        )
        .then((_) => print('Storage connection verified'))
        .catchError((e) => print('Storage check failed: $e')),
    ], eagerError: false);
    
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue with app launch, services will retry connection as needed
  }
}

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase in the background
  initializeFirebase().catchError((e) => print('Background init error: $e'));
  
  // Launch app immediately without waiting
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
            
            // Error handling for the entire app
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
                          style: Theme.of(context).textTheme.titleLarge,
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
              
              // Add error boundary for input widgets
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0, // Prevent text scaling issues
                ),
                child: child!,
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