import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/core/theme/colors.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 PROFİL BİLGİLERİ
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text("Kullanıcı Adı", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("example@email.com", style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),

            SizedBox(height: 30),

            // 📌 AYARLAR MENÜSÜ
            ListTile(
              leading: Icon(Icons.dark_mode, color: AppColors.primary),
              title: Text("Koyu Mod"),
              trailing: Switch(value: false, onChanged: (value) {
                // Tema değişimi burada olacak
              }),
            ),

            ListTile(
              leading: Icon(Icons.notifications, color: AppColors.primary),
              title: Text("Bildirim Ayarları"),
              trailing: Switch(value: true, onChanged: (value) {
                // Bildirim ayarları güncellenecek
              }),
            ),

            ListTile(
              leading: Icon(Icons.lock, color: AppColors.primary),
              title: Text("Şifre Değiştir"),
              onTap: () {
                // Şifre değiştirme ekranına git
              },
            ),

            ListTile(
              leading: Icon(Icons.info, color: AppColors.primary),
              title: Text("Hakkında"),
              onTap: () {
                // Uygulama hakkında ekranına yönlendir
              },
            ),

            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Çıkış Yap", style: TextStyle(color: Colors.red)),
              onTap: () {
                // Kullanıcı çıkışı yapılacak
              },
            ),
          ],
        ),
      ),
    );
  }
}
