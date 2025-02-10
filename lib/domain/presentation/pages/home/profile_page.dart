import 'package:flutter/material.dart';
import 'package:mytodo_app/core/theme/colors.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Profil",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            SizedBox(height: 20),
            _buildStatisticsSection(),
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
                        subtitle: "5 kategori",
                        onTap: () {},
                      ),
                      SettingsItem(
                        icon: Icons.add_circle_outline,
                        title: "Yeni Kategori Ekle",
                        onTap: () {},
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
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
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
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
                backgroundColor: Colors.grey[200],
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Kullanıcı Adı",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            "kullanici@email.com",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
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
          _buildStatItem("12", "Tamamlanan\nGörevler"),
          _buildStatDivider(),
          _buildStatItem("5", "Bekleyen\nGörevler"),
          _buildStatDivider(),
          _buildStatItem("70%", "Başarı\nOranı"),
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
    return ListTile(
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
    );
  }
}
