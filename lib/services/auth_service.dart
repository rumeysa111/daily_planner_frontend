import 'package:dio/dio.dart';
import 'package:mytodo_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService{
  final Dio dio = Dio(BaseOptions(baseUrl: "http://192.168.0.105:3000/api/auth"));

  Future<UserModel?> login(String email,String password) async{
    try{
      final response = await dio.post('/login', data: {
        "email":email,
      "password":password
      });
      print("Login API Response: ${response.data}"); // 📌 API'den gelen yanıtı konsola yazdır

      if(response.statusCode==200){
        final user=UserModel.fromMap(response.data);
        print("✅ Backend'den Gelen Kullanıcı ID: ${user.id}"); // ✅ `userId`'yi kontrol edelim


        return user;


      }
    }catch(e){
      print("Login error $e");
    }
    return null;
  }
Future<bool> register(String name, String surname, String email, String password) async {
  try {
    final response = await dio.post('/register', data: {
      "username": "$name $surname", // 📌 Ad ve soyadı birleştirerek gönderiyoruz
      "email": email,
      "password": password
    });

    return response.statusCode == 201;
  } catch (e) {
    print("Register error $e");
    return false;
  }
}
  // 📌 Token ile kullanıcı bilgilerini çekme fonksiyonu (Eksik olan metod!)
  Future<UserModel?> getUser(String token) async {
    try {
      final response = await dio.get('/user', options: Options(
          headers: {"Authorization": "Bearer $token"}
      ));

      if (response.statusCode == 200) {
        return UserModel.fromMap(response.data);
      }
    } catch (e) {
      print("Get user error: $e");
    }
    return null;
  }
}


