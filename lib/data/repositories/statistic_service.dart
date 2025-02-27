import 'package:dio/dio.dart';
import 'package:mytodo_app/constans/api_constans.dart';
import 'package:mytodo_app/data/models/task_statistics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsService {
  final Dio _dio;
  StatisticsService(): _dio=Dio(BaseOptions(baseUrl: ApiConstans.BASE_URL));
  Future<TaskStatistics> getStatistics() async {
    try {
         final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await _dio.get(
        '/statistics',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return TaskStatistics.fromMap(response.data['data']);
      } else {
        throw Exception('İstatistikler alınamadı');
      }
    } catch (e) {
      throw Exception('Sunucu hatası: $e');
    }
  }
}



