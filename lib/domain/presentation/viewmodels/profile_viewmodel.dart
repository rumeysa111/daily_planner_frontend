import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_model.dart';

class ProfileViewModel extends StateNotifier<UserModel?> {
  ProfileViewModel() : super(null) {
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final username = prefs.getString('username');
    final email = prefs.getString('email');

    if (userId != null && username != null && email != null) {
      state = UserModel(
        id: userId,
        username: username,
        email: email,
      );
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    // TODO: Backend entegrasyonu yapılacak
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', updatedUser.username);
    await prefs.setString('email', updatedUser.email);
    state = updatedUser;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = null;
  }

  Future<Map<String, int>> getTaskStatistics() async {
    // TODO: Backend'den istatistikleri al
    return {
      'completed': 12,
      'pending': 5,
      'successRate': 85,
    };
  }
}

final profileProvider =
    StateNotifierProvider<ProfileViewModel, UserModel?>((ref) {
  return ProfileViewModel();
});
