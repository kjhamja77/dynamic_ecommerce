import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../domain/entities/search_subcategory.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/models/catalog_args.dart';

class SubcategoryDetailsPage extends StatefulWidget {
  final String subcategoryId;
  final String title;

  const SubcategoryDetailsPage({
    super.key,
    required this.subcategoryId,
    required this.title,
  });

  @override
  State<SubcategoryDetailsPage> createState() => _SubcategoryDetailsPageState();
}

class _SubcategoryDetailsPageState extends State<SubcategoryDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Load initial data and nested subcategories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = context.read<SearchBloc>().state;
      if (currentState is! SearchLoaded) {
        // Load initial search data first
        context.read<SearchBloc>().add(const LoadSearchData());
      }
      
      // Load nested subcategories
      context.read<SearchBloc>().add(LoadNestedSubcategories(widget.subcategoryId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial || state is SearchLoading) {
            return const Center(
              child: AppLoadingWidget.defaultLoading(
                message: 'Loading category details...',
                showMessage: true,
              ),
            );
          }

          if (state is SearchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: ResponsiveConstants.xlIconSize,
                    color: Colors.red.shade400,
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  Text(
                    'Error: ${state.message}',
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                      color: Colors.red.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveConstants.lgSpacing),
                  ElevatedButton(
                    onPressed: () async {
          await HapticService.buttonClick();
          context.read<SearchBloc>().add(LoadNestedSubcategories(widget.subcategoryId));
        },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SearchLoaded) {
            final isLoading = state.loadingSubcategories.contains(widget.subcategoryId);
            final subcategories = state.subcategories[widget.subcategoryId];
            
            if (isLoading) {
              return const Center(
                child: AppLoadingWidget.defaultLoading(
                  message: 'Loading subcategories...',
                  showMessage: true,
                ),
              );
            }
            
            if (subcategories == null || subcategories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: ResponsiveConstants.xlIconSize,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: ResponsiveConstants.mdSpacing),
                    Text(
                      'No subcategories found',
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xlFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveConstants.smSpacing),
                    Text(
                      'This category doesn\'t have any subcategories.',
                      textAlign: TextAlign.center,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return _buildSubcategoryContent(subcategories);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.black,
          size: ResponsiveConstants.mdIconSize,
        ),
        onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        widget.title,
        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.black,
            size: ResponsiveConstants.mdIconSize,
          ),
          onPressed: () async {
          await HapticService.buttonClick();
          // TODO: Implement search functionality
        },
        ),
      ],
    );
  }

  Widget _buildSubcategoryContent(List<SearchSubcategory> subcategories) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Convert SearchSubcategory to SubcategoryItem for display
          ...subcategories.map((subcategory) => _buildSubcategoryItem(subcategory)),
        ],
      ),
    );
  }

  Widget _buildSubcategoryItem(SearchSubcategory subcategory) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      child: InkWell(
        onTap: () async {
          await HapticService.buttonClick();
          _onSubcategoryTap(subcategory);
        },
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
                  Icons.category_outlined,
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
                      subcategory.title,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    if (subcategory.hasChildren) ...[
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Text(
                        '${subcategory.children.length} subcategories available',
                        style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ] else if (subcategory.productCount > 0) ...[
                      SizedBox(height: ResponsiveConstants.xsSpacing),
                      Text(
                        '${subcategory.productCount} products available',
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

  void _onSubcategoryTap(SearchSubcategory subcategory) {
    if (subcategory.hasChildren) {
      // For subcategories with children, show a choice dialog
      _showSubcategoryOptionsDialog(subcategory);
    } else {
      // Navigate to products page for leaf categories
      Navigator.pushNamed(
        context,
        '/catalog',
        arguments: CatalogArgs(
          title: subcategory.title,
          category: widget.title,
          categoryId: subcategory.id,
          query: subcategory.title,
        ),
      );
    }
  }

  void _showSubcategoryOptionsDialog(SearchSubcategory subcategory) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            subcategory.title,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.lgFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This subcategory contains more subcategories. What would you like to do?',
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: ResponsiveConstants.lgSpacing),
              // Expand inline option
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(ResponsiveConstants.smPadding),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.expand_more,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Expand Here',
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Show subcategories in this page',
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.smFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
                onTap: () => Navigator.of(context).pop('expand'),
              ),
              SizedBox(height: ResponsiveConstants.smSpacing),
              // Navigate to new page option
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(ResponsiveConstants.smPadding),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.open_in_new,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ),
                title: Text(
                  'New Page',
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Navigate to dedicated page',
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.smFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
                onTap: () => Navigator.of(context).pop('navigate'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: AppFonts.getTextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Handle the user's choice
    if (result == 'expand') {
      // TODO: Implement inline expansion functionality
      // For now, show a message that this feature is coming soon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inline expansion coming soon! For now, using new page.'),
          duration: const Duration(seconds: 2),
        ),
      );
      // Fallback to navigation for now
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SubcategoryDetailsPage(
            subcategoryId: subcategory.id,
            title: subcategory.title,
          ),
        ),
      );
    } else if (result == 'navigate') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SubcategoryDetailsPage(
            subcategoryId: subcategory.id,
            title: subcategory.title,
          ),
        ),
      );
    }
  }
}
