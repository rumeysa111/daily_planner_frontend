// ignore_for_file: unused_import, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/core/navigation/routes.dart';
import 'package:mytodo_app/core/theme/colors.dart';
import 'package:mytodo_app/domain/presentation/pages/profile/change_password_page.dart';
import 'package:mytodo_app/domain/presentation/pages/profile/edit_profile_page.dart';
import 'package:mytodo_app/domain/presentation/providers/providers.dart';
import 'package:mytodo_app/domain/presentation/providers/theme_providers.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../../widgets/category_management_dialog.dart';
import '../../widgets/custom_app_bar.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode=ref.watch(themeProvider);
    final user = ref.watch(authProvider);
    final todos = ref.watch(todoProvider);

    // İstatistikleri hesapla
    final completedTasks = todos.where((todo) => todo.isCompleted).length;
    final pendingTasks = todos.where((todo) => !todo.isCompleted).length;
    final successRate =
        todos.isEmpty ? 0 : (completedTasks / todos.length * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        showLeading: false,
        title: "Profil",
    
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(user?.name ?? "Kullanıcı", user?.email ?? ""),
            const SizedBox(height: 20),
            _buildStatisticsSection(completedTasks, pendingTasks, successRate),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildSettingsSection(
                    "Kategoriler",
                    [
                      SettingsItem(
                        icon: Icons.category,
                        title: "Kategorileri Yönet",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => CategoryManagementDialog(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsSection(
                    "Hesap Ayarları",
                    [
                      SettingsItem(
                        icon: Icons.person_outline,
                        title: "Profili Düzenle",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfilePage()),
                          );
                        },
                      ),
                      SettingsItem(
                        icon: Icons.lock_outline,
                        title: "Şifre Değiştir",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangePasswordPage()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsSection(
                    "Uygulama",
                    [
                      SettingsItem(icon: isDarkMode ? Icons.light_mode : Icons.dark_mode, title: "Tema",subtitle:isDarkMode ?"Açık Temaya Geç":"Koyu Temaya Geç",
                      trailing: Switch(value: isDarkMode, onChanged: (value){
                        ref.read(themeProvider.notifier).toggleTheme();
                      },activeColor: AppColors.primary,),
                      ), 
                      SettingsItem(
                        icon: Icons.logout,
                        title: "Çıkış Yap",
                        textColor: Colors.red,
                        onTap: () async {
                          await ref.read(authProvider.notifier).logout();
                          Navigator.pushNamedAndRemoveUntil(
                            // ignore: use_build_context_synchronously
                            context,
                            AppRoutes.login,
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                email,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(int completed, int pending, int successRate) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              "$completed", "Tamamlanan\nGörevler", AppColors.success),
          _buildStatDivider(),
          _buildStatItem("$pending", "Bekleyen\nGörevler", AppColors.warning),
          _buildStatDivider(),
          _buildStatItem("$successRate%", "Başarı\nOranı", AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.divider,
    );
  }

  Widget _buildSettingsSection(String title, List<SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;

  const SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            title,
            style: TextStyle(
              color: textColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: const TextStyle(color: AppColors.textSecondary),
                )
              : null,
          trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 0.5, color: AppColors.divider,),
      ],
    );
  }
}
