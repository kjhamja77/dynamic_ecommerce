import 'package:flutter/material.dart';
import '../../domain/entities/search_category.dart';
import '../../domain/entities/search_subcategory.dart';
import '../constants/category_card_theme.dart';
import 'category_header_widget.dart';
import 'subcategories_list_widget.dart';

class CategoryWithSubcategoriesWidget extends StatefulWidget {
  final SearchCategory category;
  final List<SearchSubcategory>? subcategories;
  final VoidCallback? onCategoryTap;
  final Function(SearchSubcategory)? onSubcategoryTap;

  const CategoryWithSubcategoriesWidget({
    super.key,
    required this.category,
    this.subcategories,
    this.onCategoryTap,
    this.onSubcategoryTap,
  });

  @override
  State<CategoryWithSubcategoriesWidget> createState() => _CategoryWithSubcategoriesWidgetState();
}

class _CategoryWithSubcategoriesWidgetState extends State<CategoryWithSubcategoriesWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Ensure state starts as collapsed
    _isExpanded = false;
  }

  @override
  void didUpdateWidget(CategoryWithSubcategoriesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset expansion state if category changes
    if (oldWidget.category.id != widget.category.id) {
      _isExpanded = false;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSubcategories = widget.subcategories != null && widget.subcategories!.isNotEmpty;
    
    return Container(
      margin: CategoryCardTheme.cardMargin,
      decoration: CategoryCardTheme.cardDecoration,
      child: Column(
        children: [
          // Main Category Row
          CategoryHeaderWidget(
            category: widget.category,
            hasSubcategories: hasSubcategories,
            isExpanded: _isExpanded,
            onTap: hasSubcategories ? _toggleExpanded : (widget.onCategoryTap ?? () {}),
          ),
          
          // Subcategories (Expandable)
          if (hasSubcategories)
            SubcategoriesListWidget(
              subcategories: widget.subcategories!,
              isExpanded: _isExpanded,
            ),
        ],
      ),
    );
  }


}
