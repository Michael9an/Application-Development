import '../models/club.dart';
import '../models/user.dart';

class ClubService {
  Future<List<Club>> getClubs() async {
    // Mock data - replace with actual API
    await Future.delayed(Duration(seconds: 1));
    
    final mockUser = UserModel(
      id: '1',
      email: 'admin@club.com',
      name: 'Club Admin',
      role: 'admin',
      photoUrl: '',
      clubs: [],
    );
    
    return [
      Club(
        id: '1',
        name: 'Music Club',
        description: 'For music enthusiasts',
        createdBy: mockUser,
        imageUrl: '',
        members: [mockUser],
      ),
      Club(
        id: '2',
        name: 'Tech Club',
        description: 'Technology and innovation',
        createdBy: mockUser,
        imageUrl: '',
        members: [mockUser],
      ),
    ];
  }
}