import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytodo_app/core/theme/colors.dart';
import 'package:mytodo_app/domain/presentation/viewmodels/category_viewmodel.dart';
import '../../../data/models/category_model.dart';
import 'category_edit_dialog.dart';

class CategoryManagementDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoryProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.cardBackground,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kategorileri Yönet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, 
                       color: AppColors.primary),
                  onPressed: () => _showAddCategory(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    elevation: 0,
                    color: AppColors.background,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(category.icon, 
                               style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, 
                                 color: AppColors.primary),
                            onPressed: () => _editCategory(context, ref, category),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, 
                                 color: AppColors.error),
                            onPressed: () => _deleteCategory(context, ref, category),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: Text('Kapat'),
            ),
          ],
        ),
      ),
    );
  }

  // Update delete dialog
  void _deleteCategory(BuildContext context, WidgetRef ref, CategoryModel category) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Kategori Sil',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '${category.name} kategorisini silmek istediğinizden emin misiniz?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(categoryProvider.notifier)
                      .deleteCategory(category.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showAddCategory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CategoryEditDialog(),
    );
  }

  void _editCategory(
      BuildContext context, WidgetRef ref, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => CategoryEditDialog(category: category),
    );
  }

 
}
