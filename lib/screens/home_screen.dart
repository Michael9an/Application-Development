import 'package:flutter/material.dart';
import '../widgets/event_card.dart';
import '../widgets/bottom_nav.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import "create_event/create_event_flow.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  List<EventModel> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    // Check if mounted before starting
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      _events = await _eventService.getEvents();
      
      // Check if still mounted before updating state
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Check if still mounted before updating state
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEvents,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: EventCard(event: event),
                  );
                },
              ),
            ),
      bottomNavigationBar: BottomNav(selectedIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventFlow()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
      ),
    
    );
  }
}