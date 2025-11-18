import 'package:flutter/material.dart';
import '../../models/club.dart';
import '../../models/event.dart';
import '../../services/firestore_service.dart';
import 'create_event/create_event_flow.dart';

class ClubEventsScreen extends StatefulWidget {
  final Club club;

  const ClubEventsScreen({super.key, required this.club});

  @override
  _ClubEventsScreenState createState() => _ClubEventsScreenState();
}

class _ClubEventsScreenState extends State<ClubEventsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<List<EventModel>> _eventsStream;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    try {
      _eventsStream = _firestoreService.getEventsByClub(widget.club.id);
      _hasError = false;
      _errorMessage = null;
    } catch (e) {
      print('Error setting up events stream: $e');
      _hasError = true;
      _errorMessage = e.toString();
    }
  }

  void _createNewEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventFlow(club: widget.club),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _loadEvents();
        });
      }
    });
  }

  // Safe date formatting method
  String? _getFormattedDate(EventModel event) {
    try {
      if (event.date == null || event.date!.isEmpty) return null;
      final eventDate = DateTime.fromMillisecondsSinceEpoch(int.parse(event.date!));
      return '${eventDate.day}/${eventDate.month}/${eventDate.year}';
    } catch (e) {
      print('Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  Widget _buildEventItem(EventModel event) {
    final formattedDate = _getFormattedDate(event);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: (event.bannerUrl != null && event.bannerUrl!.isNotEmpty)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  event.bannerUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderIcon();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              )
            : _buildPlaceholderIcon(),
        title: Text(
          event.name ?? 'Unnamed Event',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            if (formattedDate != null)
              Text(
                formattedDate,
                style: TextStyle(fontSize: 14),
              ),
            if (event.location != null && event.location!.isNotEmpty)
              Text(
                event.location!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    (event.isFree ?? true) 
                      ? 'FREE' 
                      : '\$${event.price?.toStringAsFixed(2) ?? "0.00"}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: (event.isFree ?? true) ? Colors.green : Colors.blue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                SizedBox(width: 8),
                if (event.status != null)
                  Chip(
                    label: Text(
                      event.status!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: _getStatusColor(event.status!),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],
        ),
        onTap: () {
          _showEventDetails(event, formattedDate);
        },
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.event, color: Colors.blue[300]),
    );
  }

  void _showEventDetails(EventModel event, String? formattedDate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.name ?? 'Unnamed Event'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (event.bannerUrl != null && event.bannerUrl!.isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(event.bannerUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 16),
              if (event.description != null && event.description!.isNotEmpty)
                Text(
                  event.description!,
                  style: TextStyle(fontSize: 14),
                ),
              SizedBox(height: 8),
              if (formattedDate != null)
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16),
                    SizedBox(width: 8),
                    Text(formattedDate),
                  ],
                ),
              if (event.location != null && event.location!.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16),
                    SizedBox(width: 8),
                    Expanded(child: Text(event.location!)),
                  ],
                ),
              SizedBox(height: 8),
              if (event.maxAttendees != null)
                Row(
                  children: [
                    Icon(Icons.people, size: 16),
                    SizedBox(width: 8),
                    Text('${event.attendees?.length ?? 0} / ${event.maxAttendees} attendees'),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.club.name} Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createNewEvent,
            tooltip: 'Create New Event',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEvents,
            tooltip: 'Refresh Events',
          ),
        ],
      ),
      body: Column(
        children: [
          // Club Header (unchanged)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[50]!, Colors.purple[50]!],
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: widget.club.imageUrl.isNotEmpty 
                      ? NetworkImage(widget.club.imageUrl)
                      : null,
                  child: widget.club.imageUrl.isEmpty 
                      ? Icon(Icons.group, size: 30, color: Colors.white)
                      : null,
                  backgroundColor: widget.club.imageUrl.isEmpty ? Colors.blue : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.club.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.club.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${widget.club.eventIds.length} events • ${widget.club.memberIds.length} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Error Banner
          if (_hasError && _errorMessage != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              color: Colors.orange[100],
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange[800]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Error Loading Events',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          _errorMessage!.contains('index') 
                            ? 'Database index is being created. Please wait.'
                            : 'Some events may not load properly.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                      });
                    },
                  ),
                ],
              ),
            ),

          SizedBox(height: 8),

          // Events List
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: _eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading events...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load events',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadEvents,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final events = snapshot.data ?? [];

                if (events.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note, size: 80, color: Colors.grey[300]),
                          SizedBox(height: 24),
                          Text(
                            'No Events Yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Start creating amazing events for your club members',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _createNewEvent,
                            icon: Icon(Icons.add),
                            label: Text('Create Your First Event'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadEvents();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _buildEventItem(events[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewEvent,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        tooltip: 'Create New Event',
      ),
    );
  }
}