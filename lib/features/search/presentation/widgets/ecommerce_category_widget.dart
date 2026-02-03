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

class EcommerceCategoryWidget extends StatelessWidget {
  final SearchSubcategory subcategory;
  final VoidCallback? onTap;

  const EcommerceCategoryWidget({
    super.key,
    required this.subcategory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smSpacing,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Padding(
                padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                child: Row(
                  children: [
                    // Category icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: subcategory.hasChildren 
                              ? [Colors.blue.shade400, Colors.blue.shade600]
                              : [Colors.green.shade400, Colors.green.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        subcategory.hasChildren 
                            ? Icons.category_outlined 
                            : Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    
                    SizedBox(width: ResponsiveConstants.mdSpacing),
                    
                    // Category title and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subcategory.title,
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ResponsiveConstants.xsSpacing),
                          Text(
                            subcategory.hasChildren 
                                ? '${subcategory.children.length} ${AppLocalizations.of(context)!.subcategoriesAvailable}'
                                : AppLocalizations.of(context)!.browseProductsInCategory,
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Action arrow
                    Container(
                      padding: EdgeInsets.all(ResponsiveConstants.smPadding),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        subcategory.hasChildren 
                            ? Icons.keyboard_arrow_right 
                            : Icons.arrow_forward_ios,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Subcategories preview (if available)
              if (subcategory.hasChildren && subcategory.children.isNotEmpty)
                Container(
                  margin: EdgeInsets.fromLTRB(
                    ResponsiveConstants.mdPadding,
                    0,
                    ResponsiveConstants.mdPadding,
                    ResponsiveConstants.mdPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.popularSubcategories,
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.smSpacing),
                      // Grid of subcategory previews
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.5,
                          crossAxisSpacing: ResponsiveConstants.smSpacing,
                          mainAxisSpacing: ResponsiveConstants.smSpacing,
                        ),
                        itemCount: subcategory.children.length > 4 ? 4 : subcategory.children.length,
                        itemBuilder: (context, index) {
                          final child = subcategory.children[index];
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveConstants.smPadding,
                              vertical: ResponsiveConstants.xsPadding,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.label_outline,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: ResponsiveConstants.xsSpacing),
                                Expanded(
                                  child: Text(
                                    child.title,
                                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (subcategory.children.length > 4)
                        Padding(
                          padding: EdgeInsets.only(top: ResponsiveConstants.smSpacing),
                          child: Center(
                            child: Text(
                              '${AppLocalizations.of(context)!.viewAllSubcategories} ${subcategory.children.length}',
                              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
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
