// 📌 Riverpod kütüphanesini içe aktarıyoruz (State management için gerekli)
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 📌 Kullanıcı modelini içe aktarıyoruz (UserModel, giriş yapan kullanıcının bilgilerini saklar)

// 📌 AuthService, backend ile iletişimi sağlayan servis (API isteklerini yönetir)
import 'package:mytodo_app/data/repositories/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/user_model.dart';
import 'category_viewmodel.dart';

// 📌 AuthViewModel, kullanıcı giriş-çıkış durumunu yönetir ve UI ile AuthService arasında köprü kurar
class AuthViewModel extends StateNotifier<UserModel?> {
  // 📌 AuthService örneğini tanımlıyoruz (API isteklerini yönetecek)
  final AuthService _authService;
  final Ref ref; // **✅ Riverpod ref ekledik**

  // 📌 Constructor (Başlatıcı), AuthService'i alır ve başlangıç state'ini null yapar
  AuthViewModel(this._authService,this.ref) : super(null) {
    _loadUser();
  }
  /// **📌 Kullanıcı giriş yaptıysa bilgileri local storage'dan al**
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
  // 📌 Kullanıcı giriş yapma fonksiyonu
  Future<bool> login(String email, String password) async {
    // 📌 AuthService ile giriş API isteğini yapıyoruz
    final user = await _authService.login(email, password);

    // 📌 Eğer kullanıcı bilgisi geldiyse (Giriş başarılı)
    if (user != null) {
      print("✅ Kullanıcı giriş yaptı: ${user.toJson()}");

      state = user;
      //tokenı kaydet
      final prefs=await SharedPreferences.getInstance();
      await prefs.setString("token", user.token);
      await prefs.setString("userId", user.id);
      print("✅ Kullanıcı ID Kaydedildi: ${user.id}");

      // **✅ Kullanıcı giriş yaptıktan sonra kategorileri getir**
      ref.read(categoryProvider.notifier).reloadCategories();
      return true;
    }

    return false; // 📌 Giriş başarısızsa false döndürüyoruz
  }

  // 📌 Kullanıcı kayıt olma fonksiyonu
  Future<bool> register(String name,String surname, String email, String password) async {
    // 📌 AuthService içindeki register fonksiyonunu çağırarak API'ye istek gönderiyoruz
    return await _authService.register(name,surname, email, password);
  }

  // 📌 Kullanıcı çıkış yapma fonksiyonu
   Future<void> logout()async {
    state=null;
    final prefs= await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("userId");
    // **✅ Çıkış yapınca kategori listesini temizle**
    ref.read(categoryProvider.notifier).clearCategories();
  }
}

// 📌 Riverpod Provider tanımlaması
// 📌 StateNotifierProvider, AuthViewModel'in durumunu yönetir ve UI ile bağlantıyı sağlar
final authProvider = StateNotifierProvider<AuthViewModel, UserModel?>((ref) {
  return AuthViewModel(AuthService(),ref); // 📌 AuthViewModel'in bir örneğini oluşturuyoruz
});
