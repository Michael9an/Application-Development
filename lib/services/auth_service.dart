import '../models/user.dart';

class AuthService {
  Future<UserModel> login(String email, String password) async {
    // Mock login - replace with actual API call
    await Future.delayed(Duration(seconds: 1));
    
    return UserModel(
      matricNo: '1',
      email: email,
      name: 'Test User',
      role: 'user',
      photoUrl: '',
      clubs: [],
    );
  }

  Future<bool> register(String email, String password, String name) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
}