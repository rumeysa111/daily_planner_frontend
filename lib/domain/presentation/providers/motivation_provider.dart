import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/todo_viewmodel.dart';
import '../../../services/remote_config_service.dart';

final motivationProvider = Provider<String>((ref) {
  final todoList = ref.watch(todoProvider);
  final completedTasks = todoList.where((todo) => todo.isCompleted).length;
  final remoteConfig = RemoteConfigService();
  return remoteConfig.getMotivasyonMesaji(completedTasks);
});
