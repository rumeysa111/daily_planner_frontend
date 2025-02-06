import 'package:dio/dio.dart';
import 'package:mytodo_app/models/todo_model.dart';

class TodoService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: "http://192.168.0.105:3000/api/todos") // 📌 Backend URL'ini ekledik
  );

  Future<List<TodoModel>> fetchTodos(String token,{String? category}) async {
    try {
      print("📌 Backend'den görevler çekiliyor...");

      final response = await _dio.get(
        '/',
        options: Options(headers: {"Authorization": "Bearer $token"}),
        queryParameters: category != null && category != "Tümü" ? {"category": category} : {},

      );
      print("✅ Backend'den Gelen Yanıt: ${response.data}");

      return response.data.map<TodoModel>((json) => TodoModel.fromJson(json)).toList();
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }

  Future<bool> addTodo(String token, TodoModel todo) async {
    try {
      print("📌 Flutter'dan Backend'e Gönderilen JSON: ${todo.toJson()}");

      final response = await _dio.post(
        '/',
        data: todo.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("✅ Backend'den dönen yanıt: ${response.data}");

      return response.statusCode == 201;
    } catch (e) {
      print("🚨 Backend'e görev ekleme hatası: $e");
      return false;
    }
  }

  Future<bool> updateTodo(String token, String id, TodoModel todo) async {
    try {
      await _dio.put(
        '/$id',
        data: todo.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return true;
    } catch (e) {
      print("Güncelleme Hatası: $e");
      return false;
    }
  }

  Future<bool> deleteTodo(String token, String id) async {
    try {
      await _dio.delete(
        '/$id',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return true;
    } catch (e) {
      print("Silme Hatası: $e");
      return false;
    }
  }
}
