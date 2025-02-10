import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/core/theme/colors.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/category_viewmodel.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/profile_viewmodel.dart';
import '../../widgets/category_management_dialog.dart';
import '../../widgets/category_edit_dialog.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider);
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Profil",
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.primary),
            onPressed: () async {
              await ref.read(profileProvider.notifier).logout();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(context, user),
                  SizedBox(height: 20),
                  // Statistics Section
                  _buildStatisticsSection(ref),
                  SizedBox(height: 20),
                  // Settings Sections
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
                              subtitle: "${categories.length} kategori",
                              onTap: () => _showCategoryManagement(context),
                            ),
                            SettingsItem(
                              icon: Icons.add_circle_outline,
                              title: "Yeni Kategori Ekle",
                              onTap: () => _showAddCategory(context, ref),
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
                              onTap: () {},
                            ),
                            SettingsItem(
                              icon: Icons.lock_outline,
                              title: "Şifre Değiştir",
                              onTap: () {},
                            ),
                            SettingsItem(
                              icon: Icons.notifications_outlined,
                              title: "Bildirim Ayarları",
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildSettingsSection(
                          "Uygulama Ayarları",
                          [
                            SettingsItem(
                              icon: Icons.color_lens_outlined,
                              title: "Tema",
                              trailing: Switch(value: false, onChanged: (val) {}),
                            ),
                            SettingsItem(
                              icon: Icons.language,
                              title: "Dil",
                              subtitle: "Türkçe",
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildSettingsSection(
                          "Destek",
                          [
                            SettingsItem(
                              icon: Icons.help_outline,
                              title: "Yardım",
                              onTap: () {},
                            ),
                            SettingsItem(
                              icon: Icons.info_outline,
                              title: "Hakkında",
                              onTap: () {},
                            ),
                            SettingsItem(
                              icon: Icons.logout,
                              title: "Çıkış Yap",
                              textColor: Colors.red,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
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
          GestureDetector(
            onTap: () => _updateProfilePhoto(context),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            user.username,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user.email,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(WidgetRef ref) {
    return FutureBuilder<Map<String, int>>(
      future: ref.read(profileProvider.notifier).getTaskStatistics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final stats = snapshot.data!;
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
              _buildStatItem(
                  context, stats['completed'].toString(), "Tamamlanan\nGörevler"),
              _buildStatDivider(),
              _buildStatItem(
                  context, stats['pending'].toString(), "Bekleyen\nGörevler"),
              _buildStatDivider(),
              _buildStatItem(context, "${stats['successRate']}%", "Başarı\nOranı"),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryManagement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CategoryManagementDialog(),
    );
  }

  void _showAddCategory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CategoryEditDialog(),
    ).then((created) {
      if (created == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori başarıyla eklendi')),
        );
      }
    });
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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

  void _updateProfilePhoto(BuildContext context) {
    // TODO: Implement photo upload functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profil fotoğrafı güncelleme yakında!')),
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
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
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
    );
  }
}
