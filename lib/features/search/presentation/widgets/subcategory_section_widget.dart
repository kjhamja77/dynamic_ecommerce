import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../domain/entities/subcategory_details.dart';
import 'subcategory_item_widget.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class SubcategorySectionWidget extends StatelessWidget {
  final SubcategorySection section;
  final Function(SubcategoryItem) onItemTap;

  const SubcategorySectionWidget({
    super.key,
    required this.section,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: EdgeInsets.only(
            left: ResponsiveConstants.mdPadding,
            bottom: ResponsiveConstants.mdSpacing,
          ),
          child: Text(
            section.title,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        
        // Section items
        ...section.items.map((item) => SubcategoryItemWidget(
          item: item,
          onTap: () async {
          await HapticService.buttonClick();
          onItemTap(item);
        },
        )),
        
        // Spacing after section
        SizedBox(height: ResponsiveConstants.lgSpacing),
      ],
    );
  }
}
