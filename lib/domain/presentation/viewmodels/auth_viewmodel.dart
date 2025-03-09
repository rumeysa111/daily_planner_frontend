

import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:mytodo_app/data/repositories/auth_service.dart';
import 'package:mytodo_app/domain/presentation/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/user_model.dart';
import 'category_viewmodel.dart';

class AuthViewModel extends StateNotifier<UserModel?> {
  final AuthService _authService;
  final Ref ref; // Riverpod ref ekledik**

  // 📌 Constructor (Başlatıcı), AuthService'i alır ve başlangıç state'ini null yapar
  AuthViewModel(this._authService, this.ref) : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    if (token != null) {
      // **✅ Backend'den token ile kullanıcı bilgilerini çek**
      final user = await _authService.getUser(token);

      if (user != null) {
        state = user;
        print("✅ Kullanıcı başarıyla yüklendi: ${user.toJson()}");

        // **✅ Kullanıcı giriş yaptıysa kategorileri getir**
        ref.read(categoryProvider.notifier).reloadCategories();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    final user = await _authService.login(email, password);

    if (user != null) {
      print("✅ Kullanıcı giriş yaptı: ${user.toJson()}");

      state = user;
      //tokenı kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", user.token);
      await prefs.setString("userId", user.id);
      print("✅ Kullanıcı ID Kaydedildi: ${user.id}");

      // **✅ Kullanıcı giriş yaptıktan sonra kategorileri getir**
      ref.read(categoryProvider.notifier).reloadCategories();
      return true;
    }

    return false; //  Giriş başarısızsa false döndürüyoruz
  }

  //  Kullanıcı kayıt olma fonksiyonu
  Future<bool> register(
      String name, String surname, String email, String password) async {
    //  AuthService içindeki register fonksiyonunu çağırarak API'ye istek gönderiyoruz
    return await _authService.register(name, surname, email, password);
  }

  //  Kullanıcı çıkış yapma fonksiyonu
  Future<void> logout() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("userId");
    // **✅ Çıkış yapınca kategori listesini temizle**
    ref.read(categoryProvider.notifier).clearCategories();
  }

  Future<bool> updateProfile(String name, String email) async {
    if (state == null) return false;

    final updatedUser =
        await _authService.updateProfile(state!.token, name, email);
    if (updatedUser != null) {
      state = updatedUser;
      return true;
    }
    return false;
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    if (state == null) return false;
    return await _authService.changePassword(
        state!.token, currentPassword, newPassword);
  }
}

