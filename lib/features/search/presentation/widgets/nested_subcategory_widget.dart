import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../pages/nested_subcategory_page.dart';
import '../constants/category_card_theme.dart';
import '../../../catalog/domain/models/catalog_args.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class NestedSubcategoryWidget extends StatefulWidget {
  final String subcategoryId;
  final String subcategoryTitle;
  final String parentCategoryTitle;
  final List<dynamic> children;
  final int level;
  final bool isExpanded;

  const NestedSubcategoryWidget({
    super.key,
    required this.subcategoryId,
    required this.subcategoryTitle,
    required this.parentCategoryTitle,
    required this.children,
    this.level = 0,
    this.isExpanded = false,
  });

  @override
  State<NestedSubcategoryWidget> createState() => _NestedSubcategoryWidgetState();
}

class _NestedSubcategoryWidgetState extends State<NestedSubcategoryWidget> {
  bool _isExpanded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    // If expanding and we have children but they're not loaded yet, load them
    if (_isExpanded && widget.children.isNotEmpty && !_isLoading) {
      _loadNestedSubcategories();
    }
  }

  void _loadNestedSubcategories() {
    setState(() {
      _isLoading = true;
    });

    context.read<SearchBloc>().add(LoadNestedSubcategories(widget.subcategoryId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state is SearchLoaded) {
          final isLoading = state.loadingSubcategories.contains(widget.subcategoryId);
          if (_isLoading && !isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          left: widget.level * ResponsiveConstants.mdPadding,
          bottom: ResponsiveConstants.smSpacing,
        ),
        decoration: CategoryCardTheme.cardDecoration,
        child: Column(
          children: [
            // Main subcategory item
            ListTile(
              contentPadding: CategoryCardTheme.subcategoryItemPadding,
              leading: Container(
                width: 40,
                height: 40,
                decoration: CategoryCardTheme.getIconDecoration(_getCategoryColor(widget.level)),
                child: Icon(
                  _getCategoryIcon(widget.level),
                  color: _getCategoryColor(widget.level),
                  size: 20,
                ),
              ),
              title: Text(
                widget.subcategoryTitle,
                style: AppFonts.getTextStyle(fontSize: CategoryCardTheme.categoryTitleStyle.fontSize,
                  fontWeight: CategoryCardTheme.categoryTitleStyle.fontWeight,
                  color: CategoryCardTheme.categoryTitleStyle.color,
                ),
              ),
              subtitle: widget.children.isNotEmpty
                  ? Text(
                      '${widget.children.length} ${AppLocalizations.of(context)!.subcategories}',
                      style: AppFonts.getTextStyle(fontSize: CategoryCardTheme.subcategoryCountStyle.fontSize,
                        fontWeight: CategoryCardTheme.subcategoryCountStyle.fontWeight,
                        color: CategoryCardTheme.subcategoryCountStyle.color,
                      ),
                    )
                  : null,
              trailing: widget.children.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoading)
                          SizedBox(
                            width: CategoryCardTheme.loadingSize,
                            height: CategoryCardTheme.loadingSize,
                            child: CircularProgressIndicator(
                              strokeWidth: CategoryCardTheme.loadingStrokeWidth,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                CategoryCardTheme.loadingColor,
                              ),
                            ),
                          )
                        else
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: CategoryCardTheme.expandArrowColor,
                            size: CategoryCardTheme.expandArrowSize,
                          ),
                        SizedBox(width: ResponsiveConstants.smSpacing),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: CategoryCardTheme.arrowSize,
                          color: CategoryCardTheme.arrowColor,
                        ),
                      ],
                    )
                  : Icon(
                      Icons.arrow_forward_ios,
                      size: CategoryCardTheme.arrowSize,
                      color: CategoryCardTheme.arrowColor,
                    ),
              onTap: () async {
          await HapticService.buttonClick();
          if (widget.children.isNotEmpty) {
                  if (widget.level < 2) {
                    // For levels 0-1, expand inline
                    _toggleExpansion();
        } else {
                    // For deeper levels, navigate to dedicated page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<SearchBloc>(),
                          child: NestedSubcategoryPage(
                            subcategoryId: widget.subcategoryId,
                            subcategoryTitle: widget.subcategoryTitle,
                            parentCategoryTitle: widget.parentCategoryTitle,
                            breadcrumbItems: [
                              widget.parentCategoryTitle,
                              widget.subcategoryTitle,
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                } else {
                  // Navigate to catalog if no children
                  Navigator.pushNamed(
                    context,
                    '/catalog',
                    arguments: CatalogArgs(
                      title: widget.subcategoryTitle,
                      category: widget.parentCategoryTitle,
                      categoryId: widget.subcategoryId,
                      query: widget.subcategoryTitle,
                    ),
                  );
                }
              },
            ),

            // Nested children (if expanded)
            if (_isExpanded && widget.children.isNotEmpty)
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoaded) {
                    final nestedSubcategories = state.subcategories[widget.subcategoryId] ?? [];
                    
                    if (nestedSubcategories.isEmpty && !_isLoading) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveConstants.lgPadding,
                          vertical: ResponsiveConstants.mdPadding,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.noSubcategoriesAvailable,
                          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Column(
                      children: nestedSubcategories.map((subcategory) {
                        return NestedSubcategoryWidget(
                          key: ValueKey(subcategory.id),
                          subcategoryId: subcategory.id,
                          subcategoryTitle: subcategory.title,
                          parentCategoryTitle: widget.subcategoryTitle,
                          children: subcategory.children,
                          level: widget.level + 1,
                        );
                      }).toList(),
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(int level) {
    return CategoryCardTheme.getLevelColor(level);
  }

  IconData _getCategoryIcon(int level) {
    return CategoryCardTheme.getLevelIcon(level);
  }
}
