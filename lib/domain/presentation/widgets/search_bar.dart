// ignore_for_file: deprecated_member_use, use_super_parameters

import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String)? onSearch;

  const SearchBarWidget({Key? key, this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onSearch,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: "Görevleri ara...",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              cursorColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              // TextField'ı temizlemek için controller ekleyin
              // controller.clear();
            },
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}