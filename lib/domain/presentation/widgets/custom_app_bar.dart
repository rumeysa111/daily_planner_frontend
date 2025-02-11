//// filepath: /c:/src/project/mytodo_app/lib/domain/presentation/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLeading; // New parameter

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showLeading = true, // Default to true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: showLeading, // Use the parameter here
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: actions,
      iconTheme: IconThemeData(color: AppColors.primary),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}