import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'event_details_page.dart';
import 'event_pricing_page.dart';
import 'event_overview_page.dart';
import '../../models/event.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../services/firebase_init.dart';

class CreateEventFlow extends StatefulWidget {
  const CreateEventFlow({super.key});

  @override
  _CreateEventFlowState createState() => _CreateEventFlowState();
}

class _CreateEventFlowState extends State<CreateEventFlow> {
  int _currentStep = 0;
  late EventModel _eventData;

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();


  @override
  void initState() {
    super.initState();
    _eventData = EventModel(
      id: '',
      name: '',
      description: '',
      date: DateTime.now().millisecondsSinceEpoch.toString(),
      bannerUrl: null,
      location: '',
      clubId: '1', 
      clubName: 'UTM Club',
      clubImageUrl: null,
      maxAttendees: 0,
      price: 0.0,
      isFree: true,
      refundPolicy: null,
      publishTime: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );
  }

  void _goToPage(int page) {
    setState(() {
      _currentStep = page;
    });
  }

  void _submitEvent() async {
    if (!mounted) return;

    // Ensure Firebase is initialized (short timeout) before starting uploads
    final initOk = await ensureFirebaseInitialized(timeout: Duration(seconds: 10));
    if (!initOk) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to connect to Firebase. Please try again later.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show submission dialog with progress tracking
    final progressNotifier = ValueNotifier<String>('Creating event...');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: ValueListenableBuilder<String>(
            valueListenable: progressNotifier,
            builder: (context, statusMessage, _) {
              return Center(
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(statusMessage),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    try {
      // Generate a unique ID for the event and create a new instance
      final generatedId = DateTime.now().millisecondsSinceEpoch.toString();
      EventModel eventToSave = _eventData.copyWith(id: generatedId);

      // Handle image upload if needed
      if (eventToSave.bannerUrl != null && eventToSave.bannerUrl!.startsWith('/')) {
        progressNotifier.value = 'Uploading event image...';
        final imageFile = File(eventToSave.bannerUrl!);
        
        if (await imageFile.exists()) {
          try {
            final downloadUrl = await _storageService.uploadEventImage(
              imageFile,
              eventToSave.id,
              onProgress: (progress) {
                progressNotifier.value = 
                  'Uploading image: ${(progress * 100).toStringAsFixed(1)}%';
              },
            ).timeout(
              Duration(seconds: 30),
              onTimeout: () {
                throw TimeoutException('Image upload took too long. Please try again.');
              },
            );

            if (downloadUrl != null) {
              eventToSave = eventToSave.copyWith(bannerUrl: downloadUrl);
            } else {
              throw Exception('Failed to upload image. Please try again.');
            }
          } catch (uploadError) {
            // Log the error but continue with event creation
            print('Image upload failed: $uploadError');
            // Keep the local path if upload fails
          }
        }
      }

      progressNotifier.value = 'Saving event details...';
      
      // Save event to Firestore with timeout
      await _firestoreService.addEvent(eventToSave).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Failed to save event: operation timed out. Please try again.');
        },
      );
      
      if (!mounted) return;
      Navigator.pop(context); // Close progress dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event created successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      Navigator.pop(context); // Return to previous screen
      
    } catch (e) {
      // Ensure progress dialog is closed
      if (!mounted) return;
      Navigator.pop(context);
      
      // Handle specific error types
      String errorMessage = 'An unexpected error occurred. Please try again.';
      
      if (e is TimeoutException) {
        errorMessage = e.message ?? 'Operation timed out. Please try again.';
      } else if (e is FirebaseException) {
        errorMessage = 'Firebase error: ${e.message}';
      }
      
      // Clean up the error message
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'DISMISS',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      EventDetailsPage(
        eventData: _eventData,
        onNext: (updated) {
          setState(() {
            _eventData = updated;
            _goToPage(1);
          });
        },
      ),
      EventPricingPage(
        eventData: _eventData,
        onNext: (updated) {
          setState(() {
            _eventData = updated;
            _goToPage(2);
          });
        },
        onBack: () => _goToPage(0),
      ),
      EventOverviewPage(
        eventData: _eventData,
        onSubmit: _submitEvent,
        onBack: () => _goToPage(1),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _goToPage(_currentStep - 1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / pages.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Step ${_currentStep + 1} of ${pages.length}'),
                Text(_getStepTitle(_currentStep)),
              ],
            ),
          ),
          Expanded(
            child: pages[_currentStep],
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return 'Event Details';
      case 1: return 'Pricing & Policies';
      case 2: return 'Overview';
      default: return '';
    }
  }
}