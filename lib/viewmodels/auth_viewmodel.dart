// 📌 Riverpod kütüphanesini içe aktarıyoruz (State management için gerekli)
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 📌 Kullanıcı modelini içe aktarıyoruz (UserModel, giriş yapan kullanıcının bilgilerini saklar)
import 'package:mytodo_app/models/user_model.dart';

// 📌 AuthService, backend ile iletişimi sağlayan servis (API isteklerini yönetir)
import 'package:mytodo_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 📌 AuthViewModel, kullanıcı giriş-çıkış durumunu yönetir ve UI ile AuthService arasında köprü kurar
class AuthViewModel extends StateNotifier<UserModel?> {
  // 📌 AuthService örneğini tanımlıyoruz (API isteklerini yönetecek)
  final AuthService _authService;

  // 📌 Constructor (Başlatıcı), AuthService'i alır ve başlangıç state'ini null yapar
  AuthViewModel(this._authService) : super(null) {
    _loadUser();
  }
  //kullanıcı giriş yaptısaa bilgileri local storaden al

  Future<void> _loadUser() async {
    final prefs=await SharedPreferences.getInstance();
    final String? token= prefs.getString("token");
    if(token !=null){
      //backednden token ile kullanıcı bilgileirni çek
      final user=await _authService.getUser(token);
      state=user;
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

  }
}

// 📌 Riverpod Provider tanımlaması
// 📌 StateNotifierProvider, AuthViewModel'in durumunu yönetir ve UI ile bağlantıyı sağlar
final authProvider = StateNotifierProvider<AuthViewModel, UserModel?>((ref) {
  return AuthViewModel(AuthService()); // 📌 AuthViewModel'in bir örneğini oluşturuyoruz
});
