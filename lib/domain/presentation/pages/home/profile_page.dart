import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/core/navigation/routes.dart';
import 'package:mytodo_app/domain/presentation/pages/profile/change_password_page.dart';
import 'package:mytodo_app/domain/presentation/pages/profile/edit_profile_page.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../../widgets/category_management_dialog.dart';
import '../../widgets/custom_app_bar.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final todos = ref.watch(todoProvider);

    // İstatistikleri hesapla
    final completedTasks = todos.where((todo) => todo.isCompleted).length;
    final pendingTasks = todos.where((todo) => !todo.isCompleted).length;
    final successRate =
        todos.isEmpty ? 0 : (completedTasks / todos.length * 100).round();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: "Profil",
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue),
            onPressed: () {
              // Profil ayarları
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(user?.name ?? "Kullanıcı", user?.email ?? ""),
            SizedBox(height: 20),
            _buildStatisticsSection(completedTasks, pendingTasks, successRate),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
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
                  SizedBox(height: 20),
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
                  SizedBox(height: 20),
                  _buildSettingsSection(
                    "Uygulama",
                    [
                      SettingsItem(
                        icon: Icons.logout,
                        title: "Çıkış Yap",
                        textColor: Colors.red,
                        onTap: () async {
                          await ref.read(authProvider.notifier).logout();
                          Navigator.pushNamedAndRemoveUntil(
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
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            email,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(int completed, int pending, int successRate) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("$completed", "Tamamlanan\nGörevler"),
          _buildStatDivider(),
          _buildStatItem("$pending", "Bekleyen\nGörevler"),
          _buildStatDivider(),
          _buildStatItem("$successRate%", "Başarı\nOranı"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildSettingsSection(String title, List<SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
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
          leading: Icon(icon, color: Colors.blue),
          title: Text(
            title,
            style: TextStyle(
              color: textColor ?? Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        Divider(height: 1, thickness: 0.5, color: Colors.grey[300]),
      ],
    );
  }
}
