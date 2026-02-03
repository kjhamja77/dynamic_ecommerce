import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/search_subcategory.dart';
import '../constants/category_card_theme.dart';
import 'ecommerce_category_widget.dart';

class SubcategoriesListWidget extends StatelessWidget {
  final List<SearchSubcategory> subcategories;
  final bool isExpanded;

  const SubcategoriesListWidget({
    super.key,
    required this.subcategories,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: CategoryCardTheme.expansionAnimationDuration,
      curve: CategoryCardTheme.expansionAnimationCurve,
      height: isExpanded ? null : 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveConstants.smPadding,
        ),
        child: Column(
          children: subcategories.map((subcategory) {
            return EcommerceCategoryWidget(
              key: ValueKey(subcategory.id),
              subcategory: subcategory,
            );
          }).toList(),
        ),
      ),
    );
  }
}
