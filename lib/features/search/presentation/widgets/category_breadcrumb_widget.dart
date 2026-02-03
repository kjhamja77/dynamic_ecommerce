import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';

class CategoryBreadcrumbWidget extends StatelessWidget {
  final List<String> breadcrumbItems;
  final VoidCallback? onItemTap;
  final VoidCallback? onBackTap;

  const CategoryBreadcrumbWidget({
    super.key,
    required this.breadcrumbItems,
    this.onItemTap,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    if (breadcrumbItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          if (breadcrumbItems.length > 1)
            InkWell(
              onTap: onBackTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          
          if (breadcrumbItems.length > 1)
            SizedBox(width: ResponsiveConstants.smSpacing),

          // Breadcrumb items
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: breadcrumbItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == breadcrumbItems.length - 1;

                  return Row(
                    children: [
                      InkWell(
                        onTap: isLast ? null : onItemTap,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveConstants.smPadding,
                            vertical: ResponsiveConstants.xsPadding,
                          ),
                          child: Text(
                            item,
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                              fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                              color: isLast ? Colors.black87 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast) ...[
                        SizedBox(width: ResponsiveConstants.xsSpacing),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(width: ResponsiveConstants.xsSpacing),
                      ],
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
