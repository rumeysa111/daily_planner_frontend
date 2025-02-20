import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/core/theme/colors.dart';
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
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.cardBackground,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.category == null ? 'Yeni Kategori' : 'Kategori Düzenle',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Kategori Adı',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.background,
                ),
                style: TextStyle(color: AppColors.textPrimary),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kategori adı girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildIconSelector(theme),
              SizedBox(height: 16),
              _buildColorSelector(theme),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: Text('İptal'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
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

  Widget _buildIconSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İkon Seç',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _icons.length,
            itemBuilder: (context, index) {
              final icon = _icons[index];
              final isSelected = _selectedIcon == icon;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = icon),
                child: Container(
                  width: 50,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withOpacity(0.2)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? _selectedColor : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: TextStyle(fontSize: 24),
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

  Widget _buildColorSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Renk Seç',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _colors.length,
            itemBuilder: (context, index) {
              final color = _colors[index];
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 50,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.textPrimary
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                    ],
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
            SnackBar(
              content: Text('Kullanıcı girişi gerekli'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        return;
      }

      // Loading göstergesi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategori kaydediliyor...'),
            backgroundColor: AppColors.error,
          ),
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      print("🚨 Kategori kaydetme hatası: $e"); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: AppColors.error,
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
