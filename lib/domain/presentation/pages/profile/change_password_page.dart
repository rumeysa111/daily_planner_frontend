import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/core/theme/colors.dart';
import 'package:mytodo_app/domain/presentation/widgets/custom_button.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

   @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Şifre Değiştir',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Güvenlik',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      obscure: _obscureCurrentPassword,
                      onToggle: () => setState(() => 
                        _obscureCurrentPassword = !_obscureCurrentPassword),
                      label: 'Mevcut Şifre',
                      theme: theme,
                    ),
                    SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      obscure: _obscureNewPassword,
                      onToggle: () => setState(() => 
                        _obscureNewPassword = !_obscureNewPassword),
                      label: 'Yeni Şifre',
                      theme: theme,
                    ),
                    SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      obscure: _obscureConfirmPassword,
                      onToggle: () => setState(() => 
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                      label: 'Yeni Şifre (Tekrar)',
                      theme: theme,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              CustomButton(
                text: 'Şifreyi Değiştir',
                onPressed: () async {
                  if (_newPasswordController.text != 
                      _confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Yeni şifreler eşleşmiyor'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  final success = await ref
                      .read(authProvider.notifier)
                      .changePassword(_currentPasswordController.text,
                          _newPasswordController.text);

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Şifre başarıyla değiştirildi'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Şifre değiştirilirken bir hata oluştu'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required String label,
    required ThemeData theme,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.primary,
            size: 22,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: theme.colorScheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }


  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
