import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/nested_subcategory_widget.dart';
import '../widgets/category_breadcrumb_widget.dart';
import '../widgets/subcategory_shimmer.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class NestedSubcategoryPage extends StatefulWidget {
  final String subcategoryId;
  final String subcategoryTitle;
  final String parentCategoryTitle;
  final List<String> breadcrumbItems;

  const NestedSubcategoryPage({
    super.key,
    required this.subcategoryId,
    required this.subcategoryTitle,
    required this.parentCategoryTitle,
    required this.breadcrumbItems,
  });

  @override
  State<NestedSubcategoryPage> createState() => _NestedSubcategoryPageState();
}

class _NestedSubcategoryPageState extends State<NestedSubcategoryPage> {
  @override
  void initState() {
    super.initState();
    // Load nested subcategories when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchBloc>().add(LoadNestedSubcategories(widget.subcategoryId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
          ),
          onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
        ),
        title: Text(
          widget.subcategoryTitle,
          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Breadcrumb navigation
          CategoryBreadcrumbWidget(
            breadcrumbItems: widget.breadcrumbItems,
            onBackTap: () => Navigator.of(context).pop(),
          ),

          // Content
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial || state is SearchLoading) {
                  return const SubcategoryShimmer();
                }

                if (state is SearchError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.lgPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 56,
                            color: Colors.red.shade400,
                          ),
                          SizedBox(height: ResponsiveConstants.mdSpacing),
                          Text(
                            'Something went wrong',
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xlFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ResponsiveConstants.smSpacing),
                          Text(
                            state.message,
                            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ResponsiveConstants.lgSpacing),
                          ElevatedButton.icon(
                            onPressed: () async {
          await HapticService.buttonClick();
          context.read<SearchBloc>().add(LoadNestedSubcategories(widget.subcategoryId));
        },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveConstants.lgPadding,
                                vertical: ResponsiveConstants.smPadding,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is SearchLoaded) {
                  final isLoading = state.loadingSubcategories.contains(widget.subcategoryId);
                  final nestedSubcategories = state.subcategories[widget.subcategoryId] ?? [];

                  // Show shimmer while loading
                  if (isLoading) {
                    return const SubcategoryShimmer();
                  }

                  // Show empty state if no subcategories and not loading
                  if (nestedSubcategories.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.lgPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: ResponsiveConstants.mdSpacing),
                            Text(
                              AppLocalizations.of(context)!.noSubcategoriesFound,
                              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xlFontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: ResponsiveConstants.smSpacing),
                            Text(
                              AppLocalizations.of(context)!.tryDifferentSearchTerms,
                              textAlign: TextAlign.center,
                              style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: ResponsiveConstants.lgSpacing),
                            ElevatedButton.icon(
                              onPressed: () async {
          await HapticService.buttonClick();
          context.read<SearchBloc>().add(LoadNestedSubcategories(widget.subcategoryId));
        },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveConstants.lgPadding,
                                  vertical: ResponsiveConstants.smPadding,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
                    itemCount: nestedSubcategories.length,
                    itemBuilder: (context, index) {
                      final subcategory = nestedSubcategories[index];
                      
                      return NestedSubcategoryWidget(
                        key: ValueKey(subcategory.id),
                        subcategoryId: subcategory.id,
                        subcategoryTitle: subcategory.title,
                        parentCategoryTitle: widget.subcategoryTitle,
                        children: subcategory.children,
                        level: 0,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
