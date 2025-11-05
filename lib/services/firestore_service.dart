import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all events
  Stream<List<EventModel>> getEvents() {
    return _firestore
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get events by club
  Stream<List<EventModel>> getEventsByClub(String clubId) {
    return _firestore
        .collection('events')
        .where('clubId', isEqualTo: clubId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Add new event with timeout and retry
  Future<void> addEvent(EventModel event) async {
    try {
      // Add with timeout to prevent hanging
      await _firestore
          .collection('events')
          .doc(event.id)
          .set(
            event.toFirestore(),
            SetOptions(merge: true), // Enable merge to prevent conflicts
          )
          .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Failed to save event: operation timed out');
            },
          );
    } catch (e) {
      print('Error adding event: $e');
      throw e;
    }
  }

  // Update event
  Future<void> updateEvent(String eventId, EventModel event) async {
    try {
      await _firestore.collection('events').doc(eventId).update(event.toFirestore());
    } catch (e) {
      print('Error updating event: $e');
      throw e;
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      throw e;
    }
  }
}