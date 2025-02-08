import 'package:flutter/material.dart';
import '../models/category_model.dart'; // 📌 Kategori Modelini Dahil Et

class CategoryCard extends StatelessWidget {
  final CategoryModel category; // ✅ Direkt model kullanıyoruz
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ✅ Kullanıcı tıklayınca kategori seçilsin
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300), // ✅ Animasyonlu geçiş efekti
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? category.color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: category.color, width: 2) : null,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon, style: TextStyle(fontSize: 30)), // ✅ İkon gösterme
            SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
