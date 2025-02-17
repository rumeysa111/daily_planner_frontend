import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:convert';

class RemoteConfigService {
  final _remoteConfig = FirebaseRemoteConfig.instance;
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() {
    return _instance;
  }

  RemoteConfigService._internal();

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      final defaultMessages = jsonEncode([
        'Harika gidiyorsun!',
        'Bugün çok üretkensin!',
        'Görevlerini tamamlamaya devam et!',
      ]);

      await _remoteConfig.setDefaults({
        'is_enabled': true,
        'max_tasks_per_day': 10,
        'motivation_messages': defaultMessages,
      });

      // Hata yönetimi ekleyelim
      try {
        await _remoteConfig.fetchAndActivate();
      } catch (e) {
        print('Remote config fetch error: $e');
        // Hata durumunda varsayılan değerleri kullan
      }
    } catch (e) {
      print('Remote config initialization error: $e');
      // Hata durumunda servisi yine de kullanılabilir hale getir
    }
  }

  bool get isEnabled => _remoteConfig.getBool('is_enabled');
  int get maxTasksPerDay => _remoteConfig.getInt('max_tasks_per_day');

  String getMotivasyonMesaji(int completedTasks) {
    try {
      List<dynamic> messages =
          jsonDecode(_remoteConfig.getString('motivation_messages'));

      if (messages.isEmpty) {
        return 'Görevlerini tamamlamaya devam et!';
      }

      if (completedTasks == 0) {
        return 'Haydi ilk görevini tamamla!';
      } else if (completedTasks < 3) {
        return messages[0];
      } else if (completedTasks < 5) {
        return messages[1];
      } else {
        return messages[2];
      }
    } catch (e) {
      return 'Görevlerini tamamlamaya devam et!';
    }
  }
}
