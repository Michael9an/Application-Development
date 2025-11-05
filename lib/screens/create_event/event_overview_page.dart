import 'package:flutter/material.dart';
import '../../models/event.dart';

class EventOverviewPage extends StatefulWidget {
  final EventModel eventData;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const EventOverviewPage({super.key, 
    required this.eventData,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  _EventOverviewPageState createState() => _EventOverviewPageState();
}

class _EventOverviewPageState extends State<EventOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildSectionHeader('Event Details'),
                _buildInfoCard(
                  title: 'Event Name',
                  value: widget.eventData.name,
                  icon: Icons.event,
                ),
                _buildInfoCard(
                  title: 'Description',
                  value: widget.eventData.description,
                  icon: Icons.description,
                ),
                _buildInfoCard(
                  title: 'Date & Time',
                  value: '${widget.eventData.formattedDate} at ${widget.eventData.formattedTime}',
                  icon: Icons.calendar_today,
                ),
                _buildInfoCard(
                  title: 'Location',
                  value: widget.eventData.location,
                  icon: Icons.location_on,
                ),
                _buildInfoCard(
                  title: 'Max Attendees',
                  value: widget.eventData.maxAttendees == 0 
                      ? 'Unlimited' 
                      : widget.eventData.maxAttendees.toString(),
                  icon: Icons.people,
                ),

                _buildSectionHeader('Pricing & Policies'),
                _buildInfoCard(
                  title: 'Event Type',
                  value: widget.eventData.isFree ? 'Free' : 'Paid',
                  icon: Icons.attach_money,
                ),
                if (!widget.eventData.isFree)
                  _buildInfoCard(
                    title: 'Ticket Price',
                    value: '\$${widget.eventData.price.toStringAsFixed(2)}',
                    icon: Icons.payment,
                  ),
                if (widget.eventData.refundPolicy?.isNotEmpty ?? false)
                  _buildInfoCard(
                    title: 'Refund Policy',
                    value: widget.eventData.refundPolicy!,
                    icon: Icons.policy,
                  ),
                _buildInfoCard(
                  title: 'Publish Time',
                  value: _formatPublishTime(),
                  icon: Icons.schedule,
                ),
              ],
            ),
          ),

          // Submit Button
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, 50),
                  ),
                  child: Text('Back'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onSubmit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(0, 50),
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Create Event'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isEmpty ? 'Not provided' : value),
      ),
    );
  }

  String _formatPublishTime() {
    if (widget.eventData.publishTime == null) return 'Immediately';
    
    final timestamp = int.tryParse(widget.eventData.publishTime!);
    if (timestamp == null) return 'Immediately';
    
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}