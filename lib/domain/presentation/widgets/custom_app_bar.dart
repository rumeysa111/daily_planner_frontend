// ignore_for_file: prefer_null_aware_operators

import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLeading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      automaticallyImplyLeading: showLeading,
      leading: showLeading 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, 
                   size: 20,
                   color: AppColors.primary),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      actions: actions != null 
          ? actions!.map((action) {
              if (action is IconButton) {
                return IconButton(
                  icon: action.icon,
                  onPressed: action.onPressed,
                  color: AppColors.primary,
                  iconSize: 24,
                  splashRadius: 24,
                );
              }
              return action;
            }).toList()
          : null,
      centerTitle: true,
      shape: const Border(
        bottom: const BorderSide(
          color: AppColors.divider,
          width: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}