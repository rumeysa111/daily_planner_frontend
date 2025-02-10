import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/category_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/category_model.dart';

class CategoryEditDialog extends ConsumerStatefulWidget {
  final CategoryModel? category;

  const CategoryEditDialog({Key? key, this.category}) : super(key: key);

  @override
  _CategoryEditDialogState createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends ConsumerState<CategoryEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIcon = "📝";
  Color _selectedColor = Colors.blue;

  final List<String> _icons = [
    "📝",
    "📌",
    "📚",
    "💼",
    "🏠",
    "🛒",
    "💪",
    "🎯",
    "🎨",
    "🎮",
    "📱",
    "💻",
    "🎵",
    "🎬",
    "⚽",
    "🍔",
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.category == null ? 'Yeni Kategori' : 'Kategori Düzenle',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Kategori Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kategori adı girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildIconSelector(),
              SizedBox(height: 16),
              _buildColorSelector(),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('İptal'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveCategory,
                    child: Text('Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('İkon Seç', style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _icons.length,
            itemBuilder: (context, index) {
              final icon = _icons[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = icon),
                child: Container(
                  width: 50,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: _selectedIcon == icon
                        ? _selectedColor.withOpacity(0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedIcon == icon
                          ? _selectedColor
                          : Colors.grey[300]!,
                    ),
                  ),
                  child:
                      Center(child: Text(icon, style: TextStyle(fontSize: 24))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Renk Seç', style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _colors.length,
            itemBuilder: (context, index) {
              final color = _colors[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 50,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color
                          ? Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kullanıcı girişi gerekli')),
          );
        }
        return;
      }

      // Loading göstergesi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori kaydediliyor...')),
        );
      }

      final category = CategoryModel(
        id: widget.category?.id ?? "", // Yeni kategori için boş ID
        name: _nameController.text,
        icon: _selectedIcon,
        color: _selectedColor,
        userId: userId,
      );

      print("📌 Kategori oluşturuldu: ${category.toJson()}"); // Debug log

      bool success;
      if (widget.category == null) {
        success =
            await ref.read(categoryProvider.notifier).addCategory(category);
      } else {
        success = await ref
            .read(categoryProvider.notifier)
            .updateCategory(widget.category!.id, category);
      }

      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori başarıyla kaydedildi')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategori kaydedilemedi. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("🚨 Kategori kaydetme hatası: $e"); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
