import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/subcategory_details.dart';
import '../constants/search_icon_constants.dart';
import '../../../../core/theme/app_fonts.dart';

class SubcategoryItemWidget extends StatelessWidget {
  final SubcategoryItem item;
  final VoidCallback? onTap;

  const SubcategoryItemWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveConstants.mdPadding,
            vertical: ResponsiveConstants.mdPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                ),
                child: Icon(
                  _getIconData(item.iconName),
                  color: Colors.black,
                  size: ResponsiveConstants.mdIconSize,
                ),
              ),
              
              SizedBox(width: ResponsiveConstants.mdSpacing),
              
              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    if (item.description != null) ...[
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Text(
                        item.description!,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: ResponsiveConstants.smIconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    return SearchIconConstants.getSubcategoryIcon(iconName);
  }
}
