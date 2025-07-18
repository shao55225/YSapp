import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 自定义AppBar组件
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double elevation;
  final Widget? leading;
  final Widget? titleWidget;
  final bool centerTitle;

  const CustomAppBar({
    Key? key,
    this.title = '',
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.textColor,
    this.elevation = 0,
    this.leading,
    this.titleWidget,
    this.centerTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? Text(
        title,
        style: AppTextStyles.headline4.copyWith(
          color: textColor ?? Colors.white,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: elevation,
      leading: _buildLeading(context),
      actions: actions,
      automaticallyImplyLeading: false,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    
    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }
    
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 透明AppBar
class TransparentAppBar extends CustomAppBar {
  TransparentAppBar({
    Key? key,
    String title = '',
    List<Widget>? actions,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
    Color textColor = Colors.white,
    Widget? leading,
    Widget? titleWidget,
    bool centerTitle = true,
  }) : super(
    key: key,
    title: title,
    actions: actions,
    showBackButton: showBackButton,
    onBackPressed: onBackPressed,
    backgroundColor: Colors.transparent,
    textColor: textColor,
    elevation: 0,
    leading: leading,
    titleWidget: titleWidget,
    centerTitle: centerTitle,
  );
}

/// 搜索AppBar
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String hintText;
  final TextEditingController controller;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onBackPressed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color? backgroundColor;
  final bool showBackButton;
  final bool autofocus;

  const SearchAppBar({
    Key? key,
    this.hintText = '搜索',
    required this.controller,
    this.onSearchPressed,
    this.onBackPressed,
    this.onChanged,
    this.onSubmitted,
    this.backgroundColor,
    this.showBackButton = true,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: 0,
      titleSpacing: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Container(
        height: 36,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: TextField(
          controller: controller,
          autofocus: autofocus,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
        ),
      ),
      actions: [
        if (onSearchPressed != null)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchPressed,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 