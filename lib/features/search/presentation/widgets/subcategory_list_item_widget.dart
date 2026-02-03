import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/search_subcategory.dart';
import '../bloc/subcategory_details_bloc.dart';
import '../pages/subcategory_details_page.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class SubcategoryListItemWidget extends StatelessWidget {
  final SearchSubcategory subcategory;

  const SubcategoryListItemWidget({
    super.key,
    required this.subcategory,
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
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          await HapticService.buttonClick();
          _navigateToSubcategoryDetails(context, subcategory);
        },
        child: Padding(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          child: Row(
            children: [
              // Modern icon with subtle background
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  subcategory.hasChildren ? Icons.folder_outlined : Icons.category_outlined,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
              SizedBox(width: ResponsiveConstants.mdSpacing),
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
                    ),
                    if (subcategory.hasChildren)
                      Text(
                        '${subcategory.children.length} ${AppLocalizations.of(context)!.subcategories}',
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                  
                ),
              ),
              // Modern arrow with subtle styling
              Container(
                padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade600,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSubcategoryDetails(BuildContext context, SearchSubcategory subcategory) {
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
  }
}
