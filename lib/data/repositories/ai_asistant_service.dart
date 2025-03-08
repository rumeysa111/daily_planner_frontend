// ignore_for_file: unused_import, avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class AiAssistantService {
  static bool _isInitialized = false;
  static late GenerativeModel model;
  static DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 2);
  static const int _maxRetries=3;

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
        if (kDebugMode) {
          print('AI Service initialization error: $e');
        }
        throw Exception('AI servisi başlatılamadı: $e');
      }
    }
  }

static Future<String> getAIResponse(String userMessage) async {
    if (!_isInitialized) {
      return "AI servisi henüz başlatılmadı.";
    }

    if (apiKey.isEmpty) {
      return "API anahtarı bulunamadı. Lütfen sistem yöneticinize başvurun.";
    }

    // Rate limiting kontrolü
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - timeSinceLastRequest);
      }
    }

    int currentRetry = 0;
    Duration backoffDuration = const Duration(seconds: 2);

    while (currentRetry < _maxRetries) {
      try {
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
        _lastRequestTime = DateTime.now();
        
        return response.text ?? "Üzgünüm, yanıt oluşturulamadı. Lütfen tekrar deneyin.";

      } catch (e) {
        currentRetry++;
        if (e.toString().contains('503')) {
          if (currentRetry == _maxRetries) {
            return "Üzgünüm, servis şu anda yoğun. Lütfen birkaç dakika sonra tekrar deneyin.";
          }
          print('Retry attempt $currentRetry after server overload');
          await Future.delayed(backoffDuration);
          backoffDuration *= 2; // Exponential backoff
          continue;
        }
        if (currentRetry == _maxRetries) {
          return "Bir hata oluştu: $e";
        }
        await Future.delayed(backoffDuration);
        backoffDuration *= 2;
      }
    }
    
    return "Maksimum deneme sayısına ulaşıldı. Lütfen daha sonra tekrar deneyin.";
}
}
