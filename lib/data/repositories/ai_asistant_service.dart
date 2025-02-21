import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiAssistantService {
    static bool _isInitialized = false;
  static late GenerativeModel model;

  static String apiKey = dotenv.env['GEMINI_API_KEY'] ??
      ""; // Buraya kendi OpenAI API anahtarını ekle
  static Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        await dotenv.load(fileName: ".env");
        apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
        
        if (apiKey.isEmpty) {
          throw Exception("API anahtarı bulunamadı!");
        }

        model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
        );

        _isInitialized = true;
      } catch (e) {
        print('AI Service initialization error: $e');
        throw Exception('AI servisi başlatılamadı: $e');
      }
    }
  }
  static Future<String> getAIResponse(String userMessage) async {
    try {
      if (apiKey.isEmpty) {
        return "API anahtarı bulunamadı. Lütfen sistem yöneticinize başvurun.";
      }

      final content = [
Content.text(
  "Sen, bir görev yönetimi ve zaman planlama asistanısın. "
  "Kullanıcılar günlük planlarını, tamamlanması gereken görevlerini ve verimli çalışmak için en iyi zamanlarını sana sorabilirler. "
  "Her önerini kişiselleştir ve zaman yönetimi prensiplerine uygun planlar sun. "
  "Görevleri önceliklendirirken Eisenhower Matrisi, Pomodoro Tekniği ve verimlilik odaklı planlama tekniklerini kullanabilirsin. "
  "Eğer kullanıcı önceki görevlerinden bahsettiyse, onlara devam edip etmemesi gerektiğini de değerlendir. "
  "Her yanıtını anlaşılır, net ve motive edici bir dille ver."
),
        Content.text(userMessage),
      ];

      final response = await model.generateContent(content);
      final text = response.text;

      if (text == null) {
        return "Üzgünüm, yanıt oluşturulamadı. Lütfen tekrar deneyin.";
      }

      return text;
    } catch (e) {
      print('Exception in getAIResponse: $e');
      return "Bir hata oluştu: $e";
    }
  }
}
