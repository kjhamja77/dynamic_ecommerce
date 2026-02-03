import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/search_subcategory.dart';
import '../bloc/subcategory_details_bloc.dart';
import '../pages/subcategory_details_page.dart';
import '../../../catalog/domain/models/catalog_args.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class ModernSubcategoryWidget extends StatelessWidget {
  final SearchSubcategory subcategory;
  final VoidCallback? onTap;

  const ModernSubcategoryWidget({
    super.key,
    required this.subcategory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.xsSpacing,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
          await HapticService.buttonClick();
          _handleTap(context);
        },
          splashColor: Colors.grey.shade100,
          highlightColor: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            child: Row(
              children: [
                // Category icon with modern styling
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: subcategory.hasChildren 
                        ? Colors.blue.shade50 
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: subcategory.hasChildren 
                          ? Colors.blue.shade200 
                          : Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    subcategory.hasChildren 
                        ? Icons.category_outlined 
                        : Icons.shopping_bag_outlined,
                    color: subcategory.hasChildren 
                        ? Colors.blue.shade600 
                        : Colors.green.shade600,
                    size: 28,
                  ),
                ),
                
                SizedBox(width: ResponsiveConstants.mdSpacing),
                
                // Category info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subcategory.title,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      if (subcategory.hasChildren)
                        Row(
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: ResponsiveConstants.xsSpacing),
                            Text(
                              '${subcategory.children.length} ${AppLocalizations.of(context)!.subcategories}',
                              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: ResponsiveConstants.xsSpacing),
                            Text(
                              AppLocalizations.of(context)!.browseProducts,
                              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                
                // Action indicator
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.smPadding),
                  decoration: BoxDecoration(
                    color: subcategory.hasChildren 
                        ? Colors.blue.shade50 
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    subcategory.hasChildren 
                        ? Icons.keyboard_arrow_right 
                        : Icons.arrow_forward_ios,
                    color: subcategory.hasChildren 
                        ? Colors.blue.shade600 
                        : Colors.green.shade600,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (subcategory.hasChildren) {
      // Navigate to subcategory details page for nested categories
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => sl<SubcategoryDetailsBloc>(),
            child: SubcategoryDetailsPage(
              subcategoryId: subcategory.id,
              title: subcategory.title,
            ),
          ),
        ),
      );
    } else {
      // Navigate directly to catalog for leaf categories
      Navigator.pushNamed(
        context,
        '/catalog',
        arguments: CatalogArgs(
          title: subcategory.title,
          category: subcategory.title,
          categoryId: subcategory.id,
          query: subcategory.title,
        ),
      );
    }
  }
}
