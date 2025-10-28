import '../models/event.dart';

class EventService {
  Future<List<EventModel>> getEvents() async {
    // Mock data - replace with actual API
    await Future.delayed(Duration(seconds: 1));
    
    return [
      EventModel(
        id: '1',
        name: 'Music Festival',
        description: 'Annual music festival',
        date: DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch.toString(),
        bannerUrl: '',
        location: 'Central Park',
        clubId: '1',
        clubName: 'Music Club',
        clubImageUrl: '',
      ),
      EventModel(
        id: '2',
        name: 'Tech Talk',
        description: 'Latest in technology',
        date: DateTime.now().add(Duration(days: 3)).millisecondsSinceEpoch.toString(),
        bannerUrl: '',
        location: 'Tech Hub',
        clubId: '2',
        clubName: 'Tech Club',
        clubImageUrl: '',
      ),
    ];
  }

  Future<List<EventModel>> getClubEvents(String clubId) async {
    final events = await getEvents();
    return events.where((event) => event.clubId == clubId).toList();
  }
}