import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/data/models/user_model.dart';
import 'package:mytodo_app/data/repositories/auth_service.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/auth_viewmodel.dart';

final authServiceProvider = Provider<AuthService>(
    (ref) {
      return AuthService();
    });

// Auth view model provider
final authProvider = StateNotifierProvider<AuthViewModel, UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthViewModel(authService, ref);
});