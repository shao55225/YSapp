import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/models/shop_models.dart';

class CategoryTabs extends ConsumerWidget {
  final List<ProductCategory> categories;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;
  final bool showAllOption;

  const CategoryTabs({
    Key? key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.showAllOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (showAllOption)
            _buildCategoryTab(
              context,
              null,
              '全部',
              selectedCategoryId == null,
            ),
          ...categories
              .where((category) => category.status == 1) // 只显示启用的分类
              .map((category) => _buildCategoryTab(
                    context,
                    category.id,
                    category.name,
                    selectedCategoryId == category.id,
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(
    BuildContext context,
    int? categoryId,
    String name,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ElevatedButton(
        onPressed: () => onCategorySelected(categoryId),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(name),
      ),
    );
  }
}

class CategoryGrid extends ConsumerWidget {
  final List<ProductCategory> categories;
  final Function(int) onCategorySelected;

  const CategoryGrid({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredCategories = categories.where((cat) => cat.status == 1).toList();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        return _buildCategoryItem(context, category);
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, ProductCategory category) {
    return InkWell(
      onTap: () => onCategorySelected(category.id),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (category.icon != null)
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: Image.network(
                category.icon!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.category,
                  size: 36,
                  color: Colors.grey,
                ),
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.category,
                color: Colors.grey,
              ),
            ),
          Text(
            category.name,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 